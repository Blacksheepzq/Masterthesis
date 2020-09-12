function SaveAsOSM2(name,data)
% function splitline(name,data)
% %TRANSFER ������ĵ�·�������ݰ���GPS�źźû����зֶΣ�
% nameΪ��󱣴�ɵ��ļ�����dataΪ�������ݣ�����γ�ȣ�����,GPS״̬λ�����ݸ�ʽΪ��һ��γ�ȣ��ڶ��о��ȣ�������Ϊ״̬λ��Ĭ��Ϊ5��11Ϊ״̬���ã�

% Transfer data to XML(OSM) file 
% Name is the saved file's name (like, 'NewFile')
% data is import data. a,b are longitude and latitude line in original file
% (For example: First and second are lon and lat,then a,b is 1 and 2)

n = length(data);
% ����һ�����Ⱥ�ԭ������ͬ��0����
% ����������У��źźõĵ��Ϊ1�����зֶ�
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
 
%% �ֶδ洢way
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
