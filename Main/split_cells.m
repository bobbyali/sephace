% =========================================================================
% split_cells.m
% Rehan Ali, 2nd December 2007
%
% Splits up cells by eroding until the required number of regions are
% obtained.
%
% Inputs:
%       I           Input class map with n classes
%       c           Class ids to break apart (vector form)
%       n           Number of regions to obtain for each targeted class id
%                   after splitting (vector form)
%
% Outputs:
%       output      Final class map
%
% v1.0  Created
% =========================================================================

function [output] = split_cells(I,c,n)

%  I = L1;
%  c = multiple_cell_regions;
%  n = multiple_cell_number;

[dimX dimY] = size(I);
s = strel('disk',2,0);
s = strel('diamond',2);
s = strel('octagon',3);

output = zeros(dimX,dimY);

% loop through cells that need to be broken up
for i = 1 : length(c)
    
    % create binary of current targeted cell
    init = zeros(dimX,dimY);
    init(find(I == c(i))) = 1;  
    init = logical(init);
    
    blnLoop = 1;
    count = 0;
    numcells = n(i);
    
    while blnLoop == 1
        
        % erode target region
        init = imerode(init,s);
        count = count + 1;
        
        % check number of regions after erosion
        region_count = max(max(bwlabel(init)));
     
        % figure;imagesc(init);pause
        
        % if splitting has occured
        if region_count > 1

            % relabel new pieces
            init = bwlabel(init);
            
            % delete small fragments
            numfragments = 0;
            for j = 1 : region_count
                region_size(j) = length(find(init == j));
                if region_size(j) < 2000
                    init(find(init == j)) = 0;
                    numfragments = numfragments + 1;
                end
            end

% DEBUG
            region_count
            numfragments
            %figure;imagesc(init);axis equal;pause
            
            % if num regions after deleting fragments exceeds target 
            % number then stop
            if region_count - numfragments >= numcells
                
                blnLoop = 0;
                output = output + init;
                
            % check if there are still multiple regions after deleting
            % fragments
            elseif region_count - numfragments > 1
                
                % retain largest region, save smaller regions to 'output'
                % and delete from 'init'
                maxsize = 0;
                maxregion = 0;
               
                for j = 1 : region_count
                    
                    big_region_size(j) = length(find(init == j));
                    
                    % keep track of largest fragment
                    if big_region_size(j) > maxsize
                        maxsize = big_region_size(j);
                        maxregion = j;
                    end
                 
                end
                
                % add small cell regions to output
                temp = init;
                temp(find(init == maxregion)) = 0;
                output = output + temp;
                init(find(init ~= maxregion)) = 0;
                
                % adjust target region count
                numcells = numcells - (region_count - numfragments - 1);
            
            end
            
            init = logical(im2bw(init,0));
            
        end
        
    end
      
end
    
% renumber regions in output class map
output = bwlabel(output);

%%
% clc
% for i = 1 : max(max(I_final_classes))+1
%     pixelcount(i) = length(find(I_final_classes == i-1));
%     disp(['Class ' num2str(i-1) ' pixels=' num2str(pixelcount(i)) ]);
% end