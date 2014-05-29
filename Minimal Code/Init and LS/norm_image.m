% =========================================================================
% norm_image.m
% Rehan Ali, 31st October 2007
%
% Normalises image intensity values to 0-1.
% =========================================================================

function J = norm_image(I);
    
    J = I - min(min(I));
    J = J / max(max(J));