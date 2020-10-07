function PlotRelation(PresentID,NextLanes,WayData,RelationData)
% PLOTRELATION 
% ATTENTION: it is necessary to load map data first!!
% plot relations on the map
% 
loc = find(ismember([RelationData.ID],PresentID)==1);
Left = RelationData(loc).Member{1};
Right = RelationData(loc).Member{2};
LeftData = cell2mat(WayData(ismember([WayData.ID],Left)).Nodes);
RightData = cell2mat(WayData(ismember([WayData.ID],Right)).Nodes);
plot(LeftData(:,2),LeftData(:,3),'k-o',RightData(:,2),RightData(:,3),'k-o')
if NextLanes ~= 0
    for i = 1:length(NextLanes)
        loc = find(ismember([RelationData.ID],NextLanes(i))==1);
        Left = RelationData(loc).Member{1};
        Right = RelationData(loc).Member{2};
        LeftData = cell2mat(WayData(ismember([WayData.ID],Left)).Nodes);
        RightData = cell2mat(WayData(ismember([WayData.ID],Right)).Nodes);
        plot(LeftData(:,2),LeftData(:,3),'b-o',RightData(:,2),RightData(:,3),'b-o')
    end
end
end

