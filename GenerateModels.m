function [TR,TL,SR,SL] = GenerateModels(s,Smallwindow)
%function:according to the size of sliding window to generate related model
%         Including switch left, switch right, turn right, turn left
% s: Model size

%% Straight part is not necessary
% SP = zeros(s,1);
%% Turn Right
Line = fix(Smallwindow/2);
Curve = s - 2 * Line;
xTR = linspace(0,pi,Curve);
yTR = sin(xTR) + 1;
TR = [ones(1,Line),yTR,ones(1,Line)];
TR = MeanFilter(5,TR,5)' - 1;

%% Turn Left
Line = fix(Smallwindow/2);
Curve = s - 2 * Line;
xTF = linspace(pi,2*pi,Curve);
yTF = sin(xTF) + 1;
TL = [ones(1,Line),yTF,ones(1,Line)];
TL = MeanFilter(5,TL,5)' - 1;

%% Switch Right
Line = fix(Smallwindow/2);
Curve = s - 2 * Line;
xSR = linspace(0,2*pi,Curve);
ySR = sin(xSR) + 1;
SR = [ones(1,Line),ySR,ones(1,Line)];
SR = MeanFilter(5,SR,5)' - 1;

%% Switch Right
Line = fix(Smallwindow/2);
Curve = s - 2 * Line;
xSF = linspace(-pi,pi,Curve);
ySF = sin(xSF) + 1;
SL = [ones(1,Line),ySF,ones(1,Line)];
SL = MeanFilter(5,SL,5)' - 1;

% f2 = figure('Name','Signal Model');
% figure(f2)
% hold on
% subplot(2,2,1)
% plot(x,TR);
% title('FeatureModel 1: Turn Right')
% 
% subplot(2,2,2)
% plot(x,TL);
% title('FeatureModel 2: Turn Left')
% 
% subplot(2,2,3)
% plot(x,SR);
% title('FeatureModel 3: Switch Right')
% 
% subplot(2,2,4)
% plot(x,SL);
% title('FeatureModel 4: Switch Left')
% hold off
end

