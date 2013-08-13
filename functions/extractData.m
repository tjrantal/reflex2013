function [extractedData samplingFreq] = extractData(data,constants)
    %Channel name  data(chan).hdr.title
    %Channel type data(chan).hdr.channeltype ('Continuous Waveform')
    %Scaling of a given channel is in data(chan).hdr.adc.Scale
    %Sampling interval is in data(chan).hdr.adc.SampleInterval(1)
    %Units data(chan).hdr.adc.Units
    
    %Get channels of interest
    triggerIndex = 0;
    dataChannels = [];
    tStamps = [];
    
    for chan = 1:length(data)
        if isfield(data(chan).hdr,'title')
            %Trigger channel
%             disp(data(chan).hdr.title)
            for n = 1:length(constants.varNames)
%                 disp([lower(data(chan).hdr.title) ' ' lower(char(constants.varNames{n})) ' ' num2str(strfind(lower(data(chan).hdr.title),lower(char(constants.varNames{n}))))])
                if strfind(lower(data(chan).hdr.title),lower(char(constants.varNames{n})))> 0
%                     disp([lower(data(chan).hdr.title) ' found'])
                    dataChannels(n) = chan;
                    tStamps(:,n)= data(chan).imp.tim;
                end
            end
        end
    end
%     keyboard;
    
    %Find temporal synchronization
    %Get common timestamps
    i = 1;
    onsetOffset(i) = max(tStamps(i,:));
    i = 2;
    onsetOffset(i) = min(tStamps(i,:));
    %Figure out which datapoint is init and how many datapoints to include
    initSampleNo = [];
    remainingTStamps = [];
    for i = 1:length(dataChannels)
        initSampleNo(i) = int32(round(1+(double(onsetOffset(1)-tStamps(1,i)))*data(dataChannels(i)).hdr.tim.Units*data(dataChannels(i)).hdr.tim.Scale/(data(dataChannels(i)).hdr.adc.SampleInterval(1)*data(dataChannels(i)).hdr.adc.SampleInterval(2))));
         remainingTStamps(i) =tStamps(2,i)-onsetOffset(1);
    end
    includeTStamps = min(remainingTStamps);
    includeSampleNo = [];
    
    %Resample data to have the same virtual sampling freq...
    samplingFreqs = [];
    for i = 1:length(dataChannels)
        samplingFreqs(i) = 1/(data(dataChannels(i)).hdr.adc.SampleInterval(1)*data(dataChannels(i)).hdr.adc.SampleInterval(2));
    end
    samplingFreq = max(samplingFreqs);
 
    for i = 1:length(dataChannels)
        includeSampleNo(i) = -1+ int32(floor((double(includeTStamps-onsetOffset(1)))*data(dataChannels(i)).hdr.tim.Units*data(dataChannels(i)).hdr.tim.Scale/(data(dataChannels(i)).hdr.adc.SampleInterval(1)*data(dataChannels(i)).hdr.adc.SampleInterval(2))));
    end

    extractedData = zeros(max(includeSampleNo)+1,length(dataChannels));
%     keyboard;
    for c = 1:length(dataChannels)
        if  samplingFreqs(c) < samplingFreq %resample to higher sampling freq
            tempData =   double(data(dataChannels(c)).imp.adc(initSampleNo(c):initSampleNo(c)+includeSampleNo(c)+1))*data(dataChannels(c)).hdr.adc.Scale;
            resampledData= interp1([1:1:length(tempData)],tempData,[1:samplingFreqs(c)/samplingFreq:length(tempData)]);%linspace(1,length(angleData),length(angleData)*2+1));
            resampledData = resampledData(1:size(extractedData,1));
            extractedData(:,c) = resampledData(:);
        else
            extractedData(:,c) = double(data(dataChannels(c)).imp.adc(initSampleNo(c):initSampleNo(c)+includeSampleNo(c)))*data(dataChannels(c)).hdr.adc.Scale;    
        end
    end
    
 
end