function results = analyzeStretch(dataIn,parameters)
	results = struct();
	rectified = sqrt(dataIn.^2);
	bgMean = mean(rectified(parameters.trigger:parameters.trigger+int32(0.030*parameters.samplingFreq)-1));
	bgSTDev = std(rectified(parameters.trigger:parameters.trigger+int32(0.030*parameters.samplingFreq)-1));
	reflexInitIndex = find(rectified(parameters.trigger:length(rectified)) > (bgMean + 3*bgSTDev),1,'first');
	results.latency = (reflexInitIndex)/parameters.samplingFreq*1000.0;	%Latency in ms
	results.ms20 = sqrt(mean(rectified(parameters.trigger+reflexInitIndex-1:parameters.trigger+reflexInitIndex-1+int32(0.020*parameters.samplingFreq)-1)));
	results.first5 = sqrt(mean(rectified(parameters.trigger+reflexInitIndex-1:parameters.trigger+reflexInitIndex-1+int32(0.005*parameters.samplingFreq)-1)));
	results.last15 = sqrt(mean(rectified(parameters.trigger+reflexInitIndex-1+int32(0.005*parameters.samplingFreq):parameters.trigger+reflexInitIndex-1+int32(0.020*parameters.samplingFreq))));
end