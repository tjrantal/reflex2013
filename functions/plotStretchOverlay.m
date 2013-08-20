function plotStretchOverlay(data,synchronization,constants,triggerVarIndex,fName,ch)
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
            %Angle
            if strfind(lower(data(chan).hdr.title),lower(char(constants.varNames(2))))> 0
                emgChannels(5) = chan;
            end
        end
    end
 %     keyboard
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
    
    %Filter the triggerdata
    [b,a] = butter(4,50/samplingFreq,'low');
    triggerData = filtfilt(b,a,triggerData);
    
    triggerThresh = -0.01;% min(triggerData)/2;
    stretches = find(triggerData <= triggerThresh);
    stretchInits = find(diff(stretches) > 10)+1;
    stretchInits = [1; stretchInits];   %The first is also a beginning...
	%keyboard
    %  figure
    %  plot(triggerData);
    %  hold on;
    %  plot(stretches(stretchInits),triggerData(stretches(stretchInits)),'r*','linestyle','none');
%     close
    %Plot overlays
    overlayFig = figure;
    %set(overlayFig,'position',[10 10 1200 1200],'visible','off');
	set(overlayFig,'position',[10 10 600 600],'visible','off');
    for p = 1:6
        sAxis(p) = subplot(3,2,p);
        hold on;
    end
    colourSelection = 'k';
    if strfind(lower(fName),lower(constants.trialGroups{1})) > 0
        colourSelection = 'g';
    end
    if strfind(lower(fName),lower(constants.trialGroups{2})) > 0
        colourSelection = 'r';
    end
    if strfind(lower(fName),lower(constants.trialGroups{3})) > 0
        colourSelection = 'b';
    end
    for i = 1:length(stretchInits)
        for p = 1:length(emgChannels)
           set(overlayFig,'currentaxes',sAxis(p));
%            plot(stretches(stretchInits(i)):stretches(stretchInits(i))+constants.visualizationEpoc,emgData(stretches(stretchInits(i)):stretches(stretchInits(i))+constants.visualizationEpoc,p))
            plot(emgData(stretches(stretchInits(i))-constants.preTriggerEpoc:stretches(stretchInits(i))-constants.preTriggerEpoc+constants.visualizationEpoc,p),colourSelection)
           % if p == 1
            %    set(gca,'ylim',[-5 5])
            %end
            %if p == 5
             %   set(gca,'ylim',[14 22])
            %end
        end
    end
%     print('-dpng',['-S' num2str(1200) ',' num2str(1200)],[constants.visualizationFolder constants.separator fName(1:length(fName)-4) '_channel_' num2str(ch) '.png']);
    if exist([constants.visualizationFolder constants.separator constants.subjectFolders(constants.p).dir.name]) == 0
        mkdir([constants.visualizationFolder constants.separator constants.subjectFolders(constants.p).dir.name]);
    end

	%Plotting is different between octave and matlab!!
    if exist ('OCTAVE_VERSION', 'builtin') %OCTAVE
		set(overlayFig,'visible','on');
		print('-dpng','-r300','-S2400,2400',[constants.visualizationFolder constants.separator constants.subjectFolders(constants.p).dir.name constants.separator fName(1:length(fName)-4) '_channel_' num2str(ch) '.png']);
		disp('plotted octave')
	else	%MATLAB
		print('-dpng','-r300',[constants.visualizationFolder constants.separator constants.subjectFolders(constants.p).dir.name constants.separator fName(1:length(fName)-4) '_channel_' num2str(ch) '.png']);
		disp('plotted matlab')
	end
	close(overlayFig);
end