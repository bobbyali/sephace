% =========================================================================
% resize_to_image_size.m
% Rehan Ali, 8th October 2007
%
% Resizes first input image to same dimensions as second input image
%
% Input:
%   I    -    input image to be resized
%   J    -    input image to take size from
%   
% Output:
%   K    -    final subimage
%
% Version 1.0  -  Set up function
% =========================================================================  

function [K] = resize_to_image_size(I,J)

    [dimX dimY] = size(J);
    K = I(1:dimX,1:dimY);
    