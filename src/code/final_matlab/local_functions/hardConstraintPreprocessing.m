function [rps_hard_constraint_split, rpt_hard_constraint_split] = hardConstraintPreprocessing(preprocessed_img, no_of_blocks, T_nuclei)

th = graythresh(preprocessed_img); % determine an Otsu threshold for the image
segmented = preprocessed_img > th; % apply the threshold to the image to generate a binarized image

% Determine the volume of regions using connected component analysis
cc = bwconncomp(segmented); 
region_info = regionprops3(cc,{'Volume','VoxelIdxList'});

small_objs = region_info(region_info.Volume <= T_nuclei,'VoxelIdxList'); % find regions where the size of nuclei is less than the threshold 
large_objs = region_info(region_info.Volume > 2*T_nuclei,'VoxelIdxList'); % find regions where the size of nuclei is greater than twice the threshold

% Make a 1-dimensional vector of all the small object areas
so = table2array(small_objs);
so = vertcat(so{:});

% Make a 1-dimensional vector of all the large object areas
lo = table2array(large_objs);
lo = vertcat(lo{:});

% Create two "images" where a 1 represents the node whose edges need the
% hard constraints imposed
% Creating image array for those nodes whose foreground connections (i.e. 
% connections to s) need to be set to 1/10000 of their values because the
% objects are tiny and are probably nuclei
rps_hard_constraint = zeros(size(preprocessed_img));
rps_hard_constraint(so) = 1;

% Creating image array for those nodes whose background connections (i.e. 
% connections to t) need to be set to 1/10000 of their values because the
% objects are large and are probably fibers
rpt_hard_constraint = zeros(size(preprocessed_img));
rpt_hard_constraint(lo) = 1;

% Since we split the image when doing graph cuts for computational reasons,
% we need to do the same for these constraint terms
rps_hard_constraint_split = splitImage(rps_hard_constraint,no_of_blocks); 
rpt_hard_constraint_split = splitImage(rpt_hard_constraint,no_of_blocks);

end