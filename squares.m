% Start up:

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear
close all hidden
clc
tic

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Create some data specific variables:

fivename = '5x5';
tenname = '10x10';

openname = 'openfield';
darkname = 'dark_b';
ext = 'mi3';
devin = 'v';
devout = 'vp';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Merge relevent images if necessary:

if (exist([fivename '_all.' ext]) == 0)
    merge(fivename, ext, devin);
end

if (exist([tenname '_all.' ext]) == 0)
    merge(tenname, ext, devin);
end

if (exist([openname '_all.' ext]) == 0)
    merge(openname, ext, devin);
end

if (exist([darkname '_all.' ext]) == 0)
    merge(darkname, ext, devin);
end

% Open images:

[img5] = mi3read([fivename '_all.' ext], devout);
[img10] = mi3read([tenname '_all.' ext], devout);
[imgo] = mi3read([openname '_all.' ext], devout);
[imgd] = mi3read([darkname '_all.' ext], devout);

% Correct images:

imgofin = (imgo - imgd)./max(max(imgo));
img5fin = (img5 - imgd)./imgofin;
img10fin = (img10 - imgd)./imgofin;

% Remove bright columns:

img10fin(:,1:10) = img10fin(:,11:20);
img10fin(:,511:520) = img10fin(:,501:510);

img10fin(1:10,:) = img10fin(11:20,:);
img10fin(511:520,:) = img10fin(501:510,:);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Calculate area and length:

pixelcmsq = size(find(img10fin > 0.5*max(max(img10fin))),1)/100
pixelcm = sqrt(pixelcmsq)

% Calculate centre:

xcen = sum(mean(img10fin,1) .* (1:size(img10fin,2))) / sum(mean(img10fin,1))
ycen = sum(mean(img10fin,2) .* permute(1:size(img10fin,1),[2 1])) / sum(mean(img10fin,2))

xc = xcen - (pixelcm * 20)
yc = ycen - size(img10fin,1)/2

% Check for rotation:

i=0;
for x = round(xcen-(4*pixelcm)):round(xcen+(4*pixelcm))
    
    % Generate profile:
    
    yprofstart = permute(img10(:,x),[2 1]);
    
    % Remove repeating values (for interp1) and resort into x order:
    
    [yprofun, ind] = unique(yprofstart);
    yprofun(2,:) = ind;
    yprof = permute(sortrows(permute(yprofun,[2 1]),2),[2 1]);
    
    % Find edges of square then interpolate to improve precision:
    
    thresh = 0.5*max(yprof(1,:));
    ylo = min(find(yprof(1,:) > thresh));
    yhi = max(find(yprof(1,:) > thresh));
    ylofin = interp1(yprof(1,ylo-2:ylo+1),yprof(2,ylo-2:ylo+1),thresh);
    yhifin = interp1(yprof(1,yhi-1:yhi+2),yprof(2,yhi-1:yhi+2),thresh);
    
    % Write results to output array:
    
    if (ylofin > 40 && yhifin < 430)
        i = i + 1;
        yall(:,i) = [ylofin yhifin x];
    end
        
end

% Plot rotation:

yuse = 1;

plot(yall(3,:),yall(yuse,:),'-k','linewidth',1.2);
set(gca,'Fontsize',16,'linewidth',1.2);
ylabel('Y Lower Edge (pixels)','Fontsize',18);
xlabel('X (pixels)','Fontsize',18);

% Fit rotation:

par = polyfit(yall(3,:),yall(yuse,:),1);
yfit = polyval(par,yall(3,:));

% Plot fit:

hold on;
plot(yall(3,:),yfit,'k','linewidth',1.5)
hold off;
print('-djpeg','out/rotation.jpg');
print('-deps','out/rotation.ps');
close;

% Calculate angle of rotation:

angle = atan(par(1))*(180/pi)