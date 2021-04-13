% This function takes ~30 seconds on i5 processor and files takes 105 Mo of
% storage

clear
close all
clc

% add source code path
addpath(genpath("../src"))

% data
load ExampleDatas
DATA=ExampleDatas.Ratios;
DATA=DATA(:,[1:4]);

% funtion parameters
effectNames={'Speed'};
EFFET_rm{1}={'RC60','RC180','RFKF','RFKE'};
colorLine{1}=[rgb('green'); rgb('blue'); rgb('red'); rgb('black')];
% There are 20 subjects

savedir=[];
xlab='Angle (°)';
ylab='Ratio';
xlimits=[30 90];
ylimits=[0 1.6];
nTicksY=17;

% SPM
tic
fctSPM(DATA,[],EFFET_rm,...
    'savedir',savedir,...
    'effectsNames',effectNames,...
    'xlabel',xlab,'ylabel',ylab,...
    'xlimits',xlimits,'ylimits',ylimits,'nTicksY',nTicksY,...
    'transparancy1D',0.05,'colorline',colorLine);
toc
