% This function takes ~70 seconds on i5 processor and files takes 10 Mo of
% storage
% don't forget to add the source code path

clear
close all
clc

% data
load ExampleDatas
DATA=ExampleDatas.Ratios;
DATA=DATA(:,[1 5]);

% funtion parameters
effectNames={'Sex','Side'};

EFFET_ind{1}={'M','M','M','F','M','F','F','M','F','M','M','F','F','M','F','F','M','F','F','M'}; % same number than participants
colorLine{1}=[rgb('blue'); rgb('magenta')];
% There are 20 subjects

EFFET_rm{1}={'Right','Left'};
colorLine{2}=[rgb('green'); rgb('red')];

savedir=[];
xlab='Angle (°)';
ylab='Ratio';
xlimits=[30 90];
ylimits=[0 1.6];
nTicksY=9;
nTicksX=7;

% SPM
tic
fctSPM(DATA,EFFET_ind,EFFET_rm,...
    'savedir',savedir,...
    'effectsNames',effectNames,...
    'xlabel',xlab,'ylabel',ylab,...
    'xlimits',xlimits,'ylimits',ylimits,'nTicksY',nTicksY,'nTicksX',nTicksX,...
    'transparancy1D',0.05,'colorline',colorLine,'imageSize',15);
toc

