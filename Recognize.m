function [DTR,DTL,DSR,DSL] = Recognize(Target,TR,TL,SR,SL)
% FUNCTION: To recognize the signal of sliding window
% Target : Original signal
% Straight,TR,TL,SR,SL: Models

T = Target;
T = T'-1; % Move the central part of Signal from 1 to 0, then amplitude of positive and negative can be changed with same size
%% Generate Weight Data and amplitude of data
Weight = (1 * 1);
Amplitude = max(abs(T));
T = T ./ Amplitude; % To keep target signal has same size with model
%% Straight part is not necessary in Recognition
% DSP = norm(  (SP - Target) .* Weight );
%% Turn Right
DTR = norm(  (TR - T).* Weight );
%% Turn Left
DTL = norm( ( (TL - T)).* Weight );
%% Switch Right
DSR = norm( ( (SR - T)).* Weight );
%% Switch Left
DSL = norm( ( (SL - T)).* Weight );

end

