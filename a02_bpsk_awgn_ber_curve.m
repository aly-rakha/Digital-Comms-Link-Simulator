%% a02 - BPSK over AWGN: BER vs Eb/N0 Curve
% This script simulates BPSK over an AWGN channel
% for multiple Eb/N0 values and plots BER vs Eb/N0.

clear; close all; clc;

%% 1. Simulation settings

N = 100000;                  % Number of bits per Eb/N0 value
EbN0_dB_range = 0:2:12;      % Eb/N0 values we want to test

BER_sim = zeros(size(EbN0_dB_range));  % Store simulated BER results

%% 2. Loop over different Eb/N0 values

for i = 1:length(EbN0_dB_range)

    %% Generate random bits

    bits = randi([0 1], N, 1);

    %% BPSK modulation

    symbols = 2*bits - 1;

    %% AWGN noise channel

    EbN0_dB = EbN0_dB_range(i);
    EbN0 = 10^(EbN0_dB/10);

    noiseSigma = sqrt(1/(2*EbN0));
    noise = noiseSigma * randn(size(symbols));

    receivedSymbols = symbols + noise;

    %% BPSK demodulation

    receivedBits = double(receivedSymbols > 0);

    %% Calculate BER

    numErrors = sum(bits ~= receivedBits);
    BER_sim(i) = numErrors / N;

    %% Print result for this Eb/N0

    fprintf("Eb/N0 = %2d dB | Errors = %5d | BER = %.6f\n", ...
            EbN0_dB, numErrors, BER_sim(i));

end

%% 3. Plot BER vs Eb/N0

figure;

semilogy(EbN0_dB_range, BER_sim, 'o-', 'LineWidth', 1.5);

xlabel("Eb/N0 (dB)");
ylabel("Bit Error Rate (BER)");
title("BPSK over AWGN: Simulated BER vs Eb/N0");
grid on;