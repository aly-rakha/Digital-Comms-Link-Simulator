%% a04 - QPSK over AWGN at One Eb/N0 Value
% This script simulates QPSK modulation over an AWGN channel
% at one Eb/N0 value and plots the noisy QPSK constellation.

clear; close all; clc;

%% 1. Generate random bits

N = 10000;                  % Number of bits to transmit

% QPSK uses 2 bits per symbol, so N must be even
if mod(N, 2) ~= 0
    error("N must be even for QPSK.");
end

bits = randi([0 1], N, 1);  % Generate random 0s and 1s

%% 2. QPSK modulation

% QPSK groups bits in pairs:
% first bit controls the real/In-phase part
% second bit controls the imaginary/Quadrature part

bits_I = bits(1:2:end);     % Bits for In-phase axis
bits_Q = bits(2:2:end);     % Bits for Quadrature axis

% Convert bits to +1 or -1
% bit 0 -> -1
% bit 1 -> +1

I = 2*bits_I - 1;
Q = 2*bits_Q - 1;

% Create complex QPSK symbols
% Divide by sqrt(2) to normalize the average symbol energy to 1

symbols = (I + 1j*Q) / sqrt(2);

%% 3. Add AWGN noise

EbN0_dB = 2;                  % Eb/N0 value in dB
EbN0 = 10^(EbN0_dB/10);       % Convert dB to linear scale

k = 2;                        % QPSK carries 2 bits per symbol

% Complex AWGN noise for QPSK
noiseSigma = sqrt(1/(2*k*EbN0));

noise = noiseSigma * (randn(size(symbols)) + 1j*randn(size(symbols)));

receivedSymbols = symbols + noise;

%% 4. QPSK demodulation

% Receiver decision rule:
% real part > 0      -> first bit = 1
% real part < 0      -> first bit = 0
% imaginary part > 0 -> second bit = 1
% imaginary part < 0 -> second bit = 0

receivedBits_I = double(real(receivedSymbols) > 0);
receivedBits_Q = double(imag(receivedSymbols) > 0);

% Put the received I and Q bits back into the original order

receivedBits = zeros(N, 1);
receivedBits(1:2:end) = receivedBits_I;
receivedBits(2:2:end) = receivedBits_Q;

%% 5. Count errors and calculate BER

numErrors = sum(bits ~= receivedBits);
BER = numErrors / N;

%% 6. Display results

fprintf("Modulation: QPSK\n");
fprintf("Eb/N0: %d dB\n", EbN0_dB);
fprintf("Number of transmitted bits: %d\n", N);
fprintf("Number of QPSK symbols: %d\n", length(symbols));
fprintf("Number of errors: %d\n", numErrors);
fprintf("BER: %.5f\n", BER);

%% 7. Plot noisy QPSK constellation

numConstellationPoints = 1000;

figure;

scatter(real(receivedSymbols(1:numConstellationPoints)), ...
        imag(receivedSymbols(1:numConstellationPoints)), ...
        'filled');

xline(0, '--', 'Decision Boundary');
yline(0, '--', 'Decision Boundary');

xlabel("In-phase axis");
ylabel("Quadrature axis");
title("QPSK Constellation with AWGN Noise");
axis equal;
grid on;

%% 8. Save figure

if ~exist("figures", "dir")
    mkdir("figures");
end

saveas(gcf, "figures/qpsk_awgn_constellation.png");