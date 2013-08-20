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

%% Octave/Matlab script to analyse “Determining the stimulus for the stretch reflex in humans” project. Written by Timo Rantalainen 2013 

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
constants.baseFolder = 'H:\timo\research\Reflex2013'; %Assuming the script is in the root folder
separator = '\';
constants.separator = separator;
constants.visualizationFolder =[constants.baseFolder separator 'analysis' separator 'visualization'];
constants.dataFileSuffix = 'smr';   %Note omit the . Used to search files from a subject's folder
constants.dataFolder =[constants.baseFolder separator 'REFLEX2013\Stretch reflex'];
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
%		for t = 1:length(synchronization)
%			figure
%			for s =1:length(synchronization(t).includedChans)
%				subplot(4,4,s)
%				dataToPlot = double(data(synchronization(t).includedChans(s)).imp.adc(synchronization(t).initSampleNo(synchronization(t).includedChans(s)):synchronization(t).initSampleNo(synchronization(t).includedChans(s))+synchronization(t).includeSampleNo(synchronization(t).includedChans(s)),t))*data(synchronization(t).includedChans(s)).hdr.adc.Scale;    
%				plot(dataToPlot)
%			end
%					for i=1:length(synchronization(t).includedChans),1/(data(synchronization(t).includedChans(i)).hdr.adc.SampleInterval(1)*data(synchronization(t).includedChans(i)).hdr.adc.SampleInterval(2)),end
%					disp('Next')
%		end

        %keyboard
		%Use the proper function for a file of a specific kind
		disp([constants.subjectFolders(p).dir.name ' ' fileList(f).name])
        %Running
        if strfind(lower(fileList(f).name),lower(constants.visualizationTitles{10})) > 0
            %keyboard;
            plotRunOverlay(data,synchronization,constants,2,fileList(f).name,f);
        end
        %Stretches
        if checkStretchFile(fileList(f).name,constants.visualizationTitles, [1:9]) > 0 
			%keyboard
            plotStretchOverlay(data,synchronization,constants,1,fileList(f).name,f);
        end
            
        clear data;
    end
end %Get next file to analyse
