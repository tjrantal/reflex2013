%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function offset=InitMATDataElementHeader(fh, chan, ScaleData)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fseek(fh,0,'eof');
offset=ftell(fh);

fwrite(fh,14,'uint32');%miMATRIX
fwrite(fh,0,'uint32');% bytes - 0 for now
fwrite(fh,6,'uint32');%miUINT32
fwrite(fh,8,'uint32');%array flag bytes

switch ScaleData
    case 0
        fwrite(fh,10,'uint32',0);%mxINT16_CLASS
    case 1
        fwrite(fh,6,'uint32',0);%mxDOUBLE_CLASS
end

fwrite(fh,0,'uint32');%unused
fwrite(fh,5,'uint32');%miINT32
fwrite(fh,8,'uint32');
fwrite(fh,[0 0],'int32');%dimensions - fill in later
fwrite(fh,1,'uint32');%miINT8
name=['chan' num2str(chan)];
len=length(name);
fwrite(fh,len,'uint32');
fwrite(fh,name,'uint8');
% Pad to 8 byte boundary
pad=8-rem(len,8);
if pad~=8
    for i=1:pad
        fwrite(fh,0,'uint8');
    end;
end;
switch ScaleData
    case 0
        fwrite(fh,3,'uint32');%miINT16
    case 1
        fwrite(fh,9,'uint32');%miDOUBLE
end
fwrite(fh,0,'uint32');%bytes - fill in later
return;

