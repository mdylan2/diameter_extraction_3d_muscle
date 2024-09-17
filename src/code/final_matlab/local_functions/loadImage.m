% This file contains functions to load a TIFF image. Assumes only one image
% in the series. This function will only extract the first series 
% Inputs: 
%   filepath: Location of the image in char format. Image must be a 
%             one-channel TIFF image
% Outputs:
%   image: A 3D image
%   spacing: Voxel spacing in [x,y,z]
%   units: string of units
% Reference: https://docs.openmicroscopy.org/bio-formats/5.7.2/developers/matlab-dev.html
function [image, spacing, omeMeta] = loadImage(filepath)
    data = bfopen(filepath); % Open the filepath
    
    series1 = data{1,1}; % data{1,1} contains the first series
    
    omeMeta = data{1,4}; % contains the omeMetadata
    stackSizeX = omeMeta.getPixelsSizeX(0).getValue(); % size x
    stackSizeY = omeMeta.getPixelsSizeY(0).getValue(); % size y
    stackSizeZ = omeMeta.getPixelsSizeZ(0).getValue(); % size z
    
    voxelSizeX = omeMeta.getPixelsPhysicalSizeX(0).value(); % in µm
    voxelSizeXdouble = voxelSizeX.doubleValue(); % The numeric value represented by this object after conversion to type double
    voxelSizeY = omeMeta.getPixelsPhysicalSizeY(0).value(); % in µm
    voxelSizeYdouble = voxelSizeY.doubleValue(); % The numeric value represented by this object after conversion to type double
    voxelSizeZ = omeMeta.getPixelsPhysicalSizeZ(0).value(); % in µm
    voxelSizeZdouble = voxelSizeZ.doubleValue(); % The numeric value represented by this object after conversion to type double
    
    image = zeros(stackSizeX, stackSizeY, stackSizeZ); % creating zeros array to store result
    
    % Looping through the z stacks and storing them in the zeros matrix
    for i = 1:stackSizeZ
        image(:,:,i) = series1{i,1};
    end
    
    % Returning the voxel spacing on [x,y,z]
    spacing = [voxelSizeXdouble, voxelSizeYdouble, voxelSizeZdouble];
    
end
