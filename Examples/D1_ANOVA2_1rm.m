% This function takes ~30 seconds on i5 processor and files takes 8 Mo of
% storage

clear
close all
clc

% path
addAbovePath

% data
load ExampleDatas
DATA=ExampleDatas.Ratios;
DATA=DATA(:,[1 4]);

% funtion parameters
EFFET_ind{1}={'M','M','M','F','M','F','F','M','F','M','M','F','F','M','F','F','M','F','F','M'}; % same number than participants
EFFET_rm{1}={'D','G'};
effectNames={'Sex','Side'};
% There are 20 subjects

savedir='Results//1D_ANOVA2_1rm';
xlab='Angle (°)';
ylab='Ratio';
xlimits=[30 90];
ylimits=[0 1.6];
nTicksY=17;
colorLine{1}=[rgb('cyan'); rgb('magenta')];
colorLine{2}=[rgb('blue'); rgb('red')];

% SPM
fctSPM(DATA,EFFET_ind,EFFET_rm,...
    'savedir',savedir,...
    'effectsNames',effectNames,...
    'xlabel',xlab,'ylabel',ylab,...
    'xlimits',xlimits,'ylimits',ylimits,'nTicksY',nTicksY,...
    'colorSPM',[0.5 0.8 0.5],'transparancy1D',0.05,'colorline',colorLine);


