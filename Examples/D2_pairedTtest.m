% This function takes ~9 seconds on i5 processor and files takes 115 Mo of
% storage

clear
close all
clc

% path
addAbovePath

% data
load ExampleDatas
DATA=ExampleDatas.BAB(:,1:2);

% parameters
EFFET_ind=[];
EFFET_rm{1}={'C1','C2'};
effectNames={'Shoes'};
% There are 9 subjects
% Data(:,1) correspond to Shoes=C1
% Data(:,2) correspond to Shoes=C2

savedir='Results/2D_pairedTtest';
xlab='Time (s)';
ylab='Frequency (Hz)';
Fs=400;
colorbarLabel='Power (au)';
limitMeanMaps=12;
ylimits=[15 200];

% SPM
tic
fctSPM(DATA,EFFET_ind,EFFET_rm,...
    'savedir',savedir,...
    'effectsNames',effectNames,...
    'xlabel',xlab,'ylabel',ylab,...
    'sampleFrequency',Fs,'colorbarLabel',colorbarLabel,...
    'limitMeanMaps',12,...
    'ylimits',ylimits);
toc

