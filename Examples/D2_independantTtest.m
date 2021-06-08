% This function takes ~15 seconds on i5 processor and files takes 6 Mo of
% storage
% don't forget to add the source code path

clear
close all
clc


% data
load ExampleDatas
DATA=ExampleDatas.ACCELECHO;

% parameters
independantEffects{1}={'L','L','L','L','L','L','L','L','S','S','S','S','S','S','S'}; % same number than participants
repeatedMeasuresEffects=[];
effectNames={'Group'};
% There is 15 subjects
% Subjects 1 to 8 are 'L', and 9 to 15 are 'S'

savedir='D2_independantTtest_results';
savedir2='D2_independantTtest_results2';
xlab='Time (s)';
ylab='Frequency (Hz)';
Fs=500;
colorbarLabel='Power (au)';
limitMeanMaps=10;
ylimits=[10 130];
nTicksY=7;
nTicksX=6;

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
