function [outputArg1,outputArg2] = Recongnise(Target,Straight,TR,TF,SR,SF)
% FUNCTION: To recognize the signal of sliding window
% Target : Original signal
% Straight,TR,TF,SR,SF: Models

Target = Filted;
%% Straight part
ProcessDataS = Target * max(Target)/ max(Straight); % To keep amplitude in a same size
DS = norm( Straight - ProcessDataS );
%% Turn Right
ProcessDataTR = Target * max(Target)/ max(TR); % To keep amplitude in a same size
DTR = norm( Straight - ProcessDataTR );
%% Turn Left
ProcessDataTF = Target * max(Target)/ max(TF); % To keep amplitude in a same size
DTF = norm( Straight - ProcessDataTF );
%% Switch Right
ProcessDataSR = Target * max(Target)/ max(SR); % To keep amplitude in a same size
DSR = norm( Straight - ProcessDataSR );
%% Switch Left
ProcessDataSF = Target * max(Target)/ max(SF); % To keep amplitude in a same size
DSF = norm( Straight - ProcessDataSF );
end

