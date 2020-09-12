function SaveAsOSM2(name,data)
% function splitline(name,data)
% %TRANSFER 将导入的道路中线数据按照GPS信号好坏进行分段，
% name为最后保存成的文件名，data为导入数据（算了纬度，经度,GPS状态位，数据格式为第一列纬度，第二列经度，第三列为状态位，默认为5，11为状态良好）

% Transfer data to XML(OSM) file 
% Name is the saved file's name (like, 'NewFile')
% data is import data. a,b are longitude and latitude line in original file
% (For example: First and second are lon and lat,then a,b is 1 and 2)

n = length(data);
% 建立一个长度和原数据相同的0数组
% 在这个数组中，信号好的点改为1，进行分段
datacheck = zeros(size(data,1),1);
datacheck5 = find(data(:,3) == 5);
datacheck11 = find(data(:,3) == 11);
datacheck(datacheck5) = 1;
datacheck(datacheck11) = 1;

duan = {};
part = [];
d =1;i=1;
while i < length(datacheck)
   for j =i:length(datacheck)-1
       if datacheck(j+1) == datacheck(j)
          part = [part datacheck(j)];
          i = j;
       else
           i = j;
           break
       end
   end
   duan{d,1} = part;
   duan{d,2} = i;
   duan{d,3} = datacheck(i);
   part = [];
   i=i+1;d=d+1;
end
PartPoint = [0,0];
for i = 1:size(duan,1)
    PartPoint = [PartPoint;(duan{i,2}),(duan{i,3})];
end
PartPoint = PartPoint(2:end,:);
startpoint = ones(size(PartPoint,1),1);
startpoint(2:end,1)=PartPoint(1:end-1,1)+1;
PartPoint = [startpoint PartPoint];


tempname = name; 
docNode = com.mathworks.xml.XMLUtils.createDocument('osm')  ;
docRootNode = docNode.getDocumentElement;  
docRootNode.setAttribute('generator','zzq');
docRootNode.setAttribute('version','0.6'); 

%   for i =n:length(m)
for i = 1:n
    thisElement = docNode.createElement('node');   
    docRootNode.appendChild(thisElement);  
    thisElement.setAttribute('id',(sprintf('%d',i+200000)));
    thisElement.setAttribute('lat',(sprintf('%12.15f',data(i,1))));
    thisElement.setAttribute('lon',(sprintf('%12.15f',data(i,2))));
    thisElement.setAttribute('version','4');
    thisElement.setAttribute('visible','true');
end
 
%% 分段存储way
for i = 1:size(PartPoint,1)
    thatElement = docNode.createElement('way');   
    docRootNode.appendChild(thatElement);  
    thatElement.setAttribute('id',(sprintf('%d',i+20000000)));
    thatElement.setAttribute('version','4');
    thatElement.setAttribute('visible','true'); 
    thatElement.setAttribute('status',(sprintf('%d',PartPoint(i,3))));
%      for i = n:length(m)

     for j = 1:PartPoint(i,2) - PartPoint(i,1)+2
    thirdElement = docNode.createElement('nd');   
    thatElement.appendChild(thirdElement); 
    thirdElement.setAttribute('ref',(sprintf('%d',j + PartPoint(i,1)+200000)))
     end
end
xmlFileName = [tempname,'.osm'];  
xmlwrite(xmlFileName,docNode);  
type(xmlFileName);  
end
