% =========================================================================
% auto_detect_cells.m
%   Rehan Ali, 12th October 2009
%
% Automatically detect cells and initialise brightfield segmentation 
% using two out-of-focus images. Returns a label map of the cell locations.
% =========================================================================

function labelled = auto_detect_cells(Imm,Ipp)

    diff = norm_image(Imm - Ipp);
    t  = graythresh(diff);
    bw = im2bw(diff,t);
        
    % cut out all noise-related small elements
    bw = medfilt2(bw);
    se = strel('disk',10);
    bw = imerode(bw,se);
    bw = imdilate(bw,se);
    
    labelled = size_filter(bw);