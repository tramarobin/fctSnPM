function [anovaEffects]=fctAnova(maps1d,dimensions,indicesEffects,sujets,nEffects,nRm,eNames,alphaOriginal,savedir,multiIterations,IT,xlab,ylab,Fs,ylimits,nx,ny,imageResolution,xlimits,maximalIT,ignoreAnova,displayContour,contourColor,dashedColor,transparency,lineWidth,linestyle,colorMap,imageSize,imageFontSize)
%% SETUP
close all

if ~ignoreAnova
       
    % Choose the type of ANOVA and name the different effects
    [ANOVA,namesEffect,testANOVA]=chooseAnova(maps1d,sujets,nEffects,nRm,indicesEffects,eNames);
    
    if isempty(ANOVA) % no ANOVA
        anovaEffects{1}=logical(ones(dimensions(1),dimensions(2)));
    else
        
        warning('off', 'MATLAB:MKDIR:DirectoryExists');
        mkdir([savedir '/' testANOVA.name '/FIG/'])
        
        % Verify the number of iterations
        [nWarning,iterations,alpha]=fctWarningIterationsAOV(ANOVA,alphaOriginal,multiIterations,maximalIT,IT);
        testANOVA.alpha=alpha;
        testANOVA.alphaOriginal=alphaOriginal;
        testANOVA.nIterations=iterations;
        
        % Statistical Inference
        ANOVA_inf=ANOVA.inference(alpha,'iterations',iterations,'force_iterations',logical(1));
        
        %% Plot of effects
        
        if nEffects==1 % ANOVA1
            
            % Values given by the inference
            Fthreshold=ANOVA_inf.zstar;
            mapsF=reshape(ANOVA_inf.z,dimensions(1),dimensions(2));
            pAnova=ANOVA_inf.p;
            clustersAnova=extractClusterData(ANOVA_inf.clusters);
            anovaEffects{1}=ANOVA_inf.z>=Fthreshold; %values save for the interpretation of post-hoc tests
            
            % Plot of Anova Results
            displayAnova(mapsF,Fthreshold,anovaEffects{1},Fs,xlab,ylab,ylimits,dimensions,nx,ny,xlimits,colorMap,imageSize,imageFontSize)
            if displayContour & size(mapsF,2)>1
                dispContour(mapsF,Fthreshold,contourColor,dashedColor,transparency,lineWidth,linestyle)
            end
            title(namesEffect)
            print('-dtiff',imageResolution,[savedir '/' testANOVA.name '/' verifSaveName(namesEffect)])
            savefig([savedir '/' testANOVA.name '/FIG/' verifSaveName(namesEffect)])
            close
            save([savedir '/' testANOVA.name '/ANOVA'], 'mapsF' , 'Fthreshold', 'namesEffect','testANOVA','pAnova','clustersAnova','anovaEffects')
            
            
            
        else % ANOVA2 & % ANOVA3
            
            for k=1:size(ANOVA_inf.SPMs,2) % for each effect or interactions
                
                % Values given by the inference
                Fthreshold{k}=ANOVA_inf.SPMs{k}.zstar;
                mapsF{k}=reshape(ANOVA_inf.SPMs{k}.z,dimensions(1),dimensions(2));
                anovaEffects{k}=ANOVA_inf.SPMs{k}.z>=Fthreshold{k};
                pAnova{k}=ANOVA_inf.SPMs{k}.p;
                clustersAnova{k}=extractClusterData(ANOVA_inf.SPMs{k}.clusters);
                
                % Plot of the full anova results
                displayAnova(mapsF{k},Fthreshold{k},anovaEffects{k},Fs,xlab,ylab,ylimits,dimensions,nx,ny,xlimits,colorMap,imageSize,imageFontSize)
                if displayContour & size(mapsF{k},2)>1
                    dispContour(mapsF{k},Fthreshold{k},contourColor,dashedColor,transparency,lineWidth,linestyle)
                end
                title(namesEffect{k})
                print('-dtiff',imageResolution,[savedir '/' testANOVA.name '/' verifSaveName(namesEffect{k})])
                savefig([savedir '/' testANOVA.name '/FIG/' verifSaveName(namesEffect{k})])
                close
                
            end
            
            save([savedir '/' testANOVA.name '/ANOVA'], 'mapsF' , 'Fthreshold', 'namesEffect','testANOVA','pAnova','clustersAnova','anovaEffects')
            
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
