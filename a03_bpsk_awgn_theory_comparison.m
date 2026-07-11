%% a03 - BPSK over AWGN: Simulated vs Theoretical BER
% This script compares the simulated BER of BPSK over AWGN
% with the theoretical BER formula.

clear; close all; clc;

%% 1. Simulation settings

N = 100000;                  % Number of bits per Eb/N0 value
EbN0_dB_range = 0:2:12;      % Eb/N0 values in dB

BER_sim = zeros(size(EbN0_dB_range));  % Store simulated BER values

%% 2. Simulated BER using Monte Carlo simulation

for i = 1:length(EbN0_dB_range)

    % Generate random bits
    bits = randi([0 1], N, 1);

    % BPSK modulation
    % bit 0 -> -1
    % bit 1 -> +1
    symbols = 2*bits - 1;

    % Convert current Eb/N0 from dB to linear scale
    EbN0_dB = EbN0_dB_range(i);
    EbN0 = 10^(EbN0_dB/10);

    % AWGN noise
    noiseSigma = sqrt(1/(2*EbN0));
    noise = noiseSigma * randn(size(symbols));

    % Received symbols
    receivedSymbols = symbols + noise;

    % BPSK demodulation
    receivedBits = double(receivedSymbols > 0);

    % Count errors and calculate BER
    numErrors = sum(bits ~= receivedBits);
    BER_sim(i) = numErrors / N;

    % Print result
    fprintf("Eb/N0 = %2d dB | Errors = %5d | Simulated BER = %.6f\n", ...
            EbN0_dB, numErrors, BER_sim(i));

end

%% 3. Theoretical BER for BPSK over AWGN

EbN0_linear = 10.^(EbN0_dB_range/10);

BER_theory = 0.5 * erfc(sqrt(EbN0_linear));

%% 4. Plot simulated and theoretical BER curves

figure;

semilogy(EbN0_dB_range, BER_sim, 'o-', 'LineWidth', 1.5);
hold on;

semilogy(EbN0_dB_range, BER_theory, '--', 'LineWidth', 1.5);

xlabel("Eb/N0 (dB)");
ylabel("Bit Error Rate (BER)");
title("BPSK over AWGN: Simulated vs Theoretical BER");
legend("Simulated BER", "Theoretical BER");
grid on;

%% 5. Save figure

if ~exist("figures", "dir")
    mkdir("figures");
end

saveas(gcf, "figures/bpsk_awgn_theory_comparison.png");
