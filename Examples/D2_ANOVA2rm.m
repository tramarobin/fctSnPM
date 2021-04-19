% This function takes ~60 seconds on i5 processor and files takes 30 Mo of
% storage
% don't forget to add the source code path

clear
close all
clc


% data
load ExampleDatas
DATA=ExampleDatas.ACCELECHO;

% parameters
independantEffects=[];
repeatedMeasuresEffects{1}={'ACC','ACC','US','US'};
repeatedMeasuresEffects{2}={'Contracted','Relaxed','Contracted','Relaxed'};
effectNames={'Device','Activation'};
% There is 15 subjects
% Data(:,1) correspond to Device=ACC and Activation=Contracted
% Data(:,2) correspond to Device=ACC and Activation=Relaxed
% Data(:,3) correspond to Device=US and Activation=Contracted
% Data(:,4) correspond to Device=US and Activation=Relaxed

savedir=[];
xlab='Time (s)';
ylab='Frequency (Hz)';
Fs=500;
colorbarLabel='Amplitude (m\cdots^-^2)';
limitMeanMaps=12;
ylimits=[10 130];

% SPM
tic
fctSPM(DATA,independantEffects,repeatedMeasuresEffects,...
    'savedir',savedir,...
    'effectsNames',effectNames,...
    'xlabel',xlab,'nTicksX',6,'ylabel',ylab,'nTicksY',7,...
    'sampleFrequency',Fs,'colorbarLabel',colorbarLabel,...
    'limitMeanMaps',limitMeanMaps,...
    'ylimits',ylimits);
toc
