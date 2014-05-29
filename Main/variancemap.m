% =========================================================================
% variancemap.m
% Rehan Ali, 19th October 2007
%
% Computes a variance map over an input image I, using a square window of
% size 'n' pixels.
%
% Input:
%   I    -    input image
%   n    -    window size
%   
% Output:
%   J    -    output variance map
%
% Version 1.0  -  Set up function
% Version 1.1  -  Added in padding to ensure J is same size as I
% =========================================================================
function J = variancemap(I,n);

if isempty(n)
    n = 4;
end

[dimX dimY] = size(I);

for i = 1 : dimX
    for j = 1 : dimY
   
        if i < n+1 | i > dimX-n | j < n+1 | j > dimY-n
            J(i,j) = 0;
        else
            patch = I(i-n:i+n,j-n:j+n);
            data = reshape(patch,[((2*n)+1)^2,1]);
            texture = 1 - (1 / (1 + var(data)));  % based on variability
            J(i,j) = texture;
        end
    end
end

