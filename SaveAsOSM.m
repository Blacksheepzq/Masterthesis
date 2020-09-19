function SaveAsOSM(name,data,a,b)
% Transfer data to XML(OSM) file 
% Name is the saved file's name (like, 'NewFile')
% data is import data. a,b are longitude and latitude line in original file
% (For example: First and second columns are lon and lat,then a,b is 1 and 2)

n = length(data);
tempname = char(name) ; 
docNode = com.mathworks.xml.XMLUtils.createDocument('osm')  ;
docRootNode = docNode.getDocumentElement;  
docRootNode.setAttribute('generator','zzq');
docRootNode.setAttribute('version','0.6'); 


for i = 1:n
    thisElement = docNode.createElement('node');   
    docRootNode.appendChild(thisElement);  
    thisElement.setAttribute('id',(sprintf('%d',i)));
    thisElement.setAttribute('lat',(sprintf('%12.15f',data(i,a))));
    thisElement.setAttribute('lon',(sprintf('%12.15f',data(i,b))));
    thisElement.setAttribute('version','4');
    thisElement.setAttribute('visible','true');
end
 
    thatElement = docNode.createElement('way');   
    docRootNode.appendChild(thatElement);  
    thatElement.setAttribute('id','1');
    thatElement.setAttribute('version','4');
    thatElement.setAttribute('visible','true');  
%      for i = n:length(m)
     for i = 1:n
    thirdElement = docNode.createElement('nd');   
    thatElement.appendChild(thirdElement); 
    thirdElement.setAttribute('ref',(sprintf('%d',i)))
     end
xmlFileName = [tempname,'.osm'];  
xmlwrite(xmlFileName,docNode);  
type(xmlFileName);  
end

