function R = display_RGB(I,L)

    R  = zeros(size(I,1),size(I,2),3);
    tmp = I;
    tmp(find(L ~= 1)) = 255;
    R(:,:,1) = tmp/255;
    R(:,:,2) = I/255;
    R(:,:,3) = I/255;