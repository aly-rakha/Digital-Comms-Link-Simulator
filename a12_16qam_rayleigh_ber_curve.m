%% a12 - 16-QAM over Rayleigh Fading: BER vs Eb/N0
% This script compares 16-QAM performance over:
%
% 1. AWGN channel
% 2. Rayleigh fading channel
%
% 16-QAM uses 4 bits per symbol.
%
% AWGN only adds noise.
% Rayleigh fading randomly changes signal amplitude and phase,
% which models multipath propagation in wireless communication.

clear; close all; clc;

%% 1. Simulation settings

N = 100000;                 % Number of bits per Eb/N0 value
EbN0_dB_range = 0:2:30;     % Eb/N0 values in dB

% 16-QAM uses 4 bits per symbol, so N must be divisible by 4
if mod(N, 4) ~= 0
    error("N must be divisible by 4 for 16-QAM.");
end

BER_AWGN = zeros(size(EbN0_dB_range));
BER_Rayleigh = zeros(size(EbN0_dB_range));

%% 2. Loop over Eb/N0 values

for i = 1:length(EbN0_dB_range)

    EbN0_dB = EbN0_dB_range(i);
    EbN0 = 10^(EbN0_dB/10);

    %% Generate random bits

    bits = randi([0 1], N, 1);

    %% Group bits into 4-bit symbols

    bitGroups = reshape(bits, 4, []).';

    bits_I = bitGroups(:, 1:2);   % First two bits control I axis
    bits_Q = bitGroups(:, 3:4);   % Last two bits control Q axis

    numSymbols = size(bitGroups, 1);

    %% 16-QAM modulation

    % Gray-coded 4-PAM mapping on each axis:
    %
    % 00 -> -3
    % 01 -> -1
    % 11 -> +1
    % 10 -> +3

    I = zeros(numSymbols, 1);
    Q = zeros(numSymbols, 1);

    % In-phase mapping
    idx = bits_I(:,1) == 0 & bits_I(:,2) == 0;
    I(idx) = -3;

    idx = bits_I(:,1) == 0 & bits_I(:,2) == 1;
    I(idx) = -1;

    idx = bits_I(:,1) == 1 & bits_I(:,2) == 1;
    I(idx) = 1;

    idx = bits_I(:,1) == 1 & bits_I(:,2) == 0;
    I(idx) = 3;

    % Quadrature mapping
    idx = bits_Q(:,1) == 0 & bits_Q(:,2) == 0;
    Q(idx) = -3;

    idx = bits_Q(:,1) == 0 & bits_Q(:,2) == 1;
    Q(idx) = -1;

    idx = bits_Q(:,1) == 1 & bits_Q(:,2) == 1;
    Q(idx) = 1;

    idx = bits_Q(:,1) == 1 & bits_Q(:,2) == 0;
    Q(idx) = 3;

    % Create normalized 16-QAM symbols.
    % Dividing by sqrt(10) normalizes the average symbol energy to 1.
    symbols = (I + 1j*Q) / sqrt(10);

    %% AWGN channel

    k = 4;   % 16-QAM carries 4 bits per symbol

    % Complex AWGN noise
    noiseSigma = sqrt(1/(2*k*EbN0));

    noise_awgn = noiseSigma * ...
        (randn(size(symbols)) + 1j*randn(size(symbols)));

    received_awgn = symbols + noise_awgn;

    %% 16-QAM demodulation for AWGN

    % Undo normalization for decision making
    received_I_awgn = real(received_awgn) * sqrt(10);
    received_Q_awgn = imag(received_awgn) * sqrt(10);

    receivedBitGroups_awgn = zeros(numSymbols, 4);

    % Decision boundaries for -3, -1, +1, +3 are:
    % -2, 0, +2

    % Demodulate I axis
    idx = received_I_awgn < -2;
    receivedBitGroups_awgn(idx, 1:2) = repmat([0 0], sum(idx), 1);

    idx = received_I_awgn >= -2 & received_I_awgn < 0;
    receivedBitGroups_awgn(idx, 1:2) = repmat([0 1], sum(idx), 1);

    idx = received_I_awgn >= 0 & received_I_awgn < 2;
    receivedBitGroups_awgn(idx, 1:2) = repmat([1 1], sum(idx), 1);

    idx = received_I_awgn >= 2;
    receivedBitGroups_awgn(idx, 1:2) = repmat([1 0], sum(idx), 1);

    % Demodulate Q axis
    idx = received_Q_awgn < -2;
    receivedBitGroups_awgn(idx, 3:4) = repmat([0 0], sum(idx), 1);

    idx = received_Q_awgn >= -2 & received_Q_awgn < 0;
    receivedBitGroups_awgn(idx, 3:4) = repmat([0 1], sum(idx), 1);

    idx = received_Q_awgn >= 0 & received_Q_awgn < 2;
    receivedBitGroups_awgn(idx, 3:4) = repmat([1 1], sum(idx), 1);

    idx = received_Q_awgn >= 2;
    receivedBitGroups_awgn(idx, 3:4) = repmat([1 0], sum(idx), 1);

    % Convert bit groups back to one column vector
    receivedBits_awgn = reshape(receivedBitGroups_awgn.', N, 1);

    % BER calculation
    errors_awgn = sum(bits ~= receivedBits_awgn);
    BER_AWGN(i) = errors_awgn / N;

    %% Rayleigh fading channel

    % Rayleigh fading coefficient:
    % h is complex because the channel changes both amplitude and phase.

    h = (randn(size(symbols)) + 1j*randn(size(symbols))) / sqrt(2);

    % Complex noise for Rayleigh fading channel
    noise_rayleigh = noiseSigma * ...
        (randn(size(symbols)) + 1j*randn(size(symbols)));

    % Received signal through Rayleigh fading:
    % received = h * transmitted symbol + noise

    received_rayleigh = h .* symbols + noise_rayleigh;

    % Equalization:
    % Assume the receiver knows h and divides by h to undo the channel.

    equalized_rayleigh = received_rayleigh ./ h;

    %% 16-QAM demodulation after Rayleigh equalization

    % Undo normalization for decision making
    received_I_rayleigh = real(equalized_rayleigh) * sqrt(10);
    received_Q_rayleigh = imag(equalized_rayleigh) * sqrt(10);

    receivedBitGroups_rayleigh = zeros(numSymbols, 4);

    % Demodulate I axis
    idx = received_I_rayleigh < -2;
    receivedBitGroups_rayleigh(idx, 1:2) = repmat([0 0], sum(idx), 1);

    idx = received_I_rayleigh >= -2 & received_I_rayleigh < 0;
    receivedBitGroups_rayleigh(idx, 1:2) = repmat([0 1], sum(idx), 1);

    idx = received_I_rayleigh >= 0 & received_I_rayleigh < 2;
    receivedBitGroups_rayleigh(idx, 1:2) = repmat([1 1], sum(idx), 1);

    idx = received_I_rayleigh >= 2;
    receivedBitGroups_rayleigh(idx, 1:2) = repmat([1 0], sum(idx), 1);

    % Demodulate Q axis
    idx = received_Q_rayleigh < -2;
    receivedBitGroups_rayleigh(idx, 3:4) = repmat([0 0], sum(idx), 1);

    idx = received_Q_rayleigh >= -2 & received_Q_rayleigh < 0;
    receivedBitGroups_rayleigh(idx, 3:4) = repmat([0 1], sum(idx), 1);

    idx = received_Q_rayleigh >= 0 & received_Q_rayleigh < 2;
    receivedBitGroups_rayleigh(idx, 3:4) = repmat([1 1], sum(idx), 1);

    idx = received_Q_rayleigh >= 2;
    receivedBitGroups_rayleigh(idx, 3:4) = repmat([1 0], sum(idx), 1);

    % Convert bit groups back to one column vector
    receivedBits_rayleigh = reshape(receivedBitGroups_rayleigh.', N, 1);

    % BER calculation
    errors_rayleigh = sum(bits ~= receivedBits_rayleigh);
    BER_Rayleigh(i) = errors_rayleigh / N;

    %% Print results

    fprintf("Eb/N0 = %2d dB | AWGN BER = %.6f | Rayleigh BER = %.6f\n", ...
            EbN0_dB, BER_AWGN(i), BER_Rayleigh(i));

end

%% 3. Theoretical BER curves

M = 16;
k = log2(M);

EbN0_linear = 10.^(EbN0_dB_range/10);

% Approximate theoretical BER for Gray-coded square 16-QAM over AWGN
BER_theory_AWGN = (4/k) * (1 - 1/sqrt(M)) * ...
                  0.5 * erfc(sqrt((3*k ./ (2*(M-1))) .* EbN0_linear));

% Approximate theoretical BER for Gray-coded square 16-QAM over Rayleigh fading
a = (3*k) / (M - 1);

BER_theory_Rayleigh = (4/k) * (1 - 1/sqrt(M)) * ...
                      0.5 * (1 - sqrt((a .* EbN0_linear) ./ ...
                      (2 + a .* EbN0_linear)));

%% 4. Prepare BER values for plotting

% semilogy cannot plot zero values.
% Replace zeros with NaN so MATLAB skips them.

BER_AWGN_plot = BER_AWGN;
BER_Rayleigh_plot = BER_Rayleigh;

BER_AWGN_plot(BER_AWGN_plot == 0) = NaN;
BER_Rayleigh_plot(BER_Rayleigh_plot == 0) = NaN;

%% 5. Plot BER comparison

figure;

semilogy(EbN0_dB_range, BER_AWGN_plot, 'o-', 'LineWidth', 1.5);
hold on;

semilogy(EbN0_dB_range, BER_Rayleigh_plot, 's-', 'LineWidth', 1.5);

semilogy(EbN0_dB_range, BER_theory_AWGN, '--', 'LineWidth', 1.5);

semilogy(EbN0_dB_range, BER_theory_Rayleigh, '--', 'LineWidth', 1.5);

xlabel("Eb/N0 (dB)");
ylabel("Bit Error Rate (BER)");
title("16-QAM over AWGN vs Rayleigh Fading");

legend("Simulated AWGN", ...
       "Simulated Rayleigh", ...
       "Theoretical AWGN", ...
       "Theoretical Rayleigh", ...
       "Location", "southwest");

grid on;
ylim([1e-5 1]);
xlim([0 30]);

%% 6. Save figure

if ~exist("figures", "dir")
    mkdir("figures");
end

ax = gca;
ax.Toolbar.Visible = 'off';

saveas(gcf, "figures/16qam_awgn_vs_rayleigh.png");