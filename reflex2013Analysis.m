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
%cd 'h:/timo/research/Reflex2013/analysis'
addpath('smrReader');   %For reading the srm-files produced by Spike
addpath('functions');   %Subfolder, which contains the analysis scripts for different conditions
%HARD CODED CONSTANTS saved in constants structure 
constants.visualizationEpoc = 499;	%Used to be 200
constants.preTriggerEpoc = 100;
constants.visualizationEpocRun = 1000;	%Used to be 200

%Enable running the script on Windows or on Linux
if isempty(strfind(computer,'linux'))
	constants.baseFolder = 'H:\timo\research\Reflex2013'; %Assuming the script is in the root folder
	separator = '\';
	constants.visualizationFolder =[constants.baseFolder separator 'analysis' separator 'visualization'];
else
	constants.baseFolder = '/home/timo/Desktop/sf_D_DRIVE/timo/research/Reflex2013'; 
	separator = '/';
	constants.visualizationFolder =[constants.baseFolder separator 'analysis' separator 'visualization'];
	constants.visualizationFolderALL =[constants.baseFolder separator 'analysis' separator 'visualizeAll'];
end
constants.separator = separator;
constants.dataFileSuffix = 'smr';   %Note omit the . Used to search files from a subject's folder
constants.dataFolder =[constants.baseFolder separator 'REFLEX2013' separator 'Stretch reflex'];
%Hard coded trial names to find
constants.trialGroups = { ...
    'Passive_1','Passive_3','Passive_6', ...
 	'10_1', '10_3','10_6', ...
 	'50_1', '50_3','50_6', ...
    'Running'};

constants.visualizationTitles= { ...
    'Passive_1','Passive_3','Passive_6', ...
 	'10_1', '10_3','10_6', ...
 	'50_1', '50_3','50_6', ...
    'Running'};

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

temp = dir(constants.dataFolder);
tempCount = 0;
constants.subjectFolders = struct([]);

for i = 1:length(temp)
    if ~strcmp(temp(i).name,'.') && ~strcmp(temp(i).name,'..')
        tempCount = tempCount+1;
        constants.subjectFolders(tempCount).dir = temp(i);    %Remove . and ..
    end
end

%keyboard
%Loop through folders..	DEBUG p = 6 p =5 p = 12 p = 4
for p = 1:length(constants.subjectFolders)
    fileList = dir([constants.dataFolder separator constants.subjectFolders(p).dir.name separator '*.' constants.dataFileSuffix]);
	%keyboard
    constants.p = p;
    for f = 1:length(fileList); %Go through files in a directory
        %Reading the protocol text file
		filename = [constants.dataFolder separator constants.subjectFolders(p).dir.name separator fileList(f).name];
		%keyboard
        data = ImportSMR([constants.dataFolder separator constants.subjectFolders(p).dir.name separator fileList(f).name]);
		%Synch channels and concat files with more than one measurement epoch
		synchronization = synchronizeChannels(data);
		%Use the proper function for a file of a specific kind
		disp([constants.subjectFolders(p).dir.name ' ' fileList(f).name])
        %Running
        %Debugging
        if 1==1
        	for t = 1:length(synchronization)
	        	esa = figure
	        	set(esa,'position',[10 10 1500 1000],'visible','off');
	        	for i  = 1:4
	        		for j = 1:4
	        			if ((i-1)*4+j <= length(data) && synchronization(t).initSampleNo((i-1)*4+j) > 0)
		        			ploth((i-1)*4+j) = subplot(4,4,(i-1)*4+j);
		        			dataToPlot = data((i-1)*4+j).imp.adc(:,t);
		        			origPoints = 1:length(dataToPlot);
		        			interpPoints = linspace(1,length(origPoints),2^15);
		        			interpData = interp1(origPoints,dataToPlot,interpPoints,'spline');
		        			plot(interpData);
		        			title(data((i-1)*4+j).hdr.title);
		        			disp([num2str((i-1)*4+j) '_' num2str(length(data((i-1)*4+j).imp.adc))])
		        			set(ploth((i-1)*4+j),'xlim',[1 2^15]);
	        			end
	        			
	        		end
		end
		set(esa,'visible','on');
		%Plot debug here
		 if exist([constants.visualizationFolderALL constants.separator constants.subjectFolders(constants.p).dir.name]) == 0
		        mkdir([constants.visualizationFolderALL constants.separator constants.subjectFolders(constants.p).dir.name]);
		end
		print('-dpng','-r300','-S3600,2400',[constants.visualizationFolderALL constants.separator constants.subjectFolders(constants.p).dir.name constants.separator fileList(f).name(1:length(fileList(f).name)-4) '_epoch_' num2str(t) '.png']);
		disp('plotted octave')
		close(esa);
		%keyboard
	end
        end
        
        if 1 == 0	%Debugging
	        if strfind(lower(fileList(f).name),lower(constants.visualizationTitles{10})) > 0
	            %keyboard;
	            plotRunOverlay(data,synchronization,constants,2,fileList(f).name,f);
	        end
	        %Stretches
	        if checkStretchFile(fileList(f).name,constants.visualizationTitles, [1:9]) > 0 
				%keyboard
	            plotStretchOverlay(data,synchronization,constants,1,fileList(f).name,f);
	        end
         end
        clear data;
    end
end %Get next file to analyse
