function [nWarning,iterations,alphaCorrected]=fctWarningIterationsAOV(ANOVA,alphaOriginal,multiIterations,maximalIT,IT)
alphaCorrected=alphaOriginal;


if isempty(IT)
iterations=multiIterations/alphaOriginal;
else
iterations=IT;
end
maxIterations=ANOVA.nPermUnique;
maxIterations=min([maximalIT,maxIterations]);
requiredIterations=1/alphaOriginal;
nWarning=0;

if iterations>=maximalIT && maxIterations>=maximalIT
    iterations=maximalIT;
end


if requiredIterations>iterations
    iterations=requiredIterations;
    warning(['The number of iterations was set to the minimal value of ' num2str(requiredIterations)])
elseif iterations>maximalIT
    warning(['The number of iterations was set to the defined value of ' num2str(maximalIT)]);
end


if iterations>maxIterations && maxIterations<requiredIterations
    warning(['The number of maximal possible iterations with the dataset is ' ...
        num2str(maxIterations) ...
        ', but the number of iterations minimally required is ' ...
        num2str(1/alphaOriginal) ...
        '. The number of iterations was set to ' ...
        num2str(maxIterations) ...
        ' and the new p-value is ' ...
        num2str(1/maxIterations) ...
        '. Please consider increasing the number of subjects to get a valid analysis for a p-value of ' ...
        num2str(alphaOriginal)])
    
    iterations=maxIterations;
    nWarning=2;
    alphaOriginal=1/iterations;
    alphaCorrected=1/iterations;
    
elseif iterations>maxIterations && maxIterations>=requiredIterations
    
    warning(['The number of maximal possible iterations with the dataset is ' ...
        num2str(maxIterations) ...
        '. The number of iterations was set to ' ...
        num2str(maxIterations) ...
        '. Please consider increasing the number of subjects if you want to perform ' ...
        num2str(iterations) ' iterations'])
    
    iterations=maxIterations;
    nWarning=1;
    alphaCorrected=alphaOriginal;
    
elseif iterations<requiredIterations && requiredIterations<=maxIterations
    
    iterations=requiredIterations;
    warning(['The number of iterations was set to ' ...
        num2str(requiredIterations) ...
        ' to obtain a p-value of ' num2str(alphaOriginal)])
    
    nWarning=1;
    
end

iterations=round(iterations);
end