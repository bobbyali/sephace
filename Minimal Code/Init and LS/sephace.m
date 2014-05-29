% =========================================================================
% single_set_segmentation.m
% 
% Rehan Ali, 3rd December 2012
% 
% Runs sephaCe algorithms on a single manually defined set of images.
% =========================================================================

clear all
close all
clc

% level set parameters
iterations = '50';              % number of iterations to run LS
alpha   = '5';                  % weighting for edge term
beta    = '0';                  % weighting for region term
gamma   = '5';                  % weighting for repulsion term
delta   = '5';                  % weighting for curvature term

% set up paths to key images
path = 'data/';
f_I    = 'fine_121112SH9_p0076_t00004_z001_w00.tif';
f_Im   = 'im_121112SH9_p0076_t00004_z001_w04.tif';
f_Ip   = 'ip_121112SH9_p0076_t00004_z001_w07.tif';
f_Imm  = 'imm_121112SH9_p0076_t00004_z001_w05.tif';
f_Ipp  = 'ipp_121112SH9_p0076_t00004_z001_w06.tif';

% load images
I = double(imread([path f_I]));
Im = double(imread([path f_Im]));
Imm = double(imread([path f_Imm]));
Ip = double(imread([path f_Ip]));
Ipp = double(imread([path f_Ipp]));

% run cell auto-detection algorithm
L = auto_detect_cells(Im,Ip);        
L = L + 1;  % need bg = 1 for LS
R = display_RGB(Ip,L);    
figure;colormap('gray');axis image;imagesc(R);
pause

% start level set segmentation (via Windows exe)
diff = Im - Ip;
figure;imagesc(diff);axis image;colormap('gray');
[f, A, theta, psi] = fastMonogenic(diff);
local_energy = norm_image(A);
local_phase  = norm_image_zeromean(psi);
local_orient = norm_image(theta)*2*pi;
 
imwrite(L/255, 'label_start.png', 'PNG');
imwrite(norm_image(local_phase), 'localphase.png', 'PNG');
imwrite(norm_image(local_orient), 'localorient.png', 'PNG');
imwrite(norm_image(local_energy), 'localenergy.png', 'PNG');
imwrite(norm_image(Ip), 'Ip.png', 'PNG');

delete _out_classes.png
delete _out_phi.png
delete _out_iterations.txt
delete _out_volume.txt   

fid = fopen('runLS.bat','w+');
fprintf(fid,['localphaseLS.exe ' ...
               'localphase.png ' ... 
               'label_start.png ' ... 
               'localorient.png ' ... 
               'out_classes.png ' ... 
               'out_phi.png ' ... 
              iterations ' 1 ' ... 
              alpha ' ' beta ' ' gamma ' ' delta ' \n']);
fprintf(fid,'exit\n');
fclose(fid);  

% now run the file "runLS.bat" which will execute the level set executable

% once it's finished (when the DOS window disappears), you can view the
% results using the script
%   view_segmentation.m