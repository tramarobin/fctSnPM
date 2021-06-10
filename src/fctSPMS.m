% Trama Robin (LIBM) 04/2021 --> JOSS
% trama.robin@gmail.com

% available at :
% - https://github.com/tramarobin/fctSPM
% - https://www.mathworks.com/matlabcentral/fileexchange/77945-fctspm

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Please read README.md on https://github.com/tramarobin/fctSPM for all information

% Using spm1d package (v.0.4.3), compute anova and post-hoc tests from anova1 to anova3rm, with a non-parametric approach (permutation tests)
% The type of anova (if required) and post-hoc are choosen regarding the independant or repeated measure effect given in parameters.
% The function automatically adapts to 1D and 2D data
% You can find different scripts creating output for 1D and 2D data in ...\fctSPM\Examples
% 1D examples are torque ratios
% 2D examples are maps obtained with continuous wavelet transforms

% Please visit http://spm1d.org/index.html for information
% spm1d package for matlab is published elswhere : https://github.com/0todd0000/spm1dmatlab

% please cite for spm1d : Pataky TC (2010). Generalized n-dimensional biomechanical field analysis using statistical parametric mapping. Journal of Biomechanics 43, 1976-1982.
% please cite for permutation tests : Nichols TE, Holmes AP (2002). Nonparametric permutation tests for functional neuroimaging: a primer with examples. Human Brain Mapping 15(1), 1-25.

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
%* `nPermutations` is the number of permutations performed for the anova.
%* `maxPermutations` is the number of maximal permutations possible for the anova.
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
%* `tTests.nWarning` represents the number of warnings displayed during the analysis : 0 is OK, 1 means the number of permutations was reduced but `pCritical` = `pBonferroni`, 2 means that the number of permutations was reduced and `pCritical` > `pBonferroni`. In this case, more subjects are required to performed the analysis. %* `tTests.alphaOriginal` is the alpha risk choosen for the post hoc tests  before Bonferroni correction (default is the same as the ANOVA).
%* `tTests.alpha` is the alpha risk choosen for the post hoc tests  before Bonferroni correction (default is the same as the ANOVA).
%* `tTests.warning` : only if alpha is modified with `alphaT` input.
%* `tTests.pBonferroni` is the alpha risk choosen for the post hoc tests after Bonferroni correction.
%* `tTests.pCritical` is the alpha risk used for the post hoc tests. Warning message is displayed if this value does not meet pBonferroni.
%* `tTests.maxPermutations` is the number of maximal permutations possible for the t-test.
%* `tTests.Tcontinuum` represents the T-value for each node
%* `tTests.Tthreshold` represents the statistical threshold for the T-values (statistical inference)
%* `tTests.Tsignificant` contains the logical for the significance (Tcontinuum > Tthreshold) (1 if significant, 0 if not). This value is corrected with the result of the corresponding ANOVA and previous t-tests.

%* `tTests.clusterLocation` is a structure (one for each significant cluster) that contains the location (start and end as indexes) of each significant cluster.
%* `tTests.clusterP` is a structure (one for each significant cluster) that contains the p-value of each significant cluster. This value is corrected with inverse Bonferonni correction.
%`clusterLocation` and `clusterP` are created only in one dimension and are not corrected with the result of the ANOVA.

%* `tTests.contourSignificant` represents a modified T-value continuum to display smoother contour plots.
%`tTests.contourSignificant is created only in two dimensions.  

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
% see the description at begining of the function (inputParser) or on GitHub (https://github.com/tramarobin/fctSPM#optional-inputs)
% see .\fctSPM\Examples for help

%% Information
% All the dataset must be balanced for ANOVA 2 and 3
% Post-hoc tests with Bonferonni correction are only approximate
% See spm1d.org for the spm1d package information used with this functions.
% works with spm1d v.0.4.3 and non-parametric (permutation test) approach
% don't forget to cite :
% Pataky TC (2010). Generalized n-dimensional biomechanical field analysis using statistical parametric mapping. Journal of Biomechanics 43, 1976-1982.
% Nichols TE, Holmes AP (2002). Nonparametric permutation tests for functional neuroimaging: a primer with examples. Human Brain Mapping 15(1), 1-25.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function spmAnalysis=fctSPMS(mapsAll,effectsInd,effectsRm,varargin)

%% Optional inputs
p = inputParser;

% utilities
addParameter(p,'effectsNames',{'A','B','C'},@iscell); % name of the different effect tested (changes the name of folder and files)
% the independant effects must be named first

% statistical parameters
addParameter(p,'alpha',0.05,@isnumeric); % alpha used for the ANOVA
addParameter(p,'alphaT',[],@isnumeric); % Do not modify except for exploratory purposes. Original alpha used for post hoc tests (Bonferonni correction is applied afetr as alphaT/ number of comparisons). By default, this value is the same than the alpha used for the ANOVA.
addParameter(p,'multiPerm',10,@isnumeric); % the number of permutations is multiPerm/alpha. Must be increased for better reproductibility
addParameter(p,'Perm',[],@isnumeric); % fixed number of permutations (override the multiPerm - not recommanded)
% specified either multiPerm or Perm, but not both
addParameter(p,'maximalPerm',10000,@isnumeric); % limits the number of maximal permutations in case of too many multiple comparisons.
addParameter(p,'doAllInteractions',1,@isnumeric); % by default, all post hoc tested are made even if anova did not revealed interaction. 0 to performed only posthoc were interaction was found.
addParameter(p,'ignoreAnova',0,@isnumeric); % by default, consider the ANOVA signifant location to interpert post-hoc. 1 to interpret only post-hoc tests.

parse(p,varargin{:});

alpha=p.Results.alpha;
alphaT=p.Results.alphaT;
effectNames=p.Results.effectsNames;
multiPerm=p.Results.multiPerm;
Perm=p.Results.Perm;
maximalPerm=p.Results.maximalPerm;
doAllInteractions=p.Results.doAllInteractions;
ignoreAnova=p.Results.ignoreAnova;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Converting data for spm analysis
[maps1d,dimensions,sujets,nRm,nEffects,typeEffectsAll,modalitiesAll,indicesEffects]=findModalities(mapsAll,effectsRm,effectsInd);

%% Choose and perform ANOVA
[anovaEffects,anova]=fctAnovaS(maps1d,dimensions,indicesEffects,sujets,nEffects,nRm,effectNames,alpha,multiPerm,Perm,maximalPerm,ignoreAnova);

%% Choose and perform post-hocs
if min(dimensions)==1 %1D
    posthoc=fctPostHoc1dS(nEffects,indicesEffects,maps1d,dimensions,modalitiesAll,typeEffectsAll,effectNames,multiPerm,Perm,anovaEffects,maximalPerm,doAllInteractions,alphaT,alpha);
else %2D
    posthoc=fctPostHoc2dS(nEffects,indicesEffects,maps1d,dimensions,modalitiesAll,typeEffectsAll,effectNames,multiPerm,Perm,anovaEffects,maximalPerm,doAllInteractions,alphaT,alpha);
end

spmAnalysis.anova=anova;
spmAnalysis.posthoc=posthoc;

end