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
resultFile = fopen('StretchResults.xls','w');	%Open a file for writing the results to
%print the header
fprintf(resultFile,"FName\t");
for i = 1:12
		fprintf(resultFile,"condition\tlatency [ms]\tinitial 5 ms RMS [mV]\tlast 15 ms RMS [mV]\treflex 20 ms RMS [mV]\t");
end
fprintf(resultFile,"\n");


for f = 1:length(fileList);%:1:length(fileList); %Go through files in a directory
	%Reading the protocol text file
	filename = [constants.dataFolder separator fileList(f).name];
	%keyboard
	data = load(filename);
	%Create folder for overlayResults
	if exist([constants.visualizationFolder constants.separator fileList(f).name(1:length(fileList(f).name)-4)]) == 0
        mkdir([constants.visualizationFolder constants.separator fileList(f).name(1:length(fileList(f).name)-4)]);
    end
	fName = fileList(f).name(1:length(fileList(f).name)-4);
	fprintf(resultFile,[fName '\t']);
	%Go through all stretches
	for s = 1:9 %Go through different stretches
		%Analyse slow
		meanTrace = getMeanStretch(data.stretchData(s));
		parameters = struct();
		parameters.trigger = data.constants.preTriggerEpoc;
		parameters.samplingFreq = meanTrace.fast.samplingFreq;
		numericalResults = analyzeStretch(meanTrace.fast.emg,parameters);
		fprintf(resultFile,"%s\t%f\t%f\t%f\t%f\t", ...
			[constants.trialGroups{s} '_fast'] ...
			,numericalResults(1).latency ...
			,numericalResults(1).first5 ...
			,numericalResults(1).last15 ...
			,numericalResults(1).ms20 ...
			);
		if isfield(meanTrace,'slow') % check if slow exists
			%Plot test figure
			parameters = struct();
			parameters.trigger = data.constants.preTriggerEpoc;
			parameters.samplingFreq =meanTrace.slow.samplingFreq;
			numericalResults = analyzeStretch(meanTrace.slow.emg,parameters);
			fprintf(resultFile,"%s\t%f\t%f\t%f\t%f\t", ...
				[constants.trialGroups{s} '_slow'] ...
				,numericalResults(1).latency ...
				,numericalResults(1).first5 ...
				,numericalResults(1).last15 ...
				,numericalResults(1).ms20 ...
				);
		end
	end
	fprintf(resultFile,"\n");
	clear data;
end
fclose(resultFile);
%keyboard;
%save data here

