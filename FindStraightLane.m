function [PresentID,Lanes,NextLanes,LaneDistance] = FindStraightLane(NextLanes,RelationData)
% when NextLane has mutiply possiblities and pattern detection has no
% result then the vehicle must be going straight, this function is aim to find that straight lane
AngleChange = zeros(length(NextLanes),1);
for i = 1:length(NextLanes)
   loc = ismember([RelationData.ID],NextLanes(i))==1; 
   AngleOfRelation = RelationData(loc).AngleOfRelation;
   Change = sum(diff(AngleOfRelation));
   AngleChange(i) = Change;
end
PresentID = NextLanes(AngleChange == min(AngleChange));
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

