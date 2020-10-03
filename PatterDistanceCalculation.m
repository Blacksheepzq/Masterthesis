function [ForwardDis,SideDis,Angle] = PatterDistanceCalculation(RelatedData,UnknowPart,KL)
%PATTERDISTANCECALCULATION Summary of this function goes here
%   Detailed explanation goes here

VL = diff(RelatedData(:,4)) * KL;
VR = VL ./ UnknowPart(2:end)';
width = 1.72;% [m]
Alpha = (VL - VR) / width;
% plot(1:length(Alpha),Alpha);
Beta = cumsum(Alpha);
BetaD = Beta * 180 /pi;
% plot(1:length(BetaD),BetaD);
D = (VL + VR) / 2;
Df = D .* cos(Beta);
Ds = D .* sin(Beta);
ForwardDis = sum(Df); SideDis = sum(Ds);
Angle = BetaD;
end

