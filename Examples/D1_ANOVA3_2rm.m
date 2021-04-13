% This function takes ~700 seconds on i5 processor and files takes 1.4 Go of space

clear
close all
clc

% add source code path
addpath(genpath("../src"))

% data
load ExampleDatas
DATA=ExampleDatas.Ratios;

% parameters
effectNames={'Sex','Speed','Side'};

EFFET_ind{1}={'M','M','M','F','M','F','F','M','F','M','M','F','F','M','F','F','M','F','F','M'}; % same number than participants
colorLine{1}=[rgb('cyan'); rgb('magenta')];

EFFET_rm{1}={'RC60','RC180','RFKF','RFKE','RC60','RC180','RFKF','RFKE'};
colorLine{2}=[rgb('green'); rgb('blue'); rgb('red'); rgb('black')];

EFFET_rm{2}={'Right','Right','Right','Right','Left','Left','Left','Left'};
colorLine{3}=[rgb('gray'); rgb('darkgray')];

% There are 20 subjects
% ANOVA3 does not accept unbalanced data (10 males, 10 females)

savedir=[];
xlab='Angle (°)';
ylab='Ratio';
xlimits=[30 90];
ylimits=[0 1.6];
nTicksY=17;


% SPM
tic
fctSPM(DATA,EFFET_ind,EFFET_rm,...
    'savedir',savedir,'imageSize',25,...
    'effectsNames',effectNames,...
    'xlabel',xlab,'ylabel',ylab,...
    'xlimits',xlimits,'ylimits',ylimits,'nTicksY',nTicksY,'colorline',colorLine);
toc

