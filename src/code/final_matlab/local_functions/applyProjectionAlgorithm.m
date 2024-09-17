function [final_table,imLabel,imSkel] = applyProjectionAlgorithm(im, lMin, dMax, stdev, d2plane, ths)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

% Label connected components to simplify problem
[imLabel, num_objects] = bwlabeln(im);

% Get skeleton of image: Prune things smaller than a value that should be
% approx the radius of fibers. This might be fine but maybe a more
% sophisticated function for pruning is necessary
imSkel=bwskel(im, 'MinBranchLength',lMin);

final_table = cell(length(num_objects),1); % intialize a cell array to store information for all fiber objects

for object_no=1:num_objects
    bo = imLabel==object_no; % extract voxels belonging to that object
    sk = imSkel.*(bo); % extract skeleton belonging to object number

    if sum(sk,'all') == 0
        continue
    end
    try
        % Convert the skeleton into a graph structure
        [~,~,links] = Skel2Graph3D(logical(sk),lMin); % nodes are central points of skeleton and links are connections between nodes
    catch
        continue
    end
    projection_table = cell(length(links),1); % intialize an array to store all final projections

    % For each link
    for i = 1:length(links)
        [xs,ys,zs] = ind2sub(size(im),links(i).point'); % determine the x,y,z points within a certain link
        [xb,yb,zb] = ind2sub(size(im),find(bo)); % determine the x,y,z points of the boundary voxels

        Xs = [xs,ys,zs]; % store smoothed coordinates in one variable
        Xb = [xb,yb,zb]; % store object voxels in one variable

        % Applies 0th and 1st order Gaussians to the points in the skeleton link
        % to obtain smoothed coordinates and tangent vectors respectively
        [Xsf, dXsf] = smoothAndComputeTangents(Xs,stdev);

        % Compute the distance between the object points and the link points
        % This spits out a matrix of size [nb x ns] where (i,j) represents the
        % distance of the jth link point to the ith object point
        nodeIdsPerCenter = pointsInsideNodeSphere(Xsf, Xb, dMax);

        % Compute the projections for each node in the link
        projection_table{i,1} = orthogonalProjections(nodeIdsPerCenter,Xsf,dXsf,Xb,object_no,i,d2plane, ths);
    end
    
    final_table{object_no,1} = vertcat(projection_table{:});
end

final_table = vertcat(final_table{:});

end

