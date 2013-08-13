%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function CompleteMATDataElementHeader(fhandle, Offset, LengthOfFrame, NumOfFrames)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% Save current offset - end of channel data area
pos=ftell(fhandle);
pad=8-rem(pos,8);

if pad~=8
    for i=1:pad
        fwrite(fhandle,0,'uint8');
    end;
end;

eof=ftell(fhandle);

% Complete header for this channel
fseek(fhandle,Offset,'bof');
temp=fread(fhandle,1,'uint32');
if temp~=14
    warning('miMatrix value wrong')
end
fseek(fhandle,Offset+4,'bof');
temp=eof-Offset-8;
fwrite(fhandle,temp,'uint32');
fseek(fhandle,Offset+32,'bof');
fwrite(fhandle,LengthOfFrame,'uint32');
fwrite(fhandle,NumOfFrames,'uint32');
% Assume 8 byte name including padding
fseek(fhandle,Offset+60,'bof');
temp=eof-Offset-64-rem(pos,8);
fwrite(fhandle,temp,'uint32');
return;