function t = computeRegionPropsForEmpty()
% This function takes an image and returns a table of properties for all
% disconnected blobs in the image. 
t = table(0,0,0,0,0,0,0,0,0,0,2);
t.Properties.VariableNames = {'MajorAxisLength','MinorAxisLength',...
    'Eccentricity','ConvexImage','Circularity','Image','EquivDiameter',...
    'Solidity','Perimeter','Convexity','Outlier'};


end
