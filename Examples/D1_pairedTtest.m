% This function takes ~15 seconds on i5 processor and files takes 2 Mo of
% storage
% don't forget to add the source code path


clear
close all
clc


% data
load ExampleDatas
DATA=ExampleDatas.Ratios(:,[1 5]);

% function parameters
effectNames={'Side'};
independantEffects=[]; % empty
repeatedMeasuresEffects{1}={'Right','Left'}; % Side


savedir='D1_pairedTtest_results';
savedir2='D1_pairedTtest_results';
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