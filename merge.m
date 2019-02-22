function [] = merge(name, ext, device)

% Matlab script to merge all frames with a common prefix into single, mean
% file.

% Set some additional veriables:

filename = [name '_all.' ext];

% Delete existing averaged files:

if ( exist(filename) == 2 )
    delete(filename);
end

% Read image names into array:

nameall = dir([name '_*.' ext]);

% Loop round all frames:

for frame = 1:length(nameall)
    [img(:,:,frame)] = mi3read(nameall(frame).name, device);
end

imgmean = mean(img, 3);
clear img

% Write averaged image:

fp = fopen(filename, 'wb');
fwrite(fp, imgmean, 'uint16');
fclose(fp);

end