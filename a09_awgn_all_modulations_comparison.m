%% a09 - AWGN BER Comparison: BPSK vs QPSK vs 16-QAM
% This script compares BPSK, QPSK, and 16-QAM over an AWGN channel.
%
% It plots BER vs Eb/N0 for all three modulation schemes.
%
% Main idea:
% BPSK  -> 1 bit per symbol, very robust
% QPSK  -> 2 bits per symbol, similar BER to BPSK in AWGN
% 16-QAM -> 4 bits per symbol, higher data rate but more noise-sensitive

clear; close all; clc;

%% 1. Simulation settings

N = 100000;                 % Number of bits per Eb/N0 value
EbN0_dB_range = 0:2:18;     % Eb/N0 values in dB

% N must work for all modulations.
% BPSK needs any N.
% QPSK needs N divisible by 2.
% 16-QAM needs N divisible by 4.
if mod(N, 4) ~= 0
    error("N must be divisible by 4.");
end

BER_BPSK = zeros(size(EbN0_dB_range));
BER_QPSK = zeros(size(EbN0_dB_range));
BER_16QAM = zeros(size(EbN0_dB_range));

%% 2. Loop over Eb/N0 values

for i = 1:length(EbN0_dB_range)

    EbN0_dB = EbN0_dB_range(i);
    EbN0 = 10^(EbN0_dB/10);

    %% =========================
    %  BPSK simulation
    %  =========================

    bits_bpsk = randi([0 1], N, 1);

    % BPSK mapping:
    % 0 -> -1
    % 1 -> +1
    symbols_bpsk = 2*bits_bpsk - 1;

    % AWGN noise for BPSK
    k_bpsk = 1;
    noiseSigma_bpsk = sqrt(1/(2*k_bpsk*EbN0));
    noise_bpsk = noiseSigma_bpsk * randn(size(symbols_bpsk));

    received_bpsk = symbols_bpsk + noise_bpsk;

    % BPSK demodulation
    receivedBits_bpsk = double(received_bpsk > 0);

    % BPSK BER
    errors_bpsk = sum(bits_bpsk ~= receivedBits_bpsk);
    BER_BPSK(i) = errors_bpsk / N;

    %% =========================
    %  QPSK simulation
    %  =========================

    bits_qpsk = randi([0 1], N, 1);

    % QPSK uses 2 bits per symbol
    bits_I = bits_qpsk(1:2:end);
    bits_Q = bits_qpsk(2:2:end);

    % Convert bits to +1 or -1
    I = 2*bits_I - 1;
    Q = 2*bits_Q - 1;

    % Normalized QPSK symbols
    symbols_qpsk = (I + 1j*Q) / sqrt(2);

    % AWGN noise for QPSK
    k_qpsk = 2;
    noiseSigma_qpsk = sqrt(1/(2*k_qpsk*EbN0));

    noise_qpsk = noiseSigma_qpsk * ...
        (randn(size(symbols_qpsk)) + 1j*randn(size(symbols_qpsk)));

    received_qpsk = symbols_qpsk + noise_qpsk;

    % QPSK demodulation
    receivedBits_I = double(real(received_qpsk) > 0);
    receivedBits_Q = double(imag(received_qpsk) > 0);

    receivedBits_qpsk = zeros(N, 1);
    receivedBits_qpsk(1:2:end) = receivedBits_I;
    receivedBits_qpsk(2:2:end) = receivedBits_Q;

    % QPSK BER
    errors_qpsk = sum(bits_qpsk ~= receivedBits_qpsk);
    BER_QPSK(i) = errors_qpsk / N;

    %% =========================
    %  16-QAM simulation
    %  =========================

    bits_16qam = randi([0 1], N, 1);

    % Group bits into groups of 4
    bitGroups = reshape(bits_16qam, 4, []).';

    bits_I_16qam = bitGroups(:, 1:2);
    bits_Q_16qam = bitGroups(:, 3:4);

    numSymbols_16qam = size(bitGroups, 1);

    % Gray-coded 4-PAM mapping:
    % 00 -> -3
    % 01 -> -1
    % 11 -> +1
    % 10 -> +3

    I_16qam = zeros(numSymbols_16qam, 1);
    Q_16qam = zeros(numSymbols_16qam, 1);

    % In-phase mapping
    idx = bits_I_16qam(:,1) == 0 & bits_I_16qam(:,2) == 0;
    I_16qam(idx) = -3;

    idx = bits_I_16qam(:,1) == 0 & bits_I_16qam(:,2) == 1;
    I_16qam(idx) = -1;

    idx = bits_I_16qam(:,1) == 1 & bits_I_16qam(:,2) == 1;
    I_16qam(idx) = 1;

    idx = bits_I_16qam(:,1) == 1 & bits_I_16qam(:,2) == 0;
    I_16qam(idx) = 3;

    % Quadrature mapping
    idx = bits_Q_16qam(:,1) == 0 & bits_Q_16qam(:,2) == 0;
    Q_16qam(idx) = -3;

    idx = bits_Q_16qam(:,1) == 0 & bits_Q_16qam(:,2) == 1;
    Q_16qam(idx) = -1;

    idx = bits_Q_16qam(:,1) == 1 & bits_Q_16qam(:,2) == 1;
    Q_16qam(idx) = 1;

    idx = bits_Q_16qam(:,1) == 1 & bits_Q_16qam(:,2) == 0;
    Q_16qam(idx) = 3;

    % Normalized 16-QAM symbols
    symbols_16qam = (I_16qam + 1j*Q_16qam) / sqrt(10);

    % AWGN noise for 16-QAM
    k_16qam = 4;
    noiseSigma_16qam = sqrt(1/(2*k_16qam*EbN0));

    noise_16qam = noiseSigma_16qam * ...
        (randn(size(symbols_16qam)) + 1j*randn(size(symbols_16qam)));

    received_16qam = symbols_16qam + noise_16qam;

    % 16-QAM demodulation
    received_I = real(received_16qam) * sqrt(10);
    received_Q = imag(received_16qam) * sqrt(10);

    receivedBitGroups = zeros(numSymbols_16qam, 4);

    % Decision boundaries: -2, 0, +2

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

    % Convert received bit groups back to one column vector
    receivedBits_16qam = reshape(receivedBitGroups.', N, 1);

    % 16-QAM BER
    errors_16qam = sum(bits_16qam ~= receivedBits_16qam);
    BER_16QAM(i) = errors_16qam / N;

    %% Print results

    fprintf("Eb/N0 = %2d dB | BPSK = %.6f | QPSK = %.6f | 16-QAM = %.6f\n", ...
            EbN0_dB, BER_BPSK(i), BER_QPSK(i), BER_16QAM(i));

end

%% 3. Theoretical BER curves

EbN0_linear = 10.^(EbN0_dB_range/10);

% BPSK and Gray-coded QPSK have the same theoretical BER over AWGN
BER_theory_BPSK_QPSK = 0.5 * erfc(sqrt(EbN0_linear));

% Approximate theoretical BER for Gray-coded square 16-QAM
M = 16;
k = log2(M);

BER_theory_16QAM = (4/k) * (1 - 1/sqrt(M)) * ...
                   0.5 * erfc(sqrt((3*k ./ (2*(M-1))) .* EbN0_linear));

%% 4. Prepare BER values for plotting

% semilogy cannot plot zero values.
% Replace zero simulated BER values with NaN so MATLAB skips them.
BER_BPSK_plot = BER_BPSK;
BER_QPSK_plot = BER_QPSK;
BER_16QAM_plot = BER_16QAM;

BER_BPSK_plot(BER_BPSK_plot == 0) = NaN;
BER_QPSK_plot(BER_QPSK_plot == 0) = NaN;
BER_16QAM_plot(BER_16QAM_plot == 0) = NaN;

%% 5. Plot comparison

figure;

semilogy(EbN0_dB_range, BER_BPSK_plot, 'o-', 'LineWidth', 1.5);
hold on;

semilogy(EbN0_dB_range, BER_QPSK_plot, 's-', 'LineWidth', 1.5);

semilogy(EbN0_dB_range, BER_16QAM_plot, 'd-', 'LineWidth', 1.5);

semilogy(EbN0_dB_range, BER_theory_BPSK_QPSK, '--', 'LineWidth', 1.5);

semilogy(EbN0_dB_range, BER_theory_16QAM, '--', 'LineWidth', 1.5);

xlabel("Eb/N0 (dB)");
ylabel("Bit Error Rate (BER)");
title("BER Comparison over AWGN: BPSK vs QPSK vs 16-QAM");

legend("Simulated BPSK", ...
       "Simulated QPSK", ...
       "Simulated 16-QAM", ...
       "Theoretical BPSK/QPSK", ...
       "Theoretical 16-QAM", ...
       "Location", "southwest");

grid on;
ylim([1e-5 1]);

%% 6. Save figure

if ~exist("figures", "dir")
    mkdir("figures");
end

ax = gca;
ax.Toolbar.Visible = 'off';

saveas(gcf, "figures/awgn_all_modulations_comparison.png");