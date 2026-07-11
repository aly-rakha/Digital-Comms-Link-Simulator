%% a05 - QPSK over AWGN: BER vs Eb/N0 Curve
% This script simulates QPSK over an AWGN channel
% for multiple Eb/N0 values and plots BER vs Eb/N0.

clear; close all; clc;

%% 1. Simulation settings

N = 100000;                  % Number of bits per Eb/N0 value
EbN0_dB_range = 0:2:12;      % Eb/N0 values in dB

% QPSK uses 2 bits per symbol, so N must be even
if mod(N, 2) ~= 0
    error("N must be even for QPSK.");
end

BER_sim = zeros(size(EbN0_dB_range));  % Store simulated BER values

%% 2. Loop over different Eb/N0 values

for i = 1:length(EbN0_dB_range)

    %% Generate random bits

    bits = randi([0 1], N, 1);

    %% QPSK modulation

    % Group bits into pairs
    bits_I = bits(1:2:end);     % First bit of each pair
    bits_Q = bits(2:2:end);     % Second bit of each pair

    % Convert bits to +1 or -1
    % bit 0 -> -1
    % bit 1 -> +1
    I = 2*bits_I - 1;
    Q = 2*bits_Q - 1;

    % Create complex QPSK symbols
    symbols = (I + 1j*Q) / sqrt(2);

    %% AWGN noise channel

    EbN0_dB = EbN0_dB_range(i);
    EbN0 = 10^(EbN0_dB/10);

    k = 2;   % QPSK carries 2 bits per symbol

    noiseSigma = sqrt(1/(2*k*EbN0));
    noise = noiseSigma * (randn(size(symbols)) + 1j*randn(size(symbols)));

    receivedSymbols = symbols + noise;

    %% QPSK demodulation

    receivedBits_I = double(real(receivedSymbols) > 0);
    receivedBits_Q = double(imag(receivedSymbols) > 0);

    % Put received bits back in original order
    receivedBits = zeros(N, 1);
    receivedBits(1:2:end) = receivedBits_I;
    receivedBits(2:2:end) = receivedBits_Q;

    %% Calculate BER

    numErrors = sum(bits ~= receivedBits);
    BER_sim(i) = numErrors / N;

    fprintf("Eb/N0 = %2d dB | Errors = %5d | QPSK BER = %.6f\n", ...
            EbN0_dB, numErrors, BER_sim(i));

end

%% 3. Theoretical BER for QPSK over AWGN

% For Gray-coded QPSK over AWGN, BER is the same as BPSK
EbN0_linear = 10.^(EbN0_dB_range/10);
BER_theory = 0.5 * erfc(sqrt(EbN0_linear));

%% 4. Plot simulated and theoretical BER

figure;

semilogy(EbN0_dB_range, BER_sim, 'o-', 'LineWidth', 1.5);
hold on;

semilogy(EbN0_dB_range, BER_theory, '--', 'LineWidth', 1.5);

xlabel("Eb/N0 (dB)");
ylabel("Bit Error Rate (BER)");
title("QPSK over AWGN: Simulated vs Theoretical BER");
legend("Simulated QPSK BER", "Theoretical QPSK BER");
grid on;

%% 5. Save figure

if ~exist("figures", "dir")
    mkdir("figures");
end

saveas(gcf, "figures/qpsk_awgn_ber_curve.png");