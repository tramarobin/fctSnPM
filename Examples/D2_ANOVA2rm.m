% This function takes ~30 seconds on i5 processor and files takes 55 Mo of space

clear
close all
clc

% path (change to your own path)
addpath(genpath('C:\Users\LIBM_yb\Google Drive\Thèse\MATLAB\library_matlab\fctSPM'));

% data
load ExampleDatas
DATA=ExampleDatas.ACCELECHO;

% parameters
EFFET_ind=[];
EFFET_rm{1}={'ACC','ACC','US','US'};
EFFET_rm{2}={'Contracted','Relaxed','Contracted','Relaxed'};
effectNames={'Device','Activation'};
% There is 15 subjects
% Data(:,1) correspond to Device=ACC and Activation=Contracted
% Data(:,2) correspond to Device=ACC and Activation=Relaxed
% Data(:,3) correspond to Device=US and Activation=Contracted
% Data(:,4) correspond to Device=US and Activation=Relaxed

savedir='Results//2D_ANOVA2rm';
xlab='Time (s)';
ylab='Frequency (Hz)';
Fs=500;
colorbarLabel='Power (au)';
limitMeanMaps=12;
ylimits=[10 130];

% SPM
fctSPM(DATA,EFFET_ind,EFFET_rm,...
    'savedir',savedir,...
    'effectsNames',effectNames,...
    'xlabel',xlab,'ylabel',ylab,...
    'sampleFrequency',Fs,'colorbarLabel',colorbarLabel,...
    'limitMeanMaps',limitMeanMaps,...
    'ylimits',ylimits);


