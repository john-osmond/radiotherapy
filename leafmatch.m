function [leavesout, m, xc] = leafmatch(img, jaws, leaves, m, xc)

% Function to find mlc leaves in an imrt image.  Receives image, an array
% containing jaw positions and leaf positions in isocentre co-ordinates,
% segment number, scale factor and x offset as input.  Produces an array
% containing leaf positions in pixel co-ordinates, scale factor and xc as
% output.  Cannot write out leaf positions in isocentre co-ordinates as
% calibration in y direction has yet to be performed.

report = 0;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Set up some initial variables:

leavesout = zeros(40,6);

% Calculate ratio of shortest leaf spacing to longest:

leafind = find(leaves(:,5)>0);
leafsize = leaves(leafind,1)-leaves(leafind,2);
startratio = leafsize(1)/max(leafsize);
endratio = leafsize(end)/max(leafsize);

% Generate profiles in y direction:

yprofstart = mean(img,2);
[yprofun, ind] = unique(yprofstart);
yprofun(:,2) = ind;
yprof = sortrows(yprofun,2);

thresh = 0.5 * startratio * max(yprof(:,1));
ylo = min(find(yprof(:,1) > thresh));
yrange(1) = interp1(yprof(ylo-2:ylo+1,1),yprof(ylo-2:ylo+1,2),thresh);

thresh = 0.5 * endratio * max(yprof(:,1));
yhi = max(find(yprof(:,1) > thresh));
yrange(2) = interp1(yprof(yhi-1:yhi+2,1),yprof(yhi-1:yhi+2,2),thresh);

% Derive transform from leaf to pixel:

if ( strcmp(m,'n') == 1 )
    m = (yrange(2) - yrange(1)) / (jaws(1,2) - jaws(1,1));
end

if ( strcmp(xc,'n') == 1 )
    xc = yrange(1) - ( m * jaws(1,1) );
end

%yloiso = leaves((min(find(leaves(1,:,3) > 0))),3);
%yhiiso = leaves((max(find(leaves(1,:,4) > 0))),4);

% Open image:

if ( report == 1 )
    imagesc(img);
    colormap(gray);
end

% Loop around all leaves:

for leaf = 1:length(leaves)
    
    % Proceed if leaf area > 0:
    
    if ( leaves(leaf,5) > 0 )
        
        % Convert leaf width and position to pixel co-ordinates:
        
        leafwidth = ( leaves(leaf,4) - leaves(leaf,3) ) * m;
        leafyco = [(leaves(leaf,3)*m + xc) (leaves(leaf,4)*m + xc)];
        
        % Generate intensity profile in x direction and find leaf edges:
        
        xprofstart = permute(mean(img(uint16(leafyco(1)+(leafwidth*0.25)): ...
           uint16(leafyco(1)+(leafwidth*0.75)),:),1),[2 1]);
        [xprofun, ind] = unique(xprofstart);
        xprofun(:,2) = ind;
        xprof = sortrows(xprofun,2);
      
        thresh = 0.5 * max(xprof(:,1));
        xpos = find(xprof(:,1) > thresh);
        
        %xlo = xprof(xpos(1),2)
        %xhi = xprof(xpos(end),2)
        xlo = interp1(xprof(xpos(1)-2:xpos(1)+1,1),xprof(xpos(1)-2:xpos(1)+1,2),thresh);
        xhi = interp1(xprof(xpos(end)-1:xpos(end)+2,1),xprof(xpos(end)-1:xpos(end)+2,2),thresh);
        
        % Draw rectangle on image:
        
        if ( report == 1)
            
            rectangle('Position',...
                [xlo, leafyco(1), xhi-xlo, leafwidth], ...
                'LineWidth',1.0,'EdgeColor','r');
            
        end
        
        % Write leaf edges to array:
        
        leavesout(leaf,1) = xlo;
        leavesout(leaf,2) = xhi;
        
    end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if ( report == 1 )
    
    % Print and close plot:
    
    %plotylo = min(leavesout(find(leavesout(:,2) > 0))) - (3*leafwidth);
    %plotyhi = max(max(leavesout)) + (3*leafwidth);
    %set (gca,'xlim', [1 500], 'ylim', [plotylo plotyhi]);
    
    time = clock;
    mins = num2str(time(5));
    secs = num2str(uint16(time(6)*10));
    
    set(gca,'fontsize',8,'linewidth',1.0);
    xlabel('X (pixels)','Fontsize',10);
    ylabel('Y (pixels)','Fontsize',10);
    
    axis image;
    
    plotname = ['out/leafmatch_' mins '_' secs '.jpg'];
    print('-djpeg',plotname);
    plotname = ['out/leafmatch_' mins '_' secs '.ps'];
    print('-deps',plotname);
    %close;
    
    % Print to slide:
    
    set(gca,'fontsize',14,'linewidth',1.6);
    xlabel('X (pixels)','Fontsize',16);
    ylabel('Y (pixels)','Fontsize',16);
    
    axis image;
    
    plotname = ['slide/leafmatch_' mins '_' secs '.jpg'];
    print('-djpeg',plotname);
    plotname = ['slide/leafmatch_' mins '_' secs '.ps'];
    print('-deps',plotname);
    close;

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

end