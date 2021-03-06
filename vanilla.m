% Set some data specific variables:

imgname = 'dark.mi3';

class = 'uint8';
width = 520;
height = 520;
imgarea = double(width*height);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Open image file:

fp = fopen(imgname,'r');
imgdata1 = fread(fp, imgarea, class);
imgdata2 = bitand(fread(fp, imgarea, class), 15);
imgdata = 4095-(uint16(imgdata1)+(uint16(imgdata2)*256));
img = reshape(imgdata, width, height);
fclose(fp);

imtool(img);

% Mean = 240;

hist(imgdata,20);
