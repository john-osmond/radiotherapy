% SCRIPT TO COMPARE LAS DATA TO VANILLA

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% START UP

% Clear variables and screen:

clear all
clc

% Set variables:

indir = '/Users/josmond/Data/LAS/Moving_Marker';
outdir = '/Users/josmond/Results/Moving_Marker';
name = 'head4';
darkname = 'darkforhead';
openname = 'openforhead';
ext = 'raw';
startframe = 4;
endframe = 29;
xwid = 1350;
ywid = 1350;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% READ DATA

img = mi3read([indir '/' darkname '_data.' ext], 'las', [startframe endframe]);
darkimg = double(mean(img,3));
for i = 1:size(img,3)
    img(:,:,i) = img(:,:,i)-darkimg;
end
stoimg = std(img,0,3);
clear img;

img = mi3read([indir '/' openname '_data.' ext], 'las', [startframe endframe]);
openimg = double(mean(img,3))-darkimg;
%openimg = openimg/max(max(openimg));
openimg(find(openimg == 0)) = 1;
clear img;

img = mi3read([indir '/' name '_data.' ext], 'las', [startframe endframe]);
for i = 1:size(img,3)
    img(:,:,i) = medfilt2((img(:,:,i)-darkimg)./openimg,[3 3]);
end

% Evaluate CNR:

co = [700 800 1000 1100];
signal = mean2(mean(img(co(1):co(2),co(3):co(4),:),3));
noise = mean2(std(img(co(1):co(2),co(3):co(4),:),0,3));

co = [100 200 1000 1100];
signal2 = mean2(mean(img(co(1):co(2),co(3):co(4),:),3));
noise2 = mean2(std(img(co(1):co(2),co(3):co(4),:),0,3));

cnr = (signal2-signal)/sqrt((noise^2)+(noise2^2));

% Process image:

rawimg = double(mean(img,3));

negimg = -1.*rawimg;
negimg = fliplr(rot90(negimg));

cropimg = negimg(200:1060,360:1350);
imtool(cropimg);

%imagesc(cropimg);
%colormap('gray');
%axis image;
%axis off;
%print('-depsc2','-tiff',[outdir '/' plotname '_col.eps']);
%print('-deps2',[outdir '/' plotname '_bw.eps']);
    