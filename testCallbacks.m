close all;
clear all;
clc;
addpath('functions');   %Subfolder, which contains the analysis scripts for different conditions
%Add global variables to be used by callback functions
global initLineHandle overlayTrace currentInit yLims xLims data epoch currentInit;
graphics_toolkit fltk;
testF = figure('__graphics_toolkit__','fltk','position',[10,10,1000,1000]);

t = linspace(0,1,100);
sint = sin(2*pi*t);
data = [t; sint];
%callbacks are not implemented in gnuplot -> change plotting to fltk
plot(t,sint,'k.','linestyle','none');
hold on;
currentInit = round(length(t)*0.5);
epoch = 10;
overlayTrace = plot(t(currentInit:currentInit+epoch-1),sint(currentInit:currentInit+epoch-1),'r');
yLims = get(gca,'ylim');
xLims = get(gca,'xlim');
initLineHandle = plot([0.5 0.5],yLims);
set(gcf,'WindowButtonUpFcn',@mouseLeftClickTest);  %%LiveWire init and setting points are handled with callbacks
%set(gcf,'WindowButtonMotionFcn',@mouseMoved); %Draw vertical line on the figure
disp('Callback set');
