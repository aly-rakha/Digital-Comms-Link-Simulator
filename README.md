# Digital Communications Link Simulator in MATLAB

This project simulates a basic digital communication system using MATLAB.

## Current Features

- BPSK modulation and demodulation
- AWGN channel model
- Bit Error Rate (BER) calculation
- BER vs Eb/N0 simulation
- Noisy BPSK constellation visualization

## Current Results

The simulation shows that the Bit Error Rate decreases as Eb/N0 increases.

Example result from the BPSK over AWGN simulation:

| Eb/N0 (dB) | BER |
|---|---|
| 0 | 0.079300 |
| 2 | 0.036730 |
| 4 | 0.012360 |
| 6 | 0.002510 |
| 8 | 0.000190 |
| 10 | 0.000000 |
| 12 | 0.000000 |

## BER Curve

![BPSK BER Curve](figures/bpsk_awgn_ber_curve.png)

## How to Run

Open MATLAB and run:

```matlab
a01_bpsk_awgn_single_snr