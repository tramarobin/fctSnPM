% This function takes ~10 seconds on i5 processor and files takes 6 Mo of
% storage
% don't forget to add the source code path

clear
close all
clc


% data
load ExampleDatas
DATA=ExampleDatas.BAB(:,1:2);

% parameters
independantEffects=[];
repeatedMeasuresEffects{1}={'C1','C2'};
effectNames={'Shoes'};
% There are 9 subjects
% Data(:,1) correspond to Shoes=C1
% Data(:,2) correspond to Shoes=C2

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
    'limitMeanMaps',12,...
    'ylimits',ylimits);
toc

