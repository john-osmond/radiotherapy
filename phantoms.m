% Start up:

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear
close all hidden
clc
tic

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Set some data specific variables:

dark = 'dark_b';
open = 'open';
devin = 'v';
devout = 'vp';
ext = 'mi3';

frametot = 50;
phantomall =  {'lasvegas' 'qc3' 'skull' 'skull2'};
phantomall = {'skull2'};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Merge relevent images if necessary:

if (exist([dark '_all.' ext]) == 0)
    merge(dark, ext, devin);
end

if (exist([open '_all' ext]) == 0)
    merge(open, ext, devin);
end

% Loop round all phantoms:

for phantom = phantomall
    
    phantom = char(phantom);
    if (exist([phantom '_all.' ext]) == 0)
        merge(phantom, ext, devin);
    end
    
    [img] = mi3read([phantom '_all.' ext], devout);
    [imgd] = mi3read([dark '_all.' ext], devout);
    [imgo] = mi3read([open '_all.' ext], devout);
    
    % Process image:
    
    imgfin = (img-imgd)./((imgo-imgd)/max(max(imgo-imgd)));
    imgfin = permute(imgfin, [2 1]);
    
    % Print phantom image to bitmap:
    
    imagesc(imgfin);
    colormap(bone);
    xlabel('X (pixels)','fontsize',18,'linewidth',1.2);
    ylabel('Y (pixels)','fontsize',18,'linewidth',1.2);
    set(gca,'fontsize',16,'linewidth',1.2);
    print('-djpeg',['out/' phantom '.jpg']);
    print('-deps',['out/' phantom '.ps']);
    
    % Print negative phantom image to bitmap:
    
    imgneg = max(max(imgfin)) - imgfin;
    imagesc(imgneg);
    colormap(bone);
    xlabel('X (pixels)','fontsize',18,'linewidth',1.2);
    ylabel('Y (pixels)','fontsize',18,'linewidth',1.2);
    set(gca,'fontsize',16,'linewidth',1.2);
    print('-djpeg',['out/' phantom '_neg.jpg']);
    print('-deps',['out/' phantom '_neg.ps']);
    close;
     
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%