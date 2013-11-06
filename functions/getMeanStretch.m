function meanStretch = getMeanStretch(stretch)
	meanStretch = struct();	
	tempData = zeros(size(stretch.fast.stretchData(1).emg,1),size(stretch.fast.stretchData(1).emg,2),length(stretch.fast.stretchData));
	tempTrig = zeros(size(stretch.fast.stretchData(1).trigger,1),length(stretch.fast.stretchData));
	for t = 1:length(stretch.fast.stretchData)
		tempData(:,:,t) = stretch.fast.stretchData(t).emg;
		tempTrig(:,t) = stretch.fast.stretchData(t).trigger;
	end
		%Plot meanTraces
	tempMean = mean(tempData,3);
	%Remove possible DC offset and low freq noise
	samplingFreq = stretch.fast.stretchData(1).samplingFreq;
	%disp(num2str(samplingFreq));
	nyquist = samplingFreq/2.0;
    [b,a] = butter(2,[5.0/nyquist 450.0/nyquist]);
	for p = 1:size(tempMean,2)
		tempMean(:,p) = filtfilt(b,a,tempMean(:,p));
	end

	meanStretch.fast.emg = tempMean;
	meanStretch.fast.trigger = mean(tempTrig,2);
	meanStretch.fast.samplingFreq = samplingFreq;
	if isfield(stretch,'slow') % check if slow exists
			if isfield(stretch.slow,'stretchData')
				tempData = zeros(size(stretch.slow.stretchData(1).emg,1),size(stretch.slow.stretchData(1).emg,2),length(stretch.slow.stretchData));
				tempTrig = zeros(size(stretch.slow.stretchData(1).trigger,1),length(stretch.slow.stretchData));
				for t = 1:length(stretch.slow.stretchData)
					tempData(:,:,t) = stretch.slow.stretchData(t).emg;
					tempTrig(:,t) = stretch.slow.stretchData(t).trigger;
				end
					%Plot meanTraces
				tempMean = mean(tempData,3);
				%Remove possible DC offset and low freq noise
				samplingFreq = stretch.slow.stretchData(1).samplingFreq;
				%disp(num2str(samplingFreq));
				nyquist = samplingFreq/2.0;
				[b,a] = butter(2,[5.0/nyquist 450.0/nyquist]);
				for p = 1:size(tempMean,2)
					tempMean(:,p) = filtfilt(b,a,tempMean(:,p));
				end
				meanStretch.slow.emg = tempMean;
				meanStretch.slow.trigger = mean(tempTrig,2);
				meanStretch.slow.samplingFreq = samplingFreq;
			end
		end
end