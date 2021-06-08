% This function takes ~50 seconds on i5 processor and files takes 25 Mo of
% storage
% don't forget to add the source code path


clear
close all
clc


% data
load ExampleDatas
DATA=ExampleDatas.BAB;

% parameters
independantEffects=[];
repeatedMeasuresEffects{1}={'C1','C2','C3','C4'};
effectNames={'Shoes'};
% There are 9 subjects
% Data(:,1) correspond to Shoes=C1
% Data(:,2) correspond to Shoes=C2
% Data(:,3) correspond to Shoes=C3
% Data(:,4) correspond to Shoes=C4

savedir='D2_ANOVA1rm_results';
savedir2='D2_ANOVA1rm_results2';
xlab='Time (s)';
ylab='Frequency (Hz)';
Fs=400;
colorbarLabel='Power (au)';
limitMeanMaps=12;
ylimits=[15 200];
nTicksY=10;
nTicksX=7;

%SPM
tic
spmAnalysis=fctSPM(DATA,independantEffects,repeatedMeasuresEffects,...
    'savedir',savedir,...
    'effectsNames',effectNames,...
    'xlabel',xlab,'ylabel',ylab,...
    'sampleFrequency',Fs,'colorbarLabel',colorbarLabel,...
    'limitMeanMaps',limitMeanMaps,...
    'ylimits',ylimits,'nTicksX',nTicksX,'nTicksY',nTicksY);
toc

tic
spmAnalysis2=fctSPMS(DATA,independantEffects,repeatedMeasuresEffects,'effectsNames',effectNames);
toc

tic
saveNplot(spmAnalysis2,...
    'savedir',savedir2,...
    'xlabel',xlab,'ylabel',ylab,...
    'sampleFrequency',Fs,'colorbarLabel',colorbarLabel,...
    'limitMeanMaps',limitMeanMaps,...
    'ylimits',ylimits,'nTicksX',nTicksX,'nTicksY',nTicksY);
toc
