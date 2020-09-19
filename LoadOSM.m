function [NodeData,WayData,RelationData] = LoadOSM(name)
% Load OSM file, name is target file
% Export relation, way, node
%%
% read xml
OsmDoc = xmlread(name);

% create a array for node data,first is id,second line is lat,third line is lon-------------
% all data form are double 
NodeArray = OsmDoc.getElementsByTagName('node');
NodeData = [NodeArray.getLength,3];
for i = 0:NodeArray.getLength -1
    NodeData(i+1,1) = str2double(NodeArray.item(i).getAttribute('id'));
    NodeData(i+1,2) = str2double(NodeArray.item(i).getAttribute('lat'));
    NodeData(i+1,3) = str2double(NodeArray.item(i).getAttribute('lon'));
end

% create a struct for way data,first line is id,second line is nd node-----------------------
WayArray = OsmDoc.getElementsByTagName('way');
WayData = struct('ID',[],'Nodes',cell(1,1));
for i = 0:WayArray.getLength -1
    ndLength = WayArray.item(i).getElementsByTagName('nd').getLength;   %count the number of nd node in this way
    nd = cell(ndLength,1);
    WayData(i+1).ID = str2double(WayArray.item(i).getAttribute('id'));
    
    for j = 0:ndLength-1
        nd{j+1,1} = str2double(WayArray.item(i).getElementsByTagName('nd').item(j).getAttribute('ref'));
    end     
    WayData(i+1).Nodes =  nd;
end

% create a struct for relation data , first line is id,second line is member,third line is tags
% second line will have two member(2 rows),save in a (2,1) cell,
    % first row is left way id, second row is right way id
% third line will have 2 tags(2 rows), each tag save in a cell 
    % first tag will be lanes
    % second tag is Nextlane

RelationArray = OsmDoc.getElementsByTagName('relation');
% RelationData = cell(RelationArray.getLength,3);
RelationData = struct('ID',[],'Member',cell(1,1),'Tag',cell(1,1));
for i = 0 : RelationArray.getLength - 1
    % ID
    RelationData(i+1).ID = str2double(RelationArray.item(i).getAttribute('id'));
    % save member data
    Member = cell(2,1); 
    for j = 0 : RelationArray.item(i).getElementsByTagName('member').getLength -1
        if RelationArray.item(i).getElementsByTagName('member').item(j).getAttribute('role') == 'left'
           Member{1,1} = str2double(RelationArray.item(i).getElementsByTagName('member').item(j).getAttribute('ref')); % save left way id
        else
           Member{2,1} = str2double(RelationArray.item(i).getElementsByTagName('member').item(j).getAttribute('ref')); % save right way id
        end
    end
     RelationData(i+1).Member = Member;
     % save tag data
     Tag = cell(2,1); 
     for j = 0 : RelationArray.item(i).getElementsByTagName('tag').getLength -1
         if RelationArray.item(i).getElementsByTagName('tag').item(j).getAttribute('k') == 'lanes'
             Tag{1,1} = RelationArray.item(i).getElementsByTagName('tag').item(j).getAttribute('v');
         elseif RelationArray.item(i).getElementsByTagName('tag').item(j).getAttribute('k') == 'Nextlane'
             Tag{2,1} = RelationArray.item(i).getElementsByTagName('tag').item(j).getAttribute('v');
         end
     end
     RelationData(i+1).Tag = Tag;
end
end
%%