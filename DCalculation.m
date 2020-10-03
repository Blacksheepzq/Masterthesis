clc;clear all;
load('Target.mat');
R =Target;
VL = R(2:end,4) - R(1:end-1,4);
VR = R(2:end,5) - R(1:end-1,5);

VL = MidFilter(9,VL,3); % Mid - value filter , to eliminate error
VL = GaussianFilter(5,1,VL',5)'; % Gaussian filter, to smooth shape

VR = MidFilter(9,VR,3); % Mid - value filter , to eliminate error
VR = GaussianFilter(5,1,VR',5)'; % Gaussian filter, to smooth shape


P = R(:,4)./R(:,5);
P2 = VL./VR;


% set NAN and infinite value as 1
NAN = isnan(P2);
INF = isinf(P2);
IndexNAN = find(NAN == 1);
IndexINF = find(INF == 1);
P2(IndexNAN) = 1;
P2(IndexINF) = 1;
P2(P2 == 0) = 1;
P2 = MidFilter(9,P2,3); % Mid - value filter , to eliminate error
P2 = GaussianFilter(5,1,P2',5)'; % Gaussian filter, to smooth shape
plot(1:length(P2),P2)
P3 = 1 ./ P2;

KL = 0.003077; KR = 0.003083;


D = VL .* KL .* (1 + P3) ;
plot(1:length(VL) , VL)
plot(1:length(D),D);
Alpha = (VL .* KL .* (1 - P3))/1.72;
AlphaD = Alpha *180 /pi;
Beta = cumsum(Alpha);
BetaD = Beta * 180 /pi;
Df = D .* cos(Beta);
Ds = D .* sin(Beta);

SumDf = sum(Df); SumDs = sum(Ds);
D = sqrt(SumDf^2 + SumDs^2);

sqrt((R(end,6) - R(1,6))^2 + (R(end,7) - R(1,7))^2)
sqrt((R(100,6) - R(1,6))^2 + (R(100,7) - R(1,7))^2)



x1 = R(1,6); y1 = R(1,7);
x2 = R(2,6); y2 = R(2,7);
AngleStart = atan2((y2-y1),(x2-x1)) * 180 /pi;
AngleEnd = atan2(R(end-1,7)-R(end,7) , R(end-1,6)-R(end,6)) *180 /pi;
Diff = AngleEnd - AngleStart;

diffx = R(2:end,6) - R(1:end-1,6);
diffy = R(2:end,7) - R(1:end-1,7);
DiffAngle = atan2(diffy,diffx) *180 / pi;
diffD = sqrt(diffx.^2 + diffy.^2);
% Calibration of KL and KR
diffPart = [sum(diffD(1:20)),sum(diffD(21:40)),sum(diffD(41:60)),sum(diffD(61:80)),sum(diffD(81:100))];
diffPart2 = [sqrt((R(20,6) - R(1,6))^2 + (R(20,7) - R(1,7))^2);
             sqrt((R(40,6) - R(21,6))^2 + (R(40,7) - R(21,7))^2);
             sqrt((R(60,6) - R(41,6))^2 + (R(60,7) - R(41,7))^2);
             sqrt((R(80,6) - R(61,6))^2 + (R(80,7) - R(61,7))^2);
             sqrt((R(100,6) - R(81,6))^2 + (R(100,7) - R(81,7))^2)]';
diffPart3 = 
PulseLPart = [R(20,4)-R(1,4) , R(40,4)-R(21,4) , R(60,4)-R(41,4) , R(80,4)-R(61,4) , R(100,4)-R(81,4)]; 
PulseRPart = [R(20,5)-R(1,5) , R(40,5)-R(21,5) , R(60,5)-R(41,5) , R(80,5)-R(61,5) , R(100,5)-R(81,5)]; 

KL = mean(diffPart2 ./ PulseLPart)
KR = mean(diffPart2 ./ PulseRPart)


Dy = D .* sin(Beta); Dx = D .* sin(Beta);
SumDy = cumsum(Dy); SumDx = cumsum(Dx);
X = R(1,6) + SumDx; Y = R(1,7) +SumDy;
figure
hold on
plot(X,Y,'b')
plot(R(:,6),R(:,7),'r')
hold off