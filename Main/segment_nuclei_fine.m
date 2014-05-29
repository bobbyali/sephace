% =========================================================================
% segment_nuclei_fine.m
% Rehan Ali, 29th July 2010
%
% Computes the CID transform for a given brightfield in-focus image, and
% applies a circle fit to the result. Performs analysis on each cell in
% image, and then stitches the results back onto an image which is the
% size of the original image. Uses a finer sampling space which takes
% longer to compute.
%
% INPUTS:   I - Brightfield in-focus image
%           classes - Boundary segmentation class map
%
% OUTPUT:   N - Nucleus segmentation binary map
% =========================================================================

function N = segment_nuclei_fine(I,classes)

    % subtract one from classes (as 1 = background by default)
    classes = classes - 1;

    % count num of cells from seg class map
    numcells = max(max(classes));

    % initialise output map
    N = zeros(size(I));
       
    % pad out the cropped images by a fixed margin
    padding = 20;
    
    % loop through all cells
    for i = 1 : numcells
        disp(['Cell number ' num2str(i) ' of ' num2str(numcells)]);
        % create mask for current cell
        mask = ones(size(classes))*255;
        mask(classes == i) = 0;
        
        % trim edges of image, so that distance maps for any cells on image edge 
        % get computed using the image edge as well
        mask(:,1:2) = 255; mask(:,end-1:end) = 255;
        mask(1:2,:) = 255; mask(end-1:end,:) = 255;
        
        % get region of image containing selected cell
        [mask_x,mask_y] = find(mask == 0);
        xmin = min(mask_x);
        xmax = max(mask_x);
        ymin = min(mask_y);
        ymax = max(mask_y);
        
        % fix values at image edges
        if xmin < padding + 1
            xmin = padding + 1;
        end
        if ymin < padding + 1
            ymin = padding + 1;
        end
        if xmax > size(I,1) - padding - 1
            xmax = size(I,1) - padding - 1;
        end
        if ymax > size(I,2) - padding - 1
            ymax = size(I,2) - padding - 1;
        end
                  
        % crop the images
        mask = mask(xmin-padding:xmax+padding,ymin-padding:ymax+padding);
        Ic = I(xmin-padding:xmax+padding,ymin-padding:ymax+padding);

        % compute CID transform for cropped brightfield image
        [c_i0da c_i1da c_i2da] = intrinsicDim_gauss_em(Ic);
        
        % calculate distance map based on cell segmentation mask.
        % this is used to determine points within cell to sample for the circle
        % fitting, as we want to sample only points that are a circle-radius away
        % from the cell boundary
        distmap = bwdist(mask);
                       
        count = 1;
        
        % define x,y sampling grid
        [dx dy] = size(mask);
        n = 10;
        x_list = 1:n:dx;
        y_list = 1:n:dy;
        
        % create array for fitting results
        fit = zeros(1000,6);

        % for every n pixels in the mask
        for x = x_list
            for y = y_list
                % for several different values of a, b, theta
                for a = [20:10:60]
                    for b = [a:10:a+40]
                        
                        % if ellipse then test different angles
                        if b > a 
                            theta_list = [0:pi/8:3*pi/4];
                        else
                            theta_list = 0;
                        end
                        
                        for theta = theta_list

                            radius = b;

                            % if current pixel is a circle-radius away from the cell boundary
                            % (as determined using distance map)
                            if distmap(x,y) >= radius

                                % create a temporary map containing a 1 at the current point
                                circlemap = zeros(size(mask));
                                
                                % construct ellipse mask
                                try
                                    circlemap = ellipseMatrix(x,y,a,b,theta,circlemap,1);
                                
                                    % sum up c_i0da values within the circle. this is our metric
                                    % that we use to determine the nucleus position.
                                    fit(count,1) = x;
                                    fit(count,2) = y;
                                    fit(count,3) = a;
                                    fit(count,4) = b;
                                    fit(count,5) = theta;
                                    fit(count,6) = sum(sum(c_i0da(circlemap > 0)));
                                    count = count + 1;
                                end
                                
                                % clear the temporary map
                                clear circlemap
                                
                            end
                        end                        
                    end
                end

            end
        end

        % check that we have some results from the fitting
        if fit(1,1) ~= 0
            % determine point yielding maximum metric value - this is our likely
            % nucleus centre position
            idx = find(fit(:,6) == max(fit(:,6)));
            max_x = fit(idx(1),1);
            max_y = fit(idx(1),2);
            max_a = fit(idx(1),3);
            max_b = fit(idx(1),4);
            max_t = fit(idx(1),5);

            % create fitting ellipse mask for superimposing on output images
            circlemap = zeros(size(mask));
            circlemap = ellipseMatrix(max_x(1),max_y(1),max_a(1),max_b(1),max_t(1),circlemap,1);
            
            % add the circle to the output map
            N(xmin-padding:xmax+padding,ymin-padding:ymax+padding) = N(xmin-padding:xmax+padding,ymin-padding:ymax+padding) + circlemap;
        end     
        
        % tidy up
        clear circlemap max_x max_y max_a max_b max_t 
        clear fit distmap mask c_i0da c_i1da c_i2da
        clear xmin xmax ymin ymax mask_x mask_y
        
    end
    
    % convert to binary map
    N(N > 1) = 1;