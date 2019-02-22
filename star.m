% Start up:

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear
close all hidden
clc
tic

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Set some data specific variables:

width = 525;
height = 525;
class = 'uint16';

for frame = 1:3
    
    [img] = proc(['atlantis_' num2str(frame) '.vid'], 'atlantis_bg_1.vid', 'atlantis_of_1.vid', class, 525, 525, 'n');
    
    if (frame == 1)
        
        imgsum = img;
    
    else
       
        imgsum = imgsum + img;
        
    end

end

% Crop obscured region:

xrange = [440 500];
yrange = [180 230];
croparea = [(xrange(2)-xrange(1)+1)*(yrange(2)-yrange(1)+1)];
imgobs = imgsum(yrange(1):yrange(2), xrange(1):xrange(2));

[ydata, xdata] = hist(reshape(imgobs,1,croparea), 200);
[a1, mu1, sigma1, a2, mu2, sigma2] = gaussfit(xdata, ydata, 's');

% Crop background region:

xrange = [440 500];
yrange = [80 140];
croparea = [(xrange(2)-xrange(1)+1)*(yrange(2)-yrange(1)+1)];
imgamb = imgsum(yrange(1):yrange(2), xrange(1):xrange(2));

[ydata, xdata] = hist(reshape(imgamb,1,croparea), 200);
[a1, mu1, sigma1, a2, mu2, sigma2] = gaussfit(xdata, ydata, 's');

%

imgmin = min(min(imgsum));
imgmax = max(max(imgsum));
%imshow(imgsum,[imgmin+(0.05*(imgmax-imgmin)) imgmax-(0.05*(imgmax-imgmin))]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%kernal = zeros(120, 120);
%kernal(31:90, 31:90) = 1;
kernal = imgsum(135:275, 400:525);

corr = xcorr2(imgsum,kernal);

a = zeros(525, 525);
a(101:150, 101:150) = 1;

b = ones(50,50);

c = xcorr2(a,b);

imtool(c);
