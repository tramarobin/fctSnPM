# fctSPM [![View fctSPM on File Exchange](https://www.mathworks.com/matlabcentral/images/matlab-file-exchange.svg)](https://www.mathworks.com/matlabcentral/fileexchange/77945-fctspm)
Using spm1d package (v.0.4.3), compute ANOVA and post-hoc tests from anova1 to anova3rm, with a non-parametric approach (permutation tests)
The type of anova (if required) and post-hoc are choosen regarding the independant or repeated measure effect given in parameters.
The function automatically adapts to 1D and 2D data

The general usage is:
```matlab
fctSPM(data, independantEffects, repeatedMeasuresEffect,varargin)
```


## Table of contents ##
- [Why fctSPM](#Why-fctSPM)
- [Citing fctSPM](#Citing-fctSPM)
- [MATLAB Release Compatibility](#MATLAB-Release-Compatibility)
- [Simple Example](#Simple-Example)
- [Using fctSPM](#Using-fctSPM)
- [More Examples](#More-Examples)
- [Unit Test](#Unit-Test)
- [List of all input options](#List-of-all-input-options)


## Why fctSPM ##
fctSPM allows MATLAB users to create figures of 1D and 2D SPM analysis for ANOVA and post-hoc designs. The sstatistical analysis is also saved in .mat files.
This function synthetises the main and interaction effects to display only the significant post-hoc regarding the results of the ANOVA.

## Citing fctSPM ##
in progress


## MATLAB Release Compatibility ##
Compatible with R2017b


## Example ##
Examples can be found in ...\fctSPM\Examples  

Here the outcomes for a 2way ANOVA with 1 repeated measure in 1 dimension - ...\fctSPM\Examples\D1_ANOVA2_1rm.m  

ANOVA results
<img src="/Figures/ANOVA2_1RM" alt="fctSPM example" width="600"> 


## Using fctSPM ##

### Installation ###
Simply put fctSPM.m in any directory of your choice and make sure it is added to your path.

### Usage ###
  fctSPM(TimeVar, EventVar, GroupVar,'param', value, ...) creates a Kaplan-Meier plot with
  a risk table and calculates a log-rank p-value.

  [p] = fctSPM( ... ) returns the log-rank p-value
  
  [p, fh] = fctSPM( ... ) returns both p-value and figure handle
  
  [p, fh, stats] = fctSPM( ... ) returns additions stats from the log-rank test
  
  [p, fh, stats] = fctSPM([], [], [], ... ) loads a test dataset from "Freireich, EJ et al. 1963, Blood, 21, 699-716"

INPUTS:

* `TimeVar` is a vector with numeric time to event, either observed or
  censored. Values equal or less than zero will be removed by default

* `EventVar` is a vector or cell array defining events or censored
  observations. Events are defined with a 1 and censored point with a 0. By
  default 'Dead', 'Deceased', 'Relapsed', 'Yes' are considered as events.
  'Alive', 'Living', 'Not Relapsed', 'DiseaseFree', 'No' are considered as censored.
  'EventDefinition' can be used to define other types of events. 

* `GroupVar` is a vector or cell array defining the different groups.
   if `GroupVar` is a numeric vector, median-cut will be used as a default.

OUTPUTS:

* p       : Log-rank p-value

* fh      : Figure handle for KM plot figure

* stats   : Structure with additional statistics in the following fields:
```matlab
  struct with fields: 
      
          GroupNames: Cell with group names 
                p_MC: log rank p-value (Mantel-Cox) 
             Chi2_MC: Chi square (Mantel-Cox) 
          HR_logrank: Hazard Ratio (log rank)
    HR_95_CI_logrank: 95 percentile Confidence Intervals [lower upper]
      HR_logrank_Inv: Inverted Hazard Ratio (log rank)
HR_95_CI_logrank_Inv: Inverted 95 percentile Confidence Intervals [lower upper]
               HR_MH: Hazard Ratio (Mantel-Haenszel)
         HR_95_CI_MH: 95 percentile Confidence Intervals [lower upper]
           HR_MH_Inv: Inverted Hazard Ratio (Mantel-Haenszel)
     HR_95_CI_MH_Inv: Inverted 95 percentile Confidence Intervals [lower upper]
  MedianSurvivalTime: Median survival time for each group
  
```

## More Examples ##

### Additional options ###
Below are some examples for how to create different styles of KM plots and also how one can make changes using the figure handle.

In the example below, we show how we can change some of the properties of the KM plot via various name-value pair arguments. 

```matlab
 
[p,fh,stats]=fctSPM([],[],[],'Xstep',4,...
'TitleOptions',{'Color','r','Interpreter','none'},'InvHR',1,...
'Xlim',32,'XMinorTick',3,'LineColor',[0 0 1;1 0 1],'LineStyle',{'-',':'},...
'LineWidth',3,'CensorLineColor','k','RT_KMplot',1);

```
<img src="/figures/Example_02.png" alt="fctSPM example" width="600">

### Example with multiple groups ###

This example is taken from the TCGA laml data set. Obtaining the data from cBioPortal can be found in the fctSPM/Article/MATLAB/get_laml_RC_data.m script. The samples are diveded into three groups based on their Cyto score. It is clear from the KM-Plot below that these groups have different outcomes.

For this example we will load the data directly.

```matlab
load laml_RC_data.mat

[p,fh,stats]=fctSPM(laml_RC_TimeVar, laml_RC_EventVar,  laml_RC_GroupVar,...
'GroupsToUse', {'Good','Intermediate','Poor'},'Xstep',24);
```
<img src="/figures/laml_Risk_Cyto.png" alt="Multiple groups fctSPM example" width="600">

### Example with merging groups ###

Groups can be merged using a multilevel cell as GroupToUse input
This example will merge the poor and N.D group. The first element in the cell array will define the name of the merged group and can either be the name of an existing group or a new group name.

```matlab
load laml_RC_data.mat

[p,fh,stats]=fctSPM(laml_RC_TimeVar, laml_RC_EventVar,  laml_RC_GroupVar,...
'GroupsToUse', {'Good','Intermediate',{'Poor + N.D.','Poor','N.D.'}},'Xstep',24);
```
<img src="/figures/laml_Risk_Cyto_Merged.png" alt="Multiple merged groups fctSPM example" width="600">


### Example with gene expression data ###

This example is also taken from the TCGA LAML dataset but we in this example we will be using RNAseq gene expression data for the hepatocyte growth factor (HGF) gene. HGF gene expression has been related to outcome in a variety of cancers, including of the lungs, pancreas, thyroid, colon, and breast. Obtaining the data from cBioPortal can be found in the fctSPM/Article/MATLAB/get_laml_HGF_gene_data.m script. The expression level of a gene is continues and if no prior knowledge is available, the median is frequqently used to divide the samples into two groups, see the first graph below. Using the top 25% and bottom 25%, quartiles, is also frequently used, see the second graph below. Finally, if one or several cut-points level are known, these can also be used, third graph below. 
For this example we will load the data directly. 

```matlab
load laml_HGF_gene_data.mat

% Using median cut
[p,fh,stats]=fctSPM(laml_HGF_gene_TimeVar,laml_HGF_gene_EventVar,HGF_gene,'Xstep',12,'InvHR',1);

% Using quartile
[p,fh,stats]=fctSPM(laml_HGF_gene_TimeVar,laml_HGF_gene_EventVar,HGF_gene,'Xstep',12,'InvHR',1,...
                     'CutPoint','quartile');

% Using Two Cut points
[p,fh,stats]=fctSPM(laml_HGF_gene_TimeVar,laml_HGF_gene_EventVar,HGF_gene,'Xstep',12,'InvHR',1,...
                    'CutPoint',[6 12]);

```
#### Median cut ####

<img src="/figures/laml_HGF_gene_Median.png" alt="Median fctSPM example" width="600">


#### Quartile ####

<img src="/figures/laml_HGF_gene_Quartile.png" alt="Quartile fctSPM example" width="600">


#### Two cut points ####

<img src="/figures/laml_HGF_gene_TwoCutPoints.png" alt="Two Cut points fctSPM example" width="600">

## Unit Test ##

A test script for fctSPM can be found in the UnitTest directory.


## List of all input options ##

* `NoPlot`: A true/false value which, if true, no figure is created
  (default: false)

* `NoRiskTable`: A true/false value which, if true, no risk table is
  included in the KM plot. (default: false)

* `CutPoint`: Either a string or scalar/vector with cut points to be used
  for defining groups based on a continuous `GroupVar` input variable
  Allowed names are: 'Median', 'Quartile' or 'Tertile'
  If a scalar or vector is given, the groups will be defined based on the
  cut points. (default: 'Median')

* `GroupsToUse`: Cell array defining what groups to use from the `GroupVar`
   variable. Groups can be merged using a multilevel cell structure, for example:
   {{'Group 1+2','Group1','Group2'},'Group3','Group4'} Group 1 & 2 will be
   merged and called Group 1+2 (default: all groups are used)

* `GroupOrder`: A cell array or vector defining the group order to be used in the
   legend. The vector needs to have the same number of elements as groups 
   while the cell array does not have that requirement. 
   (default: Groups are sorthed by `GroupsToUse` if defined, else alphabetically)

* `EventDefinition`: Two element cell array where the first cell defines
  the event and the second defines censored values. Example {'Dead,'Alive'}

* `TimeMin`: Scalar defining minimum valid time point. Subjects with time
  values below this will be removed. (default: 0)
  
* `MinNumSamples`: Scalar defining minimum number of samples for a Group
   Groups with less samples will be removed. (default: 2)

* `TimeMax`: Scalar value defining right censoring time. Subjects with
  `TimeVar` > `TimeMax` will be set to `TimeMax` and considered as censored.
  (default: [])

* `LogRankTrend`: A true/false for performing a log rank test for trend
   requires equally spaced ordered groups (default: false)

* `PairWiseP`: A true/false value for calculating pairwise log-rank test
  between group pairs; useful if there are more than two groups. (default: false)

* `NoWarnings`: A true/false value which, if true, no warnings are printed
  if subjects are removed. (default: false)

* `MedianLess`: By default 'x < median' is used for median cut, but if false
  'x > median' is used instead, only affect the results when there
  is an odd number of samples (default: true)
 

KM plot options
* `legend`: Whether to show group legend. Default: true

* `LineColor`: Either a matrix of size numLevels-by-3 representing the
   colormap to be used, or a string for a MATLAB colormap (lines, parula,
   cool, prism) or 'JCO' 'nejm' 'Lancet' 'Science' 'Nature' 'lines' for a
   set of journal dependent palettes or custom default 'aeb01' (default:'aeb01')

* `FlipGroupOrder`: Flips the order of the groups in the legend.
  (default: false)

* `FlipColorOrder`: Flips the color order of the groups.
  (default: false)

* `KM_position`: Vector defining the KM axes for the KM plot.
  (default: [0.3 0.4 0.68 0.45])

* `RT_position`: Vector defining the risk table axes for the KM plot.
  (default: [0.3 0.05 0.68 0.20])

* `TimeUnit`: String defining the time unit displayed on the x-axis.
  (default: 'Months')

* `BaseFontSize`: Base font size for all text in the plot.
  (default: 16)

* `DispP`: A true/false value which, if true, the log-rank test p-value
  is displayed on the KM plot. (default: true)

* `DispHR`: A true/false value which, if true, the HR
  is displayed on the KM plot. (default: true)
  
* `Use_HR_MH`: A true/false value which, if true, Mantel-Haenszel HR
   is displayed instead of the logrank HR. (default: true)

* `InvHR`: A true/false value which, if true, the inverted HR value
  is displayed on the KM plot. (default: false)
  
* `DrawMSL`: A true/false value which, if true, a line for the median
  survival time is drawn in the KM-plot. (default: false)

* `XLim`: Vector defining the x-limit. Does not affect the log-rank test.
  (default: automatic)

* `LineWidth`: Scalar defining the line width used in the KM plot.
  (Default: 2)

* `LineStyle`: Cell array defining the line style for the KM plot.
  If an array is given each group will have different linestyle, for example
  `LineStyle`,{'-','--',':','-.'}
  (Default: {'-'})

* `CensorLineWidth`: Scalar defining the line width of the censored ticks.
  (default: 2)

* `CensorLineLength`: Scalar defining the length of the censored ticks.
  (Default: 0.02)

* `CensorLineColor`: Text string defining color of censor ticks. 'same'
  gives the same colors as the lines while 'k' makes them black
  (Default: 'same')

* `Xstep`: Scalar defining the x-tick step length.
  (defaut: automatic)

* `XTicks`: Vector defining the position of the x-tick marks. 
  (Default: automatic)

* `XMinorTick`: Scalar defining the number of minor ticks between major x-ticks. (Default: 1)

* `Xlabel`: Text string for x-label (Default: 'Time (Months)')

* `XlabelOptions`: MATLAB Name-value pair arguments for x-label. (Default: '')

* `XLabelFontSize`: Scalar describing x-label font size change compared
  to base font size. (Default: 0)

* `XTickFontSize`: Scalar describing x-tick font size change compared
  to base font size. (Default: -2)
  
* `YLim`: Vector defining the range of the Y-axis  (Default: [0 1])

* `YTicks`: Vector defining the position of the x-tick marks.
  (Default: [0:0.2:1])

* `YMinorTick`: Scalar defining the number of minor ticks between major y-ticks. (Default: 1)

* `Ylabel`: Text string for y-label. (Default: 'Survival Probability' )

* `YlabelOptions`: MATLAB name-value pair arguments for y-label. (Default: '')

* `YLabelFontSize`: Scalar describing y-label font size change compared
  to base font size. (Default: 0)

* `YTickFontSize`: Scalar describing y-tick font size change compared
  to base font size. (Default: -2)

* `Title`: Text string for title. (Default:'')

* `TitleOptions`: MATLAB name-value pair arguments for title. (Default:'')

* `LegendFontSize`: Scalar describing legend font size change compared
  to base font size. (Default: -2)

* `PvalFontSize`: Scalar describing p-value font size change compared
  to base font size. (Default: 0)

Risk table plot options

* `RT_KMplot`: A true/false value which, if true, the risk table is placed
  as a part of the KM-plot. (default: False)

* `RT_XAxis`: A true/false value which, if true, a X-axis line is
  included in the risk table. (default: True)

* `RT_FontSize`: Scalar describing risk table font size change compared
  to base font size. (Default: 0)

* `RT_Color`: Text string defining color of risk table text. 'same'
  gives the same colors as the groups in the KM plot while 'k' would make
  them black. (Default: 'same')

* `RT_Title`: Text string for risk table title. (Default: '' )

* `RT_TitleOptions`: MATLAB name-value pair arguments for risk table title. (Default: '')

* `RT_YLabel`: A true/false value for displaying the group names on the risk table
  y axis. (Default: true )


