% This function takes ~250 seconds on i5 processor and files takes 170 Mo

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
DATA=ExampleDatas.ACCELECHO;

% paramètres de la fonction SnPM
independantEffects{1}={'L','L','L','L','L','M','M','M','M','M','S','S','S','S','S'}; % same number than participants
repeatedMeasuresEffects{1}={'ACC','ACC','US','US'};
repeatedMeasuresEffects{2}={'Contracted','Relaxed','Contracted','Relaxed'};
effectNames={'Group','Device','Activation'};
% There are 15 subjects
% Subjects 1 to 5 are 'L', 6 to 10 are 'M', and 11 to 15 are 'S'
% ANOVA3 does not accept unbalanced data (but ANOVA 1 does)
% Data(:,1) correspond to Device=ACC and Activation=Contracted
% Data(:,2) correspond to Device=ACC and Activation=Relaxed
% Data(:,3) correspond to Device=US and Activation=Contracted
% Data(:,4) correspond to Device=US and Activation=Relaxed


xlab='Time (s)';
ylab='Frequency (Hz)';
Fs=500;
colorbarLabel='Power (au)';
limitMeanMaps=12;
ylimits=[10 130];
nTicksY=7;
nTicksX=6;

% SnPM
tic
snpmAnalysis=fctSnPM(DATA,independantEffects,repeatedMeasuresEffects,...
    'savedir',savedir,...
    'effectsNames',effectNames,...
    'xlabel',xlab,'ylabel',ylab,...
    'sampleFrequency',Fs,'colorbarLabel',colorbarLabel,...
    'limitMeanMaps',limitMeanMaps,...
    'ylimits',ylimits,'nTicksX',nTicksX,'nTicksY',nTicksY);
toc

tic
snpmAnalysis2=fctSnPMS(DATA,independantEffects,repeatedMeasuresEffects,'effectsNames',effectNames);
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

