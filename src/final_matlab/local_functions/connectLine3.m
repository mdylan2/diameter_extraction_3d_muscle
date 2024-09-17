function [P,L]=connectLine3(p1,p2)

%Return matrix P with all of the pixels (or voxels) connecting the two
%points p1 and p2. Also returns the number of points in the line. No dimension is predetermined, so this function would work for
%n-space. p1 and p2 are 1xn vectors (n dimensions)

%Round inputs
p1=round(p1);
p2=round(p2);

%Get distances in axes 
D=abs(p2-p1)+1e-6;
L=max(D);
if all(D==0) %points are the same, make raster of length 1
   P=p1;
else
    %Parametrize based on largest separation (to have no gaps)
    t=0:1/L:1;
    %Get points parametrized
    P=round(p1'+(p2-p1)'.*t)';
end

end