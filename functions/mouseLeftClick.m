function mouseLeftClick(objH,evt)
	global manualAdjustments;
		%Create local vars to make things easier
		overlayTrace		=manualAdjustments.overlayTrace;
		sAx					=manualAdjustments.sAx;
		data	 			=manualAdjustments.data;
		epoch 				=manualAdjustments.epoch;
		plotGeometry		=manualAdjustments.plotGeometry;
		samplingInstants	=manualAdjustments.samplingInstants;
		%Figure out which suplot was clicked on
		figPosition = get(gcf,'position');
		figCoordinate = get(gcf,'CurrentPoint');
		for i = 1:2
			relativePosition(i) = figCoordinate(i)/figPosition(i+2);
		end
		column = ceil((relativePosition(1))*plotGeometry(2));
		row = ceil((1-relativePosition(2))*plotGeometry(1));
		currentAxisIndex = (row-1)*plotGeometry(2)+column;
		%Get the current point from the plot clicked on
        point = round(get(sAx(currentAxisIndex),'CurrentPoint'));
		%Set the latency so that it can be read in the main analysis function
		%keyboard;
		currentInit = max([1 find(samplingInstants >= point(1),1,'first')]);	%Cannot have init less than 1 
		manualAdjustments.currentInit(currentAxisIndex) = currentInit;
		endEpoch = min([currentInit+epoch-1 size(data,1)]); %Prevent trying to plot out of bounds
		plotEpoch = currentInit:endEpoch;
		set(overlayTrace(currentAxisIndex),'XData',samplingInstants(plotEpoch) ,'YData',data(plotEpoch,currentAxisIndex),'color',[0 1 0]); %N.B. row, column and index differs by 1!!!
		drawnow();
endfunction