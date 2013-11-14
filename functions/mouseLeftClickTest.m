function mouseLeftClickTest(objH,evt)
	global initLineHandle overlayTrace sAx currentInit yLims xLims data epoch currentInit;
		%Left click, set seedPoint
		%Get the initIndex here
		currentAxisIndex = find(sAx == get(objH,'Children'),1,'first');
		
        if exist('returnedPath','var')
			%Set the initIndex here
            %digitizedPath = cat(1,digitizedPath,returnedPath+1);
        end
        %set(gcf,'WindowButtonMotionFcn','');    %Set windowButtonMotion off for the duration of calculations
        %set(gcf,'WindowButtonMotionFcn',@mouseMoved);   %Turn on windowButtonMotionFcn
        point = get(get(objH,'Children'),'CurrentPoint');
		testSize = size(point);
		for i = 1:length(testSize)
			disp(['dim ' num2str(i) ' size '  num2str(size(point))]);
		end
        %seedPoint = [round(point(1,1)), round(point(1,2))]; 
        %disp(['Seed ' num2str(seedPoint(:)')]);
        %lineHandle = plot(seedPoint(1),seedPoint(2),'r-');
        if ~exist('digitizedPath','var')
            %digitizedPath(1,1) = seedPoint(2);
            %digitizedPath(1,2) = seedPoint(1);
        end
        %drawnow;
		set(initLineHandle(currentAxisIndex),'XData',[point(1) point(1)],'YData',yLims); %N.B. row, column and index differs by 1!!!
		currentInit = max([1 find(data(1,:) >= point(1),1,'first')]);	%Cannot have init less than 1 
		endEpoch = min([currentInit+epoch-1 size(data,2)]); %Prevent trying to plot out of bounds
		plotEpoch = currentInit:endEpoch;
		set(overlayTrace(currentAxisIndex),'XData',data(1,plotEpoch) ,'YData',data(2,plotEpoch)); %N.B. row, column and index differs by 1!!!
		set(get(objH,'Children'),'xlim',xLims,'ylim',yLims);
		%plot([point(1) point(1)],'YData',yLims,'g');
		%plot(point(1),point(2),'r*');
        disp('Left Click');
		drawnow();
endfunction