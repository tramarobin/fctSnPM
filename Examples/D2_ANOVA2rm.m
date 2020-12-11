% This function takes ~60 seconds on i5 processor and files takes 130 Mo of
% storage

clear
close all
clc

% path
addAbovePath

% data
load ExampleDatas
DATA=ExampleDatas.ACCELECHO;

% parameters
EFFET_ind=[];
EFFET_rm{1}={'ACC','ACC','US','US'};
EFFET_rm{2}={'Contracted','Relaxed','Contracted','Relaxed'};
effectNames={'Device','Activation'};
% There is 15 subjects
% Data(:,1) correspond to Device=ACC and Activation=Contracted
% Data(:,2) correspond to Device=ACC and Activation=Relaxed
% Data(:,3) correspond to Device=US and Activation=Contracted
% Data(:,4) correspond to Device=US and Activation=Relaxed

savedir='Results\2D_ANOVA2rm';
xlab='Time (s)';
ylab='Frequency (Hz)';
Fs=500;
colorbarLabel='Amplitude (m\cdots^-^2)';
limitMeanMaps=12;
ylimits=[10 130];
mIT=20;

% SPM
tic
fctSPM(DATA,EFFET_ind,EFFET_rm,...
    'savedir',savedir,'multiIT',mIT,...
    'effectsNames',effectNames,...
    'xlabel',xlab,'nTicksX',6,'ylabel',ylab,'nTicksY',7,...
    'sampleFrequency',Fs,'colorbarLabel',colorbarLabel,...
    'limitMeanMaps',limitMeanMaps,...
    'ylimits',ylimits,'imagesize',[15 10]);

toc
