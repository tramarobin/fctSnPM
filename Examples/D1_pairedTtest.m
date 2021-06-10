% This function takes ~15 seconds on i5 processor and files takes 2 Mo of
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
DATA=ExampleDatas.Ratios(:,[1 5]);

% function parameters
effectNames={'Side'};
independantEffects=[]; % empty
repeatedMeasuresEffects{1}={'Right','Left'}; % Side


xlab='Angle (°)';
ylab='Ratio';
xlimits=[30 90];
ylimits=[0 1.2];
nTicksY=7;
nTicksX=7;

% SPM
tic
spmAnalysis=fctSPM(DATA,independantEffects,repeatedMeasuresEffects,...
    'savedir',savedir,...
    'effectsNames',effectNames,...
    'xlabel',xlab,'ylabel',ylab,'nTicksX',nTicksX,...
    'xlimits',xlimits,'ylimits',ylimits);
toc

tic
spmAnalysis2=fctSPMS(DATA,independantEffects,repeatedMeasuresEffects,'effectsNames',effectNames);
toc

tic
saveNplot(spmAnalysis2,...
    'savedir',savedir2,...
    'xlabel',xlab,'ylabel',ylab,'nTicksX',nTicksX,...
    'xlimits',xlimits,'ylimits',ylimits);
toc