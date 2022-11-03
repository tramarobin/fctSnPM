% This function takes ~75 seconds on ryzen 3600X processor and files takes 120 Mo of
% storage

clear
close all
clc

% Don't forget to add the source code path
% This funtion will automatically create multiple files in a save directory located at the savedir
% adress

savedir=''; % is the adress where the output of fctSnPM is saved
savedir2=savedir; % is the adress where the output of saveNplot is saved

%% data
load ExampleDatas
DATA=ExampleDatas.Pressure;

%% parameters
% new way to input the data for an ANOVA with 2 repeated measures, possible to use a 3D structure
% dimension 1 corresonds to the participants, dimension 2 the
% repeatedMeasuresEffects{1}, and the dimension 3 repeatedMeasuresEffects{2}
independantEffects=[];
repeatedMeasuresEffects{1}={'S1','S2'}; % no need to specify each column as before
repeatedMeasuresEffects{2}={'Run', 'Landing'}; % no need to specify each column as before
effectNames={'Surface','Movement'};

axisEqual=1; %  enables the equal axis option for plots (useful for pressure/positional data). By default (0), the option is not enable. 1 to enable
deleteAxis=1; % deletes the axes (useful for pressure data). By default (0), the axes are displayed. 1 to enable (also delete the title of the graph)
statLimit=1; % default option (0) set the colorbar limit of the stat maps at the significance threshold, 1 will set the limit to the max

colorbarLabel='Peak Pressure (kPa)';
colorScale=jet(1001);
colorScaleDiff=flipud(cbrewer('div','RdBu', 1001));
colorScale(1,:)=[1 1 1]; % the outside of the pressure map is white
colorScaleDiff(499:501,:)=repmat([1 1 1],3,1); % the 0 is white

%% SnPM
tic
snpmAnalysis=fctSnPM(DATA,independantEffects,repeatedMeasuresEffects,...
    'savedir',savedir,'multiPerm',1,...
    'effectsNames',effectNames,...
    'colorbarLabel',colorbarLabel,...
    'colorMap',colorScale,'colorMapDiff',colorScaleDiff,...
    'equalAxis',axisEqual,'deleteAxis',deleteAxis,'statLimit',statLimit,...
    'imageresolution',300,'imagesize',[25 20],'imagefontsize',12);
toc
