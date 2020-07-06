% This function takes ~15 seconds on i5 processor and files takes 25 Mo of space

clear
close all
clc

% path (change to your own path)
addpath(genpath('C:\Users\LIBM_yb\Google Drive\Thèse\MATLAB\library_matlab\FCT_SPM'));

% data
load ExampleDatas
DATA=ExampleDatas.ACCELECHO;

% parameters
EFFET_ind{1}={'L','L','L','L','L','L','L','M','M','M','M','S','S','S','S'}; % same number than participants
EFFET_rm=[];
effectNames={'Groupe'};
% There is 15 subjects
% Subjects 1 to 5 are 'L', 6 to 10 are 'M', and 11 to 15 are 'S'
% ANOVA1 accepts unbalanced data


savedir='Results//2D_ANOVA1';
xlab='Time (s)';
ylab='Frequency (Hz)';
Fs=500;
colorbarLabel='Power (au)';
limitMeanMaps=12;
ylimits=[10 130];

% SPM
fctSPM(DATA,EFFET_ind,EFFET_rm,...
    'savedir',savedir,...
    'effectsNames',effectNames,...
    'xlabel',xlab,'ylabel',ylab,...
    'sampleFrequency',Fs,'colorbarLabel',colorbarLabel,...
    'limitMeanMaps',limitMeanMaps,...
    'ylimits',ylimits);


