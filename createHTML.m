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

%Enable running the script on Windows or on Linux
if isempty(strfind(computer,'linux'))
	constants.baseFolder = 'H:\timo\research\Reflex2013'; %Assuming the script is in the root folder
	separator = '\';
else
	constants.baseFolder = '/home/timo/Desktop/sf_D_DRIVE/timo/research/Reflex2013'; 
	separator = '/';
end
constants.separator = separator;
constants.visualizationFolder =[constants.baseFolder separator 'analysis' separator 'visualization'];
constants.visualizationFolderALL =[constants.baseFolder separator 'analysis' separator 'visualizeAll'];
constants.htmlFolder =  [constants.baseFolder separator 'analysis' separator 'html'];


constants.dataFileSuffix = 'png';   %Note omit the . Used to search files from a subject's folder
constants.dataFolder =constants.visualizationFolder;
%Hard coded trial names to find

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
%ADD index.htmlFile
indexHtmlFile = fopen([constants.htmlFolder separator 'index.html'],'w');
fprintf(indexHtmlFile,'<html>\n');
fprintf(indexHtmlFile,'<body>\n');

for p = 1:length(constants.subjectFolders)
    fileList = dir([constants.dataFolder separator constants.subjectFolders(p).dir.name separator '*.' constants.dataFileSuffix]);
	%keyboard
	htmlFile = fopen([constants.htmlFolder separator constants.subjectFolders(p).dir.name '.html'],'w');
    constants.p = p;
	%write header
	fprintf(htmlFile,'<html>\n');
	fprintf(htmlFile,'<body>\n');
	fprintf(htmlFile,'<a href=\"%s\">%s</a></br>\n','index.html','Back');
	%fprintf(htmlFile,'<table>\n');
	%fprintf(htmlFile,'<tr><td>\n');
	fprintf(indexHtmlFile,'<a href=\"%s\">%s</a></br>\n',[constants.subjectFolders(p).dir.name '.html'],constants.subjectFolders(p).dir.name);
    for f = 1:length(fileList); %Go through files in a directory % 'analysis' separator 
        %Reading the protocol text file
        		%print the file on top of the fig
		fprintf(htmlFile,'<B>%s</B></br>\n',[constants.subjectFolders(p).dir.name ' ' fileList(f).name]);
		fprintf(htmlFile,'<img src=\"%s\" width=\"1500px\"/></br>\n',['..' separator 'visualization' separator constants.subjectFolders(p).dir.name separator fileList(f).name]);

		
    end
	%fprintf(htmlFile,'<\td><\tr>\n');
	%fprintf(htmlFile,'<\table>\n');
	fprintf(htmlFile,'<a href=\"%s\">%s</a></br>\n','index.html','Back');
	fprintf(htmlFile,'</html>\n');
	fprintf(htmlFile,'</body>\n');
	fclose(htmlFile);
end %Get next file to analyse
%close index.html file
	fprintf(indexHtmlFile,'</html>\n');
	fprintf(indexHtmlFile,'</body>\n');
	fclose(indexHtmlFile);