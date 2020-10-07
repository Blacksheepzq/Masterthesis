function [PresentID,Lanes,NextLanes,LaneDistance] = MatchTurning(Lanes,NextLanes,RelationData,Angle,SmallWindow)
% When pattern is a turning situation, match and find the most similar one
Possibility = [Lanes NextLanes];
Possibility(Possibility == 0) = [];% for now 0 means there is no further lane
Similarity = zeros(1,length(Possibility));
Angle(1:SmallWindow) = []; Angle(end - SmallWindow:end) = [];
for i = 1:length(Possibility)
    loc = ismember([RelationData.ID],Possibility(i))==1;
    AngleOfRelation = RelationData(loc).AngleOfRelation;
    AngleOfRelation = AngleOfRelation(:) - AngleOfRelation(1);
    xInter = linspace(1,length(AngleOfRelation),length(Angle));
    vInter = interp1(1:length(AngleOfRelation),AngleOfRelation,xInter);
%     plot(1:length(Angle),Angle,'r',1:length(Angle),vInter,'b')
    Difference = norm(Angle - vInter');
    Similarity(i) = Difference;
end
PresentID = Possibility(Similarity == min(Similarity));
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

