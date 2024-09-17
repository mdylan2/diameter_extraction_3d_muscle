function weight = computeBoundaryWeight(pixel1,pixel2,sigma,distance)
%COMPUTEWEIGHT Summary of this function goes here
%   Detailed explanation goes here

intermediate = (pixel1 - pixel2).^2/(2*sigma*sigma);
exponential = exp(-intermediate);
weight = exponential./(distance*sigma*sqrt(2*pi));

end

