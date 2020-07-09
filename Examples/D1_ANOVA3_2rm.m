% This function takes ~275 seconds on i5 processor and files takes 600 Mo of space

clear
close all
clc

% path (change to your own path)
addpath(genpath('C:\Users\LIBM_yb\Google Drive\Thèse\MATLAB\library_matlab\fctSPM'));

% data
load ExampleDatas
DATA=ExampleDatas.Ratios;

% parameters
EFFET_ind{1}={'M','M','M','F','M','F','F','M','F','M','M','F','F','M','F','F','M','F','F','M'}; % same number than participants
EFFET_rm{1}={'RC60','RC180','RFKF','RFKE','RC60','RC180','RFKF','RFKE'};
EFFET_rm{2}={'D','D','D','D','G','G','G','G'};
effectNames={'Sex','Speed','Side'};
% There are 20 subjects
% ANOVA3 does not accept unbalanced data (10 males, 10 females)

savedir='Results//1D_ANOVA3_2rm';
xlab='Angle (°)';
ylab='Ratio';
xlimits=[30 90];
colorLine{1}=[rgb('cyan'); rgb('magenta')];
colorLine{2}=[rgb('green'); rgb('blue'); rgb('red'); rgb('black')];
colorLine{3}=[rgb('gray'); rgb('darkgray')];

% SPM
fctSPM(DATA,EFFET_ind,EFFET_rm,'multiIteration',1,...
    'savedir',savedir,...
    'effectsNames',effectNames,...
    'xlabel',xlab,'ylabel',ylab,...
    'xlimits',xlimits,'colorline',colorLine);


