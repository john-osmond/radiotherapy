% Start up:

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Start up:

clear
close all hidden
clc
tic

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Create some data specific variables:

darkimg = 'dark_b';
ext = 'mi3';
devin = 'v';
devout = 'vp';

notot = 100;
nodis = 2;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Loop round all dark frames, open and append to img array:

for no = 2:(notot-1)

    if ( no < 10 )
        name = [darkimg '_00' num2str(no) '.' ext];
    elseif ( no < 100 )
        name = [darkimg '_0' num2str(no) '.' ext];
    else
        name = [darkimg '_' num2str(no) '.' ext];
    end
    
    [img(:,:,no-nodis+1)] = double(mi3read(name, devin));
    
    %if (no == nodis)
    %    imgsum = img;
    %else
    %    imgsum = imgsum + img;
    %end
        
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% FIXED PATTERN NOISE:

valmean = mean(mean(mean(img)))
valstd = sqrt(mean(mean(mean((img - valmean).^2))))
valmin = min(min(min(img)));
valmax = max(max(max(img)));

% Plot noise histogram:

binsize=20
nbins = single((valmax - valmin)/binsize);
imgsize = size(img);
[histy, histx] = hist(double(reshape(img,prod(imgsize),1)),nbins);
%[histy, histx] = hist(double(reshape(imgfpn,prod(imgsize),1)),nbins);
bar(histx,histy/imgsize(3),'facecolor',[0.5 0.5 0.5],'barwidth',1,'linewidth',1.2);
set(gca,'xlim',[valmean-(6*valstd) valmean+6*valstd],'Fontsize',16,'linewidth',1.2,'fontweight','demi');
xlabel('Fixed Pattern Noise (DN)','Fontsize',18);
ylabel('Frequency (pixels frame^{-1})','Fontsize',18);

text(370,26000,'\mu = 294 DN = 3328 e^{-}','fontsize',18)

print('-djpeg','out/fpn_hist.jpg');
print('-deps','out/fpn_hist.eps');
close;

% Plot image of FPN:

imgmean = sum(img, 3) / size(img, 3);
gaussfilt = fspecial('gaussian',[32 32],2);
imgsmooth = filter2(gaussfilt,imgmean);

colormap(gray);
imagesc(imgmean,[valmean-(3*valstd) valmean+3*valstd]);
set(gca,'fontsize',16,'linewidth',1.2);
xlabel('X (pixels)','Fontsize',18);
ylabel('Y (pixels)','Fontsize',18);

print('-djpeg','out/fpn_img.jpg');
print('-deps','out/fpn_img.eps');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% STOCHASTIC NOISE:

% Create corrected image array:

for no = 1:size(img,3)
    imgcor(:,:,no) = img(:,:,no) - imgmean;
end

clear img

valmean = mean(mean(mean(imgcor)))
valstd = sqrt(mean(mean(mean((imgcor - valmean).^2))))
valmin = min(min(min(imgcor)));
valmax = max(max(max(imgcor)));

% Plot noise histogram:

binsize=2;
nbins = single((valmax-valmin)/binsize);
imgsize = size(imgcor);

[histy, histx] = hist(double(reshape(imgcor,prod(imgsize),1)),nbins);
bar(histx,histy/imgsize(3),'facecolor',[0.5 0.5 0.5],'barwidth',1,'linewidth',1.2);
set(gca,'xlim',[valmean-(6*valstd) valmean+(6*valstd)],'Fontsize',16,'linewidth',1.2,'fontweight','demi');
xlabel('Stochastic Noise (DN)','Fontsize',18);
ylabel('Frequency (pixels frame^{-1})','Fontsize',18);

x = valmean-(6*valstd):0.1:valmean+(6*valstd);
y = 300000 * (1/sqrt(valstd*2*pi)) * exp(-((x-valmean).^2)/(2*valstd^2));
hold on;
plot(x,y,'k','linewidth',1.5)
hold off;

text(5,60000,'\sigma = 3.5 DN = 39 e^{-}','fontsize',18)

print('-djpeg','out/sto_hist.jpg');
print('-deps','out/sto_hist.eps');

close;
clear all;