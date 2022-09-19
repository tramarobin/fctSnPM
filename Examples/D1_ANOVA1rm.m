% This function takes ~35 seconds on i5 processor and files takes 5 Mo of
% storage

clear
close all
clc

% Don't forget to add the source code path
% This funtion will automatically create multiple files in a save directory located at the savedir
% adress

savedir=''; % is the adress where the output of fctSnPM is saved 
savedir2=savedir; % is the adress where the output of saveNplot is saved 

% data
load ExampleDatas
DATA=ExampleDatas.Ratios;
DATA=DATA(:,[1:4]);

% funtion parameters
effectNames={'Speed'};
repeatedMeasuresEffects{1}={'RC60','RC180','RFKF','RFKE'};
colorLine{1}=[rgb('green'); rgb('blue'); rgb('red'); rgb('black')];
independantEffects=[];
% There are 20 subjects

xlab='Angle (°)';
ylab='Ratio';
xlimits=[30 90];
ylimits=[0 1.6];
nTicksY=9;
nTicksX=7;

xLine{1}={1,'k--',1};

% SnPM
tic
snpmAnalysis=fctSnPM(DATA,independantEffects,repeatedMeasuresEffects,...
    'savedir',savedir,'alpha',0.01,'alphaT',0.01,...
    'effectsNames',effectNames,...
    'xlabel',xlab,'ylabel',ylab,'nTicksX',nTicksX,...
    'xlimits',xlimits,'ylimits',ylimits,'nTicksY',nTicksY,'colorline',colorLine,...
    'imagesize',[20 15],'imageresolution',300,...
    'xLine',xLine,'xGrid',1,'yGrid',1);
toc

tic
snpmAnalysis2=fctSnPMS(DATA,independantEffects,repeatedMeasuresEffects,'effectsNames',effectNames);
toc

tic
onlyPlot(snpmAnalysis2,...
    'xlabel',xlab,'ylabel',ylab,'nTicksX',nTicksX,...
    'xlimits',xlimits,'ylimits',ylimits,'nTicksY',nTicksY,'colorline',colorLine);
toc

tic
saveNplot(snpmAnalysis2,...
    'savedir',savedir2,...
    'xlabel',xlab,'ylabel',ylab,'nTicksX',nTicksX,...
    'xlimits',xlimits,'ylimits',ylimits,'nTicksY',nTicksY,'colorline',colorLine,...
    'imagesize',[20 15],'imageresolution',300,...
     'xLine',xLine,'xGrid',1,'yGrid',1)
toc
