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
	%Go through all combinations of overlays
	for s = 1:9 %Go through different streches
		for ss = s:9 %Go through the remaining combinations
			%plot
			if ss == s	%fast v.s. slow on the same condition
				if isfield(data.stretchData(s),'slow') %if slow exists, do the overlay
					if isfield(data.stretchData(s).slow,'stretchData')
						overlayFig = figure;
						set(overlayFig,'position',[10 10 600 600],'visible','off');
						hold on;	%hold on for plotting
						%create subplots
						for p = 1:6
							sAxis(p) = subplot(3,2,p);
							hold on;
						end
						%plot the overlays
						for t = 1:length(data.stretchData(ss).fast.stretchData)
							for p = 1:size(data.stretchData(ss).fast.stretchData(t).emg,2)
								set(overlayFig,'currentaxes',sAxis(p));
								plot(data.stretchData(ss).fast.stretchData(t).emg(:,p),'r-')
							end
							set(overlayFig,'currentaxes',sAxis(6));
							plot(data.stretchData(ss).fast.stretchData(t).trigger,'r-')
						end
						
						for t = 1:length(data.stretchData(ss).slow.stretchData)
							for p = 1:size(data.stretchData(ss).slow.stretchData(t).emg,2)
								set(overlayFig,'currentaxes',sAxis(p));
								plot(data.stretchData(ss).slow.stretchData(t).emg(:,p),'k-')
							end
							set(overlayFig,'currentaxes',sAxis(6));
							plot(data.stretchData(ss).slow.stretchData(t).trigger,'k-')
						end
						
						if exist ('OCTAVE_VERSION', 'builtin') %OCTAVE
							set(overlayFig,'visible','on');
							print('-dpng','-r300','-S2400,2400',[constants.visualizationFolder constants.separator fileList(f).name(1:length(fileList(f).name)-4) constants.separator fName '_' constants.visualizationTitles{ss} '_' constants.visualizationTitles{s} '_slowvsFast' '.png']);
						else	%MATLAB
							print('-dpng','-r300',[constants.visualizationFolder constants.separator fileList(f).name(1:length(fileList(f).name)-4) constants.separator fName '_' constants.visualizationTitles{ss} '_' constants.visualizationTitles{s} '_slowvsFast' .png']);
						end
						close(overlayFig);	
					end
				end
			else
				%PLOT FAST OVERLAYS
				overlayFig = figure;
					set(overlayFig,'position',[10 10 600 600],'visible','off');
					hold on;	%hold on for plotting
					%create subplots
					for p = 1:6
						sAxis(p) = subplot(3,2,p);
						hold on;
					end
					%plot the overlays
					for t = 1:length(data.stretchData(ss).fast.stretchData)
						for p = 1:size(data.stretchData(ss).fast.stretchData(t).emg,2)
							set(overlayFig,'currentaxes',sAxis(p));
							plot(data.stretchData(ss).fast.stretchData(t).emg(:,p),'r-')
						end
						set(overlayFig,'currentaxes',sAxis(6));
						plot(data.stretchData(ss).fast.stretchData(t).trigger,'r-')
					end
					
					for t = 1:length(data.stretchData(s).fast.stretchData)
						for p = 1:size(data.stretchData(s).fast.stretchData(t).emg,2)
							set(overlayFig,'currentaxes',sAxis(p));
							plot(data.stretchData(s).fast.stretchData(t).emg(:,p),'k-')
						end
						set(overlayFig,'currentaxes',sAxis(6));
						plot(data.stretchData(s).fast.stretchData(t).trigger,'k-')
					end
					
					if exist ('OCTAVE_VERSION', 'builtin') %OCTAVE
						set(overlayFig,'visible','on');
						print('-dpng','-r300','-S2400,2400',[constants.visualizationFolder constants.separator fileList(f).name(1:length(fileList(f).name)-4) constants.separator fName '_' constants.visualizationTitles{ss} '_' constants.visualizationTitles{s} '.png']);
					else	%MATLAB
						print('-dpng','-r300',[constants.visualizationFolder constants.separator fileList(f).name(1:length(fileList(f).name)-4) constants.separator fName '_' constants.visualizationTitles{ss} '_' constants.visualizationTitles{s} '.png']);
					end
					close(overlayFig);	
			end
		end
	end
	clear data;
end
%keyboard;
%save data here

