function plotRunOverlay(data,synchronization,constants,triggerVarIndex,fName,ch)
    %Channel name  data(chan).hdr.title
    %Channel type data(chan).hdr.channeltype ('Continuous Waveform')
    %Scaling of a given channel is in data(chan).hdr.adc.Scale
    %Sampling interval is in data(chan).hdr.adc.SampleInterval(1)
    %Units data(chan).hdr.adc.Units
    
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
		triggerData = [triggerData; double(data(triggerIndex).imp.adc(synchronization(e).initSampleNo(triggerIndex):synchronization(e).initSampleNo(triggerIndex)+synchronization(e).includeSampleNo(triggerIndex),e))*data(triggerIndex).hdr.adc.Scale];
		tempEmgData = zeros(synchronization(e).includeSampleNo(triggerIndex)+1,length(emgChannels));
		
		for c = 1:length(emgChannels)
			%Rescale data if it does not have the same sampling frequency as the trigger channel
			%keyboard
			tempData =  double(data(emgChannels(c)).imp.adc(synchronization(e).initSampleNo(emgChannels(c)):synchronization(e).initSampleNo(emgChannels(c))+synchronization(e).includeSampleNo(emgChannels(c)),e))*data(emgChannels(c)).hdr.adc.Scale;
			tempSamplingFreq = 1/(data(emgChannels(c)).hdr.adc.SampleInterval(1)*data(emgChannels(c)).hdr.adc.SampleInterval(2));
		   if  tempSamplingFreq ~= samplingFreq 
				resampledTempData= interp1([1:1:length(tempData)],tempData,[1:tempSamplingFreq/samplingFreq:length(angleData)]);%linspace(1,length(angleData),length(angleData)*2+1));
				resampledTempData = resampledTempData(1:size(synchronization(e).includeSampleNo(triggerIndex)+1,1));
				%         size(emgData)
				%         size(resampledAngleData)

				tempEmgData(:,c) = resampledTempData(:);
		   else 
			   tempEmgData(:,c) = tempData;    
		   end
		end
		emgData = [emgData; tempEmgData];
	end
    
    timeInstants = (0:length(triggerData)-1)/samplingFreq;
    triggerThresh = max(triggerData)/6;
    stretches = find(triggerData > triggerThresh);
    stretchInits = find(diff(stretches) > 10)+1;
    stretchInits = [1; stretchInits];   %The first is also a beginning...
%     figure
%     plot(triggerData);
%     hold on;
%     plot(stretches(stretchInits),triggerData(stretches(stretchInits)),'r*','linestyle','none');
%     pause
%     close
%keyboard;
    %Plot overlays
    overlayFig = figure;
    %set(overlayFig,'position',[10 10 1200 1200],'visible','off');
	set(overlayFig,'position',[10 10 600 600],'visible','off');
    for p = 1:6
        sAxis(p) = subplot(3,2,p);
        hold on;
    end
    emgAverages = zeros(constants.visualizationEpocRun+1,4);
    repCount = 0;
    
    for i = 1:length(stretchInits)
        %Ignore triggers that are too close to the end of the data
		if stretches(stretchInits(i))-constants.preTriggerEpoc+constants.visualizationEpoc < size(emgData,1)
			for p = 1:4
			   set(overlayFig,'currentaxes',sAxis(p));
	%            plot(stretches(stretchInits(i)):stretches(stretchInits(i))+constants.visualizationEpoc,emgData(stretches(stretchInits(i)):stretches(stretchInits(i))+constants.visualizationEpoc,p))
				plot(emgData(stretches(stretchInits(i)):stretches(stretchInits(i))+constants.visualizationEpocRun,p))
				emgAverages(:,p) = emgAverages(:,p)+emgData(stretches(stretchInits(i)):stretches(stretchInits(i))+constants.visualizationEpocRun,p);
			end
			repCount = repCount +1;
			set(overlayFig,'currentaxes',sAxis(6));
			plot(triggerData(stretches(stretchInits(i))-constants.preTriggerEpoc:stretches(stretchInits(i))-constants.preTriggerEpoc+constants.visualizationEpoc))
		end
    end
    emgAverages = emgAverages/repCount;
    %Plot the averages
    for p = 1:4
       set(overlayFig,'currentaxes',sAxis(p));
%            plot(stretches(stretchInits(i)):stretches(stretchInits(i))+constants.visualizationEpoc,emgData(stretches(stretchInits(i)):stretches(stretchInits(i))+constants.visualizationEpoc,p))
        plot(emgAverages(:,p),'r')
    end
%     print('-dpng',['-S' num2str(1200) ',' num2str(1200)],[constants.visualizationFolder constants.separator fName(1:length(fName)-4) '_channel_' num2str(ch) '.png']);
	%keyboard
    if exist([constants.visualizationFolder constants.separator constants.subjectFolders(constants.p).dir.name]) == 0
        mkdir([constants.visualizationFolder constants.separator constants.subjectFolders(constants.p).dir.name]);
    end
	if exist ('OCTAVE_VERSION', 'builtin') %OCTAVE
		set(overlayFig,'visible','on');
		print('-dpng','-r300','-S2400,2400',[constants.visualizationFolder constants.separator constants.subjectFolders(constants.p).dir.name constants.separator fName(1:length(fName)-4) '_channel_' num2str(ch) '.png']);
		
	else	%MATLAB
		print('-dpng','-r300',[constants.visualizationFolder constants.separator constants.subjectFolders(constants.p).dir.name constants.separator fName(1:length(fName)-4) '_channel_' num2str(ch) '.png']);
	end
	close(overlayFig);
    
%     keyboard
%     while data
%         
%     end

end