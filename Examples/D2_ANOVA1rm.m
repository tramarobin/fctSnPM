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

savedir=[];
xlab='Time (s)';
ylab='Frequency (Hz)';
Fs=400;
colorbarLabel='Power (au)';
limitMeanMaps=12;
ylimits=[15 200];

% SPM
tic
fctSPM(DATA,independantEffects,repeatedMeasuresEffects,...
    'savedir',savedir,...
    'effectsNames',effectNames,...
    'xlabel',xlab,'ylabel',ylab,...
    'sampleFrequency',Fs,'colorbarLabel',colorbarLabel,...
    'limitMeanMaps',limitMeanMaps,...
    'ylimits',ylimits);
toc

