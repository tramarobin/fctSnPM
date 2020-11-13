% This function takes ~20 seconds on i5 processor and files takes 13 Mo of
% storage

clear
close all
clc

% path
addAbovePath

% data
load ExampleDatas
DATA=ExampleDatas.Ratios;
DATA=DATA(:,[1:4]);

% funtion parameters
effectNames={'Speed'};
EFFET_rm{1}={'RC60','RC180','RFKF','RFKE'};
colorLine{1}=[rgb('green'); rgb('blue'); rgb('red'); rgb('black')];
% There are 20 subjects

savedir='Results\1D_ANOVA1rm';
xlab='Angle (°)';
ylab='Ratio';
xlimits=[30 90];
ylimits=[0 1.6];
nTicksY=17;

% SPM
fctSPM(DATA,[],EFFET_rm,...
    'savedir',savedir,...
    'effectsNames',effectNames,...
    'xlabel',xlab,'ylabel',ylab,...
    'xlimits',xlimits,'ylimits',ylimits,'nTicksY',nTicksY,...
    'transparancy1D',0.05,'colorline',colorLine);


