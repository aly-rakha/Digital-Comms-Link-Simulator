# Digital Communications Link Simulator in MATLAB

This project simulates a basic digital communication system using MATLAB.

## Current Features

- BPSK modulation and demodulation
- QPSK modulation and demodulation
- AWGN channel model
- Bit Error Rate (BER) calculation
- BER vs Eb/N0 simulation
- Noisy BPSK and QPSK constellation visualization
- Theoretical BER comparison for BPSK and QPSK
  
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

## BER Curves and Constellations

### BPSK Simulated BER Curve

![BPSK BER Curve](figures/bpsk_awgn_ber_curve.png)

### BPSK Simulated vs Theoretical BER

![BPSK Theory Comparison](figures/bpsk_awgn_theory_comparison.png)

### QPSK Constellation

![QPSK Constellation](figures/qpsk_awgn_constellation.png)

### QPSK Simulated vs Theoretical BER

![QPSK BER Curve](figures/qpsk_awgn_ber_curve.png)

## How to Run

Open MATLAB and set the current folder to this project folder.

Run:

```matlab
a01_bpsk_awgn_single_snr
```

to simulate BPSK over AWGN at one Eb/N0 value and view the noisy BPSK constellation.

Run:

```matlab
a02_bpsk_awgn_ber_curve
```

to generate the simulated BPSK BER vs Eb/N0 curve.

Run:

```matlab
a03_bpsk_awgn_theory_comparison
```

to compare the simulated BPSK BER curve with the theoretical BPSK BER curve.

Run:

```matlab
a04_qpsk_awgn_single_snr
```

to simulate QPSK over AWGN at one Eb/N0 value and view the noisy QPSK constellation.

Run:

```matlab
a05_qpsk_awgn_ber_curve
```

to generate the simulated QPSK BER curve and compare it with the theoretical QPSK BER curve.
