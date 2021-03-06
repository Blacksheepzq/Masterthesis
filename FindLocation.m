function [OriginRelationID,OriginLocData] = FindLocation(NodeData,WayData,RelationData,X,Y)
% function to find out the starting point's location,including relation it
% belongs to and where it is (how  far to the end of the way)
% Input: X,Y are starting point's coordinates
% Output: OriginRelationID is the ID of relation, OriginLocData contain the
% whole distance of this relation and the ratio of distance of origin point
% about Ratio:for example: the distance is 100m, the ratio is 0.6, then it
% means the points is at 60m now;


Threshold = 3;% [m] the width of road is 3m
NearNodeX = find(abs(NodeData(:,4) - X) < Threshold);
NearNodeY = find(abs(NodeData(:,5) - Y) < Threshold);
NodeLoc =  intersect(NearNodeX,NearNodeY);
NodeID = NodeData(NodeLoc,1);
NearWayID = [];
% Find out ways which near the point within 5m
for i = 1:length(NodeID)   
    for j =1:size(WayData,2)
        if isempty(find(strcmp(string(WayData(j).Nodes),string(NodeID(i)))==1, 1)) == 0
            NearWayID = [NearWayID,WayData(j).ID];
        end
    end
end
NearWayID = unique(NearWayID);
NearRelation = [];
for i = 1:length(NearWayID)   
    for j =1:size(RelationData,2)
        if isempty(find(strcmp(string(RelationData(j).Member),string(NearWayID(i)))==1, 1)) == 0
            NearRelation = [NearRelation,RelationData(j).ID];
        end
    end
end
NearRelation = unique(NearRelation);
% find location in RelationData
loc = find(ismember([RelationData.ID] , NearRelation) == 1);
Dis = []; % record the distance and 
for i = 1:size(loc,2)
    Left = RelationData(loc(i)).Member{1};
    Right = RelationData(loc(i)).Member{2};
    LeftData = cell2mat(WayData(ismember([WayData.ID], Left) == 1).Nodes);
    RightData = cell2mat(WayData(ismember([WayData.ID], Right) == 1).Nodes);
    
    mapxy = [X,Y];% original point coordinates
    % Left way process
    curvexyL = [LeftData(:,2),LeftData(:,3)];
    seglenL = sum(sqrt(sum(diff(curvexyL,[],1).^2,2)));
    [xyL,PerpenDL,tL] = distance2curve(curvexyL,mapxy,'linear');
    
    % Right way process
    curvexyR = [RightData(:,2),RightData(:,3)];
    seglenR = sum(sqrt(sum(diff(curvexyR,[],1).^2,2)));
    [xyR,PerpenDR,tR] = distance2curve(curvexyR,mapxy,'linear');
    
    % find out perpendicular point, arc length(ratio) along the curve
    PerpenD = PerpenDL + PerpenDR;
    Dis = [Dis;PerpenD seglenL tL];
end
OriginRelationID = RelationData(loc(Dis(:,1) == min(Dis(:,1)))).ID;
OriginLocData = Dis(Dis(:,1) == min(Dis(:,1)),2:3);
end
