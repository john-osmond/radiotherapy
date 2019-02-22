% Start up:

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear
close all hidden
clc
tic

localcor = 0;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Create some data specific variables:

%phantom = 'atlantis_0cm_insert';
%phantombg = 'atlantis_0cm_noinsert';

phantom = 'atlantis_6cm_insert';
phantombg = 'atlantis_6cm_noinsert';

open = 'openfield';
dark = 'dark_b';
ext = 'mi3';
devin = 'v';
devout = 'vp';

%angle = 0.78;
angle = 1.4;

% Define box parameters

%boxcorn = [142 111];
boxcorn = [135 130];

boxsize = 48;
boxsep = 83;

%thickall = [26 28 0 32 18 20 22 24 10 12 14 16 2 4 6 8];
thickall = [8 6 4 2 16 14 12 10 24 22 20 18 32 0 28 26];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Set some fixed variables:

imgarea=520*520;

% Merge relevent images if necessary:

if (exist([phantom '_all.' ext]) == 0)
    merge(phantom, ext, devin);
end

if (exist([phantombg '_all.' ext]) == 0)
    merge(phantombg, ext, devin);
end

if (exist([open '_all.' ext]) == 0)
    merge(open, ext, devin);
end

if (exist([dark '_all.' ext]) == 0)
    merge(dark, ext, devin);
end

% Open images:

[img] = mi3read([phantom '_all.' ext], devout);
[imgbg] = mi3read([phantombg '_all.' ext], devout);
[imgo] = mi3read([open '_all.' ext], devout);
[imgd] = mi3read([dark '_all.' ext], devout);

% Scale imgo to background according to 

xpos = 384
ypos = 213
squareco = [xpos xpos+boxsize ypos ypos+boxsize];
squareco = uint16(squareco);
boxerr = 5;
sqsmallco = [squareco(1)+boxerr squareco(2)-boxerr...
            squareco(3)+boxerr squareco(4)-boxerr];

imgsq = imgbgrot(sqsmallco(3):sqsmallco(4),sqsmallco(1):sqsmallco(2));

% Rotate images:

imgrot = imrotate((img - imgd), angle, 'bilinear');
imgrot2 = imgrot;

imgbgrot = imrotate((imgbg - imgd), angle, 'bilinear');
imgbgrot2 = imgbgrot;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Display image:

imagesc((imgrot./imgbgrot), [0.93 1.03]);
colormap(gray);

% NB When selecting image co-ordinates first part is y from top down, and
% second is x!!

% Define box parameters:

boxno = 4;
boxgap = boxsep - boxsize;
boxerr = 5;

% Initiate arrays:

sigall = [];

% Loop round all squares in x then y:

for x = 1:boxno
    for y = 1:boxno
        
        z = ((x-1)*4)+y;
        
        % Define co-ordinates of top left corner of each box:

        xpos = uint16(boxcorn(1) + ((x-1)*boxsep))
        ypos = uint16(boxcorn(2) + ((y-1)*boxsep))
       
        % Draw square on image:
        
        rectangle('Position',[xpos,ypos,boxsize,boxsize],...
            'LineWidth',1,'EdgeColor','r','linewidth',1.5);
        
        % Define co-ordinates of three concentric squares:
        
        squareco = [xpos xpos+boxsize ypos ypos+boxsize];
        squareco = uint16(squareco);
        
        sqsmallco = [squareco(1)+boxerr squareco(2)-boxerr...
            squareco(3)+boxerr squareco(4)-boxerr];
        
        % Cut out squares:
        
        imgbgsq = imgbgrot(sqsmallco(3):sqsmallco(4),sqsmallco(1):sqsmallco(2));
        imgsq = imgrot(sqsmallco(3):sqsmallco(4),sqsmallco(1):sqsmallco(2));

        % Parameterise square:
        
        val = mean(mean(imgsq));
        valbg = mean(mean(imgbgsq));
        valall(:,z) = [val; valbg; y-1; x-1];
            
    end
end

valall(5,:) = sqrt((valall(3,:)-1.44).^2 + (valall(4,:)-1.46).^2);

%meanall = 1 - (valall(1,:) ./ valall(2,:));
meanall =  100 * (valall(2,:) - valall(1,:)) ./ mean([valall(1,:) valall(2,:)]);

%     [8      6      4      2      16     14     12     10     24     22     20     18     32     0      28     26];
%cor = [0.0084 0.0052 0.0052 0.0084 0.0052 0      0      0.0052 0.0052 0      0      0.0052 0.0084 0.0052 0.0052 0.0084];
% meancor = meanall - cor;

meancor = meanall - (valall(5,:)*0.4951 - 0.7421);
%meancor = meanall

% Fit curve:

xfit = min(thickall)-1:.1:max(thickall)+1;
model = polyfitn(thickall,meancor,'x');
par = [model.Coefficients 0]
yfit = polyval(par,xfit);

yfit = polyval(par,xfit);
pred = thickall.*par(1) + par(2);
sumres = meancor - pred;
std(sumres)

sumrespos = (sumres.*-1) - min(sumres.*-1);
xcent = sum(valall(3,:) .* sumrespos)/sum(sumrespos)
ycent = sum(valall(4,:) .* sumrespos)/sum(sumrespos)

% Determine correction function:

polyfit(valall(5,:),sumres,1)

% Print image:

xlabel('x');
ylabel('y');
title('Phantom Image');
print('-djpeg',['out/atlantis_proc.jpg']);
print('-deps',['out/atlantis_proc.ps']);

% Calcualate detection confidences:

%refco = find(meanall == max(meanall));
%confall = (meanall(refco) - meanall) ./ (sqrt(sigall.^2 + sigall(refco)^2));
%proball = 100.*erf(confall.*(sqrt(0.5)));

% Write results to screen:

%fprintf('\n%s\n','Mean matrix (?):');
%reshape(meanall,boxno,boxno)
%fprintf('\n%s\n','Confidence matrix (Sigma):');
%reshape(confall,boxno,boxno)
%fprintf('\n%s\n','Confidence matrix (%):');
%reshape(proball,boxno,boxno)

% Plot linearity:

%errorbar(thickall,meanall,sigall,'d','markersize',10,'markeredgecolor','b','markerfacecolor','b','linewidth',1.5);
plot(sort(thickall),sort(meancor),'d','markersize',12,'markeredgecolor','k','markerfacecolor',[1 1 1],'linewidth',1.0);
set(gca,'xlim',[0 32],'ylim',[0 6],'fontsize',10);
pbaspect([1 0.7 1]);

ylabel('Contrast (%)','Fontsize',12);
xlabel('Bone Thickness (mm)','Fontsize',12);

hold on;
%plot(thickall,meanall,'s','markersize',16,'markeredgecolor','k','linewidth',1.5);
plot(xfit,yfit,'k','linestyle','-','linewidth',1.0);
hold off;
print('-djpeg','out/linearity.jpg');
print('-deps','out/linearity.ps');
close;

% Plot residuals:

plot(thickall,sumres,'d','markersize',12,'markeredgecolor','k','markerfacecolor','b','linewidth',1.2);
line([0 32],[0 0],'color','k','linewidth',1.5);
%set(gca,'xlim',[-1 33],'ylim',[-0.003 0.003]);
ylabel('Residual','Fontsize',18);
xlabel('Insert Thickness (mm)','Fontsize',18);
print('-djpeg','out/residual.jpg');
print('-deps','out/residual.ps');
close;

rms = mean(sqrt((meancor - polyval(par,thickall)).^2))

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%plot(sort(thickall),sort(proball),'--d','markersize',10,'markeredgecolor','k','markerfacecolor','b','linewidth',1.5);
%line([0 32],[68.3 68.3],'color','k','linewidth',1.5);
%line([0 32],[95.4 95.4],'color','k','linewidth',1.5);
%set(gca,'xlim',[0 32]);
%set(gca,'ylim',[0 100]);
%ylabel('Detection Confidence (%)','Fontsize',18);
%xlabel('Insert Thickness (mm)','Fontsize',18);
%print('-dbmp','out/conf.bmp');
%print('-deps','out/conf.ps');
%close;