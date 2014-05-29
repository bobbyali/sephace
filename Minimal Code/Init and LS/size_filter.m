% =========================================================================
% size_filter.m
%   Rehan Ali, 1st August 2010
%
% Applies a size-based filter on binary or integer image.
% =========================================================================

function labelled = size_filter(bw)

    if max(max(bw)) > 1
        bw(bw > 1) = 1;
    end
    
     % create copy of label map for output label map
    l = bwlabel(bw);
    l1 = l;
    s  = regionprops(l,'Area');

    for i = 1 : max(max(l))
        if s(i).Area < 100  || s(i).Area > 200000
            l1(l == i) = 0;        
        end        
    end
    
    labelled = imfill(bwlabel(l1));
