% This function will compute the x and y coordinates for the orthogonal 
% projection for the all n nodes in a link. It will return 
function table_proj = orthogonalProjections(nodeIdsPerCenter, Xsf, dXsf, Xb, object_no, link_no, d2plane, ths)

ns = size(Xsf,1); % compute the size of ns

% Create a table to store all information about the projections for each node n
proj_data = cell(ns,4);

for n=1:ns
    % Compute the object points within dMax for the nth link node
    bp_within = Xb(nodeIdsPerCenter{n},:); 

    % Compute the vector projections for the vectors that go from
    % the nth link node to the object points onto the tangent vectors
    % This calculates a distance to the theoretical orthogonal plane
    % We haven't explicitly estimated/calculated this orthogonal plane yet
    % Linear Alg refresher: vector projections are dot products
    dPlane = abs((bp_within - Xsf(n,:))*dXsf(n,:)'); % compute the distance to the orth plane

    idxPlane = dPlane <= d2plane; % determining the points that are within a certain distance to the orth plane

    coords_to_proj = bp_within(idxPlane,:); % determining points that should be projected onto 2D subspace

    % Projecting points using PCA
    % The PCA algorithm in MATLAB takes care of the mean centering
    % so all projected points will be centered around 0,0
    [~,score,~] = pca(coords_to_proj); 
    
    % if the scores are not empty
    if ~isequal(size(score), [0,0]) && ~isequal(size(score,2),1)
        % Extract the first 2 dimensions of the coordinates. Because dPlane is 
        % so small, these coordinates are basically the orthogonal projection
        proj_data{n,4} = score(:,1:2); 

        % Convert the PCA coordinates from coordinates into arrays/meshgrids 
        % so that they can now be visualized as images with blobs. This is
        % useful for measuring region props, which can help us determine how
        % many disconnected blobs are in and image, and whether or not we want
        % to measure those blobs
        x = score(:,1);
        y = score(:,2);

        % Convert to PCA coordinates. Small is used in the conversion to image.
        % Using large doesn't really make a difference
        grayImage = convertPCACoordinatesToImage(x,y,'large');

        % Compute region props for image
        props = computeRegionProps(grayImage);

        % Imposing outlier method. Filtering based on strict thresholds
        mask = props.Convexity < ths(1) | props.Solidity < ths(2);
        props.Outlier(~mask) = 0;
        props.Outlier(mask) = 1;

        % Store results in cell array
        proj_data{n,6} = props;
        
    else
        fprintf("Link %d and node %d have no proj points marking as Outlier 2...", link_no, n);
        proj_data{n,4} = score;     
        props = computeRegionPropsForEmpty();
        proj_data{n,6} = props;
    end

end

proj_data(:,1) = {object_no}; % store fiber object numbers in the first column
proj_data(:,2) = {link_no}; % store link numbers in the second column
proj_data(:,3) = num2cell(1:ns)'; % store the node numbers in the third column

% Store the number of objects per projection in the cell array
num_objects = cellfun(@height,proj_data(:,6));
proj_data(:,5) = num2cell(num_objects);

% Converting cell array to a table
table_proj = cell2table(proj_data);
table_proj.Properties.VariableNames = {'FiberNo','SkelLinkNo',...
    'SkelNodeNo','PCAProj','NumBlobs','imageProps'};

end