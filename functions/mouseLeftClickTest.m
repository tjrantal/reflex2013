function mouseLeftClickTest(objH,evt)
	global initLineHandle overlayTrace sAx currentInit yLims xLims data epoch currentInit plotGeometry;
		%Left click, set seedPoint
		%Get the initIndex here
		
		figPosition = get(gcf,'position');
		figCoordinate = get(gcf,'CurrentPoint');
		for i = 1:2
			relativePosition(i) = figCoordinate(i)/figPosition(i+2);
		end
		relativePosition
		%Figure out on which subplot the cursor must have been
		column = ceil((relativePosition(1))*plotGeometry(2))
		row = ceil((1-relativePosition(2))*plotGeometry(1))
		currentAxisIndex = (row-1)*plotGeometry(2)+column;
		currentAxisIndex

			%currentAxisIndex = find(sAx == objH,1,'first');
		
        point = get(sAx(currentAxisIndex),'CurrentPoint');
		set(initLineHandle(currentAxisIndex),'XData',[point(1) point(1)],'YData',yLims); %N.B. row, column and index differs by 1!!!
		currentInit = max([1 find(data(1,:) >= point(1),1,'first')]);	%Cannot have init less than 1 
		endEpoch = min([currentInit+epoch-1 size(data,2)]); %Prevent trying to plot out of bounds
		plotEpoch = currentInit:endEpoch;
		set(overlayTrace(currentAxisIndex),'XData',data(1,plotEpoch) ,'YData',data(2,plotEpoch),'color',[0 1 0]); %N.B. row, column and index differs by 1!!!
		set(sAx(currentAxisIndex),'xlim',xLims,'ylim',yLimsplot);
		%plot([point(1) point(1)],'YData',yLims,'g');
		%plot(point(1),point(2),'r*');
        disp('Left Click');
		drawnow();
endfunction