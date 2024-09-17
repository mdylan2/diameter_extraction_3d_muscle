function [grayImage] = convertPCACoordinatesToImage(x,y,size_)
% This function takes projected PCA coordinates and converts them into an 
% image
% Inputs:
%   x: projected x coordinates
%   y: projected y coordinates
% Outputs:
%   largeGrayImage: an array representing the 2D image assuming all
%   coordinates get rounded up
%   smallGrayImage: an array representing the 2D image assuming all
%   coordinates get rounded down

% Move the x and y coordinates such that the bottom left corner of the 
% object is located at (1,1)
xnew = x - min(x) + 1;
ynew = y - min(y) + 1;

% The height and width of the image are maximum y and x respectively
rows = ceil(max(ynew(:)));
columns = ceil(max(xnew(:)));

% Create a 0 matrix of the size
grayImage = zeros(rows, columns, 'uint8');

if size_ == "large"
    % Loop through each coordinate and at the ceil of the coordinate 
    % location, make the object pixel value 1
    for k = 1 : length(ynew)
        row = ceil(xnew(k));
        col = ceil(ynew(k));
        grayImage(row, col) = 1;
    end
elseif size_ == "small"
    % Loop through each coordinate and at the floor of the coordinate 
    % location, make the object pixel value 1
    for k = 1 : length(ynew)
        row = floor(xnew(k));
        col = floor(ynew(k));
        grayImage(row, col) = 1;
    end    
end

% Hole filling in case there are any holes in the thresholded image
% Assumes a connectivity of 8
grayImage = imfill(grayImage,8,'holes');

end