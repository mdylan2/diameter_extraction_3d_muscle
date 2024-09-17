% Stitches an image back together from a set number of part. The
% no_of_blocks needs to have a square root (4,16,64, etc). Keeps all the
% z-stacks intact
function [stitched_image] = stitchImage(set_of_images, no_of_blocks)
    % Extract height, width, depth of 3D image    
    [dx, dy, dz] = size(set_of_images,1:3);
    
    % Determining size of stitched image
    steps_x = sqrt(no_of_blocks); % multiplicative factor
    steps_y = sqrt(no_of_blocks); % multiplicative factor
    size_x = dx*steps_x;   
    size_y = dy*steps_y;
    size_z = dz;
    
    % Creating empty stitched image array
    stitched_image = zeros(size_x,size_y,size_z);
    
    % Determine the steps in each direction
    blocksize_x = dx;
    blocksize_y = dy;
    
    % Intializing 
    row = 1;
    col = 1;
    count = 1;
    
    % Looping through image and storing each part in a 4D tensor called 
    % divided_image
    for dx=1:steps_x % for each step in x
        for dy=1:steps_y % for each step in y
            stitched_image(row:row+blocksize_x-1, col:col+blocksize_y-1, :) = set_of_images(:,:,:,count); % extract from 4D tensor 
            col = col + blocksize_y; % increment the y column that is being accessed
            count = count+1; % increment the count of the split images
        end
        col = 1; % after each section in x, reinitialize back to original y
        row = row + blocksize_x; % increment x section
    end

end