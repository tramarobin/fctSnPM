% This function takes ~30 seconds on i5 processor and files takes 37 Mo of
% storage

clear
close all
clc

% path
addAbovePath

% data
load ExampleDatas
DATA=ExampleDatas.Ratios;
DATA=DATA(:,[1 5]);

% funtion parameters
effectNames={'Sex','Side'};

EFFET_ind{1}={'M','M','M','F','M','F','F','M','F','M','M','F','F','M','F','F','M','F','F','M'}; % same number than participants
colorLine{1}=[rgb('cyan'); rgb('magenta')];
% There are 20 subjects

EFFET_rm{1}={'Right','Left'};
colorLine{2}=[rgb('blue'); rgb('red')];

savedir='Results\\1D_ANOVA2_1rm';
xlab='Angle (°)';
ylab='Ratio';
xlimits=[30 90];
ylimits=[0 1.6];
nTicksY=17;


% SPM
fctSPM(DATA,EFFET_ind,EFFET_rm,...
    'savedir',savedir,...
    'effectsNames',effectNames,...
    'xlabel',xlab,'ylabel',ylab,...
    'xlimits',xlimits,'ylimits',ylimits,'nTicksY',nTicksY,...
    'transparancy1D',0.05,'colorline',colorLine,'imageSize',[15 10]);


