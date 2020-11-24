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
Statistical Parametric Mapping (SPM) is a statistical method originally used in neuroimaging developed in the early 90's in biomedical imaging, allowing to determine which brain zones were solicited during a functional MRI [@Friston:1995]. Originally developed for a three dimensional analysis, the portability of this method to the analysis of vectors or matrices was made possible thanks to @Pataky:2010 whom allows to perform statistical inference on curves (vectors - 1D) or maps (matrices - 2D).

As in "classical" statistics on scalar values (0D), there is a parametric and a non-parametric approach to the SPM method. While the parametric method is based on random gaussian fields, the non-parametric method is based on label permutation tests [@Nichols:2002], and thus, on re-sampling and randomness to make statistical inference. The main advantage of the non-parametric approach is that a gaussian distribution of the data is not required, making possible it to work with both curves and maps.

# Statement of need
This approach was proposed, coded, and put online by Pataky (https://github.com/0todd0000/spm1dmatlab). However, the use of the proposed functions does not allow the analysis of 2D data automatically. Moreover, a rather frequent error is to consider only the significance of the last statistical test performed, and not the intersection between the post-hoc tests and the ANOVA. Indeed, a difference between two samples can be significant if, and only if the ANOVA is significant in the same areas.

# fctSPM
The function we propose meets two objectives. 1) to allow statistical inferences on curves and maps with a standardized format and 2) to simplify analyses by comparing means while considering intersections with tests performed upstream (ANOVA and post-hoc of main effects).
To interpret the results, figures directly usable for presentations and/or articles are created and highly customizable according to the input parameters. Numerous figures are also created in addition, including absolute and relative differences, effect sizes with confidence intervals, and the raw value of the statistical test and its threshold.
A Matlab (.mat) file is also generated for each test family to find the number of permutations, the significant areas, the statistical thresholds, and the data used to recreate the figures. Many parameters also exist in the function to customize the figures.

This function was already used in @Trama:2020 to compare soft-tissue and muscle vibrations of the *vastus lateralis*. It is currently used to assess alterations of soft-tissue vibrations caused by mountain ultra-marathons, the effect of the pedalling phase on *quadriceps* soft-tissue vibrations, and alterations of isokinetic torque after ACL operation and rehabilitation.

# References
