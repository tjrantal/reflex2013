%A function to synchronize channels and concat files with more than one measurement epoch
function synchronization =synchronizeChannels(data)
	%Get number of data epochs in the file
	synchronization = struct();
	i = 1;
	
	while 1
		if isfield(data(i),'hdr')
			if isfield(data(i).hdr,'adc')
				if isfield(data(i).hdr.adc,'Npoints')
					epochs = length(data(i).hdr.adc.Npoints);
					break;
				end
			end
		end
	end
	
    %Go through the epochs in the file
	firstViableChannel = 0;	%used to figure out, which channel has adc data
	for e = 1:epochs
		tStamps = [];
		includedChans = [];
		chanNo = 0;
		for chan = 1:length(data)
			if isfield(data(chan),'imp')
				if isfield(data(chan).imp,'tim')
					tStamps(:,chan) = data(chan).imp.tim(e,:);	%Get timestamps for the epoch of interest
					chanNo=chanNo+1;
					includedChans(chanNo) = chan;
					
				end
			end
		end	
		%keyboard
		%Find temporal synchronization
		%Get common timestamps
		i = 1;
		onsetOffset(i) = max(tStamps(i,:));
		i = 2;
		onsetOffset(i) = min(tStamps(i,:));
		%Figure out which datapoint is init and how many datapoints to include
		initSampleNo = [];
		remainingTStamps = [];
		for i = 1:length(includedChans)
			initSampleNo(includedChans(i)) = int32(round(1+(double(onsetOffset(1)-tStamps(1,includedChans(i))))*data(includedChans(i)).hdr.tim.Units*data(includedChans(i)).hdr.tim.Scale/(data(includedChans(i)).hdr.adc.SampleInterval(1)*data(includedChans(i)).hdr.adc.SampleInterval(2))));
			remainingTStamps(includedChans(i)) = tStamps(2,includedChans(i))-onsetOffset(1);
		end
		includeTStamps = min(remainingTStamps(includedChans));
		includeSampleNo = [];
		for i = 1:length(includedChans)
			includeSampleNo(includedChans(i)) = -1+ int32(floor((double(includeTStamps-onsetOffset(1)))*data(includedChans(i)).hdr.tim.Units*data(includedChans(i)).hdr.tim.Scale/(data(includedChans(i)).hdr.adc.SampleInterval(1)*data(includedChans(i)).hdr.adc.SampleInterval(2))));
		end
		%keyboard
		synchronization(e).initSampleNo = initSampleNo;
		synchronization(e).includeSampleNo = includeSampleNo;
		synchronization(e).includedChans =includedChans;
	end
end