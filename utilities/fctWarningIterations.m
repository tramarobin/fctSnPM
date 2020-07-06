function [nWarning,iterations,alphaOriginal,alphaCorrected]=fctWarningIterations(ANOVA,alpha,multiIterations,maximalIT,IT)
alphaOriginal=alpha;
alphaCorrected=alpha;

if alpha<0.05
    warning('Post-hoc tests are only approximate with Bonferonni correction');
end

if isempty(IT)
iterations=multiIterations/alpha;
else
iterations=IT;
end
maxIterations=ANOVA.nPermUnique;
maxIterations=min([maximalIT,maxIterations]);
requiredIterations=1/alpha;
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
        num2str(1/alpha) ...
        '. The number of iterations was set to ' ...
        num2str(maxIterations) ...
        ' and the new p-value is ' ...
        num2str(1/maxIterations) ...
        '. Please consider increasing the number of subjects to get a valid analysis for a p-value of ' ...
        num2str(alpha)])
    
    iterations=maxIterations;
    nWarning=2;
    alpha=1/iterations;
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
    alphaCorrected=alpha;
    
elseif iterations<requiredIterations && requiredIterations<=maxIterations
    
    iterations=requiredIterations;
    warning(['The number of iterations was set to ' ...
        num2str(requiredIterations) ...
        ' to obtain a p-value of ' num2str(alpha)])
    
    nWarning=1;
    
end

iterations=round(iterations);
end