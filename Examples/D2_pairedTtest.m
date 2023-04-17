% This function takes ~10 seconds on i5 processor and files takes 6 Mo of
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
DATA=ExampleDatas.BAB(:,1:2);

% parameters
independantEffects=[];
repeatedMeasuresEffects{1}={'C1','C2'};
effectNames={'Shoes'};
% There are 9 subjects
% Data(:,1) correspond to Shoes=C1
% Data(:,2) correspond to Shoes=C2


xlab='Time (s)';
ylab='Frequency (Hz)';
Fs=400;
colorbarLabel='Power (au)';
limitMeanMaps=12;
ylimits=[15 200];
nTicksY=10;
nTicksX=7;

%SnPM
tic
snpmAnalysis=fctSnPM(DATA,independantEffects,repeatedMeasuresEffects,...
    'savedir',savedir,...
    'effectNames',effectNames,...
    'xlabel',xlab,'ylabel',ylab,...
    'sampleFrequency',Fs,'colorbarLabel',colorbarLabel,...
    'limitMeanMaps',limitMeanMaps,...
    'ylimits',ylimits,'nTicksX',nTicksX,'nTicksY',nTicksY);
toc

tic
snpmAnalysis2=fctSnPMS(DATA,independantEffects,repeatedMeasuresEffects,'effectNames',effectNames);
toc

tic
onlyPlot(snpmAnalysis2,...
    'xlabel',xlab,'ylabel',ylab,...
    'sampleFrequency',Fs,'colorbarLabel',colorbarLabel,...
    'limitMeanMaps',limitMeanMaps,...
    'ylimits',ylimits,'nTicksX',nTicksX,'nTicksY',nTicksY);
toc

tic
saveNplot(snpmAnalysis2,...
    'savedir',savedir2,...
    'xlabel',xlab,'ylabel',ylab,...
    'sampleFrequency',Fs,'colorbarLabel',colorbarLabel,...
    'limitMeanMaps',limitMeanMaps,...
    'ylimits',ylimits,'nTicksX',nTicksX,'nTicksY',nTicksY);
toc
