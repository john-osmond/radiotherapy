

a(1,:) = [1        73.91    1.83    2.62    73.76      74.47       1.71    3.41                -0.15     -0.20          +0.56    -0.76           -0.12     +0.79]
a(2,:) = [2        69.34    1.83    5.00    69.19      69.71       1.95    4.64                -0.15     -0.22          -0.37    -0.53           +0.12     -0.36]
a(3,:) = [3        37.04    1.83    4.50    35.77      37.03       1.95    4.39                -1.27     -3.43          -0.01    -0.03           +0.12     -0.11]
a(4,:) = [4        22.26    1.83    4.68    21.82      22.25       1.95    4.39                -0.44     -1.98          -0.01    -0.04           +0.12     -0.29]
a(5,:) = [5        08.16    1.83    6.00    08.26      08.24       1.71    6.10                +0.10     +1.23          +0.08    +0.98           -0.12     +0.10]
a(6,:) = [6        15.37    1.83    0.00    14.56      15.41       1.71    0.00                -0.81     -5.27          +0.04    +0.26           -0.12      0.00]

a(1) = mean([72.7129   73.6488   73.7534   73.9919   73.9738   74.0573   74.1560])
a(2) = mean([68.7008   69.2703   69.2864   69.2754   69.2593   69.3468   69.2059])
a(3) = mean([34.9481   35.9242   35.9685   35.8709   35.8266   35.9645   35.8679])
a(4) = mean([21.9043   22.1448   22.2726   22.2022   22.2264   22.1821   22.3703   19.2567])
a(5) = mean([8.1259    8.3041    8.2165    8.2769    8.2900    8.3161    8.3021    8.2115])
a(6) = mean([14.5281   14.5422   14.5311   14.5855   14.5774   14.5532   14.6056  ])

% Find positions of dots:

dots = 'dots';
bg = 'bg_all.vid';

width = 525;
height = 525;
imgarea = width*height;
class = 'uint16';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if (exist([dots '_all.vid']) == 0)    
    merge(dots, class, width, height);
end

[img] = proc([dots '_all.vid'], bg, 'none', class, 525, 525, 'n');

neg =  1 - img./max(max(img));
bw = im2bw(neg, 0.78);
bw2 = imfill(bw,'holes');
L = bwlabel(bw2);

s = regionprops(L, 'centroid');
centroids = cat(1, s.Centroid);

imgbw = im2bw(img, graythresh(img));
imglab = bwlabel(imgbw);
a = regionprops(imglab, 'centroid');

gaussfilt = fspecial('gaussian',[32 32],1);
imgsmooth = filter2(gaussfilt,neg);


centroids = cat(1, a.Centroid)

% Find centre of mass of an image:

xsum = 0;
ysum = 0;
for x = 1:width
    for y = 1:height
        xsum = xsum + (x*img(x,y));
        ysum = ysum + (y*img(x,y));
    end
end

meanco = [xsum ysum] ./ sum(sum(img));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Notes:

% Look at RST's correction algorithm.

% Derive a transform function for each dot. Interpolate to create either a
% matrix of transform parameters or transform parameters as a function of
% position.

% Code to plot sum of pixels vs segment area:

[jaws leaves] = leafread('out/lung_export.txt');
sumleaves = sum(leaves,2);
area = permute(sumleaves(:,:,6),[2 1]);
sumpix=[1.53e8 1.43e8 6.76e7 3.87e7 1.29e7 2.29e7];
plot(area,sumpix,'d','markersize',15,'markerfacecolor','b','markeredgecolor','k','linewidth',2)
set(gca,'xlim',[9.15 74.49],'Fontsize',14)
xlabel('Segment Area (cm)','Fontsize',14);
ylabel('Sum Over All Pixels','Fontsize',14);
title('Pixel Sum vs Segment Area','Fontsize',14);

par = polyfit(area,sumpix,1);
xfit = min(area)-1:.1:max(area)+1;
yfit = polyval(par,xfit);

hold on;
plot(xfit,yfit,'k','linewidth',1.5)
hold off;
print('-dbmp','out/sumpix vs area.bmp');
