%% a11 - QPSK over Rayleigh Fading: BER vs Eb/N0
% This script compares QPSK performance over:
%
% 1. AWGN channel
% 2. Rayleigh fading channel
%
% QPSK uses 2 bits per symbol.
%
% AWGN only adds noise.
% Rayleigh fading randomly changes signal amplitude and phase,
% which models multipath propagation in wireless communication.

clear; close all; clc;

%% 1. Simulation settings

N = 100000;                 % Number of bits per Eb/N0 value
EbN0_dB_range = 0:2:30;     % Eb/N0 values in dB

% QPSK uses 2 bits per symbol, so N must be even
if mod(N, 2) ~= 0
    error("N must be even for QPSK.");
end

BER_AWGN = zeros(size(EbN0_dB_range));
BER_Rayleigh = zeros(size(EbN0_dB_range));

%% 2. Loop over Eb/N0 values

for i = 1:length(EbN0_dB_range)

    EbN0_dB = EbN0_dB_range(i);
    EbN0 = 10^(EbN0_dB/10);

    %% Generate random bits

    bits = randi([0 1], N, 1);

    %% QPSK modulation

    % QPSK groups bits in pairs:
    % first bit controls the In-phase axis
    % second bit controls the Quadrature axis

    bits_I = bits(1:2:end);
    bits_Q = bits(2:2:end);

    % Convert bits to +1 or -1:
    % bit 0 -> -1
    % bit 1 -> +1

    I = 2*bits_I - 1;
    Q = 2*bits_Q - 1;

    % Create normalized QPSK symbols
    % Divide by sqrt(2) so average symbol energy is 1

    symbols = (I + 1j*Q) / sqrt(2);

    %% AWGN channel

    % QPSK carries 2 bits per symbol

    k = 2;

    % Complex AWGN noise
    noiseSigma = sqrt(1/(2*k*EbN0));

    noise_awgn = noiseSigma * ...
        (randn(size(symbols)) + 1j*randn(size(symbols)));

    received_awgn = symbols + noise_awgn;

    %% QPSK demodulation for AWGN

    receivedBits_I_awgn = double(real(received_awgn) > 0);
    receivedBits_Q_awgn = double(imag(received_awgn) > 0);

    receivedBits_awgn = zeros(N, 1);
    receivedBits_awgn(1:2:end) = receivedBits_I_awgn;
    receivedBits_awgn(2:2:end) = receivedBits_Q_awgn;

    errors_awgn = sum(bits ~= receivedBits_awgn);
    BER_AWGN(i) = errors_awgn / N;

    %% Rayleigh fading channel

    % Rayleigh fading coefficient:
    % h is complex because wireless channels affect both amplitude and phase.

    h = (randn(size(symbols)) + 1j*randn(size(symbols))) / sqrt(2);

    % Complex AWGN noise for Rayleigh channel
    noise_rayleigh = noiseSigma * ...
        (randn(size(symbols)) + 1j*randn(size(symbols)));

    % Received signal through Rayleigh fading:
    % received = h * transmitted symbol + noise

    received_rayleigh = h .* symbols + noise_rayleigh;

    % Equalization:
    % Assume receiver knows h and divides by h to undo the channel.

    equalized_rayleigh = received_rayleigh ./ h;

    %% QPSK demodulation after Rayleigh equalization

    receivedBits_I_rayleigh = double(real(equalized_rayleigh) > 0);
    receivedBits_Q_rayleigh = double(imag(equalized_rayleigh) > 0);

    receivedBits_rayleigh = zeros(N, 1);
    receivedBits_rayleigh(1:2:end) = receivedBits_I_rayleigh;
    receivedBits_rayleigh(2:2:end) = receivedBits_Q_rayleigh;

    errors_rayleigh = sum(bits ~= receivedBits_rayleigh);
    BER_Rayleigh(i) = errors_rayleigh / N;

    %% Print results

    fprintf("Eb/N0 = %2d dB | AWGN BER = %.6f | Rayleigh BER = %.6f\n", ...
            EbN0_dB, BER_AWGN(i), BER_Rayleigh(i));

end

%% 3. Theoretical BER curves

EbN0_linear = 10.^(EbN0_dB_range/10);

% For Gray-coded QPSK over AWGN, BER is the same as BPSK
BER_theory_AWGN = 0.5 * erfc(sqrt(EbN0_linear));

% Theoretical BER for coherent QPSK/BPSK over Rayleigh fading
BER_theory_Rayleigh = 0.5 * ...
    (1 - sqrt(EbN0_linear ./ (1 + EbN0_linear)));

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
title("QPSK over AWGN vs Rayleigh Fading");

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

saveas(gcf, "figures/qpsk_awgn_vs_rayleigh.png");