% This function takes ~8 seconds on i5 processor and files takes 89 Mo of
% storage

clear
close all
clc

% path
addAbovePath

% data
load ExampleDatas
DATA=ExampleDatas.ACCELECHO;

% parameters
EFFET_ind{1}={'L','L','L','L','L','L','L','L','S','S','S','S','S','S','S'}; % same number than participants
EFFET_rm=[];
effectNames={'Group'};
% There is 15 subjects
% Subjects 1 to 8 are 'L', and 9 to 15 are 'S'

savedir='Results/2D_independantTtest';
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

