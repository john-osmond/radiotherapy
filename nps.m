% Start up:

clear
close all hidden
clc
tic

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Set some data specific variables:

imagesize = [525 525];
imagearea = (imagesize(1)+imagesize(2))^2;
classname = 'uint16';
roi = [135 390];

% Set some standard variables:

[fileroot, N_T] = textread('nps.dat','%s %f');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Loop around all datasets:

for i=1:length(fileroot)
    
    fprintf('%s %s\n','Processing dataset',char(fileroot(i)));
    frameall = dir([char(fileroot(i)) '_*']);
    imagemean = zeros(imagesize(1),imagesize(2),classname);
    
    % Loop around all frames:

    for j=1:length(frameall)
        
        % Read in array from image file:
        
        fp = fopen([char(fileroot(i)) '_' num2str(j) '.vid'],'r');
        imdata = fread(fp,imagearea,classname);
        image = uint16( reshape(imdata,imagesize(1),imagesize(2)) );
        fclose(fp);
        
        % Create mean image:
        
        imagemean = imagemean + ( image / length(frameall) );

    end

    % Calculate mean noise for this temperature:
    
    N_T(i,2) = sum(sum(imagemean(roi(1):roi(2),roi(1):roi(2))))/((roi(2)-roi(1)+1)^2);

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Write out and plot results:

dlmwrite('N_T.txt', N_T, '\t');

par = polyfit(N_T(:,1),N_T(:,2),1);
xfit = min(N_T(:,1)):.1:max(N_T(:,1));
yfit = polyval(par,xfit);

plot(N_T(:,1),N_T(:,2),'d',xfit,yfit,'k','markersize',10,'markeredgecolor','b','markerfacecolor','b','linewidth',1);
grid on;
title('Noise vs Temperature');
xlabel('T (Deg)');
ylabel('N (e)');
print -dpdf N_T.pdf

fprintf('\n%s %3.1f %s %3.1f\n','N =',par(1),'T +',par(2));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Complete and report time:

fprintf('\n%s %3.1f%s\n','Completed in',toc,'s')