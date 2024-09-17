function t = computeRegionProps(image)
% This function takes an image and returns a table of properties for all
% disconnected blobs in the image. 
t = regionprops('table',image,'EquivDiameter','MajoraxisLength',...
    'MinoraxisLength','Circularity','Eccentricity','Solidity',...
    'Perimeter','ConvexImage','Image');

for i=1:height(t)
   cp = regionprops(t(i,:).ConvexImage{1},'Perimeter');
   t{i,'Convexity'} = t{i,'Perimeter'}/cp.Perimeter;
end
end

