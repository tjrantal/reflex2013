close all;
clear all;
clc;
addpath('functions');   %Subfolder, which contains the analysis scripts for different conditions
%Add global variables to be used by callback functions
global initLineHandle overlayTrace sAx currentInit yLims xLims data epoch currentInit;
%callbacks are not implemented in gnuplot -> change plotting to fltk
graphics_toolkit fltk;
testF = figure('__graphics_toolkit__','fltk','position',[10,10,1000,1000]);

t = linspace(0,1,100);
sint = sin(2*pi*t);
data = [t; sint];
currentInit = round(size(data,2)*0.5);
epoch = 10;
tempLims = [min(data,[],2), max(data,[],2)];
yLims = squeeze(tempLims(2,:));
xLims = squeeze(tempLims(1,:));
%test subplots with callbacks
for i = 1:4
	sAx(i) = subplot(2,2,i)
	plot(data(1,:),data(2,:),'k.','linestyle','none');
	hold on;
	overlayTrace(i) = plot(data(1,currentInit:currentInit+epoch-1),data(2,currentInit:currentInit+epoch-1),'r');
	initLineHandle(i) = plot([0.5 0.5],yLims);
end




set(gcf,'WindowButtonUpFcn',@mouseLeftClickTest);  %%LiveWire init and setting points are handled with callbacks
%set(gcf,'WindowButtonMotionFcn',@mouseMoved); %Draw vertical line on the figure
disp('Callback set');
