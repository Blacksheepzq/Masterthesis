function [DTR,DTF,DSR,DSF] = Recognize(Target,TR,TF,SR,SF)
% FUNCTION: To recognize the signal of sliding window
% Target : Original signal
% Straight,TR,TF,SR,SF: Models
Target = Target-1;
%% Generate Weight Data and amplitude of data
Weight = (1 * 1);
Amplitude = max(abs(Target));
%% Straight part is not necessary in Recognition
%% Turn Right
ProcessDataTR = Target * max(abs(TR))/ Amplitude; % To keep amplitude in a same size
DTR = norm( ( (TR - ProcessDataTR)).* Weight );
%% Turn Left
ProcessDataTF = Target * max(abs(TF))/ Amplitude; % To keep amplitude in a same size
DTF = norm( ( (TF - ProcessDataTF)).* Weight );
%% Switch Right
ProcessDataSR = Target * max(abs(SR))/ Amplitude; % To keep amplitude in a same size
DSR = norm( ( (SR - ProcessDataSR)).* Weight );
%% Switch Left
ProcessDataSF = Target * max(SF)/ Amplitude; % To keep amplitude in a same size
DSF = norm( ( (SF - ProcessDataSF)).* Weight );

% plot((1:100),SR);
%% Plot and Analysis


end

