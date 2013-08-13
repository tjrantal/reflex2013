function result = plotCED(data,constants,triggerVarIndex,fName,subjectNo,highpass)
    %Init result
    result = struct();
    %Prepare filters
    %Filter for force
    [b,a] = butter(4,50/constants.samplingFreq,'low');
    [bEMG,aEMG] = butter(4,[15/(constants.samplingFreq/2) 450/(constants.samplingFreq/2)]);
    
    triggerIndex = 0;
    emgChannels = [];
    for i = 1:length(constants.varNames)
        if i ~= triggerVarIndex     %EMG channels
            data(:,i) = filtfilt(bEMG,aEMG,data(:,i)); %Scale and filter the data
        else %force channel
            data(:,i) = filtfilt(b,a,data(:,i)); %Scale and filter the data
            %Reset zero
            data(:,i) = data(:,i)-median(data(:,i));            
        end
    end
    triggerIndex = triggerVarIndex;
    %SOL
    emgChannels(1) = 1;
    %GM
    emgChannels(2) = 2;
    %TA
    emgChannels(3) = 3;

%     figure
%     subplot(4,1,1)
%     plot(data(:,triggerIndex))
%     for i = 1:3
%         subplot(4,1,i+1)
%         plot(data(:,emgChannels(i)))
%         ylabel('mV');
%         title(constants.varNames{emgChannels(i)});
%     end
    
    timeInstants = (0:size(data,1)-1)/constants.samplingFreq;
    
    %MVC
    triggerSignal = data(:,triggerIndex);
    figure
    plot(timeInstants,triggerSignal)
    hold on;
    maxVal = max(triggerSignal);
    [stretchInits stretchEnds triggerSignal] = findInitsEnds(triggerSignal,maxVal*0.04,maxVal*highpass);
    [result.RMS_EMG result.forceLevel result.indices] = analyzeForcePlateau(data,stretchInits,stretchEnds,triggerIndex,emgChannels,constants.samplingFreq,constants);
    for i = 1:length(stretchInits)
        plot(timeInstants(stretchInits(i):stretchEnds(i)),data(stretchInits(i):stretchEnds(i),triggerIndex),'r')
    end
    plot(timeInstants(result.indices),data(result.indices,triggerIndex),'k')
   
    print('-dpng','-r300',[constants.visualizationFolder constants.separator num2str(subjectNo+1000) '_' fName(1:length(fName)-4) '.png']);
	close
end