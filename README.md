# fctSPM [![status](https://joss.theoj.org/papers/ea923a728497b806dbb59a0c4c0b76cc/status.svg)](https://joss.theoj.org/papers/ea923a728497b806dbb59a0c4c0b76cc) [![View fctSPM on File Exchange](https://www.mathworks.com/matlabcentral/images/matlab-file-exchange.svg)](https://www.mathworks.com/matlabcentral/fileexchange/77945-fctspm)
Using spm1d package (v.0.4.3), computes ANOVA and post-hoc tests from anova1 to anova3rm, with a non-parametric approach (permutation tests).
The type of ANOVA (if required) and post-hoc are chosen regarding the independent or repeated measure effects given in parameters.
The function automatically adapts to 1D and 2D data.

The general usage is:
```matlab
spmAnalysis=fctSPM(data, independantEffects, repeatedMeasuresEffects, varargin)
```


## Table of contents ##
- [Warnings](#Warnings)
- [Statement of need](#Statement-of-need)
- [Citing fctSPM](#Citing-fctSPM)
- [MATLAB Release Compatibility](#MATLAB-Release-Compatibility)
- [Outputs](#Outputs)
- [Examples](#Examples)
- [Using fctSPM](#Using-fctSPM)
- [Obligatory inputs](#Obligatory-inputs)
- [Optional inputs](#Optional-inputs)
- [Optional functions](#Optional-functions)
- [Community guidelines](#Community-guidelines)


## Warnings ##
* Unbalanced two- and three-way repeated-measures ANOVA results have not been verified.
Example: more subjects in Group 1 than in Group 2.
Please interpret results for these designs with caution, and recognize that they might not be valid.
* Post-hoc tests with Bonferonni correction are only approximate and conservative. Refer to the [spm1d documentation about post hoc tests](https://spm1d.org/doc/PostHoc/anova.html) for more information.
* Some warnings are displayed if the number of permutations is automatically modified or not sufficient to perform the analysis with the defined alpha risk.
* Effect sizes and confidence intervals are not validated and are just given as supplementary information.
* For more information, please visit the [smp1d documentation](https://spm1d.org/Documentation.html)


### Caution ###
* For `independantEffects` and `repeatedMeasuresEffects`, avoid underscore (_) or minus (-) signs. Spaces are OK. It affects the recognition of sub-data for the multiples comparisons 
* Use '/' when indicating a saving directory (`savedir` option)
* Once you are ok with the created figure, increase the number of permutations (`multiPerm` or `Perm` options) to achieve numerical stability. 1000 permutations are a good start but if your hardware allows it, the more is the better


## Statement of need ##
Most of physiological data measured during human movement are continuous and expressed in function of time. 
However, researchers predominantly analyze extracted scalar values from the continuous measurement, as the mean, the maximum, the amplitude, or the integrated value over the time. 
Analyzing continuous values (i.e., time series) can provide more information than extracted indicators, as the later discards one dimension of the data among the magnitude and localization in time. 
In addition, oscillatory signals such as muscle vibrations and electromyograms contain information in the temporal and frequency domains. 
Once again, scalar analysis reduces the information at only one dimension by discarding two dimensions among the magnitude and the localization in the time and/or frequency domain.

Factorial SPM (fctSPM) allows MATLAB users to create figures of 1D and [2D SPM](https://spm1d.org/doc/Stats2D/ex2d_matlab.html) analysis for ANOVA and post-hoc designs.
The statistical analysis is also saved in `.mat` files.   
This function synthetizes the main and interaction effects to display only the significant post-hoc regarding the results of the ANOVA.   
For post-hoc for interaction effects, the main effect is also displayed if located elsewhere than the interaction effect.


## Citing fctSPM ##
* This function: under review in JOSS   
* For spm1d: Pataky TC (2010). Generalized n-dimensional biomechanical field analysis using statistical parametric mapping. Journal of Biomechanics 43, 1976-1982.   
* For permutation tests: Nichols TE, Holmes AP (2002). Nonparametric permutation tests for functional neuroimaging: a primer with examples. Human Brain Mapping 15(1), 1–25.   
* spm1d package for matlab can be downloaded at: https://github.com/0todd0000/spm1dmatlab   


## MATLAB Release Compatibility ##
Compatible from Matlab R2017b


## Outputs ##

### spmAnalysis ###
`spmAnalaysis.mat` is a structure composed of the results of the statistical analysis (ANOVA + Post Hoc). 

`spmAnalysis.anova` is composed of different fields:  
* `type` is the type of ANOVA performed
* `effectNames` is a structure (one cell for each effect) that represent the names of the effects tested (mains and interactions)
* `alpha` is the alpha risk choosen for the anova (default is 0.05 (5%)).  
* `pCritical` is the alpha risk used for the anova. Warning message is displayed if this value is modified.
* `nPermutations` is the number of permutations performed for the anova.
* `maxPermutations` is the number of maximal permutations possible for the anova.
* `Fcontinuum` is a structure that represent the F-value for each node
* `Fthreshold` is a structure that represent the statistical threshold for the F-values (statistical inference)
* `Fsignificant` is a structure that contains the logical for the significance (Fcontinuum > Fthreshold) of each effect of the ANOVA (1 if significant, 0 if not).  
* `clusterLocation` is a structure (one for each significant cluster) that contains the location (start and end as indexes) of each significant cluster.
* `clusterP` is a structure (one for each significant cluster) that contains the p-value of each significant cluster. 

`clusterLocation` and `clusterP` are created only in one dimension

`spmAnalysis.posthoc` is a strucure of cells (one for each effect of the ANOVA) composed of different fields:
* `data.names` is a structure that contains the name of the conditions used in the analysis (\cap is the union of different conditions for interactions).
* `data.continuum` is a structure that contains the data used in the analysis.

For the following outputs, the number of cells of the structure correspond to the number of t-tests performed, one t-test corresponds to one cell.
* `differences.names` is the name of the conditions (the first minus the second) used in the differences and t-tests.
* `differences.continuum` is the data used to plot differences.
* `differences.continuumRelative` is the data used to plot relative differences
* `differences.ES` is the effect size that correspond to the differences (Hedge's g)
* `differences.ESsd` is the standard deviation of the effect size.
* `tTests.type` is the type of t-test performed (independent or paired)
* `tTests.names` is the name of the conditions (the first minus the second) used in the differences and t-tests.
* `tTests.nWarning` represents the number of warnings displayed during the analysis: 0 is OK, 1 means the number of permutations was reduced but `pCritical` = `pBonferroni`, 2 means that the number of permutations was reduced and `pCritical` > `pBonferroni`. In this case, more subjects are required to performed the analysis. %* `tTests.alpha` is the alpha risk choosen for the post hoc tests before Bonferroni correction (default is the same as the ANOVA).
* `tTests.alpha` is the alpha risk choosen for the post hoc tests  before Bonferroni correction (default is the same as the ANOVA).
* `tTests.warning`: only if alpha is modified with `alphaT` input.
* `tTests.pBonferroni` is the alpha risk choosen for the post hoc tests after Bonferroni correction.
* `tTests.pCritical` is the alpha risk used for the post hoc tests. Warning message is displayed if this value does not meet pBonferroni.
* `tTests.nPermutations` is the number of permutations performed for the t-test.
* `tTests.maxPermutations` is the number of maximal permutations possible for the t-test.
* `tTests.Tcontinuum` represents the T-value for each node
* `tTests.Tthreshold` represents the statistical threshold for the T-values (statistical inference)
* `tTests.Tsignificant` contains the logical for the significance (Tcontinuum > Tthreshold) (1 if significant, 0 if not). This value is corrected with the result of the corresponding ANOVA and previous t-tests.

* `tTests.clusterLocation` is a structure (one for each significant cluster) that contains the location (start and end as indexes) of each significant cluster.
* `tTests.clusterP` is a structure (one for each significant cluster) that contains the p-value of each significant cluster. This value is corrected with inverse Bonferonni correction.
`clusterLocation` and `clusterP` are created only in one dimension and are not corrected with the result of the ANOVA.

* `tTests.contourSignificant` represents a modified T-value continuum to display smoother contour plots.
`tTests.contourSignificant is created only in two dimensions.  

* `tTests.combi` is only created for 2 and 3-way ANOVA and used in `saveNplot` to define the data to plot.

### Figures ###
Two folders composed of figures in `.TIF` and `.fig` are created

#### ANOVA ####
Each effect is also display on a specific figure in `.TIF` format named after `effectNames`, a floder named FIG is also created and contains the figures in `.fig` format.   
For 1D:  The curve represents the `Fcontinuum`, the horizontal line is the `Fthreshold`, the highlighted parts of the curve in blue represents the significant cluster(s), and the vertical lines are the start and end indexes.
For 2D: The map represents the `Fcontinuum`, with a colorbar maximum at `Fthreshold`, the white clusters represent the significant clusters.

#### Post Hoc ####
This folder contains additional folders (0 (for anova1), 3 (for anova2) or 7 (for anova3)) that contain figures and metrics representing the different post-hoc tests.  

Interaction folders (AxB or AxBxC) contain 2 or 3 folders in which one effect is investigated.

##### In one dimension #####
A total of 5 figures with the name of the effect represent the means and standard deviations between subject for each condition (grouped in function of the effect investigated).  
Under this plot, a second graph display the result of the ANOVA (or ANOVAs for interaction) and the significant post-hoc tests for pairwise comparisons.  
The differences between the 5 figures are the representation of the ANOVA and the disposition of the statistical analysis (subplot or same plot, see optional inputs)

Subfolders: Contains the pairwise comparison results 
* DIFF: Differences plots. Filenames with '%' at the end are the relative differences
* ES: Effect size plots. Bold blue lines are located at the significant differences (corrected with the ANOVA).
* SPM: Tcontinuum and statistical inferences plots. Bold blue lines are located at the significant differences (corrected with the ANOVA).
* FIG folder contains the above mentioned folder with the figures in `.fig` format.

##### In two dimensions #####
Means maps for each condition are represented in one figure each. 
The global effect of the post hoc procedure is display on a figure with the name of the effect. Mean maps are represented on the diagonal, pairwise differences on the top-right panel, and pairwise SPM inferences on the bottom-left panel. 

Subfolders: Contains the pairwise comparison results (In one folder for ANOVA1, in 2 or 3 folders for ANOVA2 and ANOVA3)
* SD: standard deviation of the maps for each condition.
* DIFF: Differences plots. Filenames with '%' at the end are the relative differences. White clusters represent the significant effect (corrected with ANOVA)
* ES: Effect size plots. Whites clusters represent the significant effect (corrected with ANOVA)
* SPM: Tcontinuum and statistical inferences plots. Whites clusters represent the significant effect (no correction with the ANOVA)
* FIG folder contains the above mentioned folder with the figures in `.fig` format.


## Examples ##
### In one dimension ### 
The output of `D1_ANOVA2_1rm.m` for a 2way ANOVA with 1 repeated measure in 1 dimension in the Examples folder is as follows 
The curves represent the ratio between Quadriceps and Hamstrings during isokinetic tests for two sides (Left and Right) and for two sexes (M and F).  

ANOVA results: There is a "Side" effect, with a F-value above the significant threshold of 7.14 between 30 and 85°.
![alt text](https://github.com/tramarobin/fctSPM/blob/master/Figures/1D_ANOVA2_1RM.png)

Post-hoc results: The curves represent the means and the standard deviations.
Right > Left between 30 and 85°.
The significant differences are displayed below the curves using the curves to display the pairwise comparisons.
The ANOVA results are also displayed if wanted.
![alt text](https://github.com/tramarobin/fctSPM/blob/master/Figures/1D_Post-hoc.png)


### In two dimensions ###
The output of `D2_ANOVA2_2rm.m` for a 2way ANOVA with 2 repeated measures in 2 dimensions is as follows
The maps represent the time-frequency analysis of vibratory signal quantified with two devices (ACC and US), and for two muscle activations (Relaxed and Contracted).

ANOVA results: Red clusters circled in white are the zone of significant effects. There are mains and interaction effects.
![alt text](https://github.com/tramarobin/fctSPM/blob/master/Figures/2D_ANOVA2_2RM.png)

Post-hoc results for main effects: Mean maps for each condition are displayed. 
Statistical results are shown within each map of differences on the top (Device effect) and at the bottom (Activation effect).
The significant cluster are circled in white.
![alt text](https://github.com/tramarobin/fctSPM/blob/master/Figures/2D_Post-hoc_MAIN.png)

Post-hoc results for interaction effects: Mean maps for each condition are displayed. 
Statistical results are shown within each map of differences on the right (Activation effect) and at the bottom (Device effect).
The significant cluster are circled in white. Note that the main effects are also displayed.
![alt text](https://github.com/tramarobin/fctSPM/blob/master/Figures/2D_Post-hoc_INT.png)

## Using fctSPM ##

### Installation ###
Install this package by adding the `src` directory and its subdirectories to the MATLAB path. 
One way to do this is to call: `addpath(genpath("./fctSPM/src"))`, where `./fctSPM/src` is the full path to the `src` directory. 
Refer to the [MATLAB documentation regarding search paths](https://fr.mathworks.com/help/matlab/matlab_env/add-remove-or-reorder-folders-on-the-search-path.html) for alternative ways to set the path for current and future sessions.

### Usage ###
```matlab
spmAnalysis=fctSPM(data, independantEffects, repeatedMeasuresEffects, varargin)
```

### Obligatory inputs ###
* `data` is a x by y cell array, with x corresponding to subjects and y corresponding to repeated measures. Each cell contains a column vector (1D) or a matrix (2D) corresponding to the mean of the subject and condition.
* `independantEffects` is a cell array defining the independent effects. There must be 1 cell by effect. Each cell contains the name ('char') of each modality for the given subject and must correspond to the number of subjects/rows (x). For instance `independantEffects{1}={'Male' 'Male' 'Female' 'Female'}` if the two first subjects are `Male` and the two last are `Female`.
* `repeatedMeasuresEffects` is a cell array defining the repeated measure effects. There must be 1 cell by effect. Each cell contains the name ('char') of each modality for the given condition and must correspond to the number of conditions/columns (y). For instance `repeatedMeasuresEffects{1}={'PRETEST' 'POSTTEST' 'RETEST'}` if there was 3 times of measurement.

### Optional inputs ###
Optional inputs are available to personalize the figures.  
```matlab
spmAnalysis=fctSPM(data, independantEffects, repeatedMeasuresEffects, 'Optional Input Name', value)
```

#### Utilities ####
These options act on the name of the created folders.
* `savedir` is the path to the save directory. Default is empty and ask you to choose or create a folder. If filled, the existing data might be overwritten (@ischar).
* `effectsNames` are the names of the effects (the independent effects must be named first). Default names the effect {'A','B','C'} (@iscell).
* `plotSub` is an option (1 to activate) to plot the individual mean for each subject. Default = 0 and don't plot the mean (@isnumeric).
* `nameSub` is an option to name the different subjects. Default names the subject are '1', '2', etc... (@iscell).

#### Statistical parameters ####
These options act at a statistical level, modifying the alpha error or the number of permutations.
* `alpha` is the alpha error risk for the ANOVA. Default is 0.05 (@isnumeric).
* `alphaT`. Do not modify except for exploratory purposes. `alphaT` is the original alpha used for post hoc tests (Bonferonni correction is applied after as alphaT/number of comparisons. Default is the same as `alpha` (@isnumeric).
* `multiPerm` define the number of permutations as multiPerm/alpha. Default is 10 and corresponds to 200 permutations for 5% risk (@isnumeric).  
**Must be increased for better reproductibility.**
* `Perm` is a fixed number of permutations. This input overrides the multiPerm ans is not recommended (@isnumeric).    
Specified either multiPerm or Perm, but not both.
* `maximalPerm` is the limit of the number of maximal permutations in case of too many multiple comparisons. By default this value is set to 10000 to not take too many computation time (@isnumeric).
* `doAllInteractions` By default, all post hoc tested are made even if ANOVA did not revealed interaction. Use 0 to performed only post-hoc when interaction was found (@isnumeric).
* `ignoreAnova` By default, consider the ANOVA significant location to interpret post-hoc. Use 1 to interpret only post-hoc tests but it is not recommended (@isnumeric).

#### General plot parameters ####
These options can modify the general aspect of the figures for 1D and 2D.
* `ylabel` are the labels of Y-axis. No name is display by default (@ischar).
* `xlabel` are the labels of X-axis. No name is display by default (@ischar).
* `samplefrequency` changes the xticks to correspond at the specified frequency. The default value is 1 (@isnumeric).
* `xlimits` changes the xticks to correspond to the specified range (it can be negative). The format is, for instance `[0 100]` (@isnumeric).   
Specified either samplefrequency or xlimits, but not both.
* `ylimits` changes the yticks to correspond to the specified range (it can be negative). The format is, for instance `[0 100]` (@isnumeric).   
* `nTicksX` is the number of xticks displayed. By default it depends on the size of the figure in 1D, and corresonds to 5 in 2D (@isnumeric).
* `nTicksY` is the number of yticks displayed. By default it depends on the size of the figure in 1D, and corresonds to 4 in 2D (@isnumeric).
* `imageResolution` is the resolution in ppp of the tiff images. The default value is 96ppp (@isnumeric).
* `imageSize` is the size of the image in cm. For instance, `[X]` or [X X] creates X by X cm images, `[X Y]` creates X by Y cm images. The default image size is 720*480 pixels (@isnumeric).
* `imageFontSize` is the font size of images. By default it is a size 12 fontsize (@isnumeric).
* `linestyle` In 1D: lineStyle for plots (default  is a solid line for the mean, a dashed line for the SD). Specify linestyle for each modality in cell, apply each style to each modality (independant effect first). `lineStyle{1}={':' '-' '--';':' '-' '--'};` to have a dotted line, a solid line, and a dashed line for the first effect (first row is for the means, second row for the sd) // In 2D: linestyle of the contour plot

#### 2D plot parameters ####
These option are specific to 2D plots.
* `colorMap` is the colormap used for means, standard deviations, ANOVA and effect sizes plots. The default colomap is cbrewer('Reds').
* `colorMapDiff` is the colormap used for differences, relative differences and post-hoc spm plots. The default colomap is cbrewer('RdBu').
Colormaps can be defined with cbrewer (distributed in this funtion): Charles (2020). cbrewer: [colorbrewer schemes for Matlab](https://www.mathworks.com/matlabcentral/fileexchange/34087-cbrewer-colorbrewer-schemes-for-matlab), MATLAB Central File Exchange. Retrieved December 11, 2020.
* `colorbarLabel` is the name of the colorbar label. No name is display by default (@ischar).
* `limitMeanMaps` defines limit of the colorbar. By default, the maps wont necessary be with the same range but will be automatically scaled at their maximum. A value of X will make the colorbar going from 0 to X for all plots to make them easier to compare (@isnumeric).
* `displaycontour` displays contour map on differences and size effect maps. Use 0 to not display the statistical analysis but it is not recommended (@isnumeric).
* `contourcolor` is the color of the line for the contour plot. The default color is white. RGB or 'color' is accepted.
* `dashedColor` is the color of the non-significant zones of the contour plot. The default color is white black. Use RGB triplet [0 0 0].
* `transparancy` is the transparency of the non-significant zones. The default value is 50 and can range from 0 (transparent) to 255 (opaque) (@isnumeric).
* `lineWidth` is the linewidth of the contour plot. The default value is 2.5 (@isnumeric).
* `diffRatio` scales the difference maps at limitMeanMaps*diffRatio. The default value is 0.33 (@isnumeric).
* `relativeRatio` scales the relative differences maps at +-relativeRatio. By default, the maps wont necessary be with the same range but will be automatically scaled at their maximum (@isnumeric).

#### 1D plot parameters ####
These option are specific to 1D plots.
* `CI` is the confidence interval used instead of standard deviation. By default, standard deviations are displayed. Use 0.7 to 0.999 to display 70% to 99.9% confidence interval, 0 to display SEM, or negative value to not dispaly dispersion (@isnumeric).
* `colorLine` is the colorline for plots (default  is "lines"). Use rgb triplet. If in cell, apply each color to each effect (independant effect first). `colorLine{1}=[rgb('blue'); rgb('magenta'); rgb('black')]` to have blue, magenta and black lines for the first effect.
* `transparancy1D` is the transparency for the SD, CI or SEM. The default value is is 0.1 (@isnumeric).
* `ratioSPM` is the ratio of SPM subplot relative to total figure. The default value is 1/3 of the figure. Must be indicated as [1 3] to have a 1/3 ratio (@isnumeric).
* `yLimitES` is the y-axis limits for ES representation. By default, the maps wont necessary be with the same range but will be automatically scaled at their maximum.
* `spmPos` is the position of SPM plot, default SPM analysis is displayed at the bottom of the figure. Any value will set the position to up.
* `aovColor` is the color of ANOVA on SPM plot. The default color is black. Use 'color' or rgb triplet.  


## Optional functions ##
in addition of `fctSPM`, this repository contains two similar funtions. 
*`fctSPMS` performs the same analysis than `fctSPM`, however, the figures are not ploted and saved. The inputs are the same at the exception that there is no savedir and no plot parameters.
*`onlyPlot` permits to plot a part of the analysis obtain with `fctSPM` and `fctSPMS`. In 1D, the ANOVA and the means with SPM analysis are displayed. In 2D, the ANOVA and the post-hoc tests are displayed.
*`saveNplot` permits to save and plot the entire analysis obtain with `fctSPM` and `fctSPMS`.

The general use of these funtion are:
```matlab
spmAnalysis=fctSPMS(data, independantEffects, repeatedMeasuresEffects, 'Optional Input Name', value)
onlyPlot(spmAnalysis,'Optional Input Name', value)
saveNplot(spmAnalysis,'Optional Input Name', value)
```
You can use `onlyPlot` to have an insight on the figures that will be saved to adjust the plot parameters.
It may be useful to use `saveNplot` when a 2D analysis is performed, it may permit to redo quickly figures without the long time of analysis.


## Community guidelines ## 
You can create a new issue in the [Issues section of this repository](https://github.com/tramarobin/fctSPM/issues) to:
* Contribute to the software 
* Report issues or problems with the software 
* Seek support  

I will try to answer as quickly and accurately as possible. Thank's for using this function.
