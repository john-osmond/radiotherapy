% Start up:

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear
close all hidden
clc
tic

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Create some data specific variables:

name = 'logo';
dark = 'dark_b';
open = 'openfield';
ext = 'mi3';
devin = 'v';
devout = 'vp';
angle = 0.45;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Merge relevent images if necessary:

if ( exist([dark '_all.' ext]) == 0 )
    merge(dark, ext, devin);
end

if ( exist([open '_all.' ext]) == 0 )
    merge(open, ext, devin);
end

[imgd] = mi3read([dark '_all.' ext], devout);
[imgo] = mi3read([open '_all.' ext], devout);
imgo = (imgo-imgd)/max(max(imgo));
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

nameall = dir([name '_*.' ext]);
framegood = 0;
framelast = 0;

% Loop around all groups:

for frameno = 1:length(nameall)

    % Process image:
    
    [img] = mi3read(nameall(frameno).name, devin);
    img = uint16((double(img) - imgd) ./ imgo);
    
    % Threshold image and count pixels above threshold:
        
    bgind = find(img < 2000);
    pixtot = (size(img,1)*size(img,2)) - length(bgind);
    img(bgind) = 0;
        
    % If number of pixels above threshold is within range, add to sum:
       
    if ( pixtot > 600 )
        
        % Rotate for movie but not image 1.5 (for some reason)
        imgrot = imrotate(img, angle, 'bilinear');
        %imgrot = img;
        %imgcrop = imgrot(160:480,15:465);
        imgcrop = imgrot(155:465,10:455);
        
        if ( frameno > framelast+5 )
            framegood = framegood + 1;
            frameall(:,:,framegood) = imgcrop;
        else
            frameall(:,:,framegood) = frameall(:,:,framegood) + imgcrop;
        end
                
        framelast = frameno;
   
    end
        
end

imagesc(sum(frameall,3));
colormap('gray');
axis image;
axis off;
print('-djpeg','out/logo.jpg');
print('-deps','out/logo.ps');
close;

% Make movie:

movall(:,:,1,:) = frameall(:,:,:);
movall(:,:,2,:) = frameall(:,:,:);
movall(:,:,3,:) = frameall(:,:,:);

movall(:,:,:,:) = uint16(cumsum(double(movall),4));
movlength = size(movall,4);

for frame = movlength+1:movlength+9
    movall(:,:,:,frame) = movall(:,:,:,movlength);
end

movlogo = immovie(movall);
movie2avi(movlogo,'out\logo','fps',5);
close;