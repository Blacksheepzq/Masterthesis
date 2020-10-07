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
% load('Target.mat'); %Real data 
% R = Target;
% SaveAsOSM('AllData',R,2,1);
VL = R(2:end,4) - R(1:end-1,4);
VR = R(2:end,5) - R(1:end-1,5);
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

% Load and process map data
[NodeData,WayData,RelationData] = LoadOSM('../../map data/Map_Boundary.osm');
[NodeData,WayData,RelationData] = PreProcessMapData(NodeData,WayData,RelationData);
[OriginRelationID,OriginLocData] = FindLocation(NodeData,WayData,RelationData,R(1,6),R(1,7));
RestDistance = OriginLocData(1) * (1 - OriginLocData(2)); % After figure out start point location then how far it is to next lane
% scatter(NodeData(:,4),NodeData(:,5));

% odo parameter
xy = R(:,6:7);
seglen = sqrt(sum(diff(xy,[],1).^2,2));
GPSDis = sum(seglen);
% KL = 0.00281377367;
% KR = 0.00281570245;
KL = 0.003077;
KR = 0.003083;
%% Filte Whole signal for show
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

% Sliding window and detect
Time = R(2:end,1)-R(2,1);
Ratio = P2;
f3 = figure('Name','Sliding Window');
f4 = figure('Name','Likelyhood');

%% Detect Pattern Part
% Parameter
LargeWindow = 150; % Large window to detect a large area,smooth data
SmallWindow = 19;  % Small window to detect the trend of signal whether it change a lot
MoveF = 1; % step length, each time input a row data
TS = 0.0000015; %  Trend change Threshold, 0.0000015 is worked in Target1
HalfLength = fix(LargeWindow/2); % add half length of large window to before starting and after ending part
RatioModified = [ones(HalfLength,1);Ratio;ones(HalfLength,1)]; % Add enough 1 at empty area;
TimeExtend = linspace(0,HalfLength/10,HalfLength)';
TimeModified = [TimeExtend - HalfLength/10 - 0.1 ; Time ; TimeExtend + Time(end)];
i = 1 + HalfLength; % (i - HalfLength) is the location in original data
NormalStartPoint = i;
K1 = 0; K2 = 0; % Triger of segment detection
Kall = [];
PatternStartPoint = 0 ; PatternEndPoint = 0;
StraightStartPoint = 1 + HalfLength; StraightEndPoint = StraightStartPoint;
PresentID = OriginRelationID; 
Lanes = RelationData(ismember([RelationData.ID],PresentID)).Tag{1}; Lanes = str2double(strsplit(string(Lanes),'.'));
NextLanes = RelationData(ismember([RelationData.ID],PresentID)).Tag{2}; NextLanes = str2double(strsplit(string(NextLanes),'.'));
RSmoothed = [];
PatternDistance = 0;DriveDistance = 0;
SignalLength = length(P2) + HalfLength + 1;
%% Real time simulation
while i + SmallWindow <= SignalLength
%% Smooth data part 
% LargePart to filte related signal
    LargePart = MidFilter(9,RatioModified(i - HalfLength:i + HalfLength - 1),5);% (i - HalfLength) is the location in original data
    LargePart = GaussianFilter(5,1,LargePart',5)';% Midfilter for deleting outliar, GuassianFilter for smoothing signal

% Detected Part to detect change
    DetectPart = LargePart( HalfLength + 1: HalfLength + 1 + SmallWindow); % Detect the chang of signal
    DetectResult = var(DetectPart)
    RSmoothed(i - HalfLength:i - HalfLength + SmallWindow) = DetectPart;
    
%% Segmentation part 
if DetectResult > TS
   K2 = 1;   
elseif DetectResult <= TS
   K2 = 0;       
end

Kall = [Kall K2];
Kd = K2 - K1;

if Kd == 1
    PatternStartPoint = i; % find when and where the signal changes
elseif Kd == -1
    PatternEndPoint = i + SmallWindow;
    fLen = PatternEndPoint - PatternStartPoint + 1;
    [TR,TF,SR,SF] = GenerateModels(fLen,SmallWindow);
    StraightStartPoint = PatternEndPoint;
end

 
%% Recongition and calculation
if PatternStartPoint ~=0 && PatternEndPoint ~= 0
%         UnknowPart = RatioModified(StartPoint:EndPoint);
    UnknowPart = RSmoothed(PatternStartPoint - HalfLength:PatternEndPoint - HalfLength);
    RelatedData = R(PatternStartPoint - HalfLength :PatternEndPoint - HalfLength,:);
    [DTR,DTL,DSR,DSL] = Recognize(UnknowPart,TR,TF,SR,SF);
    X = categorical({'Turn Right','Turn Left','Switch Right','Switch Left'});
    X = reordercats(X,{'Turn Right','Turn Left','Switch Right','Switch Left'});
    Y = [DTR,DTL,DSR,DSL]; Type = find(Y == min(Y)); % point out the result;1 for turn right,2 for turn right
    [ForwardDis,SideDis,Angle] = PatterDistanceCalculation(RelatedData,UnknowPart,KL);
%     PatternDistance = ForwardDis;
    PatternDistance = ((RelatedData(end,4) - RelatedData(1,4))*KL + (RelatedData(end,5) - RelatedData(end,5))*KR) / 2;
    
    figure(f4)
    subplot(1,2,1)
    plot(TimeModified(PatternStartPoint:PatternEndPoint),UnknowPart,'b')
    subplot(1,2,2)
    bar(X,Y)
    
    PatternStartPoint = 0 ; PatternEndPoint = 0;
end
    
%% Distance and location calculation  
if PatternDistance == 0 % when car go straight and did not detect switching or turning
   while DriveDistance >= RestDistance  % is it in next lane?
       if length(NextLanes) == 1 % how many possible of next lane? 1 or more? 
           %Updata relation id information
           PresentID = NextLanes;% change the car location relation now
           [Lanes,NextLanes,LaneDistance] = IDRelateData(PresentID,RelationData);               
           DriveDistance = DriveDistance - RestDistance;
           RestDistance = LaneDistance - DriveDistance;
           StraightStartPoint = i + SmallWindow;
        elseif length(NextLanes) >1 
           [PesentID] = FindStraightLane(NextLanes,RelationData);
           [Lanes,NextLanes,LaneDistance] = IDRelateData(PresentID,RelationData); 
           DriveDistance = DriveDistance - RestDistance;
           RestDistance = LaneDistance - DriveDistance;
           StraightStartPoint = i + SmallWindow;
       end
   end
   
elseif  PatternDistance ~= 0
    RestDistance = LaneDistance - DriveDistance;
    PresentLoc = find(Lanes == PresentID);
    if Type == 3 % switch right        
        if PresentLoc ~= length(Lanes) % if the relation is not the rightest one ,then switch to right lane
            PresentID = Lanes(PresentLoc + 1);
            [Lanes,NextLanes,LaneDistance] = IDRelateData(PresentID,RelationData);
        end
        if RestDistance > PatternDistance
           RestDistance = RestDistance - PatternDistance;
        elseif RestDistance <= PatternDistance
            if length(NextLanes) == 1 % how many possible of next lane? 1 or more?                
               PresentID = NextLanes;% change the car location relation now
               [Lanes,NextLanes,LaneDistance] = IDRelateData(PresentID,RelationData);               
               PatternDistance = PatternDistance - RestDistance;
               RestDistance = LaneDistance - PatternDistance;
               StraightStartPoint = i + SmallWindow;
            elseif length(NextLanes) >1 
               [PesentID,Lanes,NextLanes,LaneDistance] = FindStraightLane(NextLanes,RelationData);
               PatternDistance = PatternDistance - RestDistance;
               RestDistance = LaneDistance - PatternDistance;
               StraightStartPoint = i + SmallWindow;
           end
        end

    elseif Type == 4 % switch left
        if PresentLoc ~= 1 % if the relation is not the leftest one ,then switch to left lane
            PresentID = Lanes(PresentLoc - 1);
            [Lanes,NextLanes,LaneDistance] = IDRelateData(PresentID,RelationData); 
        end
        if RestDistance > PatternDistance
           RestDistance = RestDistance - PatternDistance;
        elseif RestDistance <= PatternDistance
            if length(NextLanes) == 1 % how many possible of next lane? 1 or more?                
               PresentID = NextLanes;% change the car location relation now
               [Lanes,NextLanes,LaneDistance] = IDRelateData(PresentID,RelationData);               
               PatternDistance = PatternDistance - RestDistance;
               RestDistance = LaneDistance - PatternDistance;
               StraightStartPoint = i + SmallWindow;
            elseif length(NextLanes) >1 
               [PesentID,Lanes,NextLanes,LaneDistance] = FindStraightLane(NextLanes,RelationData);
               PatternDistance = PatternDistance - RestDistance;
               RestDistance = LaneDistance - PatternDistance;
               StraightStartPoint = i + SmallWindow;
           end
        end
    elseif Type == 1 || Type == 2 %turn right or turn left
           [PresentID,Lanes,NextLanes,LaneDistance] = MatchTurning(Lanes,NextLanes,RelationData,Angle,SmallWindow);
           RestDistance = LaneDistance - DriveDistance;
        if RestDistance > PatternDistance
           RestDistance = RestDistance - PatternDistance;
        elseif RestDistance <= PatternDistance
            if length(NextLanes) == 1 % how many possible of next lane? 1 or more?                
               PresentID = NextLanes;% change the car location relation now
               [Lanes,NextLanes,LaneDistance] = IDRelateData(PresentID,RelationData);               
               PatternDistance = PatternDistance - RestDistance;
               RestDistance = LaneDistance - PatternDistance;
               StraightStartPoint = i + SmallWindow;
            elseif length(NextLanes) >1 
               [PesentID,Lanes,NextLanes,LaneDistance] = FindStraightLane(NextLanes,RelationData);
               PatternDistance = PatternDistance - RestDistance;
               RestDistance = LaneDistance - PatternDistance;
               StraightStartPoint = i + SmallWindow;
           end
        end
    end
end
    
    
 %% Draw the situation now        
    figure(f3) % Show Sliding Window
    clf(figure(f3))
    hold on
    plot(TimeModified(i - HalfLength:i + HalfLength - 1),LargePart,'b')
    plot(TimeModified(i : i + SmallWindow),DetectPart,'r')
    hold off    

    figure(f5) % Show Trakectory Window
    clf(figure(f5))
    hold on
    title(['Present Location:' ,num2str(PresentID), ', Next possible location:',num2str(NextLanes)])
    plot(R(2:end,6),R(2:end,7),'b')
    plot(R(i - HalfLength:i - HalfLength + SmallWindow - 1 ,6),R(i - HalfLength:i - HalfLength + SmallWindow - 1,7),'r')
    PlotRelation(PresentID,NextLanes,WayData,RelationData)
    hold off 
    
%% finish this loop, Clear data and step into next loop
if K2 == 0
    StraightEndPoint = i + SmallWindow;
    DriveDistance = (R(StraightEndPoint  - HalfLength,4) - R(StraightStartPoint - HalfLength,4)) * KL;
end   
    PatternDistance = 0;
    K1 = K2;
    i = i + MoveF;
end
