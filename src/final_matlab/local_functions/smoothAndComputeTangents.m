function [Xsf, dXsf] = smoothAndComputeTangents(Xs, stdev)

ns = size(Xs,1); % number of nodes in the link

Xsf = zeros(ns,3);
dXsf = zeros(ns,3);

% https://www.mathworks.com/matlabcentral/fileexchange/34089-gradients-with-gaussian-smoothing
for i=1:3
    % Smoothing coordinates using zeroth order Gaussian kernel (zeroth 
    % order is a fancy word for a plain old gaussian)
    Xsf(:,i) = gsmooth(Xs(:,i),stdev,'Region','same'); 
    
    % Getting derivatives of points i.e. tangents using first order 
    % Gaussian (derivative of the smoothed coordinates is the same as 
    % applying a first order Gaussian to the original set of coordinates)
    dXsf(:,i) = gradients_x(Xs(:,i),stdev,'Region','same'); 
end

dXsf = dXsf./sqrt(sum(dXsf.^2,2)); % normalize the tangents to make them unit vectors

end

