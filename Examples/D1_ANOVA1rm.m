% This function takes ~35 seconds on i5 processor and files takes 5 Mo of
% storage
% don't forget to add the source code path

clear
close all
clc


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

savedir='./D1_ANOVA1rm_results';
savedir2='./D1_ANOVA1rm_results';
xlab='Angle (°)';
ylab='Ratio';
xlimits=[30 90];
ylimits=[0 1.6];
nTicksY=9;
nTicksX=7;

% SPM
tic
spmAnalysis=fctSPM(DATA,independantEffects,repeatedMeasuresEffects,...
    'savedir',savedir,'alpha',0.01,'alphaT',0.01,...
    'effectsNames',effectNames,...
    'xlabel',xlab,'ylabel',ylab,'nTicksX',nTicksX,...
    'xlimits',xlimits,'ylimits',ylimits,'nTicksY',nTicksY,'colorline',colorLine);
toc

tic
spmAnalysis2=fctSPMS(DATA,independantEffects,repeatedMeasuresEffects,'effectsNames',effectNames);
toc

tic
saveNplot(spmAnalysis2,...
    'savedir',savedir2,...
    'xlabel',xlab,'ylabel',ylab,'nTicksX',nTicksX,...
    'xlimits',xlimits,'ylimits',ylimits,'nTicksY',nTicksY,'colorline',colorLine);
toc
