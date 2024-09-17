function [s_fgweights, t_bgweights] = computeRegionalWeights(image, a, b)
%COMPUTEBOUNDARYWEIGHTS Summary of this function goes here
%   Detailed explanation goes here

s_fgweights = exp(-(abs(image(:) - 1).^a)./(b*b));
t_bgweights = exp(-(abs(image(:)).^a)./(b*b));

end

