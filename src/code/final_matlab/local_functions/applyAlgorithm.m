function [thresholded_image] = applyAlgorithm(image,rps_hard_con,rpt_hard_con,voxel_spacing,lambda,a,b)
%APPLYALGORITHM Summary of this function goes here
%   Detailed explanation goes here

%%%%%%%%%%%%%%
% Image info %
%%%%%%%%%%%%%%
stdev = std(image,0,'all');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Generating graph structure %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
g = imageGraph3(size(image)); % generate a graph that's the size of the image split 
edge_table = splitvars(g.Edges,'EndNodes','NewVariableNames',{'startNode','endNode'}); % the edge table has a nested column, EndNodes, that I split into two columns

%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Creating boundary links %
%%%%%%%%%%%%%%%%%%%%%%%%%%%
edge_table.StartIntensity = image(table2array(edge_table(:,"startNode"))); % extract the intensity of the start node
edge_table.EndIntensity = image(table2array(edge_table(:,"endNode"))); % extract the intensity of the end node
[start_x,start_y,start_z] = ind2sub(size(image),table2array(edge_table(:,"startNode"))); % x,y,z coordinates for the start node
[end_x,end_y,end_z] = ind2sub(size(image),table2array(edge_table(:,"endNode"))); % x,y,z coordinates for the end node

% Storing the result in separate columns
edge_table.start_x = start_x; 
edge_table.start_y = start_y;
edge_table.start_z = start_z;
edge_table.end_x = end_x;
edge_table.end_y = end_y;
edge_table.end_z = end_z;

% Compute Eucledian distance
edge_table.distance = sqrt(sum((voxel_spacing.*([edge_table.start_x, edge_table.start_y, edge_table.start_z] - [edge_table.end_x, edge_table.end_y, edge_table.end_z])).^2,2));

% Compute the weights using Gaussian 
edge_table.Weight = computeBoundaryWeight(edge_table.StartIntensity,edge_table.EndIntensity,stdev,edge_table.distance);

g.Edges.Weight(:) = lambda*edge_table.Weight; % change the weights in the graph to the calculated ones

%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Creating regional links %
%%%%%%%%%%%%%%%%%%%%%%%%%%%
[s_fgweights, t_bgweights] = computeRegionalWeights(image,a,b); % computing s and t weights for each node

num = size(image(:),1); % Getting all nodes

startNodes = (1:num)'; % creating a vector from 1 to n
startNodes = [startNodes;startNodes]; % duplicating vertically for s and t

endNodes = zeros(num*2,1); % creating zeros array for end nodes
endNodes(1:num,1) = num+1; % first half s nodes
endNodes(num+1:num*2,1) = num+2; % second half t

node_links = [startNodes endNodes]; % concatenating the start and end nodes horizontally

regional_weights = [s_fgweights; t_bgweights]; % vertically concatenating s and t weights

new_edges = table(node_links, regional_weights); % making a table of the weights and links
new_edges.Properties.VariableNames = {'EndNodes','Weight'}; % they need to have this naming scheme

g = g.addedge(new_edges); % adding edges to the graph

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Applying hard constraint %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Hard constraint on small objects (set Rp(S) to 1/10000 because the
% regions belong to small objects)
idxS = findedge(g,num+1,find(rps_hard_con)); % find edge indices where the nodes in the small areas are connected to the "s" node (s node is num+1 in our graph structure)
g.Edges.Weight(idxS) = g.Edges.Weight(idxS)/10000; % make the foreground connections as close to 0 as possible

% Hard constraint on large objects (set Rp(T) to 1/10000 because the
% regions belong to large objects)
idxT = findedge(g,num+2,find(rpt_hard_con)); % find edge indices where the nodes in the large areas are connected to the "t" node (t node is num+2 in our graph structure)
g.Edges.Weight(idxT) = g.Edges.Weight(idxT)/10000; % make the background connections as close to 0 as possible


%%%%%%%%%%%%%%%%%%%%%
% Applying max-flow %
%%%%%%%%%%%%%%%%%%%%%
[~,~,cs,~] = maxflow(g,num+1,num+2); % maxflow min cut algorithm

%%%%%%%%%%%%%%%%%%%%%%%%%%
% Doing the thresholding %
%%%%%%%%%%%%%%%%%%%%%%%%%%
cs(end) = []; % removing the s node
thresholded_image = zeros(size(image)); % creating new thresholded image
thresholded_image(cs) = 1; % applying threshold to the image

end

