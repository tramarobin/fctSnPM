% This function takes ~180 seconds on i5 processor and files takes 355 Mo of space

clear
close all
clc

% path (change to your own path)
addpath(genpath('C:\Users\LIBM_yb\Google Drive\Thèse\MATLAB\library_matlab\fctSPM'));

% data
load ExampleDatas
DATA=ExampleDatas.ACCELECHO;

% paramètres de la fonction SPM
EFFET_ind{1}={'L','L','L','L','L','M','M','M','M','M','S','S','S','S','S'}; % same number than participants
EFFET_rm{1}={'ACC','ACC','US','US'};
EFFET_rm{2}={'Contracted','Relaxed','Contracted','Relaxed'};
effectNames={'Group','Device','Activation'};
% There are 15 subjects
% Subjects 1 to 5 are 'L', 6 to 10 are 'M', and 11 to 15 are 'S'
% ANOVA3 does not accept unbalanced data (but ANOVA 1 does)
% Data(:,1) correspond to Device=ACC and Activation=Contracted
% Data(:,2) correspond to Device=ACC and Activation=Relaxed
% Data(:,3) correspond to Device=US and Activation=Contracted
% Data(:,4) correspond to Device=US and Activation=Relaxed

savedir='Results//2D_ANOVA3_2rm';
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


