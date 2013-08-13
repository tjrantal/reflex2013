function plotRunOverlay(data,constants,triggerVarIndex,fName,ch)
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
    
    
    
    
    
    
%     keyboard
    triggerData = double(data(triggerIndex).imp.adc)*data(triggerIndex).hdr.adc.Scale;
    emgData = zeros(length(data(emgChannels(1)).imp.adc),4);
    for c = 1:4
       emgData(:,c) =  double(data(emgChannels(c)).imp.adc)*data(emgChannels(c)).hdr.adc.Scale;
    end
    
    samplingFreq = 1/(data(triggerIndex).hdr.adc.SampleInterval(1)*data(triggerIndex).hdr.adc.SampleInterval(2))
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
    %Plot overlays
    overlayFig = figure;
    %set(overlayFig,'position',[10 10 1200 1200],'visible','off');
	set(overlayFig,'position',[10 10 600 600],'visible','off');
    for p = 1:4
        sAxis(p) = subplot(2,2,p);
        hold on;
    end
    emgAverages = zeros(constants.visualizationEpocRun+1,4);
    repCount = 0;
    
    for i = 1:length(stretchInits)
        
        for p = 1:4
           set(overlayFig,'currentaxes',sAxis(p));
%            plot(stretches(stretchInits(i)):stretches(stretchInits(i))+constants.visualizationEpoc,emgData(stretches(stretchInits(i)):stretches(stretchInits(i))+constants.visualizationEpoc,p))
            plot(emgData(stretches(stretchInits(i)):stretches(stretchInits(i))+constants.visualizationEpocRun,p))
            emgAverages(:,p) = emgAverages(:,p)+emgData(stretches(stretchInits(i)):stretches(stretchInits(i))+constants.visualizationEpocRun,p);
        end
        repCount = repCount +1;
    end
    emgAverages = emgAverages/repCount;
    %Plot the averages
    for p = 1:4
       set(overlayFig,'currentaxes',sAxis(p));
%            plot(stretches(stretchInits(i)):stretches(stretchInits(i))+constants.visualizationEpoc,emgData(stretches(stretchInits(i)):stretches(stretchInits(i))+constants.visualizationEpoc,p))
        plot(emgAverages(:,p),'r')
    end
%     print('-dpng',['-S' num2str(1200) ',' num2str(1200)],[constants.visualizationFolder constants.separator fName(1:length(fName)-4) '_channel_' num2str(ch) '.png']);
    if exist([constants.visualizationFolder constants.separator constants.subjectFolders(p).dir.name]) == 0
        mkdir([constants.visualizationFolder constants.separator constants.subjectFolders(p).dir.name]);
    end
	if exist ('OCTAVE_VERSION', 'builtin') %OCTAVE
		print('-dpng','-r300','-S2400,2400',[constants.visualizationFolder constants.separator constants.subjectFolders(p).dir.name constants.separator fName(1:length(fName)-4) '_channel_' num2str(ch) '.png']);
		set(overlayFig,'visible','on');
	else	%MATLAB
		print('-dpng','-r300',[constants.visualizationFolder constants.separator constants.subjectFolders(p).dir.name constants.separator fName(1:length(fName)-4) '_channel_' num2str(ch) '.png']);
	end
	close(overlayFig);
    
%     keyboard
%     while data
%         
%     end

end