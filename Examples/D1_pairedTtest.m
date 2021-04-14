% This function takes ~15 seconds on i5 processor and files takes 2 Mo of
% storage
% don't forget to add the source code path


clear
close all
clc


% data
load ExampleDatas
DATA=ExampleDatas.Ratios(:,[1 5]);

% function parameters
effectNames={'Side'};
EFFET_ind=[]; % empty
EFFET_rm{1}={'Right','Left'}; % Side


savedir=[];
xlab='Angle (°)';
ylab='Ratio';
xlimits=[30 90];
ylimits=[0.3 1];
nTicksY=8;

% SPM
tic
fctSPM(DATA,EFFET_ind,EFFET_rm,...
    'savedir',savedir,'CI',0,...
    'effectsNames',effectNames,...
    'xlabel',xlab,'ylabel',ylab,...
    'xlimits',xlimits,'ylimits',ylimits,'nTicksY',nTicksY);
toc