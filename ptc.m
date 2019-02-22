% Start up:

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear
close all hidden
clc
tic

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Create some data specific variables:

grey = 'lighte';
dark = 'darke';
ext = 'mi3';
devin = 'v';
devout = 'vp';
fit = 'yes';

xrange = [1 520];
yrange = [48 486];
irange = [0 4095];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Open all grey images:

greyall = dir([grey '_*.' ext]);
for frame = 1:length(greyall)
    [imgg(:,:,frame)] = double(mi3read(greyall(frame).name, devin));
end

% Open all dark images:

darkall = dir([dark '_*.' ext]);
for frame = 1:length(darkall)
    [imgd(:,:,frame)] = double(mi3read(darkall(frame).name, devin));
end

% Generate signal and noise images:

imgfpn = mean(imgd,3);
clear imgd;

for frame = 1:size(imgg,3)
   imgg(:,:,frame) = imgg(:,:,frame) - imgfpn;
end

imgs = mean(imgg,3);
imgs(find(imgs < 0)) = 0;
imgg(find(imgg < 0)) = 0;

%imgn = var(imgg,0,3);
imgn = (1/sqrt(2)) .* mean(sqrt(diff(imgg,1,3).^2),3);
clear imgg;

%imgm = mean(imgg,3);
%imgs = mean(imgg,3) - mean(imgd,3);
%clear imgd;
%for frame = 1:size(imgg,3)
%    imgvar(:,:,frame) = (imgg(:,:,frame) - imgm).^2;
%end
%imgn = mean(imgvar,3);
%clear imgg imgvar;

% Crop image:

imgsc = imgs(yrange(1):yrange(2),xrange(1):xrange(2));
imgnc = imgn(yrange(1):yrange(2),xrange(1):xrange(2));

%ign = find(imgg1 < irange(1) | imgg1 > irange(2));
%imgsc(ign) = 0;
%imgnc(ign) = 0;

% Select range and fit straight line in log space:

if ( strcmp(fit,'yes') == 1)
    
    indsel = find(imgsc > 0.01 & imgsc < 2);
    par = polyfit(log10(imgsc(indsel)),log10(imgnc(indsel)),1)
    xfit = -2:1:4;
    yfit = polyval(par,xfit);
    
    indsel = find(imgsc > 10 & imgsc < 500);
    par2 = polyfit(log10(imgsc(indsel)),log10(imgnc(indsel)),1)
    yfit2 = polyval(par2,xfit);
    
    % Calculate gain:
    
    1/par2(1)
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

colormap(gray);
imagesc(imgs);
set(gca,'fontsize',16,'linewidth',1.2);
xlabel('X (pixels)','Fontsize',18);
ylabel('Y (pixels)','Fontsize',18);

print('-djpeg','out/ptc_img.jpg');
print('-deps','out/ptc_img.eps');

% Plot noise against signal:

loglog(imgsc,imgnc,'d','markersize',8,'markeredgecolor','k','markerfacecolor','w','linewidth',1.2);
set(gca,'xlim',[0.1 4000],'ylim',[0.1 20],'fontsize',16,'linewidth',1.2);
line([10 10],[0.1 20],'color','k','linewidth',1.5,'linestyle','--');
line([500 500],[0.1 20],'color','k','linewidth',1.5,'linestyle','--');
text(0.15,8,'1/k = 11.3 e^{-} DN^{-1}','fontsize',18)

%plot(imgsc(find(imgsc>10)),imgnc(find(imgsc>10)),'d','markersize',8,'markeredgecolor','k','markerfacecolor','w','linewidth',1);
%set(gca,'xlim',[0 4000],'ylim',[0 20],'fontsize',16);
%set(gca,'xlim',[10 4000],'ylim',[5 20],'fontsize',16);

%ylabel('Variance (DN^{2})','Fontsize',18);
ylabel('Noise (DN)','Fontsize',18);
xlabel('Signal (DN)','Fontsize',18);

% Plot fit line:

if ( strcmp(fit,'yes') == 1)
    
    hold on;
    plot((10.^xfit),(10.^yfit2),'k','linewidth',1.5);
    hold off;

end

% Print to file:

print('-djpeg','out/ptc.jpg');
print('-deps','out/ptc.ps');
close;

%set(gca,'xlim',[1 5000],'ylim',[1 50],'fontsize',16);

%print('-djpeg','out/ptc_crop.jpg');
%print('-deps','out/ptc_crop.ps');

clear all;