function result = runCommunicationLink(message, config)
% runCommunicationLink runs a complete digital communication link.
%
% FLOW:
%
% Text
% -> Bits
% -> Modulation
% -> Channel
% -> Demodulation
% -> BER
% -> Recovered Text
%
%
% INPUTS:
%
% message = text message to transmit
%
% config.modulation:
%     "BPSK"
%     "QPSK"
%     "16QAM"
%
% config.channel:
%     "AWGN"
%     "Rayleigh"
%
% config.EbN0_dB:
%     Eb/N0 value in dB
%
%
% OUTPUT:
%
% result = structure containing all important
%          transmission results


    %% 1. CHECK CONFIGURATION

    if ~isfield(config, 'modulation')
        error("config.modulation is missing.");
    end

    if ~isfield(config, 'channel')
        error("config.channel is missing.");
    end

    if ~isfield(config, 'EbN0_dB')
        error("config.EbN0_dB is missing.");
    end


    %% 2. PREPARE USER SETTINGS

    modulationType = upper(string(config.modulation));
    channelType = upper(string(config.channel));
    EbN0_dB = config.EbN0_dB;


    % Allow either:
    %
    % "16QAM"
    % "16-QAM"

    if modulationType == "16-QAM"
        modulationType = "16QAM";
    end


    %% 3. CHECK MODULATION TYPE

    validModulations = ...
        ["BPSK", "QPSK", "16QAM"];

    if ~any(modulationType == validModulations)

        error( ...
            "Unsupported modulation. Choose BPSK, QPSK, or 16QAM." ...
        );

    end


    %% 4. CHECK CHANNEL TYPE

    validChannels = ...
        ["AWGN", "RAYLEIGH"];

    if ~any(channelType == validChannels)

        error( ...
            "Unsupported channel. Choose AWGN or Rayleigh." ...
        );

    end


    %% 5. CHECK Eb/N0

    if ~isscalar(EbN0_dB) || ~isnumeric(EbN0_dB)

        error("Eb/N0 must be a single numeric value.");

    end


    %% 6. TEXT -> BITS

    transmittedBits = ...
        textToBits(message);


    %% 7. MODULATE BITS

    [transmittedSymbols, k] = ...
        modulateSignal( ...
            transmittedBits, ...
            modulationType ...
        );


    %% 8. PASS SIGNAL THROUGH CHANNEL

    [receivedSymbols, equalizedSymbols, h] = ...
        applyChannel( ...
            transmittedSymbols, ...
            channelType, ...
            EbN0_dB, ...
            k ...
        );


    %% 9. DEMODULATE SIGNAL

    receivedBits = ...
        demodulateSignal( ...
            equalizedSymbols, ...
            modulationType ...
        );


    %% 10. CALCULATE BER

    [BER, numErrors] = ...
        calculateBER( ...
            transmittedBits, ...
            receivedBits ...
        );


    %% 11. BITS -> TEXT

    recoveredMessage = ...
        bitsToText(receivedBits);


    %% 12. CREATE DISPLAY-SAFE MESSAGE

    % Noise can sometimes create non-printable characters.
    % Keep the real recovered message, but also create a
    % readable version for displaying in the Command Window.

    displayMessage = recoveredMessage;

    for i = 1:length(displayMessage)

        characterValue = ...
            double(displayMessage(i));

        if characterValue < 32 || ...
           characterValue > 126

            displayMessage(i) = '?';

        end

    end


    %% 13. CLEAN CHANNEL NAME FOR DISPLAY

    if channelType == "RAYLEIGH"

        displayChannelType = "Rayleigh";

    else

        displayChannelType = "AWGN";

    end


    %% 14. STORE EVERYTHING INSIDE result

    result.originalMessage = char(message);

    result.recoveredMessage = recoveredMessage;

    result.displayMessage = displayMessage;


    result.modulation = modulationType;

    result.channel = displayChannelType;

    result.EbN0_dB = EbN0_dB;


    result.bitsPerSymbol = k;

    result.numberOfBits = ...
        length(transmittedBits);

    result.numberOfSymbols = ...
        length(transmittedSymbols);


    result.numErrors = numErrors;

    result.BER = BER;


    result.transmittedBits = ...
        transmittedBits;

    result.receivedBits = ...
        receivedBits;


    result.transmittedSymbols = ...
        transmittedSymbols;

    result.receivedSymbols = ...
        receivedSymbols;

    result.equalizedSymbols = ...
        equalizedSymbols;


    result.channelCoefficients = h;

end