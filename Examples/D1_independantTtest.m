% This function takes ~15 seconds on i5 processor and files takes 1 Mo of
% storage
% don't forget to add the source code path

clear
close all
clc

% data
load ExampleDatas
DATA=ExampleDatas.Ratios(:,1);

% function parameters
effectNames={'Sex'};
linestyle{1}={'--' ':'};
independantEffects{1}={'M','M','M','F','M','F','F','M','F','M','M','F','F','M','F','F','M','F','F','M'}; % same number than participants
repeatedMeasuresEffects=[]; % empty

savedir='D1_independantTtest_results';
savedir2='D1_independantTtest_results2';
xlab='Angle (°)';
ylab='Ratio';
xlimits=[30 90];
ylimits=[0 1.2];
nTicksY=7;
nTicksX=7;

% SPM
tic
spmAnalysis=fctSPM(DATA,independantEffects,repeatedMeasuresEffects,...
    'savedir',savedir,'linestyle',linestyle,...
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
