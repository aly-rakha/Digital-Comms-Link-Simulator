%% a10 - BPSK over Rayleigh Fading: BER vs Eb/N0
% This script compares BPSK performance over:
%
% 1. AWGN channel
% 2. Rayleigh fading channel
%
% AWGN only adds noise.
% Rayleigh fading randomly changes the signal amplitude and phase,
% which models multipath propagation in wireless communication.

clear; close all; clc;

%% 1. Simulation settings

N = 100000;                 % Number of bits per Eb/N0 value
EbN0_dB_range = 0:2:30;     % Eb/N0 values in dB

BER_AWGN = zeros(size(EbN0_dB_range));
BER_Rayleigh = zeros(size(EbN0_dB_range));

%% 2. Loop over Eb/N0 values

for i = 1:length(EbN0_dB_range)

    EbN0_dB = EbN0_dB_range(i);
    EbN0 = 10^(EbN0_dB/10);

    %% Generate random bits

    bits = randi([0 1], N, 1);

    %% BPSK modulation

    % BPSK mapping:
    % bit 0 -> -1
    % bit 1 -> +1

    symbols = 2*bits - 1;

    %% AWGN channel

    % For BPSK over AWGN:
    % received = symbols + noise

    noiseSigma = sqrt(1/(2*EbN0));
    noise_awgn = noiseSigma * randn(size(symbols));

    received_awgn = symbols + noise_awgn;

    % BPSK demodulation
    receivedBits_awgn = double(received_awgn > 0);

    % BER calculation
    errors_awgn = sum(bits ~= receivedBits_awgn);
    BER_AWGN(i) = errors_awgn / N;

    %% Rayleigh fading channel

    % Rayleigh fading coefficient:
    % h is complex because a wireless channel changes both amplitude and phase.

    h = (randn(size(symbols)) + 1j*randn(size(symbols))) / sqrt(2);

    % Complex noise for Rayleigh fading channel
    noise_rayleigh = noiseSigma * ...
        (randn(size(symbols)) + 1j*randn(size(symbols)));

    % Received signal through Rayleigh fading:
    % received = h * symbols + noise

    received_rayleigh = h .* symbols + noise_rayleigh;

    % Equalization:
    % We assume the receiver knows h and divides by h to undo the channel.

    equalized_rayleigh = received_rayleigh ./ h;

    % BPSK demodulation after equalization
    receivedBits_rayleigh = double(real(equalized_rayleigh) > 0);

    % BER calculation
    errors_rayleigh = sum(bits ~= receivedBits_rayleigh);
    BER_Rayleigh(i) = errors_rayleigh / N;

    %% Print results

    fprintf("Eb/N0 = %2d dB | AWGN BER = %.6f | Rayleigh BER = %.6f\n", ...
            EbN0_dB, BER_AWGN(i), BER_Rayleigh(i));

end

%% 3. Theoretical BER curves

EbN0_linear = 10.^(EbN0_dB_range/10);

% Theoretical BPSK BER over AWGN
BER_theory_AWGN = 0.5 * erfc(sqrt(EbN0_linear));

% Theoretical BPSK BER over Rayleigh fading
BER_theory_Rayleigh = 0.5 * ...
    (1 - sqrt(EbN0_linear ./ (1 + EbN0_linear)));

%% 4. Prepare BER values for plotting

% semilogy cannot plot zero values.
% Replace zero simulated BER values with NaN so MATLAB skips them.

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
title("BPSK over AWGN vs Rayleigh Fading");

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

saveas(gcf, "figures/bpsk_awgn_vs_rayleigh.png");