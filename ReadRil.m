function [Hdr, Imgs, Rng] = ReadRil( fname )
  hFile = fopen( fname );
  fseek( hFile, 0, -1);  
  Hdr.wType = fread( hFile, 1, 'uint32' );
  if Hdr.wType ~= int32(double('.ril')*[1; 256; 256^2; 256^3]) ... %'.ril'
     & Hdr.wType ~= int32(double('.cmr')*[1; 256; 256^2; 256^3])   %'.cmr'
    fclose( hFile );
    return
  end
  Hdr.wHeaderLen = fread(hFile, 1, 'uint32');
  Hdr.wBinning = fread(hFile, 1, 'uint32');
  Hdr.wWidth = fread(hFile, 1, 'uint32');
  Hdr.wHeight = fread(hFile, 1, 'uint32');
  Hdr.wImageSize = fread(hFile, 1, 'uint32');
  Hdr.wPixBits = fread(hFile, 1, 'uint32');
  
  fseek( hFile, Hdr.wHeaderLen, -1);
  
  dirdat = dir( fname );
  filesize = dirdat.bytes;
  nImgs = int32((filesize-Hdr.wHeaderLen)/Hdr.wImageSize);
  
  if( nImgs <= 0 )
      Imgs = 0;
      fclose( hFile );
    return
  end

  Imgs = zeros( Hdr.wHeight, Hdr.wWidth, nImgs );
  for img = 1:nImgs
    for y = 1:Hdr.wHeight
      line = double( fread(hFile, Hdr.wWidth, 'uint16'));  
      Imgs(y,:,img ) = line;
    end
  end
  
  Rng = [min(Imgs(:)) max(Imgs(:))];
  
  fclose( hFile );
  return;
 