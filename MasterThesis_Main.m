%% Master Thesis : Lane switch dection by odo
% Author: Zhang,Ziqiang

%% Initialization and Data Loading
clc; close all;clear all;
% run MasterThese_Initialization.m
addpath(genpath('.'))
R = load('../data/red box/R3.txt');
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

% figure(1)
% hold on 
%     plot(R(2:end,1)-R(2,1),P2,'b')
% %     plot(R(2:end,1)-R(2,1),Gauss,'g')
%     plot(R(2:end,1)-R(2,1),GaussN,'r')
%     plot(x,y,'g')
%     xlabel('Gauss');
% hold off

a = x(1:2:end-1);
b = x(2:2:end);
xM = (a + b)/2;
P2M = (P2(1:2:end-1) + P2(2:2:end))/2;
xM2 = xM(1:5:end);P2M2 = P2M(1:5:end);
% figure(2)
% plot(x,P2,'b',xM,P2M,'g',xM2,P2M2,'r')


%% set up sliding window parameters
Len = 99 ;% Window length, Length must larger than 5
MoveF = 1;% Move frequence, 1 means move 1s per time
% Generate pattern model
[Straight,TR,TF,SR,SF] = GenerateModels(Len+1);

%% Sliding window and detect
Time = R(2:end,1)-R(2,1);
Ratio = P2;

i = 1;
while i + Len -1 <= length(Time)
figure(3)
hold on
%     plot(Time,Ratio,'b',Time(i:i + Len),Ratio(i:i + Len),'g')              % plot whole/window data
%     plot(Time(i:i + Len),Ratio(i:i + Len),'g') 
%     Filted = GaussianFilter(5,1,Ratio(i:i + Len)',10)'; % Filte window data
    Filted = MidFilter(9,Ratio(i:i + Len),5);
    Filted = GaussianFilter(5,1,Filted',5)';
%     Filted = MeanFilter(5,Ratio(i:i + Len)',1)';
    
    plot(Time(i:i + Len),Filted,'r');            % plot filted result

hold off
    i = i + 10;
end
    