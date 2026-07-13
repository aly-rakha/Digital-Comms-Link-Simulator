%% a08 - 16-QAM over AWGN: BER vs Eb/N0 Curve
% This script simulates 16-QAM over an AWGN channel
% for multiple Eb/N0 values and compares the simulated BER
% with the theoretical approximate BER curve.
%
% 16-QAM uses 4 bits per symbol.

clear; close all; clc;

%% 1. Simulation settings

N = 100000;                  % Number of bits per Eb/N0 value
EbN0_dB_range = 0:2:18;      % Eb/N0 values in dB

% 16-QAM uses 4 bits per symbol, so N must be divisible by 4
if mod(N, 4) ~= 0
    error("N must be divisible by 4 for 16-QAM.");
end

BER_sim = zeros(size(EbN0_dB_range));  % Store simulated BER values

%% 2. Loop over different Eb/N0 values

for i = 1:length(EbN0_dB_range)

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

    % Create normalized complex 16-QAM symbols
    % Average symbol energy becomes 1 after dividing by sqrt(10)
    symbols = (I + 1j*Q) / sqrt(10);

    %% AWGN noise channel

    EbN0_dB = EbN0_dB_range(i);
    EbN0 = 10^(EbN0_dB/10);

    k = 4;   % 16-QAM carries 4 bits per symbol

    % Complex AWGN noise for 16-QAM
    noiseSigma = sqrt(1/(2*k*EbN0));

    noise = noiseSigma * ...
        (randn(size(symbols)) + 1j*randn(size(symbols)));

    receivedSymbols = symbols + noise;

    %% 16-QAM demodulation

    % Undo normalization for easier decision making
    received_I = real(receivedSymbols) * sqrt(10);
    received_Q = imag(receivedSymbols) * sqrt(10);

    receivedBitGroups = zeros(numSymbols, 4);

    % Decision boundaries for levels -3, -1, +1, +3:
    % boundaries are -2, 0, +2

    % Demodulate I axis
    idx = received_I < -2;
    receivedBitGroups(idx, 1:2) = repmat([0 0], sum(idx), 1);

    idx = received_I >= -2 & received_I < 0;
    receivedBitGroups(idx, 1:2) = repmat([0 1], sum(idx), 1);

    idx = received_I >= 0 & received_I < 2;
    receivedBitGroups(idx, 1:2) = repmat([1 1], sum(idx), 1);

    idx = received_I >= 2;
    receivedBitGroups(idx, 1:2) = repmat([1 0], sum(idx), 1);

    % Demodulate Q axis
    idx = received_Q < -2;
    receivedBitGroups(idx, 3:4) = repmat([0 0], sum(idx), 1);

    idx = received_Q >= -2 & received_Q < 0;
    receivedBitGroups(idx, 3:4) = repmat([0 1], sum(idx), 1);

    idx = received_Q >= 0 & received_Q < 2;
    receivedBitGroups(idx, 3:4) = repmat([1 1], sum(idx), 1);

    idx = received_Q >= 2;
    receivedBitGroups(idx, 3:4) = repmat([1 0], sum(idx), 1);

    % Convert received bit groups back into one column vector
    receivedBits = reshape(receivedBitGroups.', N, 1);

    %% Calculate BER

    numErrors = sum(bits ~= receivedBits);
    BER_sim(i) = numErrors / N;

    fprintf("Eb/N0 = %2d dB | Errors = %5d | 16-QAM BER = %.6f\n", ...
            EbN0_dB, numErrors, BER_sim(i));

end

%% 3. Theoretical approximate BER for 16-QAM over AWGN

M = 16;
k = log2(M);

EbN0_linear = 10.^(EbN0_dB_range/10);

% Approximate theoretical BER for Gray-coded square M-QAM
BER_theory = (4/k) * (1 - 1/sqrt(M)) * ...
             0.5 * erfc(sqrt((3*k ./ (2*(M-1))) .* EbN0_linear));

%% 4. Plot simulated and theoretical BER

figure;

semilogy(EbN0_dB_range, BER_sim, 'o-', 'LineWidth', 1.5);
hold on;

semilogy(EbN0_dB_range, BER_theory, '--', 'LineWidth', 1.5);

xlabel("Eb/N0 (dB)");
ylabel("Bit Error Rate (BER)");
title("16-QAM over AWGN: Simulated vs Theoretical BER");
legend("Simulated 16-QAM BER", "Theoretical 16-QAM BER");
grid on;

%% 5. Save figure

if ~exist("figures", "dir")
    mkdir("figures");
end

ax = gca;
ax.Toolbar.Visible = 'off';

saveas(gcf, "figures/16qam_awgn_ber_curve.png");