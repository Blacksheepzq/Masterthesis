function [Straight,TR,TF,SR,SF] = GenerateModels(s)
%function:according to the size of sliding window to generate related model
%         Including straight line, switch left, switch right, turn right
%         ,turn left
% s: Model size
% The form of output data are same:first line is x coordinates.second line
% is y coordinates
x = (1:s)';

%% Straight part
Straight = ones(s,1) - 1;

%% Turn Right
Line = fix(s/5);
Curve = s - 2 * Line;
xTR = linspace(0,pi,Curve);
yTR = sin(xTR) + 1;
TR = [ones(1,Line),yTR,ones(1,Line)];
TR = MeanFilter(5,TR,5)' - 1;

%% Turn Left
Line = fix(s/5);
Curve = s - 2 * Line;
xTF = linspace(pi,2*pi,Curve);
yTF = sin(xTF) + 1;
TF = [ones(1,Line),yTF,ones(1,Line)];
TF = MeanFilter(5,TF,5)' - 1;

%% Switch Right
Line = fix(s/5);
Curve = s - 2 * Line;
xSR = linspace(0,2*pi,Curve);
ySR = sin(xSR) + 1;
SR = [ones(1,Line),ySR,ones(1,Line)];
SR = MeanFilter(5,SR,5)' - 1;

%% Switch Right
Line = fix(s/5);
Curve = s - 2 * Line;
xSF = linspace(-pi,pi,Curve);
ySF = sin(xSF) + 1;
SF = [ones(1,Line),ySF,ones(1,Line)];
SF = MeanFilter(5,SF,5)' - 1;

f2 = figure('Name','Signal Model');
figure(f2)
hold on
subplot(2,3,1)
plot(x,Straight);
title('FeatureModel 1: Straight part')

subplot(2,3,2)
plot(x,TR);
title('FeatureModel 2: Turn Right')

subplot(2,3,3)
plot(x,TF);
title('FeatureModel 3: Turn Left')

subplot(2,3,4)
plot(x,SR);
title('FeatureModel 4: Switch Right')

subplot(2,3,5)
plot(x,SF);
title('FeatureModel 5: Switch Left')
hold off
end

