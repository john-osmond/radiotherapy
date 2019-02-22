function [] = addzero(name, ext)

% Script to rename files.

% Assumptions:
% Files are numbered from zero.
% Files are successively numbered.
% Filenames contain no leading zeros.
% Files number less than one thousand.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Loop round all files:

for no = 0:l00

    if ( exist([name '_' num2str(no) '.' ext]) == 2 )
        
        if ( no < 10 )
            movefile([name '_00' num2str(no) '.' ext], [name '_' num2str(no) '.' ext])
        elseif ( no < 100 )
            movefile([name '_0' num2str(no) '.' ext], [name '_' num2str(no) '.' ext])
        end

    end

end