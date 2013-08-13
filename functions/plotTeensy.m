function result = plotTeensy(data,constants,triggerVarIndex,fName,subjectNo)
    %Init result
    result = struct();
    %Prepare filters
    %Filter for force
    [b,a] = butter(4,50/constants.samplingFreq,'low');
    [bEMG,aEMG] = butter(4,[15/(constants.samplingFreq/2) 450/(constants.samplingFreq/2)]);
    
    triggerIndex = 0;
    emgChannels = [];
    for i = 1:length(constants.scalingFactors)
        if i < 5 %EMG channels
            data(:,i) = filtfilt(bEMG,aEMG,data(:,i).*constants.scalingFactors(i)); %Scale and filter the data
        else %Other channels
            data(:,i) = filtfilt(b,a,data(:,i).*constants.scalingFactors(i)); %Scale and filter the data
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
    emgChannels(3) = 4;

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
    [stretchInits stretchEnds triggerSignal] = findInitsEnds(triggerSignal,maxVal*0.04,maxVal*0.65);
    [result.MVCRMS_EMG result.MVCforceLevel result.MVCindices] = analyzeForcePlateau(data,stretchInits,stretchEnds,triggerIndex,emgChannels,constants.samplingFreq,constants);
    for i = 1:length(stretchInits)
        plot(timeInstants(stretchInits(i):stretchEnds(i)),data(stretchInits(i):stretchEnds(i),triggerIndex),'r')
    end
    plot(timeInstants(result.MVCindices),data(result.MVCindices,triggerIndex),'k')
    %50%
    [stretchInits stretchEnds triggerSignal] = findInitsEnds(triggerSignal,maxVal*0.04,maxVal*0.3,maxVal*0.65);
    [result.fiftyRMS_EMG result.fiftyforceLevel result.fiftyindices] = analyzeForcePlateau(data,stretchInits,stretchEnds,triggerIndex,emgChannels,constants.samplingFreq,constants);
    for i = 1:length(stretchInits)
        plot(timeInstants(stretchInits(i):stretchEnds(i)),data(stretchInits(i):stretchEnds(i),triggerIndex),'g')
    end
    plot(timeInstants(result.fiftyindices),data(result.fiftyindices,triggerIndex),'k')
    
    %10%
    [stretchInits stretchEnds triggerSignal] = findInitsEnds(triggerSignal,maxVal*0.04,maxVal*0.05,maxVal*0.25);
    [result.tenRMS_EMG result.tenforceLevel result.tenindices] = analyzeForcePlateau(data,stretchInits,stretchEnds,triggerIndex,emgChannels,constants.samplingFreq,constants);
    for i = 1:length(stretchInits)
        plot(timeInstants(stretchInits(i):stretchEnds(i)),data(stretchInits(i):stretchEnds(i),triggerIndex),'c')
    end
    plot(timeInstants(result.tenindices),data(result.tenindices,triggerIndex),'k')
    
    print('-dpng','-r300',[constants.visualizationFolder constants.separator num2str(subjectNo+1000) '_' fName(1:length(fName)-4) '.png']);
	close
end