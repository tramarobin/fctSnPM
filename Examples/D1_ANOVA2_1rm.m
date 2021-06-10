% This function takes ~70 seconds on i5 processor and files takes 10 Mo of
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
DATA=DATA(:,[1 5]);

% funtion parameters
effectNames={'Sex','Side'};

independantEffects{1}={'M','M','M','F','M','F','F','M','F','M','M','F','F','M','F','F','M','F','F','M'}; % same number than participants
colorLine{1}=[rgb('blue'); rgb('magenta')];
lineStyle{1}={'-' '-.'; '--' '--'}; % first row is for the means, second row for the sd

% There are 20 subjects

repeatedMeasuresEffects{1}={'Right','Left'};
colorLine{2}=[rgb('green'); rgb('red')];


xlab='Angle (°)';
ylab='Ratio';
xlimits=[30 90];
ylimits=[0 1.6];
nTicksY=9;
nTicksX=7;

% SPM
tic
spmAnalysis=fctSPM(DATA,independantEffects,repeatedMeasuresEffects,...
    'savedir',savedir,...
    'effectsNames',effectNames,...
    'xlabel',xlab,'ylabel',ylab,'nTicksX',nTicksX,...
    'xlimits',xlimits,'ylimits',ylimits,'nTicksY',nTicksY,'colorline',colorLine,'lineStyle',lineStyle);
toc
% 
% tic
% spmAnalysis2=fctSPMS(DATA,independantEffects,repeatedMeasuresEffects,'effectsNames',effectNames);
% toc
% 
% tic
% saveNplot(spmAnalysis2,...
%     'savedir',savedir2,...
%     'xlabel',xlab,'ylabel',ylab,'nTicksX',nTicksX,...
%     'xlimits',xlimits,'ylimits',ylimits,'nTicksY',nTicksY,'colorline',colorLine);
% toc
