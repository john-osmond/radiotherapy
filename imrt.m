% Clear all:

clear
close all hidden
clc
tic

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Create some data specific variables:

data = 'imrt_b';
dark = 'dark_b';
open = 'openfield';
devin = 'v';
devout = 'vp';
ext = 'mi3';
grouptot = 1;
frametot = 205;

% Create additional variables:

pixthresh = 4000; % (50%)
angle = 0.45;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Merge relevent images if necessary:

if (exist([dark '_all.' ext]) == 0)
    merge(dark, ext, devin);
end

if (exist([open '_all.' ext]) == 0)
    merge(open, ext, devin);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Read in linac prescription data:

[jaws leaves] = leafread('out/lung_export.txt');
sizeleaves = size(leaves);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

delete('out/leafmatch_*')
delete('out/leafcomp_*')
delete('out/leafdisp_*')

% Initiate some variables:

sumresall = [];
sumpixall = [];
nopixall = [];
pixresall = [];
frameall = [];
scatall = [];
dispall = [];
areaall = [];
mall = [];
xcall = [];
ycall = [];
framecount = 0;
framestat = zeros(2,grouptot*frametot);
img = imrotate(mi3read([data '_003.' ext], devin),angle,'bilinear');
imgsum = double(zeros(525,525,6));
imgmaskold = imgsum(:,:,1);
imgold = imgsum(:,:,1);
beam = 0;
segment = 1;
beamsum = zeros(1,6);
beamdur = zeros(1,6);

% Loop around all groups then frames:

for group = 1:grouptot
for frame = 3:frametot
    
    framecom = ( (group-1) * frametot ) + frame;
        
    % Open images:
    
    if ( frame < 10 )
        framename = [data '_00' num2str(frame) '.' ext];
    elseif ( frame < 100 )
        framename = [data '_0' num2str(frame) '.' ext];
    else
        framename = [data '_' num2str(frame) '.' ext];
    end
    
    [img] = mi3read(framename, devin);
    img = double(img .* 1);
    [imgd] = mi3read([dark '_all.' ext], devout);
    [imgo] = mi3read([open '_all.' ext], devout);
    
    % Correct image:
    
    imgo = (imgo-imgd)/max(max(imgo));
    imgfin = (img - imgd)./imgo;
    img = imrotate(rot90(imgfin,2),angle,'bilinear');
    
    % Remove bright columns:
    
    img(:,1:10) = img(:,11:20);
    img(:,511:520) = img(:,501:510);
    
    img(1:10,:) = img(11:20,:);
    img(511:520,:) = img(501:510,:);

    % Make a mask describing pixels above threshold:
        
    imgmask = img;
    filt = fspecial('average',16);    
    imgsmooth = filter2(filt,img);
    threshold = 0.5*max(max(imgsmooth));
    if (threshold < 500)
        threshold = 500;
    end
    imgmask(find(img < threshold)) = 0;
    imgmask(find(img >= threshold)) = 1;
    
    %sum(sum(imgmask))
    
    sumpix = sum(sum(img));
    nopix = sum(sum(imgmask));
    
    % Write linac status and segment number to array:
    
    framestat(:,framecom) = [1 segment];
        
    % Count number of changed pixels:
        
    maskres = (imgmask - imgmaskold).^2;
    pixres = sum(sum(maskres));
    imgres = (img - imgold).^2;
    sumres = sum(sum(imgres));
        
    % Write variables into arrays:

    frameall = [frameall framecom];
    sumpixall = [sumpixall sumpix];
    sumresall = [sumresall sumres];
    nopixall = [nopixall nopix];
    pixresall = [pixresall pixres];
    %scatall = [scatall scatmean];
        
    % Store results of this loop:
        
    imgmaskold = imgmask;
    imgold = img;
        
    % Report results:
        
    fprintf('\n%s %i %s %i %s %.0f %s %i %s %i\n','group:',group,'frame:',frame,'threshold:',threshold,'pixels changed:',sumres,'imgsum:',sumpix);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
    % SEGMENT CHECKING:
        
    % Increment segment number at end of segment:
        
    if ( framecom > 5)
            
        if ( beam == 0 && sum(framestat(1,framecom-5:framecom-1)) == 10 )
            beam = 1;
        end
            
        if ( beam == 1 && sum(framestat(1,framecom-5:framecom-1)) <= 5 ...
                && segment < sizeleaves(1) )
            beam = 0;
            segment = segment + 1;
        end
            
    end
       
    if ( nopix > pixthresh )
        
        % Add img to sum:
             
        framecount = framecount + 1;
        imgall(:,:,framecount) = img;
        imgsum(:,:,segment) = imgsum(:,:,segment) + img;
        
        framestat(:,framecom) = [2 segment];
        
        %  Write beam dose to array
        
        beamsum(segment) = beamsum(segment) + nopix;
        beamdur(segment) = beamdur(segment) + 1;
            
        % Find leaf positions in image:
           
        [leavesout mx yc] = leafmatch(img, squeeze(jaws(segment,:,:)), squeeze(leaves(segment,:,:)), 'n', 'n');
       
        % Compare found leaf positions to prescription:
            
        [leavesout my xc] = leafcomp(squeeze(leaves(segment,:,:)), leavesout, 'n', 'n');
        
        %pause
                
        % Combine data into complete array:
            
        leavesframe(framecom,:,:) = leavesout;
        
        leafind = find(leavesout(:,5) > 0);
        disp = sqrt(mean(mean(leavesout(leafind,5:6).^2)))
        dispall = [dispall disp];
        
        % Calculate area:
        
        for leaf = 1:40
            wid = leaves(segment,leaf,4) - leaves(segment,leaf,3);
            length = leavesout(leaf,4) - leavesout(leaf,3);
            segarea(leaf) = wid*length;
        end
        
        areaall = [areaall sum(segarea)];
        mall = [mall mean([mx my])];
        xcall = [xcall xc];
        ycall = [ycall yc];
        
        if (frame == 166)
            %pause
        end
        
    end
       
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
% End of group loop then end of frame loop:

end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Print pixel sum plot:

plot(frameall,sumpixall,'-b','markeredgecolor','b','linewidth',1.0);
set(gca,'xlim',[1 205],'ylim',[0 200000000],'Fontsize',10,'linewidth',1.0)
xlabel('Frame','Fontsize',12);
ylabel('Sum Over All Pixels','Fontsize',12);
print('-djpeg','out/sumpix.jpg');
print('-deps','out/sumpix.ps');

plot(frameall/4.1,pixresall/997,'-b','markeredgecolor','b','linewidth',1.0);
set(gca,'xlim',[1 50],'ylim',[0 80],'Fontsize',10,'linewidth',1.0)
%line([0 *frametot],[350 350],'Color','k');
xlabel('Time (s)','Fontsize',12);
ylabel('\Delta_{t} (cm^{2})','Fontsize',12);
print('-djpeg','out/pixres.jpg');
print('-deps','out/pixres.ps');
close;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Print pixel no plot:

plot(frameall/4.1,nopixall/997,'-b','markeredgecolor','b','linewidth',1.0);
set(gca,'xlim',[1 50],'ylim',[0 80],'Fontsize',10,'linewidth',1.0)
%line([0 grouptot*frametot],[0 0],'Color','k','linewidth',1.5);
xlabel('Time (s)','Fontsize',12);
ylabel('Area (cm^{2})','Fontsize',12);
print('-djpeg','out/nopix.jpg');
print('-deps','out/nopix.ps');
close;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%frametime = [16 21 20 20 26];
%time = frametime/4;
%plot(time,maxdist(1:5),'d','markersize',10,'markeredgecolor','b','markerfacecolor','b','linewidth',1.5);
%par = polyfit(time,maxdist(1:5),1)
%xfit = 1:1:8;
%yfit = polyval(par,xfit);

%hold on;
%plot(xfit,yfit,'k','linewidth',1.5)
%hold off;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

colormap('gray');
co = [70 460 90 480];

for i = 1:6
imagesc(imgsum(co(1):co(2),co(3):co(4),i));
axis image;
axis off;
print('-djpeg',['out/imrt_' num2str(i) '.jpg']);
print('-deps2',['out/imrt_' num2str(i) '.ps']);
end

imgtot = mean(imgsum,3);
imagesc(imgtot(70:460,90:480));
print('-djpeg','out/imrt.jpg');
print('-deps2','out/imrt.ps');
close;

% Calculate area:

for seg = 1:1
    for leaf = 19:20
        %wid = leaves(seg,leaf,4) - leaves(seg,leaf,3)
        %length = leavesout(leaf,3) - leavesout(leaf,4)
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Print BG spread plot:

%plot(frameall,scatall,'-b','markeredgecolor','b','linewidth',1.5);
%set(gca,'FontSize',14);
%xlabel('Frame');
%ylabel('Scattered Current');
%title('Scattered Current per Frame');
%print('-dbmp','out/scat.bmp');

%imgsum(find(isfinite(img) == 0)) = 0;
%imtool(imgsum);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% 5-31 61-88 247-278 320-346 433-475 523-553
% 8-28 64-85 250-275 323-343 454-472 526-550

%resmean = [317 288 240 223 133 164];
%ressd = [37 20 13 16 58 11];

%par = polyfit(sum(leafdata(:,:,2),2),resmean,1);
%xfit = min(segarea):.1:max(segarea);
%yfit = polyval(par,xfit);

%plot(segarea,resmean,'d',xfit,yfit,'k','markersize',10,'markeredgecolor','b','markerfacecolor','b','linewidth',1.5);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Notes:

% Incorporate script checking into frame loop.  I.e. once sumpix has
% exceded a threshold, assume beam is on and check size and shape.  Must
% perform scattered current estimate.  Perhaps assume from beam area in
% future.  Correlate area, perimeter with scattered current offset and no
% of changed pixels.

% Negative sumpix in some frames means difference in bg (due to dec temp?)
% dominates over difference scattered current!  Should scale frames but
% only those with source in.

% Paper results: Plot segment area vs sumpix, plot segment perimeter vs
% changed pixel mean.  Show typical changed pixel map?

% x position calibration a problem.  Either calibrate from a square field
% or predict what intensity drop should occur at edge (not necessarily 50%).