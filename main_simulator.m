%% MAIN DIGITAL COMMUNICATION LINK SIMULATOR

clear;
close all;
clc;


%% 1. PROJECT SETUP

projectRoot = fileparts(mfilename("fullpath"));

addpath(fullfile(projectRoot, "src"));


%% 2. USER SETTINGS

message = "Hello from my digital communication simulator!";

config.modulation = "QPSK";

config.channel = "Rayleigh";

config.EbN0_dB = 10;


%% 3. RUN COMPLETE COMMUNICATION LINK

result = runCommunicationLink(message, config);


%% 4. DISPLAY RESULTS

fprintf("\n");

fprintf("=================================================\n");
fprintf("       DIGITAL COMMUNICATION LINK SIMULATOR\n");
fprintf("=================================================\n\n");

fprintf("Original message:\n");
fprintf("%s\n\n", result.originalMessage);

fprintf("Recovered message:\n");
fprintf("%s\n\n", result.displayMessage);

fprintf("Modulation: %s\n", result.modulation);

fprintf("Channel: %s\n", result.channel);

fprintf("Eb/N0: %.1f dB\n", result.EbN0_dB);

fprintf("Bits per symbol: %d\n", result.bitsPerSymbol);

fprintf("Number of transmitted bits: %d\n", ...
    result.numberOfBits);

fprintf("Number of transmitted symbols: %d\n", ...
    result.numberOfSymbols);

fprintf("Number of bit errors: %d\n", ...
    result.numErrors);

fprintf("BER: %.6f\n", ...
    result.BER);

fprintf("\n=================================================\n");


%% 5. PLOT RESULTS

fig = figure;

numBitsToPlot = ...
    min(80, result.numberOfBits);


% -------------------------------------------------------------
% ORIGINAL BITS
% -------------------------------------------------------------

subplot(3,1,1);

stem( ...
    result.transmittedBits(1:numBitsToPlot), ...
    'filled' ...
);

xlabel("Bit Number");
ylabel("Bit");

title("Original Message Bits");

ylim([-0.2 1.2]);

grid on;


% -------------------------------------------------------------
% RECOVERED BITS
% -------------------------------------------------------------

subplot(3,1,2);

stem( ...
    result.receivedBits(1:numBitsToPlot), ...
    'filled' ...
);

xlabel("Bit Number");
ylabel("Bit");

title("Recovered Message Bits");

ylim([-0.2 1.2]);

grid on;


% -------------------------------------------------------------
% CONSTELLATION
% -------------------------------------------------------------

subplot(3,1,3);

scatter( ...
    real(result.equalizedSymbols), ...
    imag(result.equalizedSymbols), ...
    20, ...
    'filled' ...
);

hold on;


switch upper(string(result.modulation))

    case "BPSK"

        xline(0, '--');


    case "QPSK"

        xline(0, '--');
        yline(0, '--');


    case {"16QAM", "16-QAM"}

        boundary = 2/sqrt(10);

        xline(-boundary, '--');
        xline(0, '--');
        xline(boundary, '--');

        yline(-boundary, '--');
        yline(0, '--');
        yline(boundary, '--');

end


hold off;

xlabel("In-Phase");
ylabel("Quadrature");

title( ...
    result.modulation + ...
    " - " + ...
    result.channel ...
);

axis equal;

grid on;


%% 6. SAVE FIGURE

figuresFolder = ...
    fullfile(projectRoot, "figures");

if ~exist(figuresFolder, "dir")
    mkdir(figuresFolder);
end


figureName = ...
    "main_simulator_" + ...
    lower(result.modulation) + ...
    "_" + ...
    lower(result.channel) + ...
    ".png";


figurePath = ...
    fullfile(figuresFolder, figureName);


drawnow;


exportgraphics( ...
    fig, ...
    figurePath, ...
    "Resolution", ...
    300 ...
);


fprintf("\nFigure saved to:\n");
fprintf("%s\n", figurePath);