% Breaks an image into a set number of parts to make computation more 
% manageable. The no of blocks needs to have a square root (4,16,64, etc)
% Fix this later to handle any splits
% Keeps the z stacks intact
function [divided_image] = splitImage(image, no_of_blocks)
    % Extract height, width, depth of 3D image    
    [size_x, size_y, size_z] = size(image);
    
    % Steps in each direction
    steps_x = sqrt(no_of_blocks);
    steps_y = sqrt(no_of_blocks);
    
    % Determine the steps in each direction
    blocksize_x = size_x/steps_x;
    blocksize_y = size_y/steps_y;
    
    % Initialize empty matrix to store the image divisions
    divided_image = zeros(blocksize_x, blocksize_y, size_z, no_of_blocks);
    
    % Intializing 
    row = 1;
    col = 1;
    count = 1;
    
    % Looping through image and storing each part in a 4D tensor called 
    % divided_image
    for dx=1:steps_x % for each step in x
        for dy=1:steps_y % for each step in y
            divided_image(:,:,:,count) = image(row:row+blocksize_x-1, col:col+blocksize_y-1, :); % store results in new 4D tensor
            col = col + blocksize_y; % increment the y column that is being accessed
            count = count+1; % increment the count of the split images
        end
        col = 1; % after each section in x, reinitialize back to original y
        row = row + blocksize_x; % increment x section
    end

end