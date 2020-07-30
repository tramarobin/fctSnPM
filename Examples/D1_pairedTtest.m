% This function takes ~5 seconds on i5 processor and files takes 1.5 Mo of
% storage

clear
close all
clc

% path
addAbovePath

% data
load ExampleDatas
DATA=ExampleDatas.Ratios(:,[1 4]);

% function parameters
EFFET_ind=[]; % empty
EFFET_rm{1}={'D','G'}; % Side
effectNames={'Side'};

savedir='Results//1D_pairedTtest';
xlab='Angle (°)';
ylab='Ratio';
xlimits=[30 90];
ylimits=[0.3 1.3];
nTicksY=11;
% SPM
fctSPM(DATA,EFFET_ind,EFFET_rm,...
    'savedir',savedir,'CI',0,...
    'effectsNames',effectNames,...
    'xlabel',xlab,'ylabel',ylab,...
    'xlimits',xlimits,'ylimits',ylimits,'nTicksY',nTicksY);
