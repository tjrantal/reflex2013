function [RMS_EMGs forceLevel indices] = analyzeForcePlateau(data,inits,ends,triggerIndex,emgChannels,samplingFreq,constants)
    minVariation = Inf;
    minIndex = 0;
    epoch = round(samplingFreq*constants.epoch);
    %Look for min variation of the trigger signal
    for i = 1:length(inits)
       currentData =  data(inits(i):ends(i),:);
       if size(currentData,1) > epoch    %epoch is 1 s
           for j = 1:size(currentData,1)-epoch+1 %search for the min variation
               if std(currentData(j:j+epoch-1,triggerIndex)) < minVariation
                 minVariation = std(currentData(j:j+epoch-1,triggerIndex));
                 minIndex =  inits(i)+j-1; 
               end
           end
       end
    end
    
    indices = minIndex:minIndex+epoch-1;
    forceLevel = mean(data(indices,triggerIndex));
    RMS_EMGs = zeros(1,3);
    for i = 1:length(emgChannels)
        RMS_EMGs(i) = sqrt(mean(data(indices,emgChannels(i)).^2));
    end
end