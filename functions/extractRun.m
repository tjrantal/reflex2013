function  stretchData = extractRun(data,synchronization,constants,triggerVarIndex,fName,ch)
    %Channel name  data(chan).hdr.title
    %Channel type data(chan).hdr.channeltype ('Continuous Waveform')
    %Scaling of a given channel is in data(chan).hdr.adc.Scale
    %Sampling interval is in data(chan).hdr.adc.SampleInterval(1)
    %Units data(chan).hdr.adc.Units
    
    %Get channels of interest
    triggerIndex = 0;
    emgChannels = [];

    %Get channels of interest
    triggerIndex = 0;
    emgChannels = [];
    for chan = 1:length(data)
        if isfield(data(chan).hdr,'title')
            %Trigger channel
            if strfind(lower(data(chan).hdr.title),lower(char(constants.triggerSignalVarsNames(triggerVarIndex))))> 0
                triggerIndex = chan;
%                break;  
            end
            %SOL
            if strfind(lower(data(chan).hdr.title),lower(char(constants.triggerSignalVarsNames(3))))> 0
                emgChannels(1) = chan;
            end
            %GM
            if strfind(lower(data(chan).hdr.title),lower(char(constants.triggerSignalVarsNames(4))))> 0
                emgChannels(2) = chan;
            end
            %TA
            if strfind(lower(data(chan).hdr.title),lower(char(constants.triggerSignalVarsNames(5))))> 0
                emgChannels(3) = chan;
            end
            %VL
            if strfind(lower(data(chan).hdr.title),lower(char(constants.triggerSignalVarsNames(6))))> 0
                emgChannels(4) = chan;
            end
        end
    end
 
 
	triggerData =[];
	emgData = [];
	samplingFreq = 1/(data(triggerIndex).hdr.adc.SampleInterval(1)*data(triggerIndex).hdr.adc.SampleInterval(2));
	for e = 1:length(synchronization)	%Concat epochs from a file
		includeSampleNo = -1+int32(floor((double(synchronization(e).includeTStamps))*data(triggerIndex).hdr.tim.Units*data(triggerIndex).hdr.tim.Scale/(data(triggerIndex).hdr.adc.SampleInterval(1)*data(triggerIndex).hdr.adc.SampleInterval(2))));
		triggerData = [triggerData; double(data(triggerIndex).imp.adc(synchronization(e).initSampleNo(triggerIndex):synchronization(e).initSampleNo(triggerIndex)+includeSampleNo,e))*data(triggerIndex).hdr.adc.Scale];
		tempEmgData = zeros(includeSampleNo+1,length(emgChannels));
		for c = 1:length(emgChannels)
			%Rescale data if it does not have the same sampling frequency as the trigger channel
			%Get the final data point number
			includeSampleNo = -1+int32(floor((double(synchronization(e).includeTStamps))*data(emgChannels(c)).hdr.tim.Units*data(emgChannels(c)).hdr.tim.Scale/(data(emgChannels(c)).hdr.adc.SampleInterval(1)*data(emgChannels(c)).hdr.adc.SampleInterval(2))));

			tempData =  double(data(emgChannels(c)).imp.adc(synchronization(e).initSampleNo(emgChannels(c)):synchronization(e).initSampleNo(emgChannels(c))+includeSampleNo,e))*data(emgChannels(c)).hdr.adc.Scale;
			tempSamplingFreq = 1/(data(emgChannels(c)).hdr.adc.SampleInterval(1)*data(emgChannels(c)).hdr.adc.SampleInterval(2));
			%Rescale data if it does not have the same sampling frequency as the trigger channel
		    if  tempSamplingFreq ~= samplingFreq 
				resampledTempData= interp1([1:1:length(tempData)],tempData,linspace(1,length(tempData),length(triggerData)));				
				tempEmgData(:,c) = resampledTempData(:);
		    else 
			   tempEmgData(:,c) = tempData;    
		    end
		end
		emgData = [emgData; tempEmgData];
	end
	
    timeInstants = (0:length(triggerData)-1)/samplingFreq;
	%Differs from stretch data
	triggerThresh = max(triggerData)/20;
	stretches = find(triggerData > triggerThresh);
	stretchInits = find(diff(stretches) > 10)+1;

	
	stretchData = struct();
	included = 0;
    for i = 1:length(stretchInits)
		%If trigger is too late or too early, exclude
		%Exclude, it the maximum during epoch isn't high enough...
		if stretches(stretchInits(i))-constants.preTriggerEpoc+constants.visualizationEpocRun <= size(emgData,1) && stretches(stretchInits(i))-constants.preTriggerEpoc>0 && ...
			max(triggerData(stretches(stretchInits(i))-constants.preTriggerEpoc:stretches(stretchInits(i))-constants.preTriggerEpoc+constants.visualizationEpoc)) > max(triggerData)/3
			included = included+1;
			stretchData(included).emg = emgData(stretches(stretchInits(i))-constants.preTriggerEpoc:stretches(stretchInits(i))-constants.preTriggerEpoc+constants.visualizationEpoc,:);
			stretchData(included).trigger = triggerData(stretches(stretchInits(i))-constants.preTriggerEpoc:stretches(stretchInits(i))-constants.preTriggerEpoc+constants.visualizationEpoc);
		end
    end

end