%width = [9 9 8 8 7 8]
%gap = [13 19 18 18 24 0]
maxdist = [1.4 5.5 4.5 4.85 7.5 0];
%plot(gap(1:5)/4,maxdist(1:5),'d')
%polyfit(gap(1:5)/4,maxdist(1:5),1)

areaall = [73.9075 69.335 37.0405 22.2605 8.155 15.37];
%areaall = [74.49 69.785 37.2405 22.4605 9.1550 15.47];

areascale = 993.73;
%areascale = 990

travel = [2.7 6.25 4.25 4.35 5.15 0];

plot((frameall-31)/4.12,nopixall/areascale,'-b','linewidth',1.6);
set(gca,'xlim',[-5 40],'ylim',[0 80],'Fontsize',14,'linewidth',1.6)
xlabel('Time (s)','Fontsize',16);
ylabel('Area (cm^{2})','Fontsize',16);
pbaspect([1 0.7 1]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% If doserate 400, framerate

% Square top parameters:

framestart = 30;
doserate = 540;
leafspeed = 2.22
delay = 2.46

framestartall = [52 80 106 131 163 200];

% Fermi parameters (25,320,2.49.1.595.0.15):

%framestart = 26;
%doserate = 340;
%leafspeed = 2.49;
%delay = 1.595;
%d = 0.15;
%dE = -1;

dosetot = 100;
segtot = 6;
framerate = 4.12;
frameseg = (dosetot/segtot) * (60/doserate) * framerate;

segment = 0;
linac = 0;

for frame = 1:size(frameall,2)
   mod(frame) = 0;
   
   if (frame == uint16(framestart) && segment < segtot )
       linac = 1;
       segment = segment + 1;
   end

   if (frame == uint16(framestart + frameseg))
       linac = 0;
       %framestart = frame + (delay + (maxdist(segment)/leafspeed)) * framerate;
       %framestart = frame + (travel(segment)*framerate)
       framestart = framestartall(segment)
   end
   
   if (linac == 1)
       fermi = 1;
       %fermi = 1 * 1/(1+exp(((framestart/framerate) - (frame/framerate) - dE)/d));
       mod(frame) = mod(frame) + (areaall(segment) * fermi);
   end

end

hold on;
plot((frameall-31)/4.12,mod,'--k','linewidth',1.6)
hold off;

%set(gca,'xtick',[0:20:200])
legend('Data','Model','Location',[1 1 8 10])
print('-djpeg','out/nopix.jpg');
print('-deps','out/nopix.ps');
close;