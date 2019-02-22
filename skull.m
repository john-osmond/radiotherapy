% Start up:

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear
close all hidden
clc
tic

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Set some data specific variables:

phantom = 'skull2';
dark = 'dark_b';
open = 'open';
devin = 'v';
devout = 'vp';
ext = 'mi3';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Delete existing averaged files:

if ( exist([phantom '_all.' ext]) == 2 )
    delete([phantom '_all.' ext]);
end

% Merge relevent images if necessary:

if (exist([dark '_all.' ext]) == 0)
    merge(dark, ext, devin);
end

if (exist([open '_all' ext]) == 0)
    merge(open, ext, devin);
end

[imgd] = imrotate(mi3read([dark '_all.' ext], devout), 270, 'bilinear');
[imgo] = imrotate(mi3read([open '_all.' ext], devout), 270, 'bilinear');

% Generate images of different image quality

nameall = dir([phantom '_*.' ext]);

for frame = 1:length(nameall)
    [img(:,:,frame)] = mi3read(nameall(frame).name, devin);
end

sumall = [1 2 4 8 16 32];

for i = 1:length(sumall);
    
    imga = imrotate(mean(img(:,:,1:sumall(i)), 3), 270, 'bilinear');
    imgfin = (imga - imgd)./(imgo - imgd);
    imgall(:,:,i) = imgfin;
    
    if (i ~= length(sumall))
    
    imgb = imrotate(mean(img(:,:,sumall(i)+1:sumall(i)*2), 3), 270, 'bilinear');
    
    % Calculate S/N:
    
    boxco = [270 370 110 210];
    imgcropa = imga(boxco(3):boxco(4),boxco(1):boxco(2));
    imgcropb = imgb(boxco(3):boxco(4),boxco(1):boxco(2));
    imgcropo = imgo(boxco(3):boxco(4),boxco(1):boxco(2));
        
    meana = mean(mean(imgcropa));
    meanb = mean(mean(imgcropb));
    meano = mean(mean(imgcropo));
    sig = mean([meana meanb]);
    con = abs(sig - meano);
    %noise = (1/sqrt(2)) .* sqrt(mean(mean((imgcropa-imgcropb).^2)));
    noise = 0.5*std(reshape(imgcropa-imgcropb,1,prod(size(imgcropa))));
    snr(i) = sig/noise;
    cnr(i) = con/noise;
    
    end
     
    % Print image:
    
    %subplot(3, 2, i, 'align')
    imgneg = sqrt((imgfin-max(max(imgfin))).^2);
    imagesc(imgneg);
    %set(gcf,'InvertHardcopy','off');
    colormap('gray');
    axis image;
    axis off;
    
    if ( i == 1 )
        rectangle('Position', [boxco(1), boxco(3), ...
            boxco(2)-boxco(1), boxco(4)-boxco(3)], 'LineWidth',1.5,'EdgeColor','k');
    end
    %text(15,30,['N = ' num2str(sumall(i))], 'color', 'w', 'fontsize', 18);
    print('-djpeg',['out/' phantom '_' num2str(sumall(i)) '.jpg']);
    print('-deps',['out/' phantom '_' num2str(sumall(i)) '.ps']);
    close;
      
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

imgcom = [imgall(:,:,1) imgall(:,:,2); imgall(:,:,3) imgall(:,:,4); ...
    imgall(:,:,5) imgall(:,:,6)]';

doseroot = sqrt(sumall(1:5)*(400/(4.1*60)));

% Print plots for paper:

plot([doseroot 7.2134], [cnr 59], 'd',...
    'markersize',14,'markeredgecolor','b','markerfacecolor',[1 1 1],...
    'linewidth',1.6);
set(gca,'xlim',[0 8],'ylim',[0 70],'Fontsize',14,'linewidth',1.6)
line([0 8],[5 5],'Color','k','linestyle','--','linewidth',1.6);
text(4,9,'CNR = 5 (Rose 1973)','Fontsize',16)
text(5.8,63,'p = 0.999','Fontsize',16)
pbaspect([1 0.7 1]);

xfit = 0:1:8;
model = polyfitn(doseroot,cnr,'x');
par = [model.Coefficients 0]
yfit = polyval(par,xfit);
hold on
plot(xfit,yfit,'-k','linewidth',1.6);
hold off

xlabel('Dose^{0.5} (cGy^{0.5})','Fontsize',16);
ylabel('CNR','Fontsize',16);
print('-djpeg','out/cnr.jpg');
print('-deps','out/cnr.ps');
close;