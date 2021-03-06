%	This program is free software: you can redistribute it and/or modify
%    it under the terms of the GNU General Public License as published by
%    the Free Software Foundation, either version 3 of the License, or
%    (at your option) any later version.
%
%    This program is distributed in the hope that it will be useful,
%    but WITHOUT ANY WARRANTY; without even the implied warranty of
%    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%    GNU General Public License for more details.
%
%    You should have received a copy of the GNU General Public License
%   along with this program.  If not, see <http://www.gnu.org/licenses/>.
%
%	N.B.  the above text was copied from http://www.gnu.org/licenses/gpl.html
%	unmodified. I have not attached a copy of the GNU license to the source...
%
%    Copyright (C) 2013 Timo Rantalainen tjrantal (at) gmail.com

%% Octave/Matlab script to analyse Determining the stimulus for the stretch reflex in humans project. Written by Timo Rantalainen 2013 

%setenv("GSC","GSC"); %To get rid of annoying error messages, when printing images...
clear all;
close all;
fclose all;
clc;
%cd 'd:/timo/research/Reflex2013/analysis'
addpath('functions');   %Subfolder, which contains the analysis scripts for different conditions
%HARD CODED CONSTANTS saved in constants structure 

%Enable running the script on Windows or on Linux
if isempty(strfind(computer,'linux'))
	constants.baseFolder = 'd:\timo\research\Reflex2013'; %Assuming the script is in the root folder
	separator = '\';
else
	constants.baseFolder = '/home/timo/Desktop/sf_D_DRIVE/timo/research/Reflex2013'; 
	separator = '/';
end
constants.separator = separator;
constants.dataFileSuffix = 'mat';   %Note omit the . Used to search files from a subject's folder
constants.dataFolder =[constants.baseFolder separator 'analysis' separator 'stretches'];
constants.resultsFolder =[constants.baseFolder separator 'analysis' separator 'results'];
constants.visualizationFolder =[constants.baseFolder separator 'analysis' separator 'stretchVisualization'];
constants.latencyFolder =[constants.baseFolder separator 'analysis' separator 'latencies'];

%Hard coded trial names to find
constants.trialGroups = { ...
    'Passive_1','Passive_3','Passive_6', ...
 	'10_1', '10_3','10_6', ...
 	'50_1', '50_3','50_6'};

constants.visualizationTitles= { ...
    'Passive_1','Passive_3','Passive_6', ...
 	'10_1', '10_3','10_6', ...
 	'50_1', '50_3','50_6'};

constants.varNames={ ...
    'pedal', ...
    'angle', ...
    'sol', ...
    'gm', ...
    'ta', ...
    'vl', ...
    'accel1', ...
    'accel2', ...
    'stretch', ...
    'mat', ...
    };

constants.triggerSignalVarsNames={ ...
    'stretch', ...
    'mat', ...
    'sol', ...
    'gm', ...
    'ta', ...
    'vl', ...
    };

constants.forceLevels = {'Passive','10% MVC','50% MVC'};


%keyboard
%Loop through folders..	DEBUG p = 6 p =5 p = 12 p = 4

fileList = dir([constants.dataFolder  separator '*.' constants.dataFileSuffix]);
%keyboard
stretchData = struct();

resultFile = fopen('StretchResultsManualAdjustedHeaders.xls','w');	%Open a file for writing the results to
%print the header
fprintf(resultFile,"FName\t");
for j = 1:3	%Print results for all three muscles analysed
	for i = 1:12
			fprintf(resultFile,"condition\tlatency [ms]\tinitial 5 ms RMS [mV]\tlast 15 ms RMS [mV]\treflex 20 ms RMS [mV]\t");
	end
end
fprintf(resultFile,"\n");

graphics_toolkit fltk;
for f = 1:length(fileList);%:1:length(fileList); %Go through files in a directory
	%Reading the protocol text file
	filename = [constants.dataFolder separator fileList(f).name];
	%keyboard
	data = load(filename);
	disp([fileList(f).name])
	%Create folder for overlayResults
	if exist([constants.visualizationFolder constants.separator fileList(f).name(1:length(fileList(f).name)-4)]) == 0
        mkdir([constants.visualizationFolder constants.separator fileList(f).name(1:length(fileList(f).name)-4)]);
    end
	fName = fileList(f).name(1:length(fileList(f).name)-4);
	fprintf(resultFile,[fName '\t']);
	
	%Go through all stretches
	%check whether latencies have already been analyzed and load, if so
	if exist([constants.latencyFolder separator fileList(f).name]) == 0
		latencies = struct();
	else
		%load pre-existing latencies
		temp = load([constants.latencyFolder separator fileList(f).name]);
		latencies = temp.latencies;
		clear temp;
	end
	global manualAdjustments;
	for s = 1:9 %Go through different stretches
		%Analyse slow
		meanTrace = getMeanStretch(data.stretchData(s));
		
		%Numerical analysis
		samplingFreq =meanTrace.fast.samplingFreq;
		visualizeEpoc = data.constants.preTriggerEpoc-int32(samplingFreq*0.05):data.constants.preTriggerEpoc+int32(samplingFreq*0.15);
		samplingInstants = linspace(-50,150,length(visualizeEpoc));
		parameters = struct();
		parameters.trigger = data.constants.preTriggerEpoc;
		parameters.samplingFreq = samplingFreq;		
		if length(latencies) >= s && isfield(latencies(s),'fast') && ~isempty(latencies(s).fast)
			manualAdjustments = latencies(s).fast.manualAdjustments;
			numericalResults = reAnalyzeStretch(meanTrace.fast.emg,parameters,manualAdjustments);
		else
			manualAdjustments = struct();
			manualAdjustments.epoch = int32(samplingFreq*0.02);
			manualAdjustments.data = meanTrace.fast.emg(visualizeEpoc,:);
			manualAdjustments.samplingInstants = samplingInstants;
			numericalResults = analyzeStretch(meanTrace.fast.emg,parameters);
		end
		%Numerical analysis done	
		
		%Plot test figure
		overlayFig = figure('__graphics_toolkit__','fltk','position',[10 10 600 600],'visible','off');
		
		%create subplots

		for p = 1:length(numericalResults)
			if ~isnan(numericalResults(p).reflexInitIndex)
				manualAdjustments.currentInit(p) = numericalResults(p).reflexInitIndex+int32(parameters.samplingFreq*0.05);
				if 0	%debugging
					disp(['prior ' num2str(p) ' lat ' num2str(manualAdjustments.currentInit(p)) ' orig ' num2str(numericalResults(p).reflexInitIndex) ' addition ' num2str(int32(parameters.samplingFreq*0.05))]);
				end
			else
				manualAdjustments.currentInit(p) = NaN;
			end
		end
		
		plotGeometry = [3,2];
		manualAdjustments.plotGeometry = plotGeometry;
		for p = 1:plotGeometry(1)*plotGeometry(2);
			sAxis(p) = subplot(plotGeometry(1),plotGeometry(2),p);
			manualAdjustments.sAx(p) = sAxis(p);
			hold on;
		end
		for p = 1:size(meanTrace.fast.emg,2)
			set(overlayFig,'currentaxes',sAxis(p));
			plot(samplingInstants,meanTrace.fast.emg(visualizeEpoc,p),'k-','linewidth',3);
			set(gca,'xlim',[samplingInstants(1) samplingInstants(length(samplingInstants))]);
			if p <=3 && ~isnan(numericalResults(p).latency)	%Plot timing
			%Highlight analyzed epochs
				reflexEpoc = data.constants.preTriggerEpoc+int32(samplingFreq*(numericalResults(p).latency/1000.0)):data.constants.preTriggerEpoc+int32(samplingFreq*(numericalResults(p).latency/1000.0))+int32(samplingFreq*0.02)-1;
				reflexInstants = linspace(numericalResults(p).latency,numericalResults(p).latency+20,length(reflexEpoc));
				manualAdjustments.overlayTrace(p) =  plot(reflexInstants,meanTrace.fast.emg(reflexEpoc,p),'r-','linewidth',5);
			end
			if p < 5
				title([constants.trialGroups{s} ' ' constants.triggerSignalVarsNames{p+2}]);
				xlabel('[ms]');
			end
		end
		set(overlayFig,'currentaxes',sAxis(plotGeometry(1)*plotGeometry(2)));
		plot(samplingInstants,meanTrace.fast.trigger(visualizeEpoc),'k-','linewidth',3);
		
		%Adjust results manually at this point
		if 1  %Removed to go through the analysis without manual adjustments
			waitButton = waitbar(0,'Done','position',[610 610 200 50]);
			set(overlayFig,'visible','on','WindowButtonUpFcn',@mouseLeftClick);
			disp('Callback set');
			waitfor(waitButton);
			disp('returned from callback');
		end
		%Manual adjustments done
		if 0	%debugging
			for p = 1:3
				disp(['after ' num2str(p) ' lat ' num2str(manualAdjustments.currentInit(p))]);
			end
		end
		latencies(s).fast.manualAdjustments = manualAdjustments;
		numericalResults = reAnalyzeStretch(meanTrace.fast.emg,parameters,manualAdjustments);
		%Print results
		for mm = 1:3
			fprintf(resultFile,"%s\t%f\t%f\t%f\t%f\t", ...
				[constants.trialGroups{s} '_' data.constants.varNames{2+mm} '_fast'] ...
				,numericalResults(mm).latency ...
				,numericalResults(mm).first5 ...
				,numericalResults(mm).last15 ...
				,numericalResults(mm).ms20 ...
				);
		end
		
		
		if exist ('OCTAVE_VERSION', 'builtin') %OCTAVE
			set(overlayFig,'visible','on');
			drawnow();
			print('-dpng','-r300','-S2400,2400',[constants.visualizationFolder constants.separator fileList(f).name(1:length(fileList(f).name)-4) constants.separator fName '_' constants.trialGroups{s} '_fast' '.png']);
		else	%MATLAB
			print('-dpng','-r300',[constants.visualizationFolder constants.separator fileList(f).name(1:length(fileList(f).name)-4) constants.separator fName  '_' constants.trialGroups{s} '_fast' '.png']);
		end
		close(overlayFig);
		
		if isfield(meanTrace,'slow') % check if slow exists
			%Numerical analysis
			samplingFreq =meanTrace.slow.samplingFreq;
			visualizeEpoc = data.constants.preTriggerEpoc-int32(samplingFreq*0.05):data.constants.preTriggerEpoc+int32(samplingFreq*0.15);
			samplingInstants = linspace(-50,150,length(visualizeEpoc));
			parameters = struct();
			parameters.trigger = data.constants.preTriggerEpoc;
			parameters.samplingFreq = samplingFreq;		
			if length(latencies) >= s && isfield(latencies(s),'slow') && ~isempty(latencies(s).slow)
				manualAdjustments = latencies(s).slow.manualAdjustments;
				numericalResults = reAnalyzeStretch(meanTrace.slow.emg,parameters,manualAdjustments);
			else
				manualAdjustments = struct();
				manualAdjustments.epoch = int32(samplingFreq*0.02);
				manualAdjustments.data = meanTrace.slow.emg(visualizeEpoc,:);
				manualAdjustments.samplingInstants = samplingInstants;
				numericalResults = analyzeStretch(meanTrace.slow.emg,parameters);
			end
			
			%Plot test figure
			overlayFig = figure('__graphics_toolkit__','fltk','position',[10 10 600 600],'visible','off');

			%Highlight analyzed epochs
			reflexEpoc = data.constants.preTriggerEpoc+int32(samplingFreq*(numericalResults(1).latency/1000.0)):data.constants.preTriggerEpoc+int32(samplingFreq*(numericalResults(1).latency/1000.0))+int32(samplingFreq*0.02)-1;
			reflexInstants = linspace(numericalResults(1).latency,numericalResults(1).latency+20,length(reflexEpoc));
		
		
		
			%create subplots
			manualAdjustments = struct();
			manualAdjustments.epoch = int32(samplingFreq*0.02);
			manualAdjustments.data = meanTrace.slow.emg(visualizeEpoc,:);
			manualAdjustments.samplingInstants = samplingInstants;
			for p = 1:length(numericalResults)
				if ~isnan(numericalResults(p).reflexInitIndex)
					manualAdjustments.currentInit(p) = numericalResults(p).reflexInitIndex+int32(parameters.samplingFreq*0.05);
					if 0 %debugging
						disp(['prior ' num2str(p) ' lat ' num2str(manualAdjustments.currentInit(p)) ' orig ' num2str(numericalResults(p).reflexInitIndex) ' addition ' num2str(int32(parameters.samplingFreq*0.05))]);
					end
				else
					manualAdjustments.currentInit(p) = NaN;
				end
			end
			plotGeometry = [3,2];
			manualAdjustments.plotGeometry = plotGeometry;
			for p = 1:plotGeometry(1)*plotGeometry(2);
				sAxis(p) = subplot(plotGeometry(1),plotGeometry(2),p);
				manualAdjustments.sAx(p) = sAxis(p);
				hold on;
			end

			for p = 1:size(meanTrace.slow.emg,2)
				set(overlayFig,'currentaxes',sAxis(p));
				plot(samplingInstants,meanTrace.slow.emg(visualizeEpoc,p),'k-','linewidth',3)
				set(gca,'xlim',[samplingInstants(1) samplingInstants(length(samplingInstants))]);
				if p <=3 && ~isnan(numericalResults(p).latency)	%Plot timing
				%Highlight analyzed epochs
					reflexEpoc = data.constants.preTriggerEpoc+int32(samplingFreq*(numericalResults(p).latency/1000.0)):data.constants.preTriggerEpoc+int32(samplingFreq*(numericalResults(p).latency/1000.0))+int32(samplingFreq*0.02)-1;
					reflexInstants = linspace(numericalResults(p).latency,numericalResults(p).latency+20,length(reflexEpoc));
					manualAdjustments.overlayTrace(p) = plot(reflexInstants,meanTrace.slow.emg(reflexEpoc,p),'r-','linewidth',5);
				end
				if p < 5
					title([constants.trialGroups{s} ' ' constants.triggerSignalVarsNames{p+2}]);
					xlabel('[ms]');
				end
			end
			set(overlayFig,'currentaxes',sAxis(plotGeometry(1)*plotGeometry(2)));
			plot(samplingInstants,meanTrace.slow.trigger(visualizeEpoc),'k-','linewidth',3);
			%Adjust results manually at this point
			if 1  %Removed to go through the analysis without manual adjustments
				waitButton = waitbar(0,'Done','position',[610 610 200 50]);
				set(overlayFig,'visible','on','WindowButtonUpFcn',@mouseLeftClick);
				disp('Callback set');
				waitfor(waitButton);
				disp('returned from callback');
			end
			latencies(s).slow.manualAdjustments = manualAdjustments;
			numericalResults = reAnalyzeStretch(meanTrace.slow.emg,parameters,manualAdjustments);
			%Print results
			%Print results
			for mm = 1:3
				fprintf(resultFile,"%s\t%f\t%f\t%f\t%f\t", ...
					[constants.trialGroups{s} '_' data.constants.varNames{2+mm} '_slow'] ...
					,numericalResults(mm).latency ...
					,numericalResults(mm).first5 ...
					,numericalResults(mm).last15 ...
					,numericalResults(mm).ms20 ...
					);
			end

			if exist ('OCTAVE_VERSION', 'builtin') %OCTAVE
				set(overlayFig,'visible','on');
				drawnow();
				print('-dpng','-r300','-S2400,2400',[constants.visualizationFolder constants.separator fileList(f).name(1:length(fileList(f).name)-4) constants.separator fName '_' constants.trialGroups{s} '_slow' '.png']);
			else	%MATLAB
				print('-dpng','-r300',[constants.visualizationFolder constants.separator fileList(f).name(1:length(fileList(f).name)-4) constants.separator fName  '_' constants.trialGroups{s} '_slow' '.png']);
			end
			close(overlayFig);			
		end



	end
	fprintf(resultFile,"\n");
		%save data here
	
	if exist ('OCTAVE_VERSION', 'builtin') %OCTAVE
		save([constants.latencyFolder separator fileList(f).name],'-mat-binary','latencies');
	else
		save([constants.latencyFolder separator fileList(f).name,'latencies']);
	end
	
	clear data;
end
fclose(resultFile);

