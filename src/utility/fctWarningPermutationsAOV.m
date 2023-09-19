function [nWarning,permutations,alphaCorrected]=fctWarningPermutationsAOV(ANOVA,alphaOriginal,multiPerm,maximalPerm,Perm)
alphaCorrected=alphaOriginal;


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
    permutations=maximalPerm;
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
    
    permutations=maxPermutations;
    nWarning=2;
    alphaOriginal=1/permutations;
    alphaCorrected=1/permutations;
    
elseif permutations>maxPermutations && maxPermutations>=requiredIterations
    
    warning(['The number of maximal possible permutations with the dataset is ' ...
        num2str(maxPermutations) ...
        '. The number of permutations was set to ' ...
        num2str(maxPermutations) ...
        '. Please consider increasing the number of subjects if you want to perform ' ...
        num2str(permutations) ' permutations'])
    
    permutations=maxPermutations;
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

if permutations==ANOVA.nPermUnique
    permutations=-1;
end

end