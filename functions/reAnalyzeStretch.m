function results = reAnalyzeStretch(dataIn,parameters,manualAdjustments)
	results = struct();
	for i = 1:3	%Analyze three first channels of EMG
		rectified = sqrt(dataIn(:,i).^2);	
		bgMean = mean(rectified(parameters.trigger:parameters.trigger+int32(0.030*parameters.samplingFreq)-1));
		bgSTDev = std(rectified(parameters.trigger:parameters.trigger+int32(0.030*parameters.samplingFreq)-1));
		%Use the manually determined init
		if ~isnan(manualAdjustments.currentInit(i))
			reflexInitIndex = double(manualAdjustments.currentInit(i)-int32(parameters.samplingFreq*0.05));
		else
			reflexInitIndex = [];
		end
		if ~isempty(reflexInitIndex) && (parameters.trigger+reflexInitIndex-1+int32(round(0.020*parameters.samplingFreq))-1) <= length(rectified)
			results(i).reflexInitIndex = reflexInitIndex;
			results(i).latency = (reflexInitIndex)/parameters.samplingFreq*1000.0;	%Latency in ms
			results(i).ms20 = sqrt(mean(rectified(parameters.trigger+reflexInitIndex-1:parameters.trigger+reflexInitIndex-1+int32(round(0.020*parameters.samplingFreq))-1)));
			results(i).first5 = sqrt(mean(rectified(parameters.trigger+reflexInitIndex-1:parameters.trigger+reflexInitIndex-1+int32(round(0.005*parameters.samplingFreq))-1)));
			results(i).last15 = sqrt(mean(rectified(parameters.trigger+reflexInitIndex-1+int32(round(0.005*parameters.samplingFreq)):parameters.trigger+reflexInitIndex-1+int32(round(0.020*parameters.samplingFreq)))));
		else
			results(i).reflexInitIndex = NaN;
			results(i).latency = NaN;	%Latency in ms
			results(i).ms20 = NaN;
			results(i).first5 = NaN;
			results(i).last15 = NaN;
		end
	end
end