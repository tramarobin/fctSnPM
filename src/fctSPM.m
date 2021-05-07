% Trama Robin (LIBM) 04/2021 --> JOSS
% trama.robin@gmail.com

% available at :
% - https://github.com/tramarobin/fctSPM
% - https://www.mathworks.com/matlabcentral/fileexchange/77945-fctspm

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% ¨Please read README.md on https://github.com/tramarobin/fctSPM for all informations

% Using spm1d package (v.0.4.3), compute anova and post-hoc tests from anova1 to anova3rm, with a non-parametric approach (permutation tests)
% The type of anova (if required) and post-hoc are choosen regarding the independant or repeated measure effect given in parameters.
% The function automatically adapts to 1D and 2D data
% Analysis and figures of the analysis are saved
% Examples are in ...\fctSPM\Examples
% 1D examples are torque ratios
% 2D examples are maps obtained with continuous wavelet transforms

% Please visit http://spm1d.org/index.html for information
% spm1d package for matlab is published elswhere : https://github.com/0todd0000/spm1dmatlab

% please cite for spm1d : Pataky TC (2010). Generalized n-dimensional biomechanical field analysis using statistical parametric mapping. Journal of Biomechanics 43, 1976-1982.
% please cite for permutation tests : Nichols TE, Holmes AP (2002). Nonparametric permutation tests for functional neuroimaging: a primer with examples. Human Brain Mapping 15(1), 1–25.

% WARNINGS:

% Unbalanced two- and three-way repeated-measures ANOVA results have not been verified.
% Example: more subjects in Group 1 than in Group 2.
% Please interpret results for these designs with caution, and recognize that they might not be valid.

% Post-hoc tests with Bonferonni correction are only approximate

% Effect sizes and confidence intervals are not validated

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% OUTPUTS
%`spmAnalaysis.mat` is a structure composed of the results of teh statistical analysis (ANOVA + Post Hoc).

%`spmAnalysis.anova` is composed of different fields :
%* `type` is the type of ANOVA performed
%* `effectNames` is a structure (one cell for each effect) that represent the names of the effects tested (mains and interactions)
%* `alpha` is the alpha risk choosen for the anova (default is 0.05 (5%)).
%* `pCritical` is the alpha risk used for the anova. Warning message is displayed if this value is modified.
%* `nIterations` is the number of iterations performed for the anova.
%* `maxIterations` is the number of maximal iterations possible for the anova.
%* `Fcontinuum` is a structure that represent the F-value for each node
%* `Fthreshold` is a structure that represent the statistical threshold for the F-values (statistical inference)
%* `Fsignificant` is a structure that contains the logical for the significance (Fcontinuum > Fthreshold) of each effect of the ANOVA (1 if significant, 0 if not).
%* `clusterLocation` is a structure (one for each significant cluster) that contains the location (start and end as indexes) of each significant cluster.
%* `clusterP` is a structure (one for each significant cluster) that contains the p-value of each significant cluster.

%`clusterLocation` and `clusterP` are created only in one dimension

%`spmAnalysis.posthoc` is a strucure of cells (one for each effect of the ANOVA) composed of different fields :
%* `data.names` is a structure that contains the name of the conditions used in the analysis (\cap is the union of different conditions for interactions).
%* `data.continuum` is a structure that contains the data used in the analysis.

%For the following outputs, the number of cells of the structure correspond to the number of t-tests performed, one t-test corresponds to one cell.
%* `differences.names` is the name of the conditions (the first minus the second) used in the differences and t-tests.
%* `differences.continuum` is the data used to plot differences.
%* `differences.continuumRelative` is the data used to plot relative differences
%* `differences.ES` is the effect size that correspond to the differences (Hedge's g)
%* `differences.ESsd` is the standard deviation of the effect size.
%* `tTests.type` is the type of t-test performed (independant or paired)
%* `tTests.names` is the name of the conditions (the first minus the second) used in the differences and t-tests.
%* `tTests.nWarning` represents the number of warnings displayed during the analysis : 0 is OK, 1 means the number of iterations was reduced but `pCritical` = `pBonferroni`, 2 means that the number of iterations was reduced and `pCritical` > `pBonferroni`. In this case, more subjects are required to performed the analysis. %* `tTests.alpha` is the alpha risk choosen for the post hoc tests  before Bonferroni correction (default is the same as the ANOVA).
%* `tTests.alpha` is the alpha risk choosen for the post hoc tests  before Bonferroni correction (default is the same as the ANOVA).
%* `tTests.warning` : only if alpha is modified with `alphaT` input.
%* `tTests.pBonferroni` is the alpha risk choosen for the post hoc tests after  Bonferroni correction.
%* `tTests.pCritical` is the alpha risk used for the post hoc tests. Warning message is displayed if this value does not meet pBonferroni.
%* `tTests.nIterations` is the number of iterations performed for the t-test.
%* `tTests.maxIterations` is the number of maximal iterations possible for the t-test.
%* `tTests.Tcontinuum` represents the T-value for each node
%* `tTests.Tthreshold` represents the statistical threshold for the T-values (statistical inference)
%* `tTests.Tsignificant` contains the logical for the significance (Tcontinuum > Tthreshold) (1 if significant, 0 if not). This value is corrected with the result of the corresponding ANOVA and previous t-tests.

%* `tTests.clusterLocation` is a structure (one for each significant cluster) that contains the location (start and end as indexes) of each significant cluster.
%* `tTests.clusterP` is a structure (one for each significant cluster) that contains the p-value of each significant cluster. This value is corrected with inverse Bonferonni correction.
%`clusterLocation` and `clusterP` are created only in one dimension and are not corrected with the result of the ANOVA.

%* `tTests.contourSignificant` represents a modified T-value continuum to display smoother contour plots.
%`tTests.contourSignificant is created only in two dimensions.



%### Figures ###
%Two folders composed of figures in `.TIF` and `.fig` are created

%#### ANOVA ####
%Each effect is also display on a specific figure in `.TIF` format named after `effectNames`, a floder named FIG is also created and contains the figures in `.fig` format.
%For 1D:  The curve represents the `Fcontinuum`, the horizontal line is the `Fthreshold`, the highlighted parts of the curve in blue represents the significant cluster(s), and the vertical lines are the start and end indexes.
%For 2D: The map represents the `Fcontinuum`, with a colorbar maximum at `Fthreshold`, the white clusters represent the significant clusters.

%#### Post Hoc ####
%This folder contains additional folders (0 (for anova1), 3 (for anova2) or 7 (for anova3)) that contain figures and metrics representing the different post-hoc tests.

%Interaction folders (AxB or AxBxC) contain 2 or 3 folders in which one effect is investigated.

%##### In one dimension #####
%A total of 5 figures with the name of the effect represent the means and standard deviations between subject for each condition (grouped in fuction of the effect investigated).
%Under this plot, a second graph display the result of the ANOVA (or ANOVAs for interaction) and the significant post-hoc tests for pairewise comparisons.
%The differences between the 5 figures are the representation of the ANOVA and the disposition of the statistical analysis (subplot or same plot, see optional inputs)

%Subfolders : Contains the pairewise comparison results
%* DIFF: Differences plots. Filenames with '%' at the end are the relative differences
%* ES: Effect size plots. Bold blue lines are located at the significant differences (corrected with the ANOVA).
%* SPM: Tcontinuum and statistical inferences plots. Bold blue lines are located at the significant differences (corrected with the ANOVA).
%* FIG folder contains the above mentionned folder with the figures in `.fig` format.


%##### In two dimensions #####
%Means maps for each condition are represented in one figure each.
%The global effect of the post hoc precedure is display on a figure with the name of the effect. Mean maps are represented on the diagonal, pairewise differences on the top-right panel, and pairewise spm inferences on the bottom-left panel.

%Subfolders : Contains the pairewise comparison results (In one folder for ANOVA1, in 2 or 3 folders for ANOVA2 and ANOVA3)
%* SD : standard deviation of the maps for each condition.
%* DIFF: Differences plots. Filenames with '%' at the end are the relative differences. White clusters represent the significant effect (corrected with ANOVA)
%* ES: Effect size plots. Whites clusters represent the significant effect (corrected with ANOVA)
%* SPM: Tcontinuum and statistical inferences plots. Whites clusters represent the significant effect (no correction with the ANOVA)
%* FIG folder contains the above mentionned folder with the figures in `.fig` format.


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
% see .\fctSPM\Examples for help

%% Informations
% All the dataset must be balanced for ANOVA 2 and 3
% Post-hoc tests with Bonferonni correction are only approximate
% See spm1d.org for the spm1d package informations used with this functions.
% works with spm1d v.0.4.3 and non-parametric (permutation test) approach
% don't forget to cite :
% Pataky TC (2010). Generalized n-dimensional biomechanical field analysis using statistical parametric mapping. Journal of Biomechanics 43, 1976-1982.
% Nichols TE, Holmes AP (2002). Nonparametric permutation tests for functional neuroimaging: a primer with examples. Human Brain Mapping 15(1), 1–25.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function spmAnalysis=fctSPM(mapsAll,effectsInd,effectsRm,varargin)

%% Optional inputs
p = inputParser;

% utilities
addParameter(p,'savedir',[]); % path to save directory
addParameter(p,'effectsNames',{'A','B','C'},@iscell); % name of the different effect tested (changes the name of folder and files)
% the independant effects must be named first
addParameter(p,'plotSub',0,@isnumeric) % 1 to plot the mean of each subject
addParameter(p,'nameSub',[],@iscell) % names of the different subjects

% statistical parameters
addParameter(p,'alpha',0.05,@isnumeric); % alpha used for the ANOVA
addParameter(p,'alphaT',[],@isnumeric); % Do not modify except for exploratory purposes. Original alpha used for post hoc tests (Bonferonni correction is applied afetr as alphaT/ number of comparisons). By default, this value is the same than the alpha used for the ANOVA.
addParameter(p,'multiIT',10,@isnumeric); % the number of permutations is multiIT/alpha. Must be increased for better reproductibility
addParameter(p,'IT',[],@isnumeric); % fixed number of iterations (override the multiIterations - not recommanded)
% specified either multiIterations or IT, but not both
addParameter(p,'maximalIT',10000,@isnumeric); % limits the number of maximal permutations in case of too many multiple comparisons.
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
addParameter(p,'imageResolution',96,@isnumeric); % resolution in ppp of the tiff images
addParameter(p,'imageSize',[],@isnumeric) % size of the image in cm. X --> X*X images, [X Y] X*Y imgages. By default the unit is pixels [0 0 720 480].
addParameter(p,'imageFontSize',12,@isnumeric) % font size of images
addParameter(p,'ylimits',[],@isnumeric); % change yticks to correspond to the specified range
addParameter(p,'linestyle','-') % In 1D : lineStyle for plots (default  is continuous) // Specify linestyle for each modality in cell, apply each style to each modality (independant effect first) // In 2D :linestyle of the contour plot

% 2d plot parameters
addParameter(p,'colorMap',cbrewer('seq','Reds', 64)) % colormap used for means and ANOVA and ES plots (0 to positive)
addParameter(p,'colorMapDiff',flipud(cbrewer('div','RdBu', 64))) % colormap used for differences and SPM plot (0 centered)
addParameter(p,'colorbarLabel','',@ischar); % name of the colorbar label
addParameter(p,'limitMeanMaps',[],@isnumeric); % limit of the colorbar. the value of X will make the colorbar going from 0 to X for all plots (easier to compare). If not specified, the maps wont necessery be with the same range but will be automatically scaled
addParameter(p,'displaycontour',1,@isnumeric); % display contour map on differences and size effect maps (0 to not display)
addParameter(p,'contourcolor','w'); % color of the line for the contour plot
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
imageResolution=['-r' num2str(p.Results.imageResolution)];
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

%% choose save directory if not specified
savedir=chooseSavedir(savedir);

%% Plot each condition (column) for each subject (row)
if plotSub==1
    PlotmeanSub(mapsAll,nameSub,effectsRm,effectNames,savedir,xlab,ylab,Fs,imageResolution,CI,ylimits,nTicksX,nTicksY,xlimits,imageFontSize,imageSize,colorLine,colorMap,colorbarLabel,limitMeanMaps,transparancy1D)
end

%% Converting data for spm analysis
[maps1d,dimensions,sujets,nRm,nEffects,typeEffectsAll,modalitiesAll,indicesEffects]=findModalities(mapsAll,effectsRm,effectsInd);

%% Choose and perform ANOVA
[anovaEffects,anova]=fctAnova(maps1d,dimensions,indicesEffects,sujets,nEffects,nRm,effectNames,alpha,savedir,multiIterations,IT,xlab,ylab,Fs,ylimits,nTicksX,nTicksY,imageResolution,xlimits,maximalIT,ignoreAnova,displayContour,contourColor,dashedColor,transparancy,lineWidth,linestyle,colorMap,imageSize,imageFontSize);

%% Choose and perform post-hocs
if min(dimensions)==1 %1D
    posthoc=fctPostHoc1d(nEffects,indicesEffects,maps1d,dimensions,modalitiesAll,typeEffectsAll,effectNames,savedir,multiIterations,IT,xlab,ylab,Fs,imageResolution,CI,ylimits,nTicksX,nTicksY,xlimits,anovaEffects,maximalIT,colorLine,doAllInteractions,imageFontSize,imageSize,alphaT,alpha,transparancy1D,ratioSPM,yLimitES,spmPos,aovColor,linestyle);
else %2D
    posthoc=fctPostHoc2d(nEffects,indicesEffects,maps1d,dimensions,modalitiesAll,typeEffectsAll,effectNames,contourColor,savedir,multiIterations,IT,xlab,ylab,Fs,ylimits,nTicksX,nTicksY,colorbarLabel,imageResolution,displayContour,limitMeanMaps,xlimits,anovaEffects,maximalIT,doAllInteractions,dashedColor,transparancy,lineWidth,imageFontSize,imageSize,colorMap,colorMapDiff,diffRatio,relativeRatio,alphaT,alpha,linestyle);
end

%% Save analysis
spmAnalysis.anova=anova;
spmAnalysis.posthoc=posthoc;
save([savedir '/spmAnalysis'], 'spmAnalysis')

end