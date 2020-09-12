%% Master Thesis : Lane switch dection by odo
% Author: Zhang,Ziqiang

%% Initialization and Data Loading
% clc; close all;clear all;
% run MasterThese_Initialization.m
% addpath(genpath('.'))
%% Data input
% % Test data
% R = load('../data/red box/toR R tR R toL tR L L R toL R L.txt'); 
% Ldata = R(2:end,2) - R(1:end-1,2);
% Rdata = R(2:end,3) - R(1:end-1,3);
% P = R(:,2)./R(:,3);
% P2 = Ldata./Rdata;

% Real odometer data
% R = load('../../map data/Testdrive_27_07_20 - Kopie.txt'); %Real data 
% R = load('../../map data/AllData_LL.txt'); %Real data 
% SaveAsOSM('AllData',R,2,1);
Ldata = R(2:end,4) - R(1:end-1,4);
Rdata = R(2:end,5) - R(1:end-1,5);
P = R(:,4)./R(:,5);
P2 = Ldata./Rdata;


% set NAN and infinite value as 1
NAN = isnan(P2);
INF = isinf(P2);
IndexNAN = find(NAN == 1);
IndexINF = find(INF == 1);
P2(IndexNAN) = 1;
P2(IndexINF) = 1;
P2(P2 == 0) = 1;

% Load map data
 
%% Filte Whole signal
WholeMid = MidFilter(9,P2,3); % Mid - value filter , to eliminate error
WholeGauss = GaussianFilter(5,1,WholeMid',5)'; % Gaussian filter, to smooth shape
f1 = figure('Name','Whole Signal,Middel Filter first then Gaussian Filter');
figure(f1)
hold on 
    plot(R(2:end,1)-R(2,1),P2,'b')
    plot(R(2:end,1)-R(2,1),WholeMid,'y')  
    plot(R(2:end,1)-R(2,1),WholeGauss,'r')  
    xlabel('WholeSignal');
hold off

f5 = figure('Name', 'Trajectory');
figure(f5)
hold on
    plot(R(2:end,6),R(2:end,7))
hold off

%% Sliding window and detect
Time = R(2:end,1)-R(2,1);
Ratio = P2;
f3 = figure('Name','Sliding Window');
f4 = figure('Name','Likelyhood');

%% Detect Interesting Part
% Parameter
LargeWindow = 150; % Large window to detect a large area,smooth data
Smallwindow = 19;  % Small window to detect the trend of signal whether it change a lot
MoveF = 1;
TS = 0.000011; %  Trend change Threshold
HalfLength = fix(LargeWindow/2);
RatioModified = [ones(HalfLength,1);Ratio;ones(HalfLength,1)]; % Add enough 1 at empty area;
TimeExtend = linspace(0,HalfLength/10,HalfLength)';
TimeModified = [TimeExtend - HalfLength/10 - 0.1 ; Time ; TimeExtend + Time(end)];
i = 1 + HalfLength;
K1 = 0; K2 = 0;
Kall = [];fArea = [];
StartPoint = 0 ; EndPoint = 0;
RSmoothed = [];
% Real time simulation
while i + Smallwindow <= length(P2) + LargeWindow
% LargePart to filte related signal
    LargePart = MidFilter(9,RatioModified(i - HalfLength:i + HalfLength - 1),5);% (i - HalfLength) is the location in original data
    LargePart = GaussianFilter(5,1,LargePart',5)';% Midfilter for deleting outliar, GuassianFilter for smoothing signal
    RSmoothed(i - HalfLength) = LargePart(HalfLength + 1);
% Detected Part to detect change
    DetectPart = LargePart( HalfLength + 1: HalfLength + 1 + Smallwindow); % Detect the chang of signal
    DetectResult = var(DetectPart)
    
    
    figure(f3) % Show Sliding Window
    clf(figure(f3))
    hold on
    plot(TimeModified(i - HalfLength:i + HalfLength - 1),LargePart,'b')
    plot(TimeModified(i : i + Smallwindow),DetectPart,'r')
    hold off    

    figure(f5) % Show Trakectory Window
    clf(figure(f5))
    hold on
    plot(R(2:end,6),R(2:end,7),'b')
    plot(R(i - HalfLength:i - HalfLength + Smallwindow,6),R(i - HalfLength:i - HalfLength + Smallwindow,7),'r')
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
        EndPoint = i + Smallwindow;
        fLen = EndPoint - StartPoint + 1;
        [TR,TF,SR,SF] = GenerateModels(fLen);
    end
    
    if StartPoint ~=0 && EndPoint ~= 0
        UnknowPart = RatioModified(StartPoint:EndPoint);
%         plot(TimeModified(StartPoint:EndPoint),RatioModified(StartPoint:EndPoint))
        [DTR,DTF,DSR,DSF] = Recognize(UnknowPart,TR,TF,SR,SF);
        X = categorical({'Turn Right','Turn Left','Switch Right','Switch Left'});
        X = reordercats(X,{'Turn Right','Turn Left','Switch Right','Switch Left'});
        Y = [DTR,DTF,DSR,DSF];
        
        figure(f4)
        subplot(1,2,1)
        plot(TimeModified(StartPoint:EndPoint),RatioModified(StartPoint:EndPoint),'b')
        subplot(1,2,2)
        bar(X,Y)
        
        StartPoint = 0 ; EndPoint = 0;
    end

    
    K1 = K2;
    i = i + MoveF;
end
