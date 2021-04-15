---
title: 'fctSPM: Factorial ANOVA and post-hoc tests for Statistical Parametric Mapping in MATLAB'
tags: 
  - MATLAB
  - statistical analysis
  - Statistical Parametric Mapping
authors: 
  - name: Robin Trama
    orcid: 0000-0001-6807-0505
    affiliation: 1
  - name: Christophe A Hautier
    ordic: 0000-0002-9845-2456
    affiliation: 1
  - name: Yoann Blache
    orcid: 0000-0001-5960-8916
    affiliation: 1
affiliations: 
  - name: Univ. Lyon, UCBL-Lyon 1, Laboratoire Interuniversitaire de Biologie de la Motricité, EA 7424, F 69622, Villeurbanne, France 
    index: 1
date: 06 November 2020
bibliography: paper.bib
---
# Summary
Statistical Parametric Mapping (SPM) is a statistical method originally used in neuroimaging developed in the early 90's in biomedical imaging, allowing to determine which brain zones were solicited during a functional MRI [@Friston:1995]. Originally developed for a three dimensional analysis, the application of this method to the analysis of vectors or matrices was made possible thanks to @Pataky:2010 whom allows to perform statistical inference on curves (vectors - 1D) or maps (matrices - 2D).

As in "classical" statistics on scalar values (0D), there is a parametric and a non-parametric approach to the SPM method. While the parametric method is based on random gaussian fields, the non-parametric method is based on label permutation tests [@Nichols:2002], and thus, on re-sampling and randomness to make statistical inference. The main advantage of the non-parametric approach is that a gaussian distribution of the data is not required, making possible it to work with both curves and maps.

# Statement of need
Most of physiological data measured during human movement are continuous and expressed in function of time. However, researchers predominantly analyze extracted scalar values from the continuous measurement, as the mean, the maximum, the amplitude, or the integrated value over the time. Analyzing continuous values (i.e., time series) can provide more information than extracted indicators, as the later discards one dimension of the data among the magnitude and localization in time. In addition, oscillatory signals such as muscle vibrations and electromyograms contain information in the temporal and frequency domains. However, scalar analysis reduces the information at only one dimension by discarding two dimensions among the magnitude and the localization in the time and/or frequency domain.

To analyze all the dimensions of a signal without losing information, the analysis of curves or maps was proposed, coded, and put online by Pataky. However, the use of the proposed functions does not allow the analysis of 2D data automatically. Moreover, a rather frequent error is to consider only the significance of the last statistical test performed and not the intersection between the post-hoc tests and the ANOVA. Indeed, a difference between two samples can be significant if, and only if the ANOVA is significant in the same areas. This package, redistributed with fctSPM at `./fctSPM/src/spm1d_Pataky` is [published elsewhere](https://github.com/0todd0000/spm1dmatlab), and thus is not part of this JOSS review.

# fctSPM
The function we propose meets two objectives. 1/ to allow statistical inferences on curves and maps with a standardized format and 2/ to simplify analyses by comparing means while considering intersections with tests performed upstream (ANOVA and post-hoc of main effects).

The statistical tests are performed taking into account the independent and repeated measure effects provided in the obligatory function inputs. ANOVA, up to three-way ANOVA with three repeated measures, is performed if required, and followed by post-hoc tests as paired or independent Student t-tests. By default, the ANOVA is performed with an alpha risk of 5%, while post-hoc tests alpha risk is adjusted with Bonferronni correction. A number of 10/alpha iterations (200 for a 5% risk) is defined for each test. Statistical parameters are customizable via optional inputs, like `multiIT` which can be used to increase the number of iterations and achieve numerical stability and reliable analysis [@Nichols:2002]. A Matlab (.mat) file containing the number of permutations, the significant clusters, the statistical thresholds, and the raw data used in the analysis is also generated for each test family.

To interpret the results, figures directly usable for presentations and/or articles are available. In one dimension, the main figure contains the mean and standard deviations for each group of the analyzed condition, and the results of the post-hoc tests corrected with the result of the ANOVA. In two dimensions, the mean maps and the standard deviations are on two separate figures, and the result of the statistical analysis is displayed on the map of differences between two modalities. Therewith, other figures that display absolute and relative differences, effect sizes, and the raw value of the statistical test and its threshold are available.

To personalize the figures, Matlab (.fig) files are implemented to perform a posteriori modifications, and optional inputs are available to a priori customize the figures. These parameters are gathered in three categories: 1/ general plot parameters working identically for one and two dimensions, acting on axis labels and limits, image resolution and size 2/ one dimension parameters that act on the characteristics of the curves like color and transparency, or the position of the statistical analysis relatively to curves 3/ two dimensions parameters acting on the colormap and its limits, as well as the color of the statistical test displayed on map of differences. 

This function was already used in @Trama:2020 to compare soft-tissue and muscle vibrations of the *vastus lateralis*. It is currently used to assess modifications of soft-tissue vibrations caused by mountain ultra-marathons, the effect of the pedaling phase on *quadriceps* soft-tissue vibrations, and differences in isokinetic torque after ACL operation and rehabilitation.

# References
