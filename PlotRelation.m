function PlotRelation(ID,WayData,RelationData)
% PLOTRELATION 
% ATTENTION: it is necessary to load map data first!!
% plot this relation on the map
% 

    for i = 1:length(ID)
        loc = find(ismember([RelationData.ID],ID(i))==1);
        Left = RelationData(loc).Member{1};
        Right = RelationData(loc).Member{2};
        LeftData = cell2mat(WayData(ismember([WayData.ID],Left)).Nodes);
        RightData = cell2mat(WayData(ismember([WayData.ID],Right)).Nodes);
        plot(LeftData(:,2),LeftData(:,3),'k-o',RightData(:,2),RightData(:,3),'k-o')
    end
end

