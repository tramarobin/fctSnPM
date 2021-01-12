% Trama Robin (LIBM) 12/01/2021 --> release 1.4.2
% trama.robin@gmail.com
 
% available at : 
% - https://github.com/tramarobin/fctSPM
% - https://www.mathworks.com/matlabcentral/fileexchange/77945-fctspm

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% ¨Please read README.md on https://github.com/tramarobin/fctSPM for all informations

% Using spm1d package (v.0.4.3), compute anova and post-hoc tests from anova1 to anova3rm, with a non-parametric approach (permutation tests)
% The type of anova (if required) and post-hoc are choosen regarding the independant or repeated measure effect given in parameters.
% The function automatically adapts to 1D and 2D data
% Examples are in ...\fctSPM\Examples
% 1D examples are torque ratios
% 2D examples are maps obtained with continuous wavelet transforms

% Please visit http://spm1d.org/index.html for information
% spm1d package for matlab : https://github.com/0todd0000/spm1dmatlab

% please cite for spm1d : Pataky TC (2010). Generalized n-dimensional biomechanical field analysis using statistical parametric mapping. Journal of Biomechanics 43, 1976-1982.
% please cite for permutation tests : Nichols TE, Holmes AP (2002). Nonparametric permutation tests for functional neuroimaging: a primer with examples. Human Brain Mapping 15(1), 1–25.

% WARNINGS:

% Unbalanced two- and three-way repeated-measures ANOVA results have not been verified.
% Example: more subjects in Group 1 than in Group 2.
% Please interpret results for these designs with caution, and recognize that they might not be valid.

% Post-hoc tests with Bonferonni correction are only approximate

% Effect sizes and confidence intervals are not validated

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% INPUTS
% OBLIGATORY
% Data are presented in cells and correspond to the mean of the subject if there are multiple trials (to consider a trial effect, specify a repeated measure parameter)
% rows = subjects // columns=conditions (repeared measure effects)
% For 1D data, data MUST be of size (X,1), X being the number of nodes
% Independant effects : 1 cell by effect. Must correspond to the number of subjects
% Repeated measures effects : 1 cell by effect. Must correspond to the number of columns in the dataset.
% avoid the same typo (e.g., POST, POST2) for the effect names, it affects
% the recognition for the multiples comparisons
% also avoid underscore (_) or minus (-) sign. Spaces are OK

% OPTIONAL
% see the description at begining of the function (inputParser)
% see ...\FCT_SPM\Examples for help

%% OUTPUTS
% Figures : One for each effect of the anova, and for each post hoc (means, means + SPM results, differences, relative differences, effect size and SPM analysis for each comparison)
% .mat files for ANOVA and multiple comparison (indicate the number of iterations, the alpha, and teh warning associated)
% Type of ANOVA is choosen in regards of the effects defined in the function (ANOVA1 --> ANOVA3rm)
% Post-hoc are corrected with Bonferonni and paired or not in fuction of the effect(s) tested (WARNING : Post-hoc tests with Bonferonni correction are only approximate)
% The SPM results displayed in 1D or 2D correspond to the intersection of the ANOVA and the t-test (a t-test is only significant if the anova is significant at the same location)
% for the interactions, main effects at the location where only main effects are located are used to display a global map of main effects+interaction on the same figure

%% Informations
% All the dataset must be balanced for ANOVA 2 and 3
% Post-hoc tests with Bonferonni correction are only approximate
% See spm1d.org for the spm1d package informations used with this functions.
% works with spm1d v.0.4.3 and non-parametric (permutation test) approach
% don't forget to cite :
% Pataky TC (2010). Generalized n-dimensional biomechanical field analysis using statistical parametric mapping. Journal of Biomechanics 43, 1976-1982.
% Nichols TE, Holmes AP (2002). Nonparametric permutation tests for functional neuroimaging: a primer with examples. Human Brain Mapping 15(1), 1–25.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function fctSPM(mapsAll,effectsInd,effectsRm,varargin)

%% Optional inputs
p = inputParser;

% utilities
addParameter(p,'savedir','RESULTS',@ischar); % save directory
addParameter(p,'effectsNames',{'A','B','C'},@iscell); % name of the different effect tested (changes the name of folder and files)
% the independant effects must be named first
addParameter(p,'plotSub',0,@isnumeric) % 1 to plot the mean of each subject
addParameter(p,'nameSub',[],@iscell) % names of the different subjects

% statistical parameters
addParameter(p,'alpha',0.05,@isnumeric); % alpha used for the ANOVA
addParameter(p,'multiIT',10,@isnumeric); % the number of permutations is multiIT/alpha. Must be increased for better reproductibility
addParameter(p,'IT',[],@isnumeric); % fixed number of iterations (override the multiIterations - not recommanded)
% specified either multiIterations or IT, but not both
addParameter(p,'maximalIT',10000,@isnumeric); % limits the number of maximal permutations in case of too many multiple comparisons.
addParameter(p,'alphaT',0.05,@isnumeric); % original alpha used for post hoc tests (Bonferonni correction is applied afetr as alphaT/ number of comparisons)
addParameter(p,'nT',[],@isnumeric); % number of post hoc tests performed (override the alphaT - not recommanded)
% specified either alphaT or nT, but not both
addParameter(p,'doAllInteractions',1,@isnumeric); % by default, all post hoc tested are made even if anova did not revealed interaction. 0 to performed only posthoc were interaction was found.
addParameter(p,'ignoreAnova',0,@isnumeric); % by default, consider the ANOVA signifant location to interpert post-hoc. 1 to interpret only post-hoc tests.

% general plot parameters
addParameter(p,'ylabel','',@ischar); % label of Y-axis
addParameter(p,'xlabel','',@ischar); % label of X-axis
addParameter(p,'samplefrequency',1,@isnumeric); % change xticks to correspond at the specified frequency
addParameter(p,'xlimits',[],@isnumeric); % change xticks to correspond to the specified range (can be negative)
% specified either samplefrequency or xlimits, but not both
addParameter(p,'nTicksX',5,@isnumeric); % number of xticks displayed
addParameter(p,'nTicksY',[],@isnumeric); % number of yticks displayed
addParameter(p,'imageresolution',300,@isnumeric); % resolution in ppp of the tiff images
addParameter(p,'imageSize',[],@isnumeric) % size of the image in cm. X --> X*X images, [X Y] X*Y imgages. By default the unit is normalized [0 0 1 1].
addParameter(p,'imageFontSize',12,@isnumeric) % font size of images
addParameter(p,'ylimits',[],@isnumeric); % change yticks to correspond to the specified range

% 2d plot parameters
addParameter(p,'colorMap',cbrewer('seq','Reds', 64)) % colormap used for means and ANOVA and ES plots (0 to positive)
addParameter(p,'colorMapDiff',flipud(cbrewer('div','RdBu', 64))) % colormap used for differences and SPM plot (0 centered)
addParameter(p,'colorbarLabel','',@ischar); % name of the colorbar label
addParameter(p,'limitMeanMaps',[],@isnumeric); % limit of the colorbar. the value of X will make the colorbar going from 0 to X for all plots (easier to compare). If not specified, the maps wont necessery be with the same range but will be automatically scaled
addParameter(p,'displaycontour',1,@isnumeric); % display contour map on differences and size effect maps (0 to not display)
addParameter(p,'contourcolor','w'); % color of the line for the contour plot
addParameter(p,'linestyle','-') % linestyle of the contour plot
addParameter(p,'dashedColor',[0 0 0],@isnumeric) % color of the dashed zone of the contour plot (default is white)
addParameter(p,'transparancy',50,@isnumeric) % transparancy of the dashed zone (0=transparant, 255=opaque)
addParameter(p,'lineWidth',2.5,@isnumeric) % linewidth of the contour plot
addParameter(p,'diffRatio',0.33,@isnumeric) % the differences map will be scale at limitMeanMaps*diffRatio.
addParameter(p,'relativeRatio',[],@isnumeric) % the relative differences maps will be scale at +-relativeRatio

% 1d plot parameters
addParameter(p,'CI',[],@isnumeric); % confidence interval is used instead of standard deviation (0.7-->0.999), 0 to display SEM
addParameter(p,'colorLine',[]); % colorline for plots (default  is "lines") // rgb triplet, if in cell, apply each color to each effect (independant effect first)
addParameter(p,'transparancy1D',0.10); % transparancy of SD for 1D plot
addParameter(p,'ratioSPM',[1 3]); % ratio of SPM subplot relative to total figure (default if 1/3 of the figure)
addParameter(p,'yLimitES',[]); % y-axis limits for ES representation
addParameter(p,'spmPos',[]); % postion of spm plot, default is bottom, any value will set the position to up
addParameter(p,'aovColor','k'); % color of anova on SPM plot (color or rgb)

parse(p,varargin{:});

alpha=p.Results.alpha;
alphaT=p.Results.alphaT;
nT=p.Results.nT;
contourColor=p.Results.contourcolor;
ylab=p.Results.ylabel;
xlab=p.Results.xlabel;
Fs=p.Results.samplefrequency;
savedir=p.Results.savedir;
effectNames=p.Results.effectsNames;
multiIterations=p.Results.multiIT;
IT=p.Results.IT;
ylimits=p.Results.ylimits;
xlimits=p.Results.xlimits;
nTicksX=p.Results.nTicksX;
nTicksY=p.Results.nTicksY;
displayContour=p.Results.displaycontour;
imageResolution=['-r' num2str(p.Results.imageresolution)];
colorbarLabel=p.Results.colorbarLabel;
limitMeanMaps=p.Results.limitMeanMaps;
CI=p.Results.CI;
maximalIT=p.Results.maximalIT;
colorLine=p.Results.colorLine;
doAllInteractions=p.Results.doAllInteractions;
dashedColor=p.Results.dashedColor;
transparancy=p.Results.transparancy;
lineWidth=p.Results.lineWidth;
imageSize=p.Results.imageSize;
imageFontSize=p.Results.imageFontSize;
colorMap=p.Results.colorMap;
colorMapDiff=p.Results.colorMapDiff;
diffRatio=p.Results.diffRatio;
relativeRatio=p.Results.relativeRatio;
ignoreAnova=p.Results.ignoreAnova;
linestyle=p.Results.linestyle;
plotSub=p.Results.plotSub;
nameSub=p.Results.nameSub;
transparancy1D=p.Results.transparancy1D;
ratioSPM=p.Results.ratioSPM;
yLimitES=p.Results.yLimitES;
spmPos=p.Results.spmPos;
aovColor=p.Results.aovColor;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Plot each condition (column) for each subject (row)
if plotSub==1
    PlotmeanSub(mapsAll,nameSub,effectsRm,effectNames,savedir,xlab,ylab,Fs,imageResolution,CI,ylimits,nTicksX,nTicksY,xlimits,imageFontSize,imageSize,colorLine,colorMap,colorbarLabel,limitMeanMaps)
end

%% Converting data for spm analysis
[maps1d,dimensions,sujets,nRm,nEffects,typeEffectsAll,modalitiesAll,indicesEffects]=findModalities(mapsAll,effectsRm,effectsInd);

%% Choose and perform ANOVA
[anovaEffects]=fctAnova(maps1d,dimensions,indicesEffects,sujets,nEffects,nRm,effectNames,alpha,savedir,multiIterations,IT,xlab,ylab,Fs,ylimits,nTicksX,nTicksY,imageResolution,xlimits,maximalIT,ignoreAnova,displayContour,contourColor,dashedColor,transparancy,lineWidth,linestyle,colorMap,imageSize,imageFontSize);

%% Choose and perform post-hocs
if min(dimensions)==1 %1D
    fctPostHoc1d(nEffects,indicesEffects,maps1d,dimensions,modalitiesAll,typeEffectsAll,effectNames,savedir,multiIterations,IT,xlab,ylab,Fs,imageResolution,CI,ylimits,nTicksX,nTicksY,xlimits,anovaEffects,maximalIT,colorLine,doAllInteractions,imageFontSize,imageSize,alphaT,nT,transparancy1D,ratioSPM,yLimitES,spmPos,aovColor);
else %2D
    fctPostHoc2d(nEffects,indicesEffects,maps1d,dimensions,modalitiesAll,typeEffectsAll,effectNames,contourColor,savedir,multiIterations,IT,xlab,ylab,Fs,ylimits,nTicksX,nTicksY,colorbarLabel,imageResolution,displayContour,limitMeanMaps,xlimits,anovaEffects,maximalIT,doAllInteractions,dashedColor,transparancy,lineWidth,imageFontSize,imageSize,colorMap,colorMapDiff,diffRatio,relativeRatio,alphaT,nT,linestyle);
end


end