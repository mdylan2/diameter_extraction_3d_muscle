function im = createArtificialNetwork(Nr,R,S,Z)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
% Initialize 3D image of size SxSx100
im = zeros(S,S,Z);

% Mesh for image - x coordinate corresponds to row index, y coordinate to
% column index
[yi,xi,zi] = meshgrid(1:S,1:S,1:100);

for i=1:Nr
    % Points that define spine of rod 
    p = 1+round(rand(2,3)*diag([S-1,S-1,99]));
    
    % Line of spine
    [P,L] = connectLine3(p(1,:),p(2,:));

    % Create rod
    for j = 1:L
        % Distance from points in image mesh to current point in spine
        D = ((xi(:)-P(j,1)).^2+(yi(:)-P(j,2)).^2+(zi(:)-P(j,3)).^2);
        
        % Point within a radius are labeled as 1 in the image
        im(D <= R^2) = 1;
    end

end

% Convert to logical array
im = im > 0;
end

