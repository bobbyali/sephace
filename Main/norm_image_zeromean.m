% =========================================================================
% norm_image_zeromean.m
% Rehan Ali, 31st October 2007
%
% Normalises image intensity values to 0-1.
% =========================================================================

function J = norm_image_zeromean(I);
    
    J = I / max(max(abs(I)));