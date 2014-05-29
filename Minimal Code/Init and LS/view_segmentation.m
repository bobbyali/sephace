% =========================================================================
% view_segmentation.m
% 
% Rehan Ali, 3rd December 2012
% 
% Views result of a single sephaCe run.
% =========================================================================

clear all
close all
clc

phi = double(imread('out_phi.png'));
final_classes = double(imread('out_classes.png'));
I = double(imread('Ip.png'));

figure;imagesc(I);colormap('gray');
axis image; hold on;
[ ct, h1] = contour( phi, [128 128] );
set( h1, 'LineColor', [1 0 0] );
set( h1, 'LineWidth', 1 );hold off; 