% Start up:

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear
close all hidden
clc
tic

% 1-3: Square; 4,10: IMRT; 5,16-17,19: Noise; 6,15,18,20,21: ?; 7-9,13: open field; 11: QC3,
% 12: Las Vegas; 14: Skull;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Set some data specific variables:
   
    [Hdr, Imgs, Rng] = ReadRil('List004.ril');
    imgsum=(sum(Imgs,3));
    imgsize=size(Imgs);
    imgmean=imgsum./imgsize(3);
    
    [ofhdr, ofimg, ofrng] = ReadRil('List007.ril');
    ofsum=(sum(ofimg,3));
    ofsize=size(ofimg);
    ofmean=ofsum./ofsize(3);

    imgcor = imgmean./ofmean;
    
    [ydata, xdata] = hist(reshape(imgmean,1,imgsize(1)*imgsize(2)), 200);
    [a1, mu1, sigma1, a2, mu2, sigma2] = gaussfit(xdata, ydata, 'd');
    
    
%croprange=[Rng(1)+0.05*(Rng(2)-Rng(1)) Rng(2)-0.05*(Rng(2)-Rng(1))];
%imshow(imgmean,[croprange]);