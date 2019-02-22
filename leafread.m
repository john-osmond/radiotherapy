function [jaws, leaves] = leafread(file)

% Writes jaw positions to variable jaws(1,2,3) where:
% 1 is the segment no, 2 is jaw letter (1=x, 2=y), 3 is the jaw number

% Writes leaf positions to variable leaves(1,2,3) where:
% 1 is the segment no (1-6)
% 2 is the leaf no (1-40)
% 3 is the parameter:

% Leaf parameters:

% 1 = positive y position
% 2 = negative y position
% 3 = lower x edge
% 4 = upper x edge
% 5 = perimeter length
% 6 = area

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Open input file:

fid = fopen(file);

% Read number of segments:

file = textscan(fid, '%*s', 4, 'delimiter', '\n', 'whitespace', '');
file = textscan(fid, '%*s %*s %*s %*s %uint16', 1);
beamno = file{1};
file = textscan(fid, '%*s', 2, 'delimiter', '\n', 'whitespace', '');

% Loop round all segments:

for segment = 1:beamno
    
    % Skip initial lines:
    
    file = textscan(fid, '%*s', 12, 'delimiter', '\n', 'whitespace', '');
    
    % Read in jaw data:

    file = textscan(fid, '%*s %*s %*s %*s %f', 4);
    jaws(segment,:,:) = permute(reshape(file{1},1,2,2),[1 3 2]);
    
    % Skip line:
    
    file = textscan(fid, '%*s', 2, 'delimiter', '\n', 'whitespace', '');
    
    % Read in positive leaf data:
    
    file = textscan(fid, '%s', 4);
    file = textscan(fid, '%f', 40);
    leaves(segment,:,1) = file{1};

    % Read in negative leaf data:
    
    file = textscan(fid, '%s', 4);
    file = textscan(fid, '%f', 40);
    leaves(segment,:,2) = file{1};
    
    % Skip remaining lines:
    
    file = textscan(fid, '%*s', 6, 'delimiter', '\n', 'whitespace', '');

end

% Closet text file:

fclose(fid);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Transform jaw positions to leaf positions.

jaws = jaws + 20;

% Loop round all segments and leaves:

for segment = 1:beamno
    
    for leaf = 1:length(leaves)
        
        leaves(segment,leaf,3) = 0;
        leaves(segment,leaf,4) = 0;
        leaves(segment,leaf,5) = 0;
        
        % Check if leaf is first:
        
        if ( leaf > jaws(segment,1,1) && leaf <= jaws(segment,1,1) + 1 )
            
            leafsep = (leaves(segment,leaf,1) - leaves(segment,leaf,2));
            
            leaves(segment,leaf,3) = jaws(segment,1,1);
            leaves(segment,leaf,4) = leaf;
            leaves(segment,leaf,5) = leafsep + ...
                (2 * (leaf - jaws(segment,1,1)));
            
        % Check if leaf is intermediary:
        
        elseif ( leaf > jaws(segment,1,1) + 1 && leaf < jaws(segment,1,2) )
            
            leafsepold = leafsep;
            leafsep = (leaves(segment,leaf,1) - leaves(segment,leaf,2));
            
            leaves(segment,leaf,3) = leaf - 1;
            leaves(segment,leaf,4) = leaf;
            leaves(segment,leaf,5) = sqrt((leafsep - leafsepold)^2) + 2;
            
        % Check if leaf is last:
       
        elseif ( leaf >= jaws(segment,1,2) && leaf < jaws(segment,1,2) + 1 )
            
            leafsepold = leafsep;
            leafsep = (leaves(segment,leaf,1) - leaves(segment,leaf,2));
            
            leaves(segment,leaf,3) = leaf - 1;
            leaves(segment,leaf,4) = jaws(segment,1,2);
            leaves(segment,leaf,5) = sqrt((leafsep - leafsepold)^2) ...
                + (2 * (jaws(segment,1,2) - leaf + 1)) + leafsep;

        end
        
        % Close segment and leaf loops:
        
    end
    
end

% Calculate leaf areas:

leaves(:,:,6) = ( leaves(:,:,1) - leaves(:,:,2) ) .* ...
    ( leaves(:,:,4) - leaves(:,:,3) );

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

end