function [anovaEffects,anova]=fctAnovaS(maps1d,dimensions,indicesEffects,sujets,nEffects,nRm,eNames,alphaOriginal,multiIterations,IT,maximalIT,ignoreAnova)
%% SETUP
if ~ignoreAnova
    
    % Choose the type of ANOVA and name the different effects
    [ANOVA,anova]=chooseAnova(maps1d,sujets,nEffects,nRm,indicesEffects,eNames);
    
    if isempty(ANOVA) % no ANOVA
        anovaEffects{1}=logical(ones(dimensions(1),dimensions(2)));
    else
        
        % Verify the number of iterations
        [nWarning,iterations,alpha]=fctWarningIterationsAOV(ANOVA,alphaOriginal,multiIterations,maximalIT,IT);
        anova.alpha=alphaOriginal;
        anova.pCritical=alpha;
        anova.nIterations=iterations;
        
        % Statistical Inference
        ANOVA_inf=ANOVA.inference(alpha,'iterations',iterations,'force_iterations',logical(1));
        
        %% Plot of effects
        
        if nEffects==1 % ANOVA1
            
            % Values given by the inference
            anova.maxIterations=ANOVA_inf.nPermUnique;
            anova.Fcontinuum=reshape(ANOVA_inf.z,dimensions(1),dimensions(2));
            anova.Fthreshold=ANOVA_inf.zstar;
            anova.Fsignificant=reshape(ANOVA_inf.z>=anova.Fthreshold,dimensions(1),dimensions(2));
            clustersAnova=extractClusterData(ANOVA_inf.clusters);
            if min(dimensions)==1
                for c=1:numel(clustersAnova)
                    anova.clusterLocation{c}=clustersAnova{c}.endpoints;
                    anova.clusterP(c)=clustersAnova{c}.P;
                end
            end
            
            anovaEffects{1}(1,:)=anova.Fsignificant(:); % values saved for the interpretation of post-hoc tests
            
        else % ANOVA2 & % ANOVA3
            
            anova.maxIterations=ANOVA_inf.nPermUnique;
            for k=1:size(ANOVA_inf.SPMs,2) % for each effect or interactions
                
                % Values given by the inference
                anova.Fcontinuum{k}=reshape(ANOVA_inf.SPMs{k}.z,dimensions(1),dimensions(2));
                anova.Fthreshold{k}=ANOVA_inf.SPMs{k}.zstar;
                anova.Fsignificant{k}=reshape(ANOVA_inf.SPMs{k}.z>=anova.Fthreshold{k},dimensions(1),dimensions(2));
                clustersAnova=extractClusterData(ANOVA_inf.SPMs{k}.clusters);
                if min(dimensions)==1
                    for c=1:numel(clustersAnova)
                        anova.clusterLocation{k}{c}=clustersAnova{c}.endpoints;
                        anova.clusterP{k}(c)=clustersAnova{c}.P;
                    end
                end
                
                
                
                anovaEffects{k}(1,:)=anova.Fsignificant{k}(:); % values saved for the interpretation of post-hoc tests
                
            end
            
        end
    end
    
    
else
    
    disp('No ANOVA performed');
    
    if nEffects==1
        anovaEffects{1}=logical(ones(dimensions(1),dimensions(2)));
    elseif nEffects==2
        for i=1:3
            anovaEffects{i}=logical(ones(dimensions(1),dimensions(2)));
        end
    elseif nEffects==3
        for i=1:7
            anovaEffects{i}=logical(ones(dimensions(1),dimensions(2)));
        end
    end
    
end

end
