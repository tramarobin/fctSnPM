% This function takes ~8 seconds on i5 processor and files takes 30 Mo of
% storage

clear
close all
clc

% add source code path
addpath(genpath("../src"))

% data
load ExampleDatas
DATA=ExampleDatas.Ratios(:,[1 5]);

% function parameters
effectNames={'Side'};
EFFET_ind=[]; % empty
EFFET_rm{1}={'Right','Left'}; % Side


savedir='Results/1D_pairedTtest';
xlab='Angle (°)';
ylab='Ratio';
xlimits=[30 90];
ylimits=[0.3 1];
nTicksY=8;

tic
% SPM
fctSPM(DATA,EFFET_ind,EFFET_rm,...
    'savedir',savedir,'CI',0,...
    'effectsNames',effectNames,...
    'xlabel',xlab,'ylabel',ylab,...
    'xlimits',xlimits,'ylimits',ylimits,'nTicksY',nTicksY);
toc
