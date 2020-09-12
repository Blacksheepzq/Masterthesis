function [NodeStruct,WayStruct,RelationStruct] = LoadOSM(name)
% Load OSM file, name is target file£¬save as cell structure
% Export relation, way, node
%%
% read xml
OsmDoc = xmlread(name);

% create a cell struct for node data,first is id,second line is lat,third line is lon-------------
% all data form are double 
NodeArray = OsmDoc.getElementsByTagName('node');
NodeStruct = [NodeArray.getLength,3];
for i = 0:NodeArray.getLength -1
    NodeStruct(i+1,1) = str2double(NodeArray.item(i).getAttribute('id'));
    NodeStruct(i+1,2) = str2double(NodeArray.item(i).getAttribute('lat'));
    NodeStruct(i+1,3) = str2double(NodeArray.item(i).getAttribute('lon'));
end

% create a cell struct for way data,first line is id,second line is nd node-----------------------
% all data form are double
WayArray = OsmDoc.getElementsByTagName('way');
WayStruct = cell(WayArray.getLength,2); 
for i = 0:WayArray.getLength -1
    ndLength = WayArray.item(i).getElementsByTagName('nd').getLength;   %count the number of nd node in this way
    nd = cell(ndLength,1);
    WayStruct{i+1,1} = str2double(WayArray.item(i).getAttribute('id'));
    
    for j = 0:ndLength-1
        nd{j+1,1} = str2double(WayArray.item(i).getElementsByTagName('nd').item(j).getAttribute('ref'));
    end     
    WayStruct{i+1,2} =  nd;
    WayStruct{i+1,3} = str2double(WayArray.item(i).getAttribute('status'));
end

% create a cell struct for relation data {relation number,3}, first line is id,second line is member,third line is tags
% second line will have two member(2 rows),save in a (2,1) cell,
    % first row is way id,
% third line will have 4 tags(4 rows), each tag save in a (4,1) cell 
    % first tag will be lanes
    % second tag is speed
    % third tag is type
    % fourth tag is road_level
% lanes , type data form is string, others are double

RelationArray = OsmDoc.getElementsByTagName('relation');
RelationStruct = cell(RelationArray.getLength,3);
for i = 0 : RelationArray.getLength - 1
    
    RelationStruct{i+1,1} = str2double(RelationArray.item(i).getAttribute('id'));
    Member = cell(2,1); % save member data
    for j = 0 : RelationArray.item(i).getElementsByTagName('member').getLength -1
        if RelationArray.item(i).getElementsByTagName('member').item(j).getAttribute('role') == 'left'
           Member{1,1} = str2double(RelationArray.item(i).getElementsByTagName('member').item(j).getAttribute('ref')); % save left way id
        else
           Member{2,1} = str2double(RelationArray.item(i).getElementsByTagName('member').item(j).getAttribute('ref')); % save right way id
        end
    end
     RelationStruct{i+1,2} = Member;
     
     Tag = cell(4,1); % save tag data
     for j = 0 : RelationArray.item(i).getElementsByTagName('tag').getLength -1
         if RelationArray.item(i).getElementsByTagName('tag').item(j).getAttribute('k') == 'lanes'
             Tag{1,1} = RelationArray.item(i).getElementsByTagName('tag').item(j).getAttribute('v');
         elseif RelationArray.item(i).getElementsByTagName('tag').item(j).getAttribute('k') == 'speed'
             Tag{2,1} = str2double(RelationArray.item(i).getElementsByTagName('tag').item(j).getAttribute('v'));
         elseif RelationArray.item(i).getElementsByTagName('tag').item(j).getAttribute('k') == 'type'
             Tag{3,1} = RelationArray.item(i).getElementsByTagName('tag').item(j).getAttribute('v');
         elseif RelationArray.item(i).getElementsByTagName('tag').item(j).getAttribute('k') == 'road_level'
             Tag{4,1} = str2double(RelationArray.item(i).getElementsByTagName('tag').item(j).getAttribute('v'));
         end
     end
     RelationStruct{i+1,3} = Tag;
end
end
%%