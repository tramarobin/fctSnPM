% This function takes ~40 seconds on i5 processor and files takes 12 Mo of
% storage
% don't forget to add the source code path


clear
close all
clc


% data
load ExampleDatas
DATA=ExampleDatas.ACCELECHO;

% parameters
EFFET_ind{1}={'L','L','L','L','L','L','L','M','M','M','M','S','S','S','S'}; % same number than participants
EFFET_rm=[];
effectNames={'Group'};
% There is 15 subjects
% Subjects 1 to 7 are 'L', 8 to 11 are 'M', and 12 to 15 are 'S'
% ANOVA1 accepts unbalanced data


savedir=[];
xlab='Time (s)';
ylab='Frequency (Hz)';
Fs=500;
colorbarLabel='Power (au)';
limitMeanMaps=10;
ylimits=[10 130];

% SPM
tic
fctSPM(DATA,EFFET_ind,EFFET_rm,...
    'savedir',savedir,...
    'effectsNames',effectNames,...
    'xlabel',xlab,'ylabel',ylab,...
    'sampleFrequency',Fs,'colorbarLabel',colorbarLabel,...
    'limitMeanMaps',limitMeanMaps,...
    'ylimits',ylimits);
toc

