function [Lanes,NextLanes,LaneDistance] = IDRelateData(PresentID,RelationData)
% According to PresentID search related information, lanes and nextlanes
if PresentID == 0
    Lanes = 0;
    NextLanes = 0;
else
Lanes = RelationData(ismember([RelationData.ID],PresentID)).Tag{1}; 
    Lanes = str2double(strsplit(string(Lanes),'.'));
NextLanes = RelationData(ismember([RelationData.ID],PresentID)).Tag{2}; 
    NextLanes = str2double(strsplit(string(NextLanes),'.'));
LaneDistance = RelationData(ismember([RelationData.ID],PresentID)).Distance;
end
end

