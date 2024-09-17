function nodeIdsPerCenter = pointsInsideNodeSphere(Xsf, Xb, dMax)

% https://www.mathworks.com/matlabcentral/answers/359821-storing-neighboring-coordinates-within-a-sphere-from-a-3d-domain
% Compute the distance between the object points and the link points
% This spits out a matrix of size [nb x ns] where (i,j) represents the
% distance of the jth link point to the ith object point
distance_matrix = pdist2(Xb,Xsf); % computing the distance matrix

[r, c] = find(distance_matrix < dMax) ; % determine the index of the object points that are within a sphere of dMax from each the link points
nodeIdsPerCenter = accumarray(c, r, [], @(x){x}); % group and store the object indices that should be kept for each link point

end

