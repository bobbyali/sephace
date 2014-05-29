function [c_i0d c_i1d c_i2d] = intrinsicDim_gauss_em(im_o)

% Calculates the continuous intrinsic dimensionality value of each pixel in
% a given image. Implementation after the Felsberg papers with the same
% title from 2009. The only input is the image, while the output
% is three probability value assigned to each pixel. 
% c_i0d - probability that the pixel belongs to a homogeneous patch, 
% c_i1d - probability that the pixel belongs to an intrinsic 1D signal
% c_i2d - probability of the pixel being part of an intrinsic dimensionality 2 patch, i.e. branching point, such as corners
% are.
% There are a few options that allow control over the calculation accuracy/complexity/time:
% CID2OPTION = 0, uses Gaussian smoothing in the cone to estimate signal complexity
%             (probability values are NOT reliable with this approach - specifically included for Bobby's (Rehan Ali) request) 
%            = other, uses NP windows
% S_OPTION = 1, perform smoothing on the original input image 
%          = 0, otherwise
% MAG_OPTION = 0, local energy from the monogenic signal to represent image energy
%            = 1, gradients to derive image energy
%            = 2, PC
%            = 3, local phase from monogenic signal
% EM-OPTION  = 1, EM noise estimation step
%              0, otherwise
% Any commenst/questions/bug reports PLEASE send to
% Tünde Szilágyi, tuende@robots.ox.ac.uk, MVL, Oxford, 2009, Thank you for this! 

% OPTIONS
cid2option = 0;
s_option = 0;
mag_option = 0;
em_option = 0;
crop = 0;


% NUMBER OF SCALES
N = 4;%0;
%FILTER PARAM
alpha = 2;
beta = 0.25;
% REGULARISATION WINDOW width (2n+1 x 2n+1)
dw = [21 21];
% ORIENTATION MARGINS
marg = 10;

% INITIALIZE
orient_reg = zeros(size(im_o)+ dw-1);

% SMOOTH THE ORIGINAL INPUT IMAGE IF THE TRANSITIONS ARE TOO SHARP (0 - 255, TESTIMAGE)
if (s_option ==1)
im = fftshift(abs(ifft2(fftshift(fft2(im_o)).* fftshift(fft2(fspecial('gaussian', [size(im_o)], size(im_o,2)*0.01))))));
else
im = im_o;
end

% MOMOGENIC SIGNAL - LOCAL PHASE AND ORIENTATION
% [f, le, lo, lp] = monogenic_bobby(im, N, alpha, beta); ??
[f, le, lo, lp] = monogenic(im, 2.5, 0.25);
% BOBBY! here use your monogenic code to get le, lo and lp from the monogenic signal - you do not need the rest 

%GRADS
[gx, gy]= gradient(im);
gradmag = gx.^2 + gy.^2;
struct_tensor = [gx gy]*[gx gy].';
eigvalue = eig(struct_tensor);
eigvect = struct_tensor - max(eigvalue)* eye(size(struct_tensor)); 

% CHOICE OF IMAGE ENERGY
if (mag_option == 0)
gradmag = le(:, :, 1); 
elseif(mag_option == 1)
gradmag = gx.^2 + gy.^2;
elseif(mag_option == 2)  
[im, rho] = pc(im_o); 
gradmag = rho;
elseif (mag_option == 3)  
% just for specific test images
temp = lp(:, :, 1);
gradmag = (temp - min(min(temp)))./max(max((temp - min(min(temp)))));     
end

% figure, imagesc(gradmag), title('Energy image used')

% ORIENTATION
orient = lo(:, :, 1);

% REGULARIZATION 
% orient = regularize_orient(im, orient, dw);

% EM ITERATION TO GET TO THE ACTIVATION FUNCTION
% MAPPING TO THE (0,1) INTERVAL
if (em_option == 1)

    grad_new = em_func_keret(gradmag);

else 
    
    grad_new = gradmag./max(max(gradmag)); 

end

d = grad_new.*exp(-i.*2.*orient);

magn = grad_new;
theta = -2*orient;

% cone representation
c1 = abs(d); c2 = real(d); c3 = imag(d);

if (cid2option == 0)
    
% GAUSSIAN SMOOTHING G(0, sigma)
% WARNING - this is not a correct way of going about - not reliable
% probabilities
mysigma = max(size(d)).*0.008;
cc1 = fftshift(abs(ifft2(fftshift(fft2(c1)).* fftshift(fft2(fspecial('gaussian', [size(d)], mysigma))))));
cc2 = fftshift(abs(ifft2(fftshift(fft2(c2)).* fftshift(fft2(fspecial('gaussian', [size(d)], mysigma))))));
cc3 = fftshift(abs(ifft2(fftshift(fft2(c3)).* fftshift(fft2(fspecial('gaussian', [size(d)], mysigma))))));
c1 = cc1; c2 = cc2; c3 = cc3;
 
else 
    
% NP win H calc.
nb = 1;
cnorm = -log(1/256); 
cc2 = abs(NPwinentropy(c2, nb));
cc3 = abs(NPwinentropy(c3, nb));
c2 = cc2/cnorm.*c2;
c3 = cc3/cnorm.*c3;
end


if (crop == 1)
c1 = c1(21: end-20, 21: end-20);
c2 = c2(21: end-20, 21: end-20);
c3 = c3(21: end-20, 21: end-20);
end

% TRIANGLE REPRESENTATION
x_t = c1;
y_t = sqrt(c2.^2 + c3.^2);

% NORMALISATION OF Y VALUES
x_t_e = x_t;
if (x_t == 0)
    y_t_e = y_t.^2./(x_t + epsilon);
else
    y_t_e = y_t.^2./x_t;
end    

% BARYCENTRIC COORDINATES
c_i0d = 1- x_t_e;
c_i1d = y_t_e;
c_i2d = x_t_e - y_t_e;

% DISPLAY BARYCENTRIC COORDINATES
% figure, subplot(3,1,1), imagesc(c_i0d), title('Ci0d'), colorbar
% subplot(3,1,2), imagesc(c_i1d), title('Ci1d'), colorbar
% subplot(3,1,3), imagesc(c_i2d), title('Ci2d'), colorbar

% disp('The end')

%----------------------------------------------------------------
%----------------------------------------------------------------
%----------------------------------------------------------------
function [seged] = em_func_keret(im)
[n m] = size(im);
seged = zeros(size(im));

nb = 1;

for i = 1+nb : n-nb
    for j = 1+nb : m-nb
        disp(['i: ', num2str(i)])
        k = (i-nb) : (i+nb);
        l = (j-nb) : (j+nb);
        [p1 p2 psig pnoi] = em_func(im(k,l));
        seged(i,j) = (1+ (pnoi.*p2)./(psig*p1 + eps)).^(-1);
    end
end

        
% BORDERS
i = 1;
    for j = (1+nb) : (m-nb)
        k = (i) : (i+nb);
        l = (j-nb) : (j+nb);
        [p1 p2 psig pnoi] = em_func(im(k,l));
        seged(i,j) = (1+ (pnoi.*p2)./(psig*p1 + eps)).^(-1);
    end

i = size(im,1);
    for j = (1+nb) : (m-nb)
        k = (i -nb) : (i);
        l = (j - nb) : (j + nb);
        [p1 p2 psig pnoi] = em_func(im(k,l));
        seged(i,j) = (1+ (pnoi.*p2)./(psig*p1 + eps)).^(-1);   
    end
    

j = 1;
for i = 1 + nb : n-nb
        k = (i -nb) : (i + nb);
        l = j : (j + nb);
        [p1 p2 psig pnoi] = em_func(im(k,l));
        seged(i,j) = (1+ (pnoi.*p2)./(psig*p1 + eps)).^(-1); 
end


j = size(im, 2);
for i = 1 + nb : n-nb
        k = (i -nb) : (i + nb);
        l = (j - nb) : j;
        [p1 p2 psig pnoi] = em_func(im(k,l));
        seged(i,j) = (1+ (pnoi.*p2)./(psig*p1 + eps)).^(-1);  
end

% disp('Starts calculations for the corner elements...')

% corners
% 1 3
% 2 4


i = 1;
j = 1;
k = i : (i + nb);
l = j : (j + nb);
      [p1 p2 psig pnoi] = em_func(im(k,l));
      seged(i,j) = (1+ (pnoi.*p2)./(psig*p1 + eps)).^(-1);

i = size(im,1);
j = 1;
k = (i - nb) : i;
l = j : (j + nb);
        [p1 p2 psig pnoi] = em_func(im(k,l));
        seged(i,j) = (1+ (pnoi.*p2)./(psig*p1 + eps)).^(-1); 

i = 1;
j = size(im,2);
k = i : (i + nb);
l = (j - nb) : j;
        [p1 p2 psig pnoi] = em_func(im(k,l));
        seged(i,j) = (1+ (pnoi.*p2)./(psig*p1 + eps)).^(-1);

i = size(im,1);
j = size(im,2);
k = (i - nb) : i;
l = (j - nb) : j;
        [p1 p2 psig pnoi] = em_func(im(k,l));
        seged(i,j) = (1+ (pnoi.*p2)./(psig*p1 + eps)).^(-1);
        
%----------------------------------------------------------------
%----------------------------------------------------------------
%----------------------------------------------------------------
function [w1 w2 psig pnoi] = em_func(data)
% CREATES THE PARAMETERS OF THE SOFT-THRESHOLDING FUNCTION

n = 1;
signal = imresize(data, [size(data,1)*size(data,2) 1]);

% RUN MODIFIED EM
[W,M,V,L] = EM_GM(signal,2,[],[],1,[]);
w1 = W(1);
w2 = W(2);

% ASSUME THAT THE LOWER MEAN VALUE IS DUE TO NOISE (0 ENFORCEMENT)
% SIGNAL INDEX
si = find(M==max(M));
% NOISE INDEX
ni = find(M==min(M));

% CALC. PROBS.
Psignal = 1./sqrt(2*pi*V(si).^2).*exp(-(signal-M(si)).^2./(2*V(si).^2));
Pnoise = 1./sqrt(2*pi*V(ni).^2).*exp(-(signal-M(ni)).^2./(2*V(ni).^2));

psig = Psignal(2*n+1);
pnoi = Pnoise(2*n+1);