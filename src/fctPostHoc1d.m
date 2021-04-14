function []=fctPostHoc1d(nEffects,indicesEffects,maps1d,dimensions,modalitiesAll,typeEffectsAll,eNames,savedir,multiIterations,IT,xlab,ylab,Fs,imageResolution,IC,ylimits,nx,ny,xlimits,anovaEffects,maximalIT,colorLine,doAllInteractions,imageFontSize,imageSize,alphaT,nT,transparancy1D,ratioSPM,yLimitES,spmPos,aovColor)
close all
set(0, 'DefaultFigureVisible', 'off');
savedir=[savedir '/Post hoc/'];

%% T-TEST 1 EFFECT = MAIN EFFECT
if nEffects==1
    
    if max(anovaEffects{1})==1 | doAllInteractions==1
        
        createSavedir(savedir)
        
        loop=0;
        for i=1:max(indicesEffects)
            loop=loop+1;
            combi{loop}=i;
        end
        nCombi=size(combi,2);
        
        legendPlot=[];
        for i=1:nCombi
            
            meansData{i}=maps1d(indicesEffects==combi{i}(1),:);
            legendPlot=[legendPlot,{char(modalitiesAll{1}(combi{i}(1)))}];
            posthoc.data.names{i}=[char(modalitiesAll{1}(combi{i}(1)))];
            
        end
        
        % full plot of means
        colorPlot=chooseColor(colorLine,1);
        plotmean(meansData,IC,xlab,ylab,Fs,xlimits,nx,ny,colorPlot,imageFontSize,imageSize,transparancy1D,ylimits)
        legend(legendPlot,'Location','eastoutside','box','off')
        print('-dtiff',imageResolution,[savedir verifSaveName(eNames{1})])
        savefig([savedir '/FIG/' verifSaveName(eNames{1})])
        close
        
        posthoc.data.continuum=meansData;
        clear meansData
        
        loop=0;
        for i=1:nCombi
            for j=1:nCombi
                if i<j
                    loop=loop+1;
                    Comp{loop}=[i j];
                end
            end
        end
        
        nComp=size(Comp,2);
        if ~isempty(nT)
            alphaOriginal=0.05/nT;
        else
            alphaOriginal=alphaT/nComp;
        end
        
        for comp=1:nComp
            
            for i=1:2
                % comparison + name
                DATA{i}=maps1d(indicesEffects==combi{Comp{comp}(i)}(1),:);
                posthoc.differences.names{i,comp}=[char(modalitiesAll{1}(combi{Comp{comp}(i)}(1)))];
            end
            
            % t-test
            if typeEffectsAll>0
                differencesData{1}=DATA{1}-DATA{2};
                relativeDifferencesData{1}=100*(DATA{1}-DATA{2})./DATA{2};
                
                posthoc.differences.continuum{1,comp}=differencesData{1};
                posthoc.differences.continuumRelative{1,comp}=relativeDifferencesData{1};
                
                Ttest=spm1d.stats.nonparam.ttest_paired(DATA{1},DATA{2});
                posthoc.tTests.type{comp}='paired';
                [posthoc.differences.ES{comp},posthoc.differences.ESsd{comp}]=esCalculation(DATA);
                
            else
                
                % differences
                differencesData{1}=mean(DATA{1})-mean(DATA{2});
                relativeDifferencesData{1}=100*(mean(DATA{1})-mean(DATA{2}))./mean(DATA{2});
                
                posthoc.differences.continuum{1,comp}=differencesData{1};
                posthoc.differences.continuumRelative{1,comp}=relativeDifferencesData{1};
                
                Ttest=spm1d.stats.nonparam.ttest2(DATA{1},DATA{2});
                posthoc.tTests.type{comp}='independant';
                [posthoc.differences.ES{comp},posthoc.differences.ESsd{comp}]=esCalculation(DATA);
            end
            
            
            % inference
            posthoc.tTests.names=posthoc.differences.names;
            [posthoc.tTests.nWarning{comp},iterations,alpha]=fctWarningIterations(Ttest,alphaOriginal,multiIterations,maximalIT,IT);
            posthoc.tTests.alphaOriginal{comp}=alphaOriginal;
            posthoc.tTests.alpha{comp}=alpha;
            posthoc.tTests.nIterations{comp}=iterations;
            Ttest_inf=Ttest.inference(alpha,'iterations',iterations,'force_iterations',logical(1),'two_tailed',logical(1));
            posthoc.tTests.maxIterations{comp}=Ttest_inf.nPermUnique;
            posthoc.tTests.Tthreshold{comp}=Ttest_inf.zstar;
            posthoc.tTests.Tsignificant{1,comp}=zeros(dimensions(1),dimensions(2));
            posthoc.tTests.Tcontinuum{1,comp}=reshape(Ttest_inf.z,dimensions(1),dimensions(2));
            mapLogical=abs(posthoc.tTests.Tcontinuum{1,comp})>=posthoc.tTests.Tthreshold{comp};
            posthoc.tTests.Tsignificant{1,comp}(anovaEffects{1})=mapLogical(anovaEffects{1});
            clustersT=extractClusterData(Ttest_inf.clusters);
            for c=1:numel(clustersT)
                posthoc.tTests.clusterLocation{comp}{c}=clustersT{c}.endpoints;
                posthoc.tTests.clusterP{comp}(c)=clustersT{c}.P;
            end
            
            plotmean(differencesData,IC,xlab,ylab,Fs,xlimits,nx,[],[],imageFontSize,imageSize,transparancy1D,[])
            legend([posthoc.differences.names{1,comp} ' - ' posthoc.differences.names{2,comp}],'Location','eastoutside','box','off')
            print('-dtiff',imageResolution,[savedir 'DIFF/' verifSaveName([eNames{1} ' (' char(posthoc.differences.names{1,comp}) ' - ' char(posthoc.differences.names{2,comp}) ')'])])
            savefig([savedir '/FIG/DIFF/' verifSaveName([eNames{1} ' (' char(posthoc.differences.names{1,comp}) ' - ' char(posthoc.differences.names{2,comp}) ')'])])
            close
            
            plotmean(relativeDifferencesData,IC,xlab,'Differences (%)',Fs,xlimits,nx,[],[],imageFontSize,imageSize,transparancy1D,[])
            legend([posthoc.differences.names{1,comp} ' - ' posthoc.differences.names{2,comp}],'Location','eastoutside','box','off')
            print('-dtiff',imageResolution,[savedir 'DIFF/' verifSaveName([eNames{1} ' (' char(posthoc.differences.names{1,comp}) ' - ' char(posthoc.differences.names{2,comp}) ') %'])])
            savefig([savedir '/FIG/DIFF/' verifSaveName([eNames{1} ' (' char(posthoc.differences.names{1,comp}) ' - ' char(posthoc.differences.names{2,comp}) ') %'])])
            close
            
            % plot of spm analysis
            displayTtest(posthoc.tTests.Tcontinuum{1,comp},posthoc.tTests.Tthreshold{comp},posthoc.tTests.Tsignificant{1,comp},Fs,xlab,ylab,ylimits,dimensions,nx,ny,xlimits,imageFontSize,imageSize,transparancy1D)
            title([char(posthoc.differences.names{1,comp}) ' - ' char(posthoc.differences.names{2,comp})])
            print('-dtiff',imageResolution,[savedir 'SPM/' verifSaveName([eNames{1} ' (' char(posthoc.differences.names{1,comp}) ' - ' char(posthoc.differences.names{2,comp}) ')'])])
            savefig([savedir '/FIG/SPM/' verifSaveName([eNames{1} ' (' char(posthoc.differences.names{1,comp}) ' - ' char(posthoc.differences.names{2,comp}) ')'])])
            close
            
            %   ES
            plotES(posthoc.differences.ES{comp},posthoc.differences.ESsd{comp},posthoc.tTests.Tsignificant{1,comp},Fs,xlab,nx,xlimits,imageFontSize,imageSize,transparancy1D,yLimitES)
            title([char(posthoc.differences.names{1,comp}) ' - ' char(posthoc.differences.names{2,comp})])
            print('-dtiff',imageResolution,[savedir 'ES/' verifSaveName([eNames{1} ' (' char(posthoc.differences.names{1,comp}) ' - ' char(posthoc.differences.names{2,comp}) ')'])])
            savefig([savedir '/FIG/ES/' verifSaveName([eNames{1} ' (' char(posthoc.differences.names{1,comp}) ' - ' char(posthoc.differences.names{2,comp}) ')'])])
            close
            
        end
        
        % full plot of means + SPM
        if max(indicesEffects)>2 % no anova required
            plotmeanSPM(posthoc.data.continuum,posthoc.tTests.Tcontinuum,posthoc.tTests.Tsignificant,legendPlot,posthoc.differences.names,IC,xlab,ylab,Fs,xlimits,nx,ny,colorPlot,imageFontSize,imageSize,transparancy1D,ylimits,anovaEffects,eNames,ratioSPM,spmPos,aovColor)
            print('-dtiff',imageResolution,[savedir verifSaveName(eNames{1}) ' + SPM'])
            savefig([savedir '/FIG/' verifSaveName(eNames{1}) ' + SPM'])
            close
        end
        
        plotmeanSPM(posthoc.data.continuum,posthoc.tTests.Tcontinuum,posthoc.tTests.Tsignificant,legendPlot,posthoc.differences.names,IC,xlab,ylab,Fs,xlimits,nx,ny,colorPlot,imageFontSize,imageSize,transparancy1D,ylimits,[],[],ratioSPM,spmPos,aovColor)
        print('-dtiff',imageResolution,[savedir verifSaveName(eNames{1}) ' + SPMnoAOV'])
        savefig([savedir '/FIG/' verifSaveName(eNames{1}) ' + SPMnoAOV'])
        close
        
        if max(indicesEffects)>2 % no anova required
            plotmeanSPMsub(posthoc.data.continuum,posthoc.tTests.Tcontinuum,posthoc.tTests.Tsignificant,legendPlot,posthoc.differences.names,IC,xlab,ylab,Fs,xlimits,nx,ny,colorPlot,imageFontSize,imageSize,transparancy1D,ylimits,anovaEffects,eNames,ratioSPM,spmPos,aovColor)
            print('-dtiff',imageResolution,[savedir verifSaveName(eNames{1}) ' + SPMsub'])
            savefig([savedir '/FIG/' verifSaveName(eNames{1}) ' + SPMsub'])
            close
        end
        
        plotmeanSPMsub(posthoc.data.continuum,posthoc.tTests.Tcontinuum,posthoc.tTests.Tsignificant,legendPlot,posthoc.differences.names,IC,xlab,ylab,Fs,xlimits,nx,ny,colorPlot,imageFontSize,imageSize,transparancy1D,ylimits,[],[],ratioSPM,spmPos,aovColor)
        print('-dtiff',imageResolution,[savedir verifSaveName(eNames{1}) ' + SPMsubNoAOV'])
        savefig([savedir '/FIG/' verifSaveName(eNames{1}) ' + SPMsubNoAOV'])
        close
        
        save([savedir 'posthoc'], 'posthoc')
        clear posthoc comp combi
        
    end
end


%% T-TESTS 2 EFFECTS - 1 FIXED = MAIN EFFECTS
if nEffects==2
    
    eff=[1;2];
    
    for effectFixed=1:size(eff,1)
        fixedEffect=eff(effectFixed,:);
        mainEffect=1:size(eff,1);
        mainEffect(fixedEffect)=[];
        
        if max(anovaEffects{mainEffect})==1 | doAllInteractions==1
            
            createSavedir([savedir verifSaveName(eNames{mainEffect(1)})])
            
            loop=0;
            for i=1:max(indicesEffects(:,mainEffect(1)))
                loop=loop+1;
                combi{loop}=i;
            end
            nCombi=size(combi,2);
            
            legendPlot=[];
            for i=1:nCombi
                meansData{i}=maps1d(indicesEffects(:,mainEffect(1))==combi{i}(1),:);
                legendPlot=[legendPlot,{char(modalitiesAll{mainEffect(1)}(combi{i}(1)))}];
                posthoc.data.names{i}=[char(modalitiesAll{mainEffect(1)}(combi{i}(1)))];
            end
            
            % full plot of means
            colorPlot=chooseColor(colorLine,mainEffect(1));
            plotmean(meansData,IC,xlab,ylab,Fs,xlimits,nx,ny,colorPlot,imageFontSize,imageSize,transparancy1D,ylimits)
            legend(legendPlot,'Location','eastoutside','box','off')
            print('-dtiff',imageResolution,[savedir verifSaveName(eNames{mainEffect(1)}) '/' verifSaveName(eNames{mainEffect(1)})])
            savefig([savedir verifSaveName(eNames{mainEffect(1)}) '/FIG/' verifSaveName(eNames{mainEffect(1)})])
            close
            
            posthoc.data.continuum=meansData;
            clear meansData
            
            loop=0;
            for i=1:nCombi
                for j=1:nCombi
                    if i<j
                        loop=loop+1;
                        Comp{loop}=[i j];
                    end
                end
            end
            
            nComp=size(Comp,2);
            if ~isempty(nT)
                alphaOriginal=0.05/nT;
            else
                alphaOriginal=alphaT/nComp;
            end
            
            for comp=1:nComp
                
                for i=1:2
                    % comparison + name
                    DATA{i}=maps1d(indicesEffects(:,mainEffect(1))==combi{Comp{comp}(i)}(1),:);
                    posthoc.differences.names{i,comp}=[char(modalitiesAll{mainEffect(1)}(combi{Comp{comp}(i)}(1)))];
                end
                
                % t-test
                if typeEffectsAll(mainEffect)==1
                    differencesData{1}=DATA{1}-DATA{2};
                    relativeDifferencesData{1}=100*(DATA{1}-DATA{2})./DATA{2};
                    
                    posthoc.differences.continuum{1,comp}=differencesData{1};
                    posthoc.differences.continuumRelative{1,comp}=relativeDifferencesData{1};
                    
                    Ttest=spm1d.stats.nonparam.ttest_paired(DATA{1},DATA{2});
                    posthoc.tTests.type{comp}='paired';
                    [posthoc.differences.ES{comp},posthoc.differences.ESsd{comp}]=esCalculation(DATA);
                    
                else
                    
                    % differences
                    differencesData{1}=mean(DATA{1})-mean(DATA{2});
                    relativeDifferencesData{1}=100*(mean(DATA{1})-mean(DATA{2}))./mean(DATA{2});
                    
                    posthoc.differences.continuum{1,comp}=differencesData{1};
                    posthoc.differences.continuumRelative{1,comp}=relativeDifferencesData{1};
                    
                    Ttest=spm1d.stats.nonparam.ttest2(DATA{1},DATA{2});
                    posthoc.tTests.type{comp}='independant';
                    [posthoc.differences.ES{comp},posthoc.differences.ESsd{comp}]=esCalculation(DATA);
                end
                
                plotmean(differencesData,IC,xlab,ylab,Fs,xlimits,nx,[],[],imageFontSize,imageSize,transparancy1D,[])
                legend([posthoc.differences.names{1,comp} ' - ' posthoc.differences.names{2,comp}],'Location','eastoutside','box','off')
                print('-dtiff',imageResolution,[savedir verifSaveName(eNames{mainEffect(1)}) '/DIFF/'  verifSaveName([char(posthoc.differences.names{1,comp}) ' - ' char(posthoc.differences.names{2,comp})])])
                savefig([savedir verifSaveName(eNames{mainEffect(1)}) '/FIG/DIFF/'  verifSaveName([char(posthoc.differences.names{1,comp}) ' - ' char(posthoc.differences.names{2,comp})])])
                close
                
                plotmean(relativeDifferencesData,IC,xlab,'Differences (%)',Fs,xlimits,nx,[],[],imageFontSize,imageSize,transparancy1D,[])
                legend([posthoc.differences.names{1,comp} ' - ' posthoc.differences.names{2,comp}],'Location','eastoutside','box','off')
                savefig([savedir verifSaveName(eNames{mainEffect(1)}) '/FIG/DIFF/'  verifSaveName([char(posthoc.differences.names{1,comp}) ' - ' char(posthoc.differences.names{2,comp})]) '%'])
                print('-dtiff',imageResolution,[savedir verifSaveName(eNames{mainEffect(1)}) '/DIFF/'  verifSaveName([char(posthoc.differences.names{1,comp}) ' - ' char(posthoc.differences.names{2,comp})]) ' %'])
                close
                
                % inference
                posthoc.tTests.names=posthoc.differences.names;
                [posthoc.tTests.nWarning{comp},iterations,alpha]=fctWarningIterations(Ttest,alphaOriginal,multiIterations,maximalIT,IT);
                posthoc.tTests.alphaOriginal{comp}=alphaOriginal;
                posthoc.tTests.alpha{comp}=alpha;
                posthoc.tTests.nIterations{comp}=iterations;
                Ttest_inf=Ttest.inference(alpha,'iterations',iterations,'force_iterations',logical(1),'two_tailed',logical(1));
                posthoc.tTests.maxIterations{comp}=Ttest_inf.nPermUnique;
                posthoc.tTests.Tthreshold{comp}=Ttest_inf.zstar;
                posthoc.tTests.Tsignificant{1,comp}=zeros(dimensions(1),dimensions(2));
                posthoc.tTests.Tcontinuum{1,comp}=reshape(Ttest_inf.z,dimensions(1),dimensions(2));
                mapLogical=abs(posthoc.tTests.Tcontinuum{1,comp})>=posthoc.tTests.Tthreshold{comp};
                posthoc.tTests.Tsignificant{1,comp}(anovaEffects{mainEffect})=mapLogical(anovaEffects{mainEffect});
                clustersT=extractClusterData(Ttest_inf.clusters);
                for c=1:numel(clustersT)
                    posthoc.tTests.clusterLocation{comp}{c}=clustersT{c}.endpoints;
                    posthoc.tTests.clusterP{comp}(c)=clustersT{c}.P;
                end
                % plot of spm analysis
                displayTtest(posthoc.tTests.Tcontinuum{1,comp},posthoc.tTests.Tthreshold{comp},posthoc.tTests.Tsignificant{1,comp},Fs,xlab,ylab,ylimits,dimensions,nx,ny,xlimits,imageFontSize,imageSize,transparancy1D)
                title([char(posthoc.differences.names{1,comp}) ' - ' char(posthoc.differences.names{2,comp})])
                savefig([savedir verifSaveName(eNames{mainEffect(1)}) '/FIG/SPM/'  verifSaveName([char(posthoc.differences.names{1,comp}) ' - ' char(posthoc.differences.names{2,comp})])])
                print('-dtiff',imageResolution,[savedir verifSaveName(eNames{mainEffect(1)}) '/SPM/'  verifSaveName([char(posthoc.differences.names{1,comp}) ' - ' char(posthoc.differences.names{2,comp})])])
                close
                
                %  ES
                plotES(posthoc.differences.ES{comp},posthoc.differences.ESsd{comp},posthoc.tTests.Tsignificant{1,comp},Fs,xlab,nx,xlimits,imageFontSize,imageSize,transparancy1D,yLimitES)
                title([char(posthoc.differences.names{1,comp}) ' - ' char(posthoc.differences.names{2,comp})])
                savefig([savedir verifSaveName(eNames{mainEffect(1)}) '/FIG/ES/'  verifSaveName([char(posthoc.differences.names{1,comp}) ' - ' char(posthoc.differences.names{2,comp})])])
                print('-dtiff',imageResolution,[savedir verifSaveName(eNames{mainEffect(1)}) '/ES/'  verifSaveName([char(posthoc.differences.names{1,comp}) ' - ' char(posthoc.differences.names{2,comp})])])
                close
                
            end
            
            % full plot of means + SPM
            plotmeanSPM(posthoc.data.continuum,posthoc.tTests.Tcontinuum,posthoc.tTests.Tsignificant,legendPlot,posthoc.differences.names,IC,xlab,ylab,Fs,xlimits,nx,ny,colorPlot,imageFontSize,imageSize,transparancy1D,ylimits,anovaEffects(mainEffect),eNames(mainEffect),ratioSPM,spmPos,aovColor)
            print('-dtiff',imageResolution,[savedir verifSaveName(eNames{mainEffect(1)}) '/' verifSaveName(eNames{mainEffect(1)}) ' + SPM'])
            savefig([savedir verifSaveName(eNames{mainEffect(1)}) '/FIG/' verifSaveName(eNames{mainEffect(1)}) ' + SPM'])
            close
            
            plotmeanSPM(posthoc.data.continuum,posthoc.tTests.Tcontinuum,posthoc.tTests.Tsignificant,legendPlot,posthoc.differences.names,IC,xlab,ylab,Fs,xlimits,nx,ny,colorPlot,imageFontSize,imageSize,transparancy1D,ylimits,[],[],ratioSPM,spmPos,aovColor)
            print('-dtiff',imageResolution,[savedir verifSaveName(eNames{mainEffect(1)}) '/' verifSaveName(eNames{mainEffect(1)}) ' + SPMnoAOV'])
            savefig([savedir verifSaveName(eNames{mainEffect(1)}) '/FIG/' verifSaveName(eNames{mainEffect(1)}) ' + SPMnoAOV'])
            close
            
            plotmeanSPMsub(posthoc.data.continuum,posthoc.tTests.Tcontinuum,posthoc.tTests.Tsignificant,legendPlot,posthoc.differences.names,IC,xlab,ylab,Fs,xlimits,nx,ny,colorPlot,imageFontSize,imageSize,transparancy1D,ylimits,anovaEffects(mainEffect),eNames(mainEffect),ratioSPM,spmPos,aovColor)
            print('-dtiff',imageResolution,[savedir verifSaveName(eNames{mainEffect(1)}) '/' verifSaveName(eNames{mainEffect(1)}) ' + SPMsub'])
            savefig([savedir verifSaveName(eNames{mainEffect(1)}) '/FIG/' verifSaveName(eNames{mainEffect(1)}) ' + SPMsub'])
            close
            
            plotmeanSPMsub(posthoc.data.continuum,posthoc.tTests.Tcontinuum,posthoc.tTests.Tsignificant,legendPlot,posthoc.differences.names,IC,xlab,ylab,Fs,xlimits,nx,ny,colorPlot,imageFontSize,imageSize,transparancy1D,ylimits,[],[],ratioSPM,spmPos,aovColor)
            print('-dtiff',imageResolution,[savedir verifSaveName(eNames{mainEffect(1)}) '/' verifSaveName(eNames{mainEffect(1)}) ' + SPMsubNoAOV'])
            savefig([savedir verifSaveName(eNames{mainEffect(1)}) '/FIG/' verifSaveName(eNames{mainEffect(1)}) ' + SPMsubNoAOV'])
            close
            
            mainForInteraction{mainEffect}=posthoc.tTests.Tsignificant;
            save([savedir '/' verifSaveName(eNames{mainEffect(1)}) '/posthoc'], 'posthoc')
            clear posthoc Comp combi legendPlot
            
        end
    end
end

%% T-TESTS 3 EFFECTS - 2 FIXED = MAIN EFFECTS

if nEffects==3
    
    eff=[1 2; 1 3; 2 3];
    
    for effectFixed=1:size(eff,1)
        fixedEffect=eff(effectFixed,:);
        mainEffect=1:size(eff,1);
        mainEffect(fixedEffect)=[];
        
        if max(anovaEffects{mainEffect})==1 | doAllInteractions==1
            
            createSavedir([savedir verifSaveName(eNames{mainEffect(1)})])
            
            loop=0;
            for i=1:max(indicesEffects(:,mainEffect(1)))
                loop=loop+1;
                combi{loop}=i;
            end
            nCombi=size(combi,2);
            
            legendPlot=[];
            for i=1:nCombi
                meansData{i}=maps1d(indicesEffects(:,mainEffect(1))==combi{i}(1),:);
                legendPlot=[legendPlot,{char(modalitiesAll{mainEffect(1)}(combi{i}(1)))}];
                posthoc.data.names{i}=[char(modalitiesAll{mainEffect(1)}(combi{i}(1)))];
            end
            
            % full plot of means
            colorPlot=chooseColor(colorLine,mainEffect(1));
            plotmean(meansData,IC,xlab,ylab,Fs,xlimits,nx,ny,colorPlot,imageFontSize,imageSize,transparancy1D,ylimits)
            legend(legendPlot,'Location','eastoutside','box','off')
            print('-dtiff',imageResolution,[savedir verifSaveName(eNames{mainEffect(1)}) '/' verifSaveName(eNames{mainEffect(1)})])
            savefig([savedir verifSaveName(eNames{mainEffect(1)}) '/FIG/' verifSaveName(eNames{mainEffect(1)})])
            close
            
            posthoc.data.continuum=meansData;
            clear meansData
            
            loop=0;
            for i=1:nCombi
                for j=1:nCombi
                    if i<j
                        loop=loop+1;
                        Comp{loop}=[i j];
                    end
                end
            end
            
            nComp=size(Comp,2);
            if ~isempty(nT)
                alphaOriginal=0.05/nT;
            else
                alphaOriginal=alphaT/nComp;
            end
            
            for comp=1:nComp
                
                for i=1:2
                    % comparison + name
                    DATA{i}=maps1d(indicesEffects(:,mainEffect(1))==combi{Comp{comp}(i)}(1),:);
                    posthoc.differences.names{i,comp}=[char(modalitiesAll{mainEffect(1)}(combi{Comp{comp}(i)}(1)))];
                end
                
                
                %t-test
                if typeEffectsAll(mainEffect)==1
                    differencesData{1}=DATA{1}-DATA{2};
                    relativeDifferencesData{1}=100*(DATA{1}-DATA{2})./DATA{2};
                    
                    posthoc.differences.continuum{1,comp}=differencesData{1};
                    posthoc.differences.continuumRelative{1,comp}=relativeDifferencesData{1};
                    
                    Ttest=spm1d.stats.nonparam.ttest_paired(DATA{1},DATA{2});
                    posthoc.tTests.type{comp}='paired';
                    [posthoc.differences.ES{comp},posthoc.differences.ESsd{comp}]=esCalculation(DATA);
                    
                else
                    
                    % differences
                    differencesData{1}=mean(DATA{1})-mean(DATA{2});
                    relativeDifferencesData{1}=100*(mean(DATA{1})-mean(DATA{2}))./mean(DATA{2});
                    
                    posthoc.differences.continuum{1,comp}=differencesData{1};
                    posthoc.differences.continuumRelative{1,comp}=relativeDifferencesData{1};
                    
                    Ttest=spm1d.stats.nonparam.ttest2(DATA{1},DATA{2});
                    posthoc.tTests.type{comp}='independant';
                    [posthoc.differences.ES{comp},posthoc.differences.ESsd{comp}]=esCalculation(DATA);
                end
                
                plotmean(differencesData,IC,xlab,ylab,Fs,xlimits,nx,[],[],imageFontSize,imageSize,transparancy1D,[])
                legend([posthoc.differences.names{1,comp} ' - ' posthoc.differences.names{2,comp}],'Location','eastoutside','box','off')
                savefig([savedir verifSaveName(eNames{mainEffect(1)}) '/FIG/DIFF/'  verifSaveName([char(posthoc.differences.names{1,comp}) ' - ' char(posthoc.differences.names{2,comp})])])
                print('-dtiff',imageResolution,[savedir verifSaveName(eNames{mainEffect(1)}) '/DIFF/'  verifSaveName([char(posthoc.differences.names{1,comp}) ' - ' char(posthoc.differences.names{2,comp})])])
                close
                
                plotmean(relativeDifferencesData,IC,xlab,'Differences (%)',Fs,xlimits,nx,[],[],imageFontSize,imageSize,transparancy1D,[])
                legend([posthoc.differences.names{1,comp} ' - ' posthoc.differences.names{2,comp}],'Location','eastoutside','box','off')
                savefig([savedir verifSaveName(eNames{mainEffect(1)}) '/FIG/DIFF/'  verifSaveName([char(posthoc.differences.names{1,comp}) ' - ' char(posthoc.differences.names{2,comp})]) '%'])
                print('-dtiff',imageResolution,[savedir verifSaveName(eNames{mainEffect(1)}) '/DIFF/'  verifSaveName([char(posthoc.differences.names{1,comp}) ' - ' char(posthoc.differences.names{2,comp})]) ' %'])
                close
                
                
                % inference
                posthoc.tTests.names=posthoc.differences.names;
                [posthoc.tTests.nWarning{comp},iterations,alpha]=fctWarningIterations(Ttest,alphaOriginal,multiIterations,maximalIT,IT);
                posthoc.tTests.alphaOriginal{comp}=alphaOriginal;
                posthoc.tTests.alpha{comp}=alpha;
                posthoc.tTests.nIterations{comp}=iterations;
                Ttest_inf=Ttest.inference(alpha,'iterations',iterations,'force_iterations',logical(1),'two_tailed',logical(1));
                posthoc.tTests.maxIterations{comp}=Ttest_inf.nPermUnique;
                posthoc.tTests.Tthreshold{comp}=Ttest_inf.zstar;
                posthoc.tTests.Tsignificant{1,comp}=zeros(dimensions(1),dimensions(2));
                posthoc.tTests.Tcontinuum{1,comp}=reshape(Ttest_inf.z,dimensions(1),dimensions(2));
                mapLogical=abs(posthoc.tTests.Tcontinuum{1,comp})>=posthoc.tTests.Tthreshold{comp};
                posthoc.tTests.Tsignificant{1,comp}(anovaEffects{mainEffect})=mapLogical(anovaEffects{mainEffect});
                clustersT=extractClusterData(Ttest_inf.clusters);
                for c=1:numel(clustersT)
                    posthoc.tTests.clusterLocation{comp}{c}=clustersT{c}.endpoints;
                    posthoc.tTests.clusterP{comp}(c)=clustersT{c}.P;
                end
                
                
                % plot of spm analysis
                displayTtest(posthoc.tTests.Tcontinuum{1,comp},posthoc.tTests.Tthreshold{comp},posthoc.tTests.Tsignificant{1,comp},Fs,xlab,ylab,ylimits,dimensions,nx,ny,xlimits,imageFontSize,imageSize,transparancy1D)
                title(strrep([char(posthoc.differences.names{1,comp}) ' - ' char(posthoc.differences.names{2,comp})],' x ',' \cap '))
                savefig([savedir verifSaveName(eNames{mainEffect(1)}) '/FIG/SPM/'  verifSaveName([char(posthoc.differences.names{1,comp}) ' - ' char(posthoc.differences.names{2,comp})])])
                print('-dtiff',imageResolution,[savedir verifSaveName(eNames{mainEffect(1)}) '/SPM/'  verifSaveName([char(posthoc.differences.names{1,comp}) ' - ' char(posthoc.differences.names{2,comp})])])
                close
                
                % ES
                plotES(posthoc.differences.ES{comp},posthoc.differences.ESsd{comp},posthoc.tTests.Tsignificant{1,comp},Fs,xlab,nx,xlimits,imageFontSize,imageSize,transparancy1D,yLimitES)
                title(strrep([char(posthoc.differences.names{1,comp}) ' - ' char(posthoc.differences.names{2,comp})],' x ',' \cap '))
                savefig([savedir verifSaveName(eNames{mainEffect(1)}) '/FIG/ES/'  verifSaveName([char(posthoc.differences.names{1,comp}) ' - ' char(posthoc.differences.names{2,comp})])])
                print('-dtiff',imageResolution,[savedir verifSaveName(eNames{mainEffect(1)}) '/ES/'  verifSaveName([char(posthoc.differences.names{1,comp}) ' - ' char(posthoc.differences.names{2,comp})])])
                close
                
            end
            
            % full plot of means + SPM
            plotmeanSPM(posthoc.data.continuum,posthoc.tTests.Tcontinuum,posthoc.tTests.Tsignificant,legendPlot,posthoc.differences.names,IC,xlab,ylab,Fs,xlimits,nx,ny,colorPlot,imageFontSize,imageSize,transparancy1D,ylimits,anovaEffects(mainEffect(1)),eNames(mainEffect(1)),ratioSPM,spmPos,aovColor)
            print('-dtiff',imageResolution,[savedir verifSaveName(eNames{mainEffect(1)}) '/' verifSaveName(eNames{mainEffect(1)}) ' + SPM'])
            savefig([savedir verifSaveName(eNames{mainEffect(1)}) '/FIG/' verifSaveName(eNames{mainEffect(1)}) ' + SPM'])
            close
            
            plotmeanSPM(posthoc.data.continuum,posthoc.tTests.Tcontinuum,posthoc.tTests.Tsignificant,legendPlot,posthoc.differences.names,IC,xlab,ylab,Fs,xlimits,nx,ny,colorPlot,imageFontSize,imageSize,transparancy1D,ylimits,[],[],ratioSPM,spmPos,aovColor)
            print('-dtiff',imageResolution,[savedir verifSaveName(eNames{mainEffect(1)}) '/' verifSaveName(eNames{mainEffect(1)}) ' + SPMnoAOV'])
            savefig([savedir verifSaveName(eNames{mainEffect(1)}) '/FIG/' verifSaveName(eNames{mainEffect(1)}) ' + SPMnoAOV'])
            close
            
            plotmeanSPMsub(posthoc.data.continuum,posthoc.tTests.Tcontinuum,posthoc.tTests.Tsignificant,legendPlot,posthoc.differences.names,IC,xlab,ylab,Fs,xlimits,nx,ny,colorPlot,imageFontSize,imageSize,transparancy1D,ylimits,anovaEffects(mainEffect(1)),eNames(mainEffect(1)),ratioSPM,spmPos,aovColor)
            print('-dtiff',imageResolution,[savedir verifSaveName(eNames{mainEffect(1)}) '/' verifSaveName(eNames{mainEffect(1)}) ' + SPMsub'])
            savefig([savedir verifSaveName(eNames{mainEffect(1)}) '/FIG/' verifSaveName(eNames{mainEffect(1)}) ' + SPMsub'])
            close
            
            plotmeanSPMsub(posthoc.data.continuum,posthoc.tTests.Tcontinuum,posthoc.tTests.Tsignificant,legendPlot,posthoc.differences.names,IC,xlab,ylab,Fs,xlimits,nx,ny,colorPlot,imageFontSize,imageSize,transparancy1D,ylimits,[],[],ratioSPM,spmPos,aovColor)
            print('-dtiff',imageResolution,[savedir verifSaveName(eNames{mainEffect(1)}) '/' verifSaveName(eNames{mainEffect(1)}) ' + SPMsubNoAOV'])
            savefig([savedir verifSaveName(eNames{mainEffect(1)}) '/FIG/' verifSaveName(eNames{mainEffect(1)}) ' + SPMsubNoAOV'])
            close
            
            mainForInteraction{mainEffect}=posthoc.tTests.Tsignificant;
            save([savedir '/' verifSaveName(eNames{mainEffect(1)}) '/posthoc'], 'posthoc')
            clear posthoc Comp combi legendPlot
            
        end
    end
end

%% T-TESTS 3 EFFECTS - 1 FIXED = INTERACTION
if nEffects==3
    
    for effectFixed=1:3
        
        fixedEffect=effectFixed;
        mainEffect=1:3;
        mainEffect(effectFixed)=[];
        anovaFixedCorr=[3 2 1];
        
        if max(anovaEffects{3+anovaFixedCorr(fixedEffect)})==1 | doAllInteractions==1
            
            for e=1:2
                createSavedir([savedir verifSaveName([eNames{mainEffect(1)} ' x ' eNames{mainEffect(2)}]) '/' verifSaveName(eNames{mainEffect(e)})])
            end
            
            loop=0;
            for i=1:max(indicesEffects(:,mainEffect(1)))
                for j=1:max(indicesEffects(:,mainEffect(2)))
                    loop=loop+1;
                    combi{loop}=[i j];
                end
            end
            nCombi=size(combi,2);
            
            legendPlot=[];
            for i=1:nCombi
                meansData{i}=maps1d(indicesEffects(:,mainEffect(1))==combi{i}(1) & indicesEffects(:,mainEffect(2))==combi{i}(2),:);
                legendPlot=[legendPlot,{[char(modalitiesAll{mainEffect(1)}(combi{i}(1))) ' \cap ' char(modalitiesAll{mainEffect(2)}(combi{i}(2)))]}];
                posthoc.data.names{i}=[char(modalitiesAll{mainEffect(1)}(combi{i}(1))) ' \cap ' char(modalitiesAll{mainEffect(2)}(combi{i}(2)))];
            end
            
            % full plot of means
            [nPlot,whichPlot,whichFixed,whichModal]=findNPlot(combi);
            for p=1:nPlot
                colorPlot=chooseColor(colorLine,mainEffect(whichFixed(2,p)));
                plotmean(meansData(whichPlot{p}),IC,xlab,ylab,Fs,xlimits,nx,ny,colorPlot,imageFontSize,imageSize,transparancy1D,ylimits)
                legend(legendPlot(whichPlot{p}),'Location','eastoutside','box','off')
                print('-dtiff',imageResolution,[savedir verifSaveName([eNames{mainEffect(1)} ' x ' eNames{mainEffect(2)}]) '/' verifSaveName(eNames{mainEffect(whichFixed(2,p))}) '/' verifSaveName(modalitiesAll{mainEffect(whichFixed(1,p))}{whichModal(p)})])
                savefig([savedir verifSaveName([eNames{mainEffect(1)} ' x ' eNames{mainEffect(2)}]) '/' verifSaveName(eNames{mainEffect(whichFixed(2,p))}) '/FIG/' verifSaveName(modalitiesAll{mainEffect(whichFixed(1,p))}{whichModal(p)})])
                close
            end
            
            posthoc.data.continuum=meansData;
            clear meansData
            
            loop=0;
            for i=1:nCombi
                for j=1:nCombi
                    if i<j
                        if max(size(find(combi{i}~=combi{j})))==1
                            loop=loop+1;
                            Comp{loop}=[i j];
                            testedEffect{loop}=find(combi{i}~=combi{j});
                        end
                    end
                end
            end
            
            nComp=size(Comp,2);
            if ~isempty(nT)
                alphaOriginal=0.05/nT;
            else
                alphaOriginal=alphaT/nComp;
            end
            
            for comp=1:nComp
                
                for i=1:2
                    % comparison + name
                    DATA{i}=maps1d(indicesEffects(:,mainEffect(1))==combi{Comp{comp}(i)}(1) & indicesEffects(:,mainEffect(2))==combi{Comp{comp}(i)}(2),:);
                    intForInteractions{anovaFixedCorr(effectFixed)}.comp{comp}(i,:)=combi{Comp{comp}(i)};
                end
                [eFixed,eTested,modalFixed,modalTested]=findWhichTitle([combi{Comp{comp}(1)};combi{Comp{comp}(2)}]);
                posthoc.differences.names{comp}=char([modalitiesAll{mainEffect(eFixed)}{modalFixed} ' (' modalitiesAll{mainEffect(eTested)}{modalTested(1)} ' - ' modalitiesAll{mainEffect(eTested)}{modalTested(2)} ')']);
                
                
                % t-test
                if typeEffectsAll(mainEffect(eTested))==1
                    differencesData{1}=DATA{1}-DATA{2};
                    relativeDifferencesData{1}=100*(DATA{1}-DATA{2})./DATA{2};
                    
                    posthoc.differences.continuum{1,comp}=differencesData{1};
                    posthoc.differences.continuumRelative{1,comp}=relativeDifferencesData{1};
                    
                    Ttest=spm1d.stats.nonparam.ttest_paired(DATA{1},DATA{2});
                    posthoc.tTests.type{comp}='paired';
                    [posthoc.differences.ES{comp},posthoc.differences.ESsd{comp}]=esCalculation(DATA);
                    
                else
                    
                    % differences
                    differencesData{1}=mean(DATA{1})-mean(DATA{2});
                    relativeDifferencesData{1}=100*(mean(DATA{1})-mean(DATA{2}))./mean(DATA{2});
                    
                    posthoc.differences.continuum{1,comp}=differencesData{1};
                    posthoc.differences.continuumRelative{1,comp}=relativeDifferencesData{1};
                    
                    Ttest=spm1d.stats.nonparam.ttest2(DATA{1},DATA{2});
                    posthoc.tTests.type{comp}='independant';
                    [posthoc.differences.ES{comp},posthoc.differences.ESsd{comp}]=esCalculation(DATA);
                end
                
                plotmean(differencesData,IC,xlab,ylab,Fs,xlimits,nx,[],[],imageFontSize,imageSize,transparancy1D,[])
                legend([posthoc.differences.names{comp}],'Location','eastoutside','box','off')
                savefig([savedir verifSaveName([eNames{mainEffect(1)} ' x ' eNames{mainEffect(2)}]) '/' verifSaveName(eNames{mainEffect(eTested)}) '/FIG/DIFF/' verifSaveName(posthoc.differences.names{comp})])
                print('-dtiff',imageResolution,[savedir verifSaveName([eNames{mainEffect(1)} ' x ' eNames{mainEffect(2)}]) '/' verifSaveName(eNames{mainEffect(eTested)}) '/DIFF/' verifSaveName(posthoc.differences.names{comp})])
                close
                
                plotmean(relativeDifferencesData,IC,xlab,'Differences (%)',Fs,xlimits,nx,[],[],imageFontSize,imageSize,transparancy1D,[])
                legend([posthoc.differences.names{comp}],'Location','eastoutside','box','off')
                savefig([savedir verifSaveName([eNames{mainEffect(1)} ' x ' eNames{mainEffect(2)}]) '/' verifSaveName(eNames{mainEffect(eTested)}) '/FIG/DIFF/' verifSaveName(posthoc.differences.names{comp}) '%'])
                print('-dtiff',imageResolution,[savedir verifSaveName([eNames{mainEffect(1)} ' x ' eNames{mainEffect(2)}]) '/' verifSaveName(eNames{mainEffect(eTested)}) '/DIFF/' verifSaveName(posthoc.differences.names{comp}) ' %'])
                close
                
                % inference
                posthoc.tTests.names=posthoc.differences.names;
                [posthoc.tTests.nWarning{comp},iterations,alpha]=fctWarningIterations(Ttest,alphaOriginal,multiIterations,maximalIT,IT);
                posthoc.tTests.alphaOriginal{comp}=alphaOriginal;
                posthoc.tTests.alpha{comp}=alpha;
                posthoc.tTests.nIterations{comp}=iterations;
                Ttest_inf=Ttest.inference(alpha,'iterations',iterations,'force_iterations',logical(1),'two_tailed',logical(1));
                posthoc.tTests.maxIterations{comp}=Ttest_inf.nPermUnique;
                posthoc.tTests.Tthreshold{comp}=Ttest_inf.zstar;
                posthoc.tTests.Tsignificant{1,comp}=zeros(dimensions(1),dimensions(2));
                posthoc.tTests.Tcontinuum{1,comp}=reshape(Ttest_inf.z,dimensions(1),dimensions(2));
                mapLogical=abs(posthoc.tTests.Tcontinuum{1,comp})>=posthoc.tTests.Tthreshold{comp};
                effectCorr=anovaEffects{3+anovaFixedCorr(fixedEffect)}(:);
                posthoc.tTests.Tsignificant{1,comp}(effectCorr)=mapLogical(effectCorr);
                indiceMain=findWhichMain(modalitiesAll{mainEffect(testedEffect{comp})},combi{Comp{comp}(1)}(testedEffect{comp}),combi{Comp{comp}(2)}(testedEffect{comp}));
                tMainEffect=abs(mainForInteraction{mainEffect(testedEffect{comp})}{indiceMain})>0;
                tMainEffect(effectCorr==1)=0;
                realEffect{comp}=reshape(max([tMainEffect(:)';posthoc.tTests.Tsignificant{1,comp}(:)']),dimensions(1),dimensions(2));
                posthoc.tTests.Tsignificant{1,comp}=realEffect{comp};
                clustersT=extractClusterData(Ttest_inf.clusters);
                for c=1:numel(clustersT)
                    posthoc.tTests.clusterLocation{comp}{c}=clustersT{c}.endpoints;
                    posthoc.tTests.clusterP{comp}(c)=clustersT{c}.P;
                end
                
                
                % plot of spm analysis
                displayTtest(posthoc.tTests.Tcontinuum{1,comp},posthoc.tTests.Tthreshold{comp},posthoc.tTests.Tsignificant{1,comp},Fs,xlab,ylab,ylimits,dimensions,nx,ny,xlimits,imageFontSize,imageSize,transparancy1D)
                title(posthoc.differences.names{comp})
                savefig([savedir verifSaveName([eNames{mainEffect(1)} ' x ' eNames{mainEffect(2)}]) '/' verifSaveName(eNames{mainEffect(eTested)}) '/FIG/SPM/' verifSaveName(posthoc.differences.names{comp})])
                print('-dtiff',imageResolution,[savedir verifSaveName([eNames{mainEffect(1)} ' x ' eNames{mainEffect(2)}]) '/' verifSaveName(eNames{mainEffect(eTested)}) '/SPM/' verifSaveName(posthoc.differences.names{comp})])
                close
                
                %   ES
                plotES(posthoc.differences.ES{comp},posthoc.differences.ESsd{comp},posthoc.tTests.Tsignificant{1,comp},Fs,xlab,nx,xlimits,imageFontSize,imageSize,transparancy1D,yLimitES)
                title(posthoc.differences.names{comp})
                savefig([savedir verifSaveName([eNames{mainEffect(1)} ' x ' eNames{mainEffect(2)}]) '/' verifSaveName(eNames{mainEffect(eTested)}) '/FIG/ES/' verifSaveName(posthoc.differences.names{comp})])
                print('-dtiff',imageResolution,[savedir verifSaveName([eNames{mainEffect(1)} ' x ' eNames{mainEffect(2)}]) '/' verifSaveName(eNames{mainEffect(eTested)}) '/ES/' verifSaveName(posthoc.differences.names{comp})])
                close
                
            end
            
            % full plot of means + SPM
            for p=1:nPlot
                data4empty=posthoc.data.continuum(whichPlot{p});
                for i=1:numel(whichPlot{p})
                    isEmptydata(i)=~isempty(data4empty{i});
                end
                
                for nC=1:numel(whichPlot{p})
                    findT(nC)=posthoc.data.names(whichPlot{p}(nC));
                    capPos(nC,:)=strfind(findT{nC},' \cap ');
                end
                if mean(diff(capPos)~=0)>0 % same letter at the end
                    sameName=findT{1}(capPos(1)+6:end);
                else
                    if findT{1}(1:capPos(1)-1)==findT{2}(1:capPos(1)-1) % start
                        sameName=findT{1}(1:capPos(1)-1);
                    else
                        sameName=findT{1}(capPos(1)+6:end); % end
                    end
                end
                sizeSname=numel(sameName);
                for nC=1:numel(posthoc.differences.names)
                    nameCompare=[posthoc.differences.names{nC} '___________________________'];
                    whichCompare(nC)=strcmp(sameName,nameCompare(1:sizeSname));
                end
                
                colorPlot=chooseColor(colorLine,mainEffect(whichFixed(2,p)));
                nAnova=whichAnova(mainEffect);
                
                plotmeanSPM(posthoc.data.continuum(whichPlot{p}),posthoc.tTests.Tcontinuum(:,whichCompare),posthoc.tTests.Tsignificant(:,whichCompare),legendPlot(whichPlot{p}),posthoc.differences.names(whichCompare),IC,xlab,ylab,Fs,xlimits,nx,ny,colorPlot,imageFontSize,imageSize,transparancy1D,ylimits,anovaEffects([mainEffect(whichFixed(2,p)), nAnova]),{eNames{mainEffect(whichFixed(2,p))},[eNames{mainEffect(1)} ' x ' eNames{mainEffect(2)}]},ratioSPM,spmPos,aovColor)
                print('-dtiff',imageResolution,[savedir verifSaveName([eNames{mainEffect(1)} ' x ' eNames{mainEffect(2)}]) '/' verifSaveName(eNames{mainEffect(whichFixed(2,p))}) '/' verifSaveName(modalitiesAll{mainEffect(whichFixed(1,p))}{whichModal(p)}) ' + SPM'])
                savefig([savedir verifSaveName([eNames{mainEffect(1)} ' x ' eNames{mainEffect(2)}]) '/' verifSaveName(eNames{mainEffect(whichFixed(2,p))}) '/FIG/' verifSaveName(modalitiesAll{mainEffect(whichFixed(1,p))}{whichModal(p)}) ' +SPM'])
                close
                
                plotmeanSPM(posthoc.data.continuum(whichPlot{p}),posthoc.tTests.Tcontinuum(:,whichCompare),posthoc.tTests.Tsignificant(:,whichCompare),legendPlot(whichPlot{p}),posthoc.differences.names(whichCompare),IC,xlab,ylab,Fs,xlimits,nx,ny,colorPlot,imageFontSize,imageSize,transparancy1D,ylimits,[],[],ratioSPM,spmPos,aovColor)
                print('-dtiff',imageResolution,[savedir verifSaveName([eNames{mainEffect(1)} ' x ' eNames{mainEffect(2)}]) '/' verifSaveName(eNames{mainEffect(whichFixed(2,p))}) '/' verifSaveName(modalitiesAll{mainEffect(whichFixed(1,p))}{whichModal(p)}) ' + SPMnoAOV'])
                savefig([savedir verifSaveName([eNames{mainEffect(1)} ' x ' eNames{mainEffect(2)}]) '/' verifSaveName(eNames{mainEffect(whichFixed(2,p))}) '/FIG/' verifSaveName(modalitiesAll{mainEffect(whichFixed(1,p))}{whichModal(p)}) ' +SPMnoAOV'])
                close
                
                plotmeanSPMsub(posthoc.data.continuum(whichPlot{p}),posthoc.tTests.Tcontinuum(:,whichCompare),posthoc.tTests.Tsignificant(:,whichCompare),legendPlot(whichPlot{p}),posthoc.differences.names(whichCompare),IC,xlab,ylab,Fs,xlimits,nx,ny,colorPlot,imageFontSize,imageSize,transparancy1D,ylimits,anovaEffects([mainEffect(whichFixed(2,p)), nAnova]),{eNames{mainEffect(whichFixed(2,p))},[eNames{mainEffect(1)} ' x ' eNames{mainEffect(2)}]},ratioSPM,spmPos,aovColor)
                print('-dtiff',imageResolution,[savedir verifSaveName([eNames{mainEffect(1)} ' x ' eNames{mainEffect(2)}]) '/' verifSaveName(eNames{mainEffect(whichFixed(2,p))}) '/' verifSaveName(modalitiesAll{mainEffect(whichFixed(1,p))}{whichModal(p)}) ' + SPMsub'])
                savefig([savedir verifSaveName([eNames{mainEffect(1)} ' x ' eNames{mainEffect(2)}]) '/' verifSaveName(eNames{mainEffect(whichFixed(2,p))}) '/FIG/' verifSaveName(modalitiesAll{mainEffect(whichFixed(1,p))}{whichModal(p)}) ' +SPMsub'])
                close
                
                plotmeanSPMsub(posthoc.data.continuum(whichPlot{p}),posthoc.tTests.Tcontinuum(:,whichCompare),posthoc.tTests.Tsignificant(:,whichCompare),legendPlot(whichPlot{p}),posthoc.differences.names(whichCompare),IC,xlab,ylab,Fs,xlimits,nx,ny,colorPlot,imageFontSize,imageSize,transparancy1D,ylimits,[],[],ratioSPM,spmPos,aovColor)
                print('-dtiff',imageResolution,[savedir verifSaveName([eNames{mainEffect(1)} ' x ' eNames{mainEffect(2)}]) '/' verifSaveName(eNames{mainEffect(whichFixed(2,p))}) '/' verifSaveName(modalitiesAll{mainEffect(whichFixed(1,p))}{whichModal(p)}) ' + SPMsubNoAOV'])
                savefig([savedir verifSaveName([eNames{mainEffect(1)} ' x ' eNames{mainEffect(2)}]) '/' verifSaveName(eNames{mainEffect(whichFixed(2,p))}) '/FIG/' verifSaveName(modalitiesAll{mainEffect(whichFixed(1,p))}{whichModal(p)}) ' +SPMsubNoAOV'])
                close
                
                clear isEmptydata findT capPos whichCompare
                
            end
            
            intForInteractions{anovaFixedCorr(effectFixed)}.t=realEffect;
            save([savedir '/' verifSaveName([eNames{mainEffect(1)} ' x ' eNames{mainEffect(2)}]) '/posthoc'], 'posthoc')
            clear posthoc Comp combi legendPlot
            
        end
    end
end

%% T-TESTS ALL INTERACTIONS (ANOVA 2 and 3)
if nEffects>1
    
    if nEffects==2
        isInteraction=max(anovaEffects{3});
        savedir2=[verifSaveName([eNames{1} ' x ' eNames{2}]) '/'] ;
        if isInteraction==1 | doAllInteractions==1
            createSavedir([savedir savedir2 verifSaveName(eNames{1})])
            createSavedir([savedir savedir2 verifSaveName(eNames{2})])
        end
        figname =verifSaveName([eNames{1} ' x ' eNames{2}]);
    elseif nEffects==3
        isInteraction=max(anovaEffects{7});
        savedir2=[verifSaveName([eNames{1} ' x ' eNames{2} ' x ' eNames{3}]) '/'];
        if isInteraction==1 | doAllInteractions==1
            createSavedir([savedir savedir2 verifSaveName(eNames{1})])
            createSavedir([savedir savedir2 verifSaveName(eNames{2})])
            createSavedir([savedir savedir2 verifSaveName(eNames{3})])
        end
        figname=verifSaveName([eNames{1} ' x ' eNames{2} ' x ' eNames{3}]);
    end
    
    if isInteraction==1 | doAllInteractions==1
        
        loop=0;
        
        if isempty(imageSize)
            f1=figure('Units', 'Pixels', 'OuterPosition', [0, 0, 720, 480],'visible','off');
        elseif max(size(imageSize))==1
            f1=figure('Units', 'Centimeter', 'OuterPosition', [0, 0, imageSize, imageSize],'visible','off');
        else
            f1=figure('Units', 'Centimeter', 'OuterPosition', [0, 0, imageSize(1), imageSize(2)],'visible','off');
        end
        % number of combinations + plot of each
        if nEffects==2
            
            for i=1:max(indicesEffects(:,1))
                for j=1:max(indicesEffects(:,2))
                    loop=loop+1;
                    combi{loop}=[i j];
                end
            end
            nCombi=size(combi,2);
            
            legendPlot=[];
            for i=1:nCombi
                meansData{i}=maps1d(indicesEffects(:,1)==combi{i}(1) & indicesEffects(:,2)==combi{i}(2),:);
                legendPlot=[legendPlot,{[char(modalitiesAll{1}(combi{i}(1))) ' \cap ' char(modalitiesAll{2}(combi{i}(2)))]}];
                posthoc.data.names{i}=[char(modalitiesAll{1}(combi{i}(1))) ' \cap ' char(modalitiesAll{2}(combi{i}(2)))];
            end
            
            % full plot of means
            [nPlot,whichPlot,whichFixed,whichModal]=findNPlot(combi);
            for p=1:nPlot
                colorPlot=chooseColor(colorLine,whichFixed(2,p));
                plotmean(meansData(whichPlot{p}),IC,xlab,ylab,Fs,xlimits,nx,ny,colorPlot,imageFontSize,imageSize,transparancy1D,ylimits)
                data4empty=meansData(whichPlot{p});
                for i=1:numel(whichPlot{p})
                    isEmptydata(i)=~isempty(data4empty{i});
                end
                legend(legendPlot(whichPlot{p}(isEmptydata)),'Location','eastoutside','box','off')
                print('-dtiff',imageResolution,[savedir savedir2 verifSaveName(eNames{whichFixed(2,p)}) '/' verifSaveName(modalitiesAll{whichFixed(1,p)}{whichModal(1,p)})])
                savefig([savedir savedir2 verifSaveName(eNames{whichFixed(2,p)}) '/FIG/' verifSaveName(modalitiesAll{whichFixed(1,p)}{whichModal(1,p)})])
                close
                clear isEmptydata whichCompare
            end
            
            posthoc.data.continuum=meansData;
            clear meansData
            
        elseif nEffects==3
            
            for i=1:max(indicesEffects(:,1))
                for j=1:max(indicesEffects(:,2))
                    for k=1:max(indicesEffects(:,3))
                        loop=loop+1;
                        combi{loop}=[i j k];
                    end
                end
            end
            nCombi=size(combi,2);
            
            legendPlot=[];
            for i=1:nCombi
                meansData{i}=maps1d(indicesEffects(:,1)==combi{i}(1) & indicesEffects(:,2)==combi{i}(2) & indicesEffects(:,3)==combi{i}(3),:);
                legendPlot=[legendPlot,{[char(modalitiesAll{1}(combi{i}(1))) ' \cap ' char(modalitiesAll{2}(combi{i}(2))) ' \cap ' char(modalitiesAll{3}(combi{i}(3)))]}];
                posthoc.data.names{i}=[char(modalitiesAll{1}(combi{i}(1))) ' \cap ' char(modalitiesAll{2}(combi{i}(2))) ' \cap ' char(modalitiesAll{3}(combi{i}(3)))];
            end
            
            [nPlot,whichPlot,whichFixed,whichModal]=findNPlot(combi);
            for p=1:nPlot
                colorPlot=chooseColor(colorLine,whichFixed(1,p));
                plotmean(meansData(whichPlot{p}),IC,xlab,ylab,Fs,xlimits,nx,ny,colorPlot,imageFontSize,imageSize,transparancy1D,ylimits)
                legend(legendPlot(whichPlot{p}),'Location','eastoutside','box','off')
                print('-dtiff',imageResolution,[savedir savedir2 verifSaveName(eNames{whichFixed(1,p)}) '/' verifSaveName([modalitiesAll{whichFixed(2,p)}{whichModal(1,p)} ' x ' modalitiesAll{whichFixed(3,p)}{whichModal(2,p)}])])
                savefig([savedir savedir2 verifSaveName(eNames{whichFixed(1,p)}) '/FIG/' verifSaveName([modalitiesAll{whichFixed(2,p)}{whichModal(1,p)} ' x ' modalitiesAll{whichFixed(3,p)}{whichModal(2,p)}])])
                close
            end
            posthoc.data.continuum=meansData;
            clear meansData
        end
        
        % number of comparisons + plot of each
        loop=0;
        for i=1:nCombi
            for j=1:nCombi
                if i<j
                    if max(size(find(combi{i}~=combi{j})))==1
                        loop=loop+1;
                        Comp{loop}=[i j];
                        testedEffect{loop}=find(combi{i}~=combi{j});
                    end
                end
            end
        end
        
        nComp=size(Comp,2);
        if ~isempty(nT)
            alphaOriginal=0.05/nT;
        else
            alphaOriginal=alphaT/nComp;
        end
        
        for comp=1:nComp
            
            for i=1:2
                % comparison + name
                if nEffects==2
                    DATA{i}=maps1d(indicesEffects(:,1)==combi{Comp{comp}(i)}(1) & indicesEffects(:,2)==combi{Comp{comp}(i)}(2),:);
                    [eFixed,eTested,modalFixed,modalTested]=findWhichTitle([combi{Comp{comp}(1)};combi{Comp{comp}(2)}]);
                    posthoc.differences.names{comp}=char([modalitiesAll{eFixed}{modalFixed} ' (' modalitiesAll{eTested}{modalTested(1)} ' - ' modalitiesAll{eTested}{modalTested(2)} ')']);
                elseif nEffects==3
                    DATA{i}=maps1d(indicesEffects(:,1)==combi{Comp{comp}(i)}(1) & indicesEffects(:,2)==combi{Comp{comp}(i)}(2) & indicesEffects(:,3)==combi{Comp{comp}(i)}(3),:);
                    [eFixed,eTested,modalFixed,modalTested]=findWhichTitle([combi{Comp{comp}(1)};combi{Comp{comp}(2)}]);
                    posthoc.differences.names{comp}=char([modalitiesAll{eFixed(1)}{modalFixed(1)} ' x ' modalitiesAll{eFixed(2)}{modalFixed(2)} ' (' modalitiesAll{eTested}{modalTested(1)} ' - ' modalitiesAll{eTested}{modalTested(2)} ')']);
                end
            end
            
            
            % t-test
            if typeEffectsAll(eTested)==1
                differencesData{1}=DATA{1}-DATA{2};
                relativeDifferencesData{1}=100*(DATA{1}-DATA{2})./DATA{2};
                
                posthoc.differences.continuum{1,comp}=differencesData{1};
                posthoc.differences.continuumRelative{1,comp}=relativeDifferencesData{1};
                
                Ttest=spm1d.stats.nonparam.ttest_paired(DATA{1},DATA{2});
                posthoc.tTests.type{comp}='paired';
                [posthoc.differences.ES{comp},posthoc.differences.ESsd{comp}]=esCalculation(DATA);
                
            else
                
                % differences
                differencesData{1}=mean(DATA{1})-mean(DATA{2});
                relativeDifferencesData{1}=100*(mean(DATA{1})-mean(DATA{2}))./mean(DATA{2});
                
                posthoc.differences.continuum{1,comp}=differencesData{1};
                posthoc.differences.continuumRelative{1,comp}=relativeDifferencesData{1};
                
                Ttest=spm1d.stats.nonparam.ttest2(DATA{1},DATA{2});
                posthoc.tTests.type{comp}='independant';
                [posthoc.differences.ES{comp},posthoc.differences.ESsd{comp}]=esCalculation(DATA);
            end
            
            plotmean(differencesData,IC,xlab,ylab,Fs,xlimits,nx,[],[],imageFontSize,imageSize,transparancy1D,[])
            legend([posthoc.differences.names{comp}],'Location','eastoutside','box','off')
            savefig([savedir savedir2 verifSaveName(eNames{testedEffect{comp}}) '/FIG/DIFF/' verifSaveName(posthoc.differences.names{comp})])
            print('-dtiff',imageResolution,[savedir savedir2 verifSaveName(eNames{testedEffect{comp}}) '/DIFF/' verifSaveName(posthoc.differences.names{comp})])
            close
            
            plotmean(relativeDifferencesData,IC,xlab,'Differences (%)',Fs,xlimits,nx,[],[],imageFontSize,imageSize,transparancy1D,[])
            legend([posthoc.differences.names{comp}],'Location','eastoutside','box','off')
            savefig([savedir savedir2 verifSaveName(eNames{testedEffect{comp}}) '/FIG/DIFF/' verifSaveName(posthoc.differences.names{comp}) '%'])
            print('-dtiff',imageResolution,[savedir savedir2 verifSaveName(eNames{testedEffect{comp}}) '/DIFF/' verifSaveName(posthoc.differences.names{comp}) ' %'])
            close
            
            % inference
            posthoc.tTests.names=posthoc.differences.names;
            [posthoc.tTests.nWarning{comp},iterations,alpha]=fctWarningIterations(Ttest,alphaOriginal,multiIterations,maximalIT,IT);
            posthoc.tTests.alphaOriginal{comp}=alphaOriginal;
            posthoc.tTests.alpha{comp}=alpha;
            posthoc.tTests.nIterations{comp}=iterations;
            Ttest_inf=Ttest.inference(alpha,'iterations',iterations,'force_iterations',logical(1),'two_tailed',logical(1));
            posthoc.tTests.maxIterations{comp}=Ttest_inf.nPermUnique;
            posthoc.tTests.Tthreshold{comp}=Ttest_inf.zstar;
            posthoc.tTests.Tcontinuum{1,comp}=reshape(Ttest_inf.z,dimensions(1),dimensions(2));
            posthoc.tTests.Tsignificant{1,comp}=zeros(dimensions(1),dimensions(2));
            posthoc.tTests.Tcontinuum{1,comp}=reshape(Ttest_inf.z,dimensions(1),dimensions(2));
            mapLogical=abs(posthoc.tTests.Tcontinuum{1,comp})>=posthoc.tTests.Tthreshold{comp};
            
            clustersT=extractClusterData(Ttest_inf.clusters);
            for c=1:numel(clustersT)
                posthoc.tTests.clusterLocation{comp}{c}=clustersT{c}.endpoints;
                posthoc.tTests.clusterP{comp}(c)=clustersT{c}.P;
            end
            
            if nEffects==2
                indiceMain=findWhichMain(modalitiesAll{testedEffect{comp}},combi{Comp{comp}(1)}(testedEffect{comp}),combi{Comp{comp}(2)}(testedEffect{comp}));
                tMainEffect=abs(mainForInteraction{testedEffect{comp}}{indiceMain})>0;
                effectCorr=anovaEffects{3}(:);
            else
                
                intLocations=[4 5;4 6;5 6]-3;
                for interactions=1:2
                    indiceInteraction=findWhichInteraction(intForInteractions{intLocations(testedEffect{comp},interactions)}.comp,combi(Comp{comp}),interactions,testedEffect{comp});
                    tInteractionEffect{interactions}=intForInteractions{intLocations(testedEffect{comp},interactions)}.t{indiceInteraction}(:);
                end
                effectCorr=anovaEffects{7};
            end
            
            posthoc.tTests.Tsignificant{1,comp}(effectCorr)=mapLogical(effectCorr);
            if nEffects==2
                tMainEffect(effectCorr==1)=0;
                realEffect{comp}=reshape(max([tMainEffect(:)';posthoc.tTests.Tsignificant{1,comp}(:)']),dimensions(1),dimensions(2));
            else
                for interactions=1:2
                    tInteractionEffect{interactions}(effectCorr==1)=0;
                end
                realEffect{comp}=reshape(max([tInteractionEffect{1}';tInteractionEffect{2}';posthoc.tTests.Tsignificant{1,comp}(:)']),dimensions(1),dimensions(2));
            end
            posthoc.tTests.Tsignificant{1,comp}=realEffect{comp};
            
            % full plot of spm analysis
            displayTtest(posthoc.tTests.Tcontinuum{1,comp},posthoc.tTests.Tthreshold{comp},posthoc.tTests.Tsignificant{1,comp},Fs,xlab,ylab,ylimits,dimensions,nx,ny,xlimits,imageFontSize,imageSize,transparancy1D)
            title(posthoc.differences.names{comp})
            savefig([savedir savedir2 verifSaveName(eNames{testedEffect{comp}}) '/FIG/SPM/' verifSaveName(posthoc.differences.names{comp})])
            print('-dtiff',imageResolution,[savedir savedir2 verifSaveName(eNames{testedEffect{comp}}) '/SPM/' verifSaveName(posthoc.differences.names{comp})])
            close
            
            % ES
            plotES(posthoc.differences.ES{comp},posthoc.differences.ESsd{comp},posthoc.tTests.Tsignificant{1,comp},Fs,xlab,nx,xlimits,imageFontSize,imageSize,transparancy1D,yLimitES)
            title(posthoc.differences.names{comp})
            savefig([savedir savedir2 verifSaveName(eNames{testedEffect{comp}}) '/FIG/ES/' verifSaveName(posthoc.differences.names{comp})])
            print('-dtiff',imageResolution,[savedir savedir2 verifSaveName(eNames{testedEffect{comp}}) '/ES/' verifSaveName(posthoc.differences.names{comp})])
            close
            
        end
        
        
        for p=1:nPlot
            
            data4empty=posthoc.data.continuum(whichPlot{p});
            for i=1:numel(whichPlot{p})
                isEmptydata(i)=~isempty(data4empty{i});
            end
            
            for nC=1:numel(whichPlot{p})
                findT(nC)=posthoc.data.names(whichPlot{p}(nC));
                capPos(nC,:)=strfind(findT{nC},' \cap ');
            end
            
            if size(capPos,2)==1 % ANOVA 2
                if mean(diff(capPos)~=0)>0 % same letter at the end
                    sameName=findT{1}(capPos(1)+6:end);
                else
                    if findT{1}(1:capPos(1)-1)==findT{2}(1:capPos(1)-1) % start
                        sameName=findT{1}(1:capPos(1)-1);
                    else
                        sameName=findT{1}(capPos(1)+6:end); % end
                    end
                end
                
                sameName=strrep(sameName,'\cap','x');
                
            else % ANOVA 3
                
                for i=1:numel(findT)
                    iFirst{i}=findT{i}(1:capPos(i,1)-1);
                    iSecond{i}=findT{i}(capPos(i,1)+6:capPos(i,2)-1);
                    iThird{i}=findT{i}(capPos(i,2)+6:end);
                end
                
                if ~strcmp(iFirst{1},iFirst{2}) % start
                    sameName=[iSecond{1} ' x ' iThird{1}];
                elseif ~strcmp(iSecond{1},iSecond{2})
                    sameName=[iFirst{1} ' x ' iThird{1}];
                else
                    sameName=[iFirst{1} ' x ' iSecond{1}];
                end
                
            end
            
            sizeSname=numel(sameName);
            for nC=1:numel(posthoc.differences.names)
                nameCompare=[posthoc.differences.names{nC} '___________________________'];
                whichCompare(nC)=strcmp(sameName,nameCompare(1:sizeSname));            end
            
            if nEffects==2
                colorPlot=chooseColor(colorLine,whichFixed(2,p));
            else
                colorPlot=chooseColor(colorLine,whichFixed(1,p));
            end
            
            if nEffects==2
                plotmeanSPM(posthoc.data.continuum(whichPlot{p}),posthoc.tTests.Tcontinuum(:,whichCompare),posthoc.tTests.Tsignificant(:,whichCompare),legendPlot(whichPlot{p}(isEmptydata)),posthoc.differences.names(whichCompare),IC,xlab,ylab,Fs,xlimits,nx,ny,colorPlot,imageFontSize,imageSize,transparancy1D,ylimits,anovaEffects([whichFixed(2,p) 3]),{eNames{whichFixed(2,p)},[eNames{1} ' x ' eNames{2}]},ratioSPM,spmPos,aovColor)
                print('-dtiff',imageResolution,[savedir savedir2 verifSaveName(eNames{whichFixed(2,p)}) '/' verifSaveName(modalitiesAll{whichFixed(1,p)}{whichModal(1,p)}) ' + SPM'])
                savefig([savedir savedir2 verifSaveName(eNames{whichFixed(2,p)}) '/FIG/' verifSaveName(modalitiesAll{whichFixed(1,p)}{whichModal(1,p)}) ' + SPM'])
                close
                
                plotmeanSPM(posthoc.data.continuum(whichPlot{p}),posthoc.tTests.Tcontinuum(:,whichCompare),posthoc.tTests.Tsignificant(:,whichCompare),legendPlot(whichPlot{p}(isEmptydata)),posthoc.differences.names(whichCompare),IC,xlab,ylab,Fs,xlimits,nx,ny,colorPlot,imageFontSize,imageSize,transparancy1D,ylimits,[],[],ratioSPM,spmPos,aovColor)
                print('-dtiff',imageResolution,[savedir savedir2 verifSaveName(eNames{whichFixed(2,p)}) '/' verifSaveName(modalitiesAll{whichFixed(1,p)}{whichModal(1,p)}) ' + SPMnoAOV'])
                savefig([savedir savedir2 verifSaveName(eNames{whichFixed(2,p)}) '/FIG/' verifSaveName(modalitiesAll{whichFixed(1,p)}{whichModal(1,p)}) ' + SPMnoAOV'])
                close
                
                plotmeanSPMsub(posthoc.data.continuum(whichPlot{p}),posthoc.tTests.Tcontinuum(:,whichCompare),posthoc.tTests.Tsignificant(:,whichCompare),legendPlot(whichPlot{p}(isEmptydata)),posthoc.differences.names(whichCompare),IC,xlab,ylab,Fs,xlimits,nx,ny,colorPlot,imageFontSize,imageSize,transparancy1D,ylimits,anovaEffects([whichFixed(2,p) 3]),{eNames{whichFixed(2,p)},[eNames{1} ' x ' eNames{2}]},ratioSPM,spmPos,aovColor)
                print('-dtiff',imageResolution,[savedir savedir2 verifSaveName(eNames{whichFixed(2,p)}) '/' verifSaveName(modalitiesAll{whichFixed(1,p)}{whichModal(1,p)}) ' + SPMsub'])
                savefig([savedir savedir2 verifSaveName(eNames{whichFixed(2,p)}) '/FIG/' verifSaveName(modalitiesAll{whichFixed(1,p)}{whichModal(1,p)}) ' + SPMsub'])
                close
                
                plotmeanSPMsub(posthoc.data.continuum(whichPlot{p}),posthoc.tTests.Tcontinuum(:,whichCompare),posthoc.tTests.Tsignificant(:,whichCompare),legendPlot(whichPlot{p}(isEmptydata)),posthoc.differences.names(whichCompare),IC,xlab,ylab,Fs,xlimits,nx,ny,colorPlot,imageFontSize,imageSize,transparancy1D,ylimits,[],[],ratioSPM,spmPos,aovColor)
                print('-dtiff',imageResolution,[savedir savedir2 verifSaveName(eNames{whichFixed(2,p)}) '/' verifSaveName(modalitiesAll{whichFixed(1,p)}{whichModal(1,p)}) ' + SPMsubNoAOV'])
                savefig([savedir savedir2 verifSaveName(eNames{whichFixed(2,p)}) '/FIG/' verifSaveName(modalitiesAll{whichFixed(1,p)}{whichModal(1,p)}) ' + SPMsubNoAOV'])
                close
            else
                [nAnovaInt,nNames]=whichAnovaInt(whichFixed(1,p));
                
                plotmeanSPM(posthoc.data.continuum(whichPlot{p}),posthoc.tTests.Tcontinuum(:,whichCompare),posthoc.tTests.Tsignificant(:,whichCompare),legendPlot(whichPlot{p}(isEmptydata)),posthoc.differences.names(whichCompare),IC,xlab,ylab,Fs,xlimits,nx,ny,colorPlot,imageFontSize,imageSize,transparancy1D,ylimits,...
                    anovaEffects([whichFixed(1,p) nAnovaInt 7]),{eNames{whichFixed(1,p)},[eNames{nNames(1,1)} ' x ' eNames{nNames(1,2)}], [eNames{nNames(2,1)} ' x ' eNames{nNames(2,2)}],[eNames{1} ' x ' eNames{2} ' x ' eNames{3}]},ratioSPM,spmPos,aovColor)
                print('-dtiff',imageResolution,[savedir savedir2 verifSaveName(eNames{whichFixed(1,p)}) '/' verifSaveName([modalitiesAll{whichFixed(2,p)}{whichModal(1,p)} ' x ' modalitiesAll{whichFixed(3,p)}{whichModal(2,p)}]) ' + SPM'])
                savefig([savedir savedir2 verifSaveName(eNames{whichFixed(1,p)}) '/FIG/' verifSaveName([modalitiesAll{whichFixed(2,p)}{whichModal(1,p)} ' x ' modalitiesAll{whichFixed(3,p)}{whichModal(2,p)}]) ' + SPM'])
                close
                
                plotmeanSPM(posthoc.data.continuum(whichPlot{p}),posthoc.tTests.Tcontinuum(:,whichCompare),posthoc.tTests.Tsignificant(:,whichCompare),legendPlot(whichPlot{p}(isEmptydata)),posthoc.differences.names(whichCompare),IC,xlab,ylab,Fs,xlimits,nx,ny,colorPlot,imageFontSize,imageSize,transparancy1D,ylimits,[],[],ratioSPM,spmPos,aovColor)
                print('-dtiff',imageResolution,[savedir savedir2 verifSaveName(eNames{whichFixed(1,p)}) '/' verifSaveName([modalitiesAll{whichFixed(2,p)}{whichModal(1,p)} ' x ' modalitiesAll{whichFixed(3,p)}{whichModal(2,p)}]) ' + SPMnoAOV'])
                savefig([savedir savedir2 verifSaveName(eNames{whichFixed(1,p)}) '/FIG/' verifSaveName([modalitiesAll{whichFixed(2,p)}{whichModal(1,p)} ' x ' modalitiesAll{whichFixed(3,p)}{whichModal(2,p)}]) ' + SPMnoAOV'])
                close
                
                plotmeanSPMsub(posthoc.data.continuum(whichPlot{p}),posthoc.tTests.Tcontinuum(:,whichCompare),posthoc.tTests.Tsignificant(:,whichCompare),legendPlot(whichPlot{p}(isEmptydata)),posthoc.differences.names(whichCompare),IC,xlab,ylab,Fs,xlimits,nx,ny,colorPlot,imageFontSize,imageSize,transparancy1D,ylimits,...
                    anovaEffects([whichFixed(1,p) nAnovaInt 7]),{eNames{whichFixed(1,p)},[eNames{nNames(1,1)} ' x ' eNames{nNames(1,2)}], [eNames{nNames(2,1)} ' x ' eNames{nNames(2,2)}],[eNames{1} ' x ' eNames{2} ' x ' eNames{3}]},ratioSPM,spmPos,aovColor)
                print('-dtiff',imageResolution,[savedir savedir2 verifSaveName(eNames{whichFixed(1,p)}) '/' verifSaveName([modalitiesAll{whichFixed(2,p)}{whichModal(1,p)} ' x ' modalitiesAll{whichFixed(3,p)}{whichModal(2,p)}]) ' + SPMsub'])
                savefig([savedir savedir2 verifSaveName(eNames{whichFixed(1,p)}) '/FIG/' verifSaveName([modalitiesAll{whichFixed(2,p)}{whichModal(1,p)} ' x ' modalitiesAll{whichFixed(3,p)}{whichModal(2,p)}]) ' + SPMsub'])
                close
                
                plotmeanSPMsub(posthoc.data.continuum(whichPlot{p}),posthoc.tTests.Tcontinuum(:,whichCompare),posthoc.tTests.Tsignificant(:,whichCompare),legendPlot(whichPlot{p}(isEmptydata)),posthoc.differences.names(whichCompare),IC,xlab,ylab,Fs,xlimits,nx,ny,colorPlot,imageFontSize,imageSize,transparancy1D,ylimits,[],[],ratioSPM,spmPos,aovColor)
                print('-dtiff',imageResolution,[savedir savedir2 verifSaveName(eNames{whichFixed(1,p)}) '/' verifSaveName([modalitiesAll{whichFixed(2,p)}{whichModal(1,p)} ' x ' modalitiesAll{whichFixed(3,p)}{whichModal(2,p)}]) ' + SPMsubNoAOV'])
                savefig([savedir savedir2 verifSaveName(eNames{whichFixed(1,p)}) '/FIG/' verifSaveName([modalitiesAll{whichFixed(2,p)}{whichModal(1,p)} ' x ' modalitiesAll{whichFixed(3,p)}{whichModal(2,p)}]) ' + SPMsubNoAOV'])
                close
            end
            
            clear isEmptydata findT capPos whichCompare
        end
        
        
        save([savedir '/' figname '/posthoc'], 'posthoc')
        clear posthoc Comp combi legendPlot
    end
    
end
end