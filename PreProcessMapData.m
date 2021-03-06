function [NodeData,WayData,RelationData] = PreProcessMapData(NodeData,WayData,RelationData)
%PREPROCESSMAPDATA Summary of this function goes here
%   After load map data, it is necessary to calculate some extra
%   information of map. such as Distance and direction change, coordinates
%   transformation

%% NodeStruct Process
% Transfer data from degree to UTM coordinates
% [NodeData,WayData,RelationData] = LoadOSM('../../map data/Map_Boundary.osm');
[NodeX,NodeY,Zone] = deg2utm(NodeData(:,2),NodeData(:,3));
NodeData(:,4) = NodeX; NodeData(:,5) = NodeY;
% scatter(NodeX,NodeY);

%% WayStruct Process
% Calculate the distance and angle change of each way
for i = 1:size(WayData,2)
    WayCoor = zeros(size(WayData(i).Nodes,1),3); % a temporary record way data record
    for j = 1:size(WayData(i).Nodes,1) % Find out each node's coordinates of a way
        Location = find(NodeData(:,1) == WayData(i).Nodes{j});
        WayCoor(j,1) = WayData(i).Nodes{j}; % id
        WayCoor(j,2) = NodeData(Location,4); % x
        WayCoor(j,3) = NodeData(Location,5); % y
        % insert coordinates back to WayData
        WayData(i).Nodes{j,2} = WayCoor(j,2);
        WayData(i).Nodes{j,3} = WayCoor(j,3);
    end
        % Calculate the distance and Angle change of this way
        % Distance part
        diffx = WayCoor(2:end,2) - WayCoor(1:end-1,2);
        diffy = WayCoor(2:end,3) - WayCoor(1:end-1,3);
        diffD = sqrt(diffx.^2 + diffy.^2);
        D = sum(diffD);
        WayData(i).Distence = D;
%         plot(WayCoor(:,2) , WayCoor(:,3))
        % Angle Part
        AngleOfTwoPoints = atan2(diffx,diffy) * 180 / pi;
        diffAngle = AngleOfTwoPoints(2:end) - AngleOfTwoPoints(1:end-1);
%         plot(1:length(AngleOfTwoPoints),AngleOfTwoPoints)
%         plot(1:length(diffAngle),diffAngle)
        WayData(i).AngleOfTwoPoints = AngleOfTwoPoints;
        WayData(i).AngleChange = diffAngle;
        AngleChange = abs(sum(diffAngle));
        if AngleChange >= 80
            WayData(i).Type = 'Turing';
        elseif AngleChange >= 20 && sum(diffAngle) < 80
            WayData(i).Type  = 'Curve';
        elseif AngleChange < 20
            WayData(i).Type  = 'Straight';
        end
end
%% RelateionStruct Process
% Calculate the central distance of this relation
for i = 1:size(RelationData,2)
    left = RelationData(i).Member{1};
    right = RelationData(i).Member{2};
    Distance = (WayData(ismember([WayData.ID],left)).Distence + WayData(ismember([WayData.ID],right)).Distence) / 2;
    RelationData(i).Distance = Distance; % [m]
    RelationData(i).AngleOfRelation = WayData(ismember([WayData.ID] , left)).AngleOfTwoPoints;
end


end