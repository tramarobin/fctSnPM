function [nWarning,permutations,alphaCorrected]=fctWarningPermutations(ANOVA,alphaOriginal,multiPerm,maximalPerm,Perm)
alphaCorrected=alphaOriginal;

if alphaOriginal<0.05
    warning('Post-hoc tests are only approximate with Bonferonni correction');
end

if isempty(Perm)
    permutations=multiPerm/alphaOriginal;
else
    permutations=Perm;
end
maxPermutations=ANOVA.nPermUnique;
maxPermutations=min([maximalPerm,maxPermutations]);
requiredIterations=1/alphaOriginal;
if requiredIterations<10
    requiredIterations=10;
end
nWarning=0;

if permutations>=maximalPerm && maxPermutations>=maximalPerm
    permutations=-1;  % allow the maximal number of permutations without replacement.
end


if requiredIterations>permutations
    permutations=requiredIterations;
    warning(['The number of permutations was set to the minimal value of ' num2str(requiredIterations)])
elseif permutations>maximalPerm
    warning(['The number of permutations was set to the defined value of ' num2str(maximalPerm)]);
end


if permutations>maxPermutations && maxPermutations<requiredIterations
    warning(['The number of maximal possible permutations with the dataset is ' ...
        num2str(maxPermutations) ...
        ', but the number of permutations minimally required is ' ...
        num2str(1/alphaOriginal) ...
        '. The number of permutations was set to ' ...
        num2str(maxPermutations) ...
        ' and the new p-value is ' ...
        num2str(1/maxPermutations) ...
        '. Please consider increasing the number of subjects to get a valid analysis for a p-value of ' ...
        num2str(alphaOriginal)])

    permutations=-1;  % allow the maximal number of permutations without replacement.
    nWarning=2;
    alphaOriginal=1/maxPermutations;
    alphaCorrected=1/maxPermutations;

elseif permutations>maxPermutations && maxPermutations>=requiredIterations

    warning(['The number of maximal possible permutations with the dataset is ' ...
        num2str(maxPermutations) ...
        '. The number of permutations was set to ' ...
        num2str(maxPermutations) ...
        '. Please consider increasing the number of subjects if you want to perform ' ...
        num2str(permutations) ' permutations'])

    permutations=-1;  % allow the maximal number of permutations without replacement.
    nWarning=1;
    alphaCorrected=alphaOriginal;

elseif permutations<requiredIterations && requiredIterations<=maxPermutations

    permutations=requiredIterations;
    warning(['The number of permutations was set to ' ...
        num2str(requiredIterations) ...
        ' to obtain a p-value of ' num2str(alphaOriginal)])

    nWarning=1;

end

permutations=round(permutations);
end