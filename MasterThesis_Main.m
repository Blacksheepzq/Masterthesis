%% Master Thesis : Lane switch dection by odo
% Author: Zhang,Ziqiang

%% Initialization and Data Loading
clc; close all;clear all;
% run MasterThese_Initialization.m
addpath(genpath('.'))
R = load('../data/red box/R.txt');
Ldata = R(2:end,2) - R(1:end-1,2);
Rdata = R(2:end,3) - R(1:end-1,3);
P = R(:,2)./R(:,3);
P2 = Ldata./Rdata;

% set NAN and infinite value as 1
NAN = isnan(P2);
INF = isinf(P2);
IndexNAN = find(NAN == 1);
IndexINF = find(INF == 1);
P2(IndexNAN) = 1;
P2(IndexINF) = 1;
P2(P2 == 0) = 1;

%% Gauss Filter
Gauss = GaussianFilter(5,1,P2',5)';
%%
x = R(2:end,1)-R(2,1); % xlabel time
y = Gauss; % ylabel Ratio
% x = x(1:4:end);y = y(1:4:end);

WholdSignal = MidFilter(9,P2,5);
WholdSignal = GaussianFilter(5,1,WholdSignal',5)';
f1 = figure('Name','Whole Signal,Middel Filter first then Gaussian Filter');
figure(f1)
hold on 
    plot(R(2:end,1)-R(2,1),P2,'b')
    plot(R(2:end,1)-R(2,1),WholdSignal,'r')
    xlabel('WholdSignal');
hold off

a = x(1:2:end-1);
b = x(2:2:end);
xM = (a + b)/2;
P2M = (P2(1:2:end-1) + P2(2:2:end))/2;
xM2 = xM(1:5:end);P2M2 = P2M(1:5:end);
% figure(2)
% plot(x,P2,'b',xM,P2M,'g',xM2,P2M2,'r')


%% set up sliding window parameters
Len = 50 ;% Window length, Length must larger than 5
MoveF = 5;% Move frequence, 1 means move 1s per time
% Generate pattern model
[Straight,TR,TF,SR,SF] = GenerateModels(Len);

%% Sliding window and detect
Time = R(2:end,1)-R(2,1);
Ratio = P2;
f3 = figure('Name','Sliding Window');
f4 = figure('Name','Likelyhood');
% 
% i = 1;
% while i + Len -1 <= length(Time)
% 
% %     plot(Time,Ratio,'b',Time(i:i + Len),Ratio(i:i + Len),'g')              % plot whole/window data
% %     plot(Time(i:i + Len),Ratio(i:i + Len),'g') 
% %     Filted = GaussianFilter(5,1,Ratio(i:i + Len)',10)'; % Filte window data
%     Filted = MidFilter(9,Ratio(i:i + Len -1),5);
%     Filted = GaussianFilter(5,1,Filted',5)';  
%     figure(f2)
%     clf(figure(f2))
%     hold on
%     plot(Time(i:i + Len),Ratio(i:i + Len),'g') 
%     plot(Time(i:i + Len-1),Filted,'r');            % plot filted result
%     hold off 
%     
%     [DS,DTR,DTF,DSR,DSF] = Recognize(Filted,Straight,TR,TF,SR,SF);
%     
%     X = categorical({'Straight part','Turn Right','Turn Left','Switch Right','Switch Left'});
%     X = reordercats(X,{'Straight part','Turn Right','Turn Left','Switch Right','Switch Left'});
%     Y = [DS,DTR,DTF,DSR,DSF];
%     figure(f3)
%     bar(X,Y)
%     
%     i = i + MoveF;
% end

%% Detect Interesting Part
LargeWindow = 100; % Large window to detect a large area,smooth data
Smallwindow = 9;  % Small window to detect the trend of signal whether it change a lot
MoveF = 1;
TS = 0.0001; %  Trend change Threshold
HalfLength = fix(LargeWindow/2);
RatioModified = [ones(HalfLength,1);Ratio;ones(HalfLength,1)]; % Add enough 1 at empty area;
TimeExtend = linspace(0,5,50)';
TimeModified = [TimeExtend - 5.1 ; Time ; TimeExtend + Time(end)];
i = 1 + HalfLength;
K1 = 0; K2 = 0;
Kall = [];fArea = [];
while i + Smallwindow <= length(P2) + HalfLength

    LargePart = MidFilter(9,RatioModified(i - HalfLength:i + HalfLength - 1),5);
    LargePart = GaussianFilter(5,1,LargePart',5)';
    
    DetectPart = LargePart( HalfLength + 1: HalfLength + 1 + Smallwindow);
    DetectResult = var(DetectPart)
    
    figure(f3)
    clf(figure(f3))
    hold on
    plot(TimeModified(i - HalfLength:i + HalfLength - 1),LargePart,'b')
    plot(TimeModified(i : i + Smallwindow),DetectPart,'r')
    hold off    
    
    if DetectResult > TS
       K2 = 1;   
    elseif DetectResult <= TS
       K2 = 0;       
    end
    
    Kall = [Kall K2]; % Kall is not necessary in cpp
    Kd = K2 - K1;
    
    if Kd == 1
        StartPoint = i; % find when and where the signal changes
    elseif Kd == -1
        EndPoint = i;
        fLen = EndPoint - StartPoint;
        [Straight,TR,TF,SR,SF] = GenerateModels(fLen);
        
    end
    
    if StartPoint ~= 0
        fArea = [fArea ; ]
    end
    
    
    K1 = K2;
    i = i + MoveF;
end
