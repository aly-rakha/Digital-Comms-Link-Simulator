function [receivedSymbols, equalizedSymbols, h] = ...
    applyChannel(symbols, channelType, EbN0_dB, k)
% applyChannel passes modulation symbols through a selected channel.
%
% Supported channels:
% "AWGN"
% "Rayleigh"
%
% Inputs:
% symbols      = transmitted modulation symbols
% channelType  = "AWGN" or "Rayleigh"
% EbN0_dB      = Eb/N0 in dB
% k            = bits per symbol
%
% Outputs:
% receivedSymbols  = signal directly after the channel
% equalizedSymbols = signal used by the demodulator
% h                = channel coefficient
%
% For AWGN:
% received = transmitted + noise
%
% For Rayleigh:
% received = h .* transmitted + noise
% equalized = received ./ h


    %% 1. Prepare inputs

    symbols = symbols(:);

    channelType = upper(string(channelType));


    %% 2. Check inputs

    if k <= 0
        error("k must be greater than zero.");
    end

    if ~isscalar(EbN0_dB)
        error("Eb/N0 must be a single value.");
    end


    %% 3. Convert Eb/N0 from dB to linear scale

    EbN0 = 10^(EbN0_dB/10);


    %% 4. Calculate noise standard deviation

    noiseSigma = sqrt(1/(2*k*EbN0));


    %% 5. Select channel

    switch channelType


        % =====================================================
        % AWGN
        % =====================================================

        case "AWGN"

            % AWGN does not change the signal amplitude
            % or phase, so channel gain is 1.

            h = ones(size(symbols));


            % If the transmitted signal is real, such as BPSK,
            % use real Gaussian noise.

            if isreal(symbols)

                noise = ...
                    noiseSigma * randn(size(symbols));

            else

                % QPSK and 16-QAM use complex noise

                noise = noiseSigma * ...
                    ( ...
                    randn(size(symbols)) + ...
                    1j*randn(size(symbols)) ...
                    );

            end


            % Channel equation:
            %
            % received = signal + noise

            receivedSymbols = ...
                symbols + noise;


            % AWGN does not need equalization

            equalizedSymbols = ...
                receivedSymbols;


        % =====================================================
        % RAYLEIGH FADING
        % =====================================================

        case "RAYLEIGH"

            % Generate complex Rayleigh fading coefficient
            %
            % h changes both amplitude and phase.

            h = ...
                ( ...
                randn(size(symbols)) + ...
                1j*randn(size(symbols)) ...
                ) / sqrt(2);


            % Rayleigh channel uses complex Gaussian noise

            noise = noiseSigma * ...
                ( ...
                randn(size(symbols)) + ...
                1j*randn(size(symbols)) ...
                );


            % Channel equation:
            %
            % received = h * signal + noise

            receivedSymbols = ...
                h .* symbols + noise;


            % Perfect channel equalization
            %
            % We assume the receiver knows h.

            equalizedSymbols = ...
                receivedSymbols ./ h;


        % =====================================================
        % INVALID CHANNEL
        % =====================================================

        otherwise

            error( ...
                "Unsupported channel. Choose AWGN or Rayleigh." ...
            );

    end
