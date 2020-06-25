%% Master Thesis : Lane switch dection by odo
% Author: Zhang,Ziqiang

%% Initialization and Data Loading
clc; close all;clear all;
% run MasterThese_Initialization.m
addpath(genpath('.'))
R = load('../data/red box/toR R tR R toL tR L L R toL R L.txt');
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

% %% Midium value filter
% n = 5;
% Mid = medfilt1(P2,n);
% %% Mean Value Filter
% n = 5;
% mean = ones(1,n)./n;
% Mean = conv(P2,mean);
% Mean = Mean(3:end-2,1);
%% Gauss Filter
Gauss=GaussianFilter(5,1,P2');
Gauss = Gauss';
GaussN = Gauss;
for i = 1:10
    GaussN = (GaussianFilter(5,1,GaussN'))';
end
%%%%
%% plot
% figure(1)
% hold on
% plot(R(:,1), R(:,2),'r','DisplayName','Left Wheel')
% plot(R(:,1), R(:,3),'b','DisplayName','Right Wheel')
% xlabel('Time step')
% ylabel('Roll distance')
% hold off 
% 
% figure(2)
% hold on
% plot(R(:,1), P,'r','DisplayName','Distance Ratio')
% plot(R(2:end,1), P2,'b','DisplayName','Gap Ratio')
% plot(R(:,1),ones(length(R(:,1)),1),'g')
% xlabel('Time step')
% ylabel('Ratio of Left/Right')
% hold off
% 
% figure(3)
% hold on 
%     plot(R(2:end,1),P2,'b')
%     plot(R(2:end,1),Mid,'r')
%     xlabel('Midum');
% hold off
% figure(4)
% hold on 
%     plot(R(2:end,1),P2,'b')
%     plot(R(2:end,1),Mean,'r')
%     xlabel('Mean');
% hold off


x = R(2:end,1)-R(2,1); % xlabel time
y = GaussN; % ylabel Ratio
% x = x(1:4:end);y = y(1:4:end);
figure(5)
hold on 
    plot(R(2:end,1)-R(2,1),P2,'b')
%     plot(R(2:end,1)-R(2,1),Gauss,'g')
    plot(R(2:end,1)-R(2,1),GaussN,'r')
    plot(x,y,'g')
    xlabel('Gauss');
hold off

% 
% Theta = linspace(-pi,pi,200);
% ThetaAll = ones(length(x),1) * Theta;
% Rho = x .* cos(Theta) + y .* sin(Theta);
% figure(6)
% plot(ThetaAll',Rho')


a = x(1:2:end-1);
b = x(2:2:end);
xM = (a + b)/2;
P2M = (P2(1:2:end-1) + P2(2:2:end))/2;
xM2 = xM(1:5:end);P2M2 = P2M(1:5:end);
figure(7)

plot(x,P2,'b',xM,P2M,'g',xM2,P2M2,'r')



% x0 = R(2,1); y0 = GaussN(1);
% x1 = R(3,1); y1 = GaussN(2);
% x2 = R(100,1); y2 = GaussN(100);
% x3 = R(300,1); y3 = GaussN(300);
% x4 = R(500,1); y4 = GaussN(500);
% x = [x0,x1,x2,x3,x4]; y = [y0,y1,y2,y3,y4];
% x= x- x0;
% Theta = linspace(-pi,pi,200);
% P = x(1) * cos(Theta) + y0 * sin(Theta);
% P1 =  x(2) * cos(Theta) + y1 * sin(Theta);
% P2 =  x(3) * cos(Theta) + y2 * sin(Theta);
% P3 =  x(4) * cos(Theta) + y3 * sin(Theta);
% P4 =  x(5) * cos(Theta) + y4 * sin(Theta);
% figure(6)
% hold on
% plot(Theta,P)
% plot(Theta,P1)
% plot(Theta,P2)
% plot(Theta,P3)
% plot(Theta,P4)
% hold off
% T = ones(5,1) * Theta;
% Pall = [P;P1;P2;P3;P4];
% figure(7)
% plot(T',Pall')




    