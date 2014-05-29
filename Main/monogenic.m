function  [f, A, theta, psi] = monogenic(image,rangeBase,rangeStep);

   warning off
   
   [dimx,dimy] = size(image);

   if nargin == 1
       
      rangeBase = 2/8;
      rangeStep = 0.25/1; %scale down by 8 as well?
      
      %rangeBase = 2;
      %rangeStep = 0.25;

   end;

   %nscale = 5;  % we don't need all these scales - not doing phase
                 % congruency
   nscale = 1;  
   orientWarp = 0;

   [u1,u2] = meshgrid((1:dimy*2)-(2*dimy+1)/2,(1:dimx*2)-(2*dimx+1)/2);

   hyp = sqrt(u1.^2+u2.^2);
    
   v1 = ([0:dimx-1]-round(dimx/2))'*ones(1,dimy);
   v2 = ones(dimx,1)*([0:dimy-1]-round(dimy/2));
   hyp2 = sqrt(v1.^2+v2.^2);
   V1 = i*v1./(hyp2+eps); 
   V2 = i*v2./(hyp2+eps); 
      
   fftimg =fft2(imresize(image,2));

   for N=1:nscale,

        kern_p = hyp.^-(rangeBase+rangeStep*(N+1));
        kern_p = kern_p/sum(sum(kern_p));
        kern_n = hyp.^-(rangeBase+rangeStep*N);
        kern_n = kern_n/sum(sum(kern_n));
        kern = kern_p-kern_n;
       
        im_r = real(ifft2(fftimg.*fft2(ifftshift(kern))));
         
        for x=1:dimx,
            for y=1:dimy,
                imf1(x,y) = im_r(x*2-1,y*2-1);
            end; 
        end;
        
        f(:,:,N)=imf1;
        monogenicStack(:,:,1,N) = imf1; 
        fftimg2 = fftshift(fft2(imf1));
        monogenicStack(:,:,2,N) = real(ifft2(ifftshift(V1.*fftimg2)));
        monogenicStack(:,:,3,N) = real(ifft2(ifftshift(V2.*fftimg2)));
        
        f(:,:,N)=imf1; %band-passed image;
        A(:,:,N)= sqrt(monogenicStack(:,:,1,N).^2 + monogenicStack(:,:,2,N).^2 + monogenicStack(:,:,3,N).^2); %local engergy
        theta(:,:,N) = atan2(monogenicStack(:,:,2,N), monogenicStack(:,:,3,N)); %local orientation
        psi(:,:,N)= atan2(monogenicStack(:,:,1,N), sqrt(monogenicStack(:,:,2,N).^2+monogenicStack(:,:,3,N).^2)); %local phase
        
        if orientWarp
            psi1{N} = psi(:,:,N);
            theta1{N} = theta(:,:,N);
            negind = find(theta1{N}<0);
		    theta1{N}(negind) = theta1{N}(negind) + pi;
		
		% Where orientation values have been wrapped we should adjust phase accordingly
		psi1{N}(negind) = pi-psi1{N}(negind);
		morethanpi = find(psi1{N}>pi);
		psi1{N}(morethanpi) = psi1{N}(morethanpi)-2*pi;
        end
        
   end;    
