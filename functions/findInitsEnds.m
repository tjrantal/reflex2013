function [inits ends triggerSignal] = findInitsEnds(triggerSignal,eraseVal,over,under)
    if exist('under','var')  %range
       stretches = find(triggerSignal > over & triggerSignal < under);
    else                       %higher than
        stretches = find(triggerSignal > over);
    end
    inits = find(diff(stretches) > 1000)+1;
%     keyboard;
    inits = stretches([1; inits]);   %The first is also a beginning...
    ends = find(diff(stretches) > 1000);
    ends = stretches([ends; length(stretches)]);

    %Remove MVCs from triggerSignal
    for i = 1:length(inits)
        eraseInit = inits(i);
        while triggerSignal(eraseInit) > eraseVal && eraseInit > 1
            eraseInit = eraseInit-1;
        end
        eraseEnd= ends(i);
        while triggerSignal(eraseEnd) > eraseVal && eraseInit < length(triggerSignal)
            eraseEnd = eraseEnd+1;
        end
        triggerSignal(eraseInit:eraseEnd) = eraseVal;
    end
    
end