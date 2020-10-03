function [PresentID] = FindStraightLane(NextLanes,RelationData)
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
end

