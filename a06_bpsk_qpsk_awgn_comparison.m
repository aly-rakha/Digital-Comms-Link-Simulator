%% a06 - BPSK vs QPSK over AWGN: BER Comparison
% This script compares BPSK and QPSK performance over an AWGN channel.
% It plots simulated BER curves for both modulation schemes and compares
% them with the theoretical BER curve.

clear; close all; clc;

%% 1. Simulation settings

N = 100000;                  % Number of bits per Eb/N0 value
EbN0_dB_range = 0:2:12;      % Eb/N0 values in dB

BER_BPSK = zeros(size(EbN0_dB_range));
BER_QPSK = zeros(size(EbN0_dB_range));

%% 2. Loop over Eb/N0 values

for i = 1:length(EbN0_dB_range)

    EbN0_dB = EbN0_dB_range(i);
    EbN0 = 10^(EbN0_dB/10);

    %% BPSK simulation

    bits_bpsk = randi([0 1], N, 1);

    % BPSK modulation: 0 -> -1, 1 -> +1
    symbols_bpsk = 2*bits_bpsk - 1;

    % AWGN noise for BPSK
    noiseSigma_bpsk = sqrt(1/(2*EbN0));
    noise_bpsk = noiseSigma_bpsk * randn(size(symbols_bpsk));

    received_bpsk = symbols_bpsk + noise_bpsk;

    % BPSK demodulation
    receivedBits_bpsk = double(received_bpsk > 0);

    % BPSK BER
    errors_bpsk = sum(bits_bpsk ~= receivedBits_bpsk);
    BER_BPSK(i) = errors_bpsk / N;

    %% QPSK simulation

    bits_qpsk = randi([0 1], N, 1);

    % QPSK uses 2 bits per symbol
    bits_I = bits_qpsk(1:2:end);
    bits_Q = bits_qpsk(2:2:end);

    % Convert bits to +1 or -1
    I = 2*bits_I - 1;
    Q = 2*bits_Q - 1;

    % QPSK symbols, normalized by sqrt(2)
    symbols_qpsk = (I + 1j*Q) / sqrt(2);

    k = 2;   % QPSK carries 2 bits per symbol

    % Complex AWGN noise for QPSK
    noiseSigma_qpsk = sqrt(1/(2*k*EbN0));
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

    %% Print results

    fprintf("Eb/N0 = %2d dB | BPSK BER = %.6f | QPSK BER = %.6f\n", ...
            EbN0_dB, BER_BPSK(i), BER_QPSK(i));

end

%% 3. Theoretical BER

% For BPSK and Gray-coded QPSK over AWGN, theoretical BER is the same
EbN0_linear = 10.^(EbN0_dB_range/10);
BER_theory = 0.5 * erfc(sqrt(EbN0_linear));

%% 4. Plot comparison

figure;

semilogy(EbN0_dB_range, BER_BPSK, 'o-', 'LineWidth', 1.5);
hold on;

semilogy(EbN0_dB_range, BER_QPSK, 's-', 'LineWidth', 1.5);

semilogy(EbN0_dB_range, BER_theory, '--', 'LineWidth', 1.5);

xlabel("Eb/N0 (dB)");
ylabel("Bit Error Rate (BER)");
title("BPSK vs QPSK over AWGN");
legend("Simulated BPSK", "Simulated QPSK", "Theoretical BER");
grid on;

%% 5. Save figure

if ~exist("figures", "dir")
    mkdir("figures");
end

ax = gca;
ax.Toolbar.Visible = 'off';

saveas(gcf, "figures/bpsk_qpsk_awgn_comparison.png");