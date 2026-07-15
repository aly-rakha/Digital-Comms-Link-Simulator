%% a13 - AWGN vs Rayleigh: All Modulations BER Comparison
% This script compares BPSK, QPSK, and 16-QAM over:
%
% 1. AWGN channel
% 2. Rayleigh fading channel
%
% The goal is to show two important tradeoffs:
%
% 1. Rayleigh fading performs worse than AWGN.
% 2. 16-QAM carries more bits per symbol, but is less robust than BPSK/QPSK.

clear; close all; clc;

%% 1. Simulation settings

N = 100000;                 % Number of bits per Eb/N0 value
EbN0_dB_range = 0:2:30;     % Eb/N0 values in dB

% N must be divisible by 4 so it works for BPSK, QPSK, and 16-QAM
if mod(N, 4) ~= 0
    error("N must be divisible by 4.");
end

BER_BPSK_AWGN = zeros(size(EbN0_dB_range));
BER_QPSK_AWGN = zeros(size(EbN0_dB_range));
BER_16QAM_AWGN = zeros(size(EbN0_dB_range));

BER_BPSK_Rayleigh = zeros(size(EbN0_dB_range));
BER_QPSK_Rayleigh = zeros(size(EbN0_dB_range));
BER_16QAM_Rayleigh = zeros(size(EbN0_dB_range));

%% 2. Loop over Eb/N0 values

for i = 1:length(EbN0_dB_range)

    EbN0_dB = EbN0_dB_range(i);
    EbN0 = 10^(EbN0_dB/10);

    %% Generate bits for each modulation

    bits_bpsk = randi([0 1], N, 1);
    bits_qpsk = randi([0 1], N, 1);
    bits_16qam = randi([0 1], N, 1);

    %% AWGN simulations

    BER_BPSK_AWGN(i) = simulateBPSK(bits_bpsk, EbN0, "AWGN");
    BER_QPSK_AWGN(i) = simulateQPSK(bits_qpsk, EbN0, "AWGN");
    BER_16QAM_AWGN(i) = simulate16QAM(bits_16qam, EbN0, "AWGN");

    %% Rayleigh fading simulations

    BER_BPSK_Rayleigh(i) = simulateBPSK(bits_bpsk, EbN0, "Rayleigh");
    BER_QPSK_Rayleigh(i) = simulateQPSK(bits_qpsk, EbN0, "Rayleigh");
    BER_16QAM_Rayleigh(i) = simulate16QAM(bits_16qam, EbN0, "Rayleigh");

    %% Print results

    fprintf("Eb/N0 = %2d dB | AWGN: BPSK %.6f, QPSK %.6f, 16-QAM %.6f | Rayleigh: BPSK %.6f, QPSK %.6f, 16-QAM %.6f\n", ...
            EbN0_dB, ...
            BER_BPSK_AWGN(i), BER_QPSK_AWGN(i), BER_16QAM_AWGN(i), ...
            BER_BPSK_Rayleigh(i), BER_QPSK_Rayleigh(i), BER_16QAM_Rayleigh(i));

end

%% 3. Prepare BER values for plotting

% semilogy cannot plot zero values.
% Replace zeros with NaN so MATLAB skips them.

BER_BPSK_AWGN_plot = replaceZerosWithNaN(BER_BPSK_AWGN);
BER_QPSK_AWGN_plot = replaceZerosWithNaN(BER_QPSK_AWGN);
BER_16QAM_AWGN_plot = replaceZerosWithNaN(BER_16QAM_AWGN);

BER_BPSK_Rayleigh_plot = replaceZerosWithNaN(BER_BPSK_Rayleigh);
BER_QPSK_Rayleigh_plot = replaceZerosWithNaN(BER_QPSK_Rayleigh);
BER_16QAM_Rayleigh_plot = replaceZerosWithNaN(BER_16QAM_Rayleigh);

%% 4. Plot comparison

figure;

%% AWGN subplot

subplot(1,2,1);

semilogy(EbN0_dB_range, BER_BPSK_AWGN_plot, 'o-', 'LineWidth', 1.5);
hold on;

semilogy(EbN0_dB_range, BER_QPSK_AWGN_plot, 's-', 'LineWidth', 1.5);

semilogy(EbN0_dB_range, BER_16QAM_AWGN_plot, 'd-', 'LineWidth', 1.5);

xlabel("Eb/N0 (dB)");
ylabel("Bit Error Rate (BER)");
title("AWGN Channel");
legend("BPSK", "QPSK", "16-QAM", "Location", "southwest");
grid on;
ylim([1e-5 1]);
xlim([0 30]);

%% Rayleigh subplot

subplot(1,2,2);

semilogy(EbN0_dB_range, BER_BPSK_Rayleigh_plot, 'o-', 'LineWidth', 1.5);
hold on;

semilogy(EbN0_dB_range, BER_QPSK_Rayleigh_plot, 's-', 'LineWidth', 1.5);

semilogy(EbN0_dB_range, BER_16QAM_Rayleigh_plot, 'd-', 'LineWidth', 1.5);

xlabel("Eb/N0 (dB)");
ylabel("Bit Error Rate (BER)");
title("Rayleigh Fading Channel");
legend("BPSK", "QPSK", "16-QAM", "Location", "southwest");
grid on;
ylim([1e-5 1]);
xlim([0 30]);

sgtitle("BER Comparison: AWGN vs Rayleigh Fading");

%% 5. Save figure

if ~exist("figures", "dir")
    mkdir("figures");
end

axList = findall(gcf, 'Type', 'axes');
for k = 1:length(axList)
    axList(k).Toolbar.Visible = 'off';
end

saveas(gcf, "figures/awgn_vs_rayleigh_all_modulations.png");

%% Local functions

function BER = simulateBPSK(bits, EbN0, channelType)

    N = length(bits);
    k = 1;

    % BPSK modulation:
    % bit 0 -> -1
    % bit 1 -> +1
    symbols = 2*bits - 1;

    noiseSigma = sqrt(1/(2*k*EbN0));

    if channelType == "AWGN"

        noise = noiseSigma * randn(size(symbols));
        received = symbols + noise;

    elseif channelType == "Rayleigh"

        h = (randn(size(symbols)) + 1j*randn(size(symbols))) / sqrt(2);

        noise = noiseSigma * ...
            (randn(size(symbols)) + 1j*randn(size(symbols)));

        received = h .* symbols + noise;

        % Equalization
        received = received ./ h;

    else
        error("Unknown channel type.");
    end

    % BPSK demodulation
    receivedBits = double(real(received) > 0);

    % BER calculation
    numErrors = sum(bits ~= receivedBits);
    BER = numErrors / N;

end

function BER = simulateQPSK(bits, EbN0, channelType)

    N = length(bits);
    k = 2;

    if mod(N, 2) ~= 0
        error("N must be even for QPSK.");
    end

    % Group bits into I and Q
    bits_I = bits(1:2:end);
    bits_Q = bits(2:2:end);

    % bit 0 -> -1
    % bit 1 -> +1
    I = 2*bits_I - 1;
    Q = 2*bits_Q - 1;

    % Normalized QPSK symbols
    symbols = (I + 1j*Q) / sqrt(2);

    noiseSigma = sqrt(1/(2*k*EbN0));

    if channelType == "AWGN"

        noise = noiseSigma * ...
            (randn(size(symbols)) + 1j*randn(size(symbols)));

        received = symbols + noise;

    elseif channelType == "Rayleigh"

        h = (randn(size(symbols)) + 1j*randn(size(symbols))) / sqrt(2);

        noise = noiseSigma * ...
            (randn(size(symbols)) + 1j*randn(size(symbols)));

        received = h .* symbols + noise;

        % Equalization
        received = received ./ h;

    else
        error("Unknown channel type.");
    end

    % QPSK demodulation
    receivedBits_I = double(real(received) > 0);
    receivedBits_Q = double(imag(received) > 0);

    receivedBits = zeros(N, 1);
    receivedBits(1:2:end) = receivedBits_I;
    receivedBits(2:2:end) = receivedBits_Q;

    % BER calculation
    numErrors = sum(bits ~= receivedBits);
    BER = numErrors / N;

end

function BER = simulate16QAM(bits, EbN0, channelType)

    N = length(bits);
    k = 4;

    if mod(N, 4) ~= 0
        error("N must be divisible by 4 for 16-QAM.");
    end

    symbols = modulate16QAM(bits);

    noiseSigma = sqrt(1/(2*k*EbN0));

    if channelType == "AWGN"

        noise = noiseSigma * ...
            (randn(size(symbols)) + 1j*randn(size(symbols)));

        received = symbols + noise;

    elseif channelType == "Rayleigh"

        h = (randn(size(symbols)) + 1j*randn(size(symbols))) / sqrt(2);

        noise = noiseSigma * ...
            (randn(size(symbols)) + 1j*randn(size(symbols)));

        received = h .* symbols + noise;

        % Equalization
        received = received ./ h;

    else
        error("Unknown channel type.");
    end

    receivedBits = demodulate16QAM(received, N);

    numErrors = sum(bits ~= receivedBits);
    BER = numErrors / N;

end

function symbols = modulate16QAM(bits)

    bitGroups = reshape(bits, 4, []).';

    bits_I = bitGroups(:, 1:2);
    bits_Q = bitGroups(:, 3:4);

    numSymbols = size(bitGroups, 1);

    I = zeros(numSymbols, 1);
    Q = zeros(numSymbols, 1);

    % Gray-coded 4-PAM mapping:
    % 00 -> -3
    % 01 -> -1
    % 11 -> +1
    % 10 -> +3

    % I-axis mapping
    idx = bits_I(:,1) == 0 & bits_I(:,2) == 0;
    I(idx) = -3;

    idx = bits_I(:,1) == 0 & bits_I(:,2) == 1;
    I(idx) = -1;

    idx = bits_I(:,1) == 1 & bits_I(:,2) == 1;
    I(idx) = 1;

    idx = bits_I(:,1) == 1 & bits_I(:,2) == 0;
    I(idx) = 3;

    % Q-axis mapping
    idx = bits_Q(:,1) == 0 & bits_Q(:,2) == 0;
    Q(idx) = -3;

    idx = bits_Q(:,1) == 0 & bits_Q(:,2) == 1;
    Q(idx) = -1;

    idx = bits_Q(:,1) == 1 & bits_Q(:,2) == 1;
    Q(idx) = 1;

    idx = bits_Q(:,1) == 1 & bits_Q(:,2) == 0;
    Q(idx) = 3;

    % Normalize average symbol energy to 1
    symbols = (I + 1j*Q) / sqrt(10);

end

function receivedBits = demodulate16QAM(receivedSymbols, N)

    numSymbols = length(receivedSymbols);

    % Undo normalization for decision making
    received_I = real(receivedSymbols) * sqrt(10);
    received_Q = imag(receivedSymbols) * sqrt(10);

    receivedBitGroups = zeros(numSymbols, 4);

    % Decision boundaries for -3, -1, +1, +3:
    % -2, 0, +2

    % I-axis decisions
    idx = received_I < -2;
    receivedBitGroups(idx, 1:2) = repmat([0 0], sum(idx), 1);

    idx = received_I >= -2 & received_I < 0;
    receivedBitGroups(idx, 1:2) = repmat([0 1], sum(idx), 1);

    idx = received_I >= 0 & received_I < 2;
    receivedBitGroups(idx, 1:2) = repmat([1 1], sum(idx), 1);

    idx = received_I >= 2;
    receivedBitGroups(idx, 1:2) = repmat([1 0], sum(idx), 1);

    % Q-axis decisions
    idx = received_Q < -2;
    receivedBitGroups(idx, 3:4) = repmat([0 0], sum(idx), 1);

    idx = received_Q >= -2 & received_Q < 0;
    receivedBitGroups(idx, 3:4) = repmat([0 1], sum(idx), 1);

    idx = received_Q >= 0 & received_Q < 2;
    receivedBitGroups(idx, 3:4) = repmat([1 1], sum(idx), 1);

    idx = received_Q >= 2;
    receivedBitGroups(idx, 3:4) = repmat([1 0], sum(idx), 1);

    % Convert groups back into one column vector
    receivedBits = reshape(receivedBitGroups.', N, 1);

end

function output = replaceZerosWithNaN(input)

    output = input;
    output(output == 0) = NaN;

end