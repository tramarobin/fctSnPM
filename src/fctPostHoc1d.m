function posthoc=fctPostHoc1d(nEffects,indicesEffects,maps1d,dimensions,modalitiesAll,typeEffectsAll,eNames,savedir,multiPerm,Perm,xlab,ylab,Fs,imageResolution,IC,ylimits,nx,ny,xlimits,anovaEffects,maximalPerm,colorLine,doAllInteractions,imageFontSize,imageSize,alphaT,alphaAOV,transparancy1D,ratioSnPM,yLimitES,SnPMPos,aovColor,lineStyle,xLine,yLine,xGrid,yGrid,sub)
close all

savedir=[savedir '/Post hoc/'];
imageResolution=['-r' num2str(imageResolution)];

%% define alpha risk
if isempty(alphaT)
    alphaT=alphaAOV;
    warnT=0;
else
    if alphaT~=alphaAOV
        warning('Post-hoc analysis is not valid. Please keep the same alpha risk for ANOVA and post hoc tests');
        warnT=1;
    else
        warnT=0;
    end
end

%% T-TEST 1 EFFECT = MAIN EFFECT
if nEffects==1

    if max(anovaEffects{1})==1 | doAllInteractions==1

        createSavedir(savedir)
        posthoc{1}.name=eNames{1};

        loop=0;
        for i=1:max(indicesEffects)
            loop=loop+1;
            combi{loop}=i;
        end
        nCombi=size(combi,2);

        legendPlot=[];
        for i=1:nCombi

            meansData{i}=maps1d(indicesEffects==combi{i}(1),:);
            meansData{i}=groupBysub(meansData{i},sub(indicesEffects==combi{i}(1),:));
            legendPlot=[legendPlot,{char(modalitiesAll{1}(combi{i}(1)))}];
            posthoc{1}.data.names{i}=[char(modalitiesAll{1}(combi{i}(1)))];

        end

        % full plot of means
        clPlot=chooseCL(colorLine,lineStyle,1);
        plotmean(meansData,IC,xlab,ylab,Fs,xlimits,nx,ny,clPlot,imageFontSize,imageSize,transparancy1D,ylimits,xLine,yLine,xGrid,yGrid)
        legend(legendPlot,'Location','eastoutside','box','off')
        print('-dtiff',imageResolution,[savedir verifSaveName(eNames{1})])
        savefig([savedir '/FIG/' verifSaveName(eNames{1})])
        close

        posthoc{1}.data.continuum=meansData;
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
        pBonferroni=alphaT/nComp;

        for comp=1:nComp

            for i=1:2
                % comparison + name
                DATA{i}=maps1d(indicesEffects==combi{Comp{comp}(i)}(1),:);
                DATA{i}=groupBysub(DATA{i},sub(indicesEffects==combi{Comp{comp}(i)}(1),:));
                posthoc{1}.differences.names{i,comp}=[char(modalitiesAll{1}(combi{Comp{comp}(i)}(1)))];
            end

            % t-test
            if typeEffectsAll>0
                differencesData{1}=DATA{1}-DATA{2};
                relativeDifferencesData{1}=100*(DATA{1}-DATA{2})./DATA{2};

                posthoc{1}.differences.continuum{1,comp}=differencesData{1};
                posthoc{1}.differences.continuumRelative{1,comp}=relativeDifferencesData{1};

                Ttest=spm1d.stats.nonparam.ttest_paired(DATA{1},DATA{2});
                posthoc{1}.tTests.type{comp}='paired';
                [posthoc{1}.differences.ES{comp},posthoc{1}.differences.ESsd{comp}]=esCalculation(DATA);

            else

                % differences
                differencesData{1}=mean(DATA{1})-mean(DATA{2});
                relativeDifferencesData{1}=100*(mean(DATA{1})-mean(DATA{2}))./mean(DATA{2});

                posthoc{1}.differences.continuum{1,comp}=differencesData{1};
                posthoc{1}.differences.continuumRelative{1,comp}=relativeDifferencesData{1};

                Ttest=spm1d.stats.nonparam.ttest2(DATA{1},DATA{2});
                posthoc{1}.tTests.type{comp}='independant';
                [posthoc{1}.differences.ES{comp},posthoc{1}.differences.ESsd{comp}]=esCalculation(DATA);
            end


            % inference
            posthoc{1}.tTests.names=posthoc{1}.differences.names;
            [posthoc{1}.tTests.nWarning{comp},permutations,alpha]=fctWarningPermutations(Ttest,pBonferroni,multiPerm,maximalPerm,Perm);
            posthoc{1}.tTests.alpha=alphaT;
            if warnT==1
                posthoc{1}.tTests.warning="alpha is not valid";
            end
            posthoc{1}.tTests.pBonferroni=pBonferroni;
            posthoc{1}.tTests.pCritical{comp}=alpha;
            posthoc{1}.tTests.nPermutations{comp}=permutations;
            Ttest_inf=Ttest.inference(alpha,'iterations',permutations,'force_iterations',logical(1),'two_tailed',logical(1));
            posthoc{1}.tTests.maxPermutations{comp}=Ttest_inf.nPermUnique;
            posthoc{1}.tTests.Tthreshold{comp}=Ttest_inf.zstar;
            posthoc{1}.tTests.Tsignificant{1,comp}=zeros(dimensions(1),dimensions(2));
            posthoc{1}.tTests.Tcontinuum{1,comp}=reshape(Ttest_inf.z,dimensions(1),dimensions(2));
            mapLogical=abs(posthoc{1}.tTests.Tcontinuum{1,comp})>=posthoc{1}.tTests.Tthreshold{comp};
            posthoc{1}.tTests.Tsignificant{1,comp}(anovaEffects{1})=mapLogical(anovaEffects{1});
            clustersT=extractClusterData(Ttest_inf.clusters);
            for c=1:numel(clustersT)
                posthoc{1}.tTests.clusterLocation{comp}{c}=clustersT{c}.endpoints;
                posthoc{1}.tTests.clusterP{comp}(c)=clustersT{c}.P*nComp;
            end

            plotmean(differencesData,IC,xlab,ylab,Fs,xlimits,nx,[],[],imageFontSize,imageSize,transparancy1D,[],[],[],0,0)
            legend([posthoc{1}.differences.names{1,comp} ' - ' posthoc{1}.differences.names{2,comp}],'Location','eastoutside','box','off')
            print('-dtiff',imageResolution,[savedir 'DIFF/' verifSaveName([eNames{1} ' (' char(posthoc{1}.differences.names{1,comp}) ' - ' char(posthoc{1}.differences.names{2,comp}) ')'])])
            savefig([savedir '/FIG/DIFF/' verifSaveName([eNames{1} ' (' char(posthoc{1}.differences.names{1,comp}) ' - ' char(posthoc{1}.differences.names{2,comp}) ')'])])
            close

            plotmean(relativeDifferencesData,IC,xlab,'Differences (%)',Fs,xlimits,nx,[],[],imageFontSize,imageSize,transparancy1D,[],[],[],0,0)
            legend([posthoc{1}.differences.names{1,comp} ' - ' posthoc{1}.differences.names{2,comp}],'Location','eastoutside','box','off')
            print('-dtiff',imageResolution,[savedir 'DIFF/' verifSaveName([eNames{1} ' (' char(posthoc{1}.differences.names{1,comp}) ' - ' char(posthoc{1}.differences.names{2,comp}) ') %'])])
            savefig([savedir '/FIG/DIFF/' verifSaveName([eNames{1} ' (' char(posthoc{1}.differences.names{1,comp}) ' - ' char(posthoc{1}.differences.names{2,comp}) ') %'])])
            close

            % plot of SnPM analysis
            plotTtest(posthoc{1}.tTests.Tcontinuum{1,comp},posthoc{1}.tTests.Tthreshold{comp},posthoc{1}.tTests.Tsignificant{1,comp},Fs,xlab,ylab,ylimits,dimensions,nx,ny,xlimits,imageFontSize,imageSize)
            title([char(posthoc{1}.differences.names{1,comp}) ' - ' char(posthoc{1}.differences.names{2,comp})])
            print('-dtiff',imageResolution,[savedir 'SnPM/' verifSaveName([eNames{1} ' (' char(posthoc{1}.differences.names{1,comp}) ' - ' char(posthoc{1}.differences.names{2,comp}) ')'])])
            savefig([savedir '/FIG/SnPM/' verifSaveName([eNames{1} ' (' char(posthoc{1}.differences.names{1,comp}) ' - ' char(posthoc{1}.differences.names{2,comp}) ')'])])
            close

            %   ES
            plotES(posthoc{1}.differences.ES{comp},posthoc{1}.differences.ESsd{comp},posthoc{1}.tTests.Tsignificant{1,comp},Fs,xlab,nx,xlimits,imageFontSize,imageSize,transparancy1D,yLimitES)
            title([char(posthoc{1}.differences.names{1,comp}) ' - ' char(posthoc{1}.differences.names{2,comp})])
            print('-dtiff',imageResolution,[savedir 'ES/' verifSaveName([eNames{1} ' (' char(posthoc{1}.differences.names{1,comp}) ' - ' char(posthoc{1}.differences.names{2,comp}) ')'])])
            savefig([savedir '/FIG/ES/' verifSaveName([eNames{1} ' (' char(posthoc{1}.differences.names{1,comp}) ' - ' char(posthoc{1}.differences.names{2,comp}) ')'])])
            close

        end

        % full plot of means + SnPM
        if max(indicesEffects)>2 % no anova required
            plotmeanSnPM(posthoc{1}.data.continuum,posthoc{1}.tTests.Tcontinuum,posthoc{1}.tTests.Tsignificant,legendPlot,posthoc{1}.differences.names,IC,xlab,ylab,Fs,xlimits,nx,ny,clPlot,imageFontSize,imageSize,transparancy1D,ylimits,anovaEffects,eNames,ratioSnPM,SnPMPos,aovColor,xLine,yLine,xGrid,yGrid)
            print('-dtiff',imageResolution,[savedir verifSaveName(eNames{1}) ' + SnPM'])
            savefig([savedir '/FIG/' verifSaveName(eNames{1}) ' + SnPM'])
            close
        end

        plotmeanSnPM(posthoc{1}.data.continuum,posthoc{1}.tTests.Tcontinuum,posthoc{1}.tTests.Tsignificant,legendPlot,posthoc{1}.differences.names,IC,xlab,ylab,Fs,xlimits,nx,ny,clPlot,imageFontSize,imageSize,transparancy1D,ylimits,[],[],ratioSnPM,SnPMPos,aovColor,xLine,yLine,xGrid,yGrid)
        print('-dtiff',imageResolution,[savedir verifSaveName(eNames{1}) ' + SnPMnoAOV'])
        savefig([savedir '/FIG/' verifSaveName(eNames{1}) ' + SnPMnoAOV'])
        close

        if max(indicesEffects)>2 % no anova required
            plotmeanSnPMsub(posthoc{1}.data.continuum,posthoc{1}.tTests.Tcontinuum,posthoc{1}.tTests.Tsignificant,legendPlot,posthoc{1}.differences.names,IC,xlab,ylab,Fs,xlimits,nx,ny,clPlot,imageFontSize,imageSize,transparancy1D,ylimits,anovaEffects,eNames,ratioSnPM,SnPMPos,aovColor,xLine,yLine,xGrid,yGrid)
            print('-dtiff',imageResolution,[savedir verifSaveName(eNames{1}) ' + SnPMsub'])
            savefig([savedir '/FIG/' verifSaveName(eNames{1}) ' + SnPMsub'])
            close
        end

        plotmeanSnPMsub(posthoc{1}.data.continuum,posthoc{1}.tTests.Tcontinuum,posthoc{1}.tTests.Tsignificant,legendPlot,posthoc{1}.differences.names,IC,xlab,ylab,Fs,xlimits,nx,ny,clPlot,imageFontSize,imageSize,transparancy1D,ylimits,[],[],ratioSnPM,SnPMPos,aovColor,xLine,yLine,xGrid,yGrid)
        print('-dtiff',imageResolution,[savedir verifSaveName(eNames{1}) ' + SnPMsubNoAOV'])
        savefig([savedir '/FIG/' verifSaveName(eNames{1}) ' + SnPMsubNoAOV'])
        close

        clear comp combi DATA

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
            posthoc{mainEffect(1)}.name=eNames{mainEffect(1)};

            loop=0;
            for i=1:max(indicesEffects(:,mainEffect(1)))
                loop=loop+1;
                combi{loop}=i;
            end
            nCombi=size(combi,2);

            legendPlot=[];
            for i=1:nCombi
                meansData{i}=maps1d(indicesEffects(:,mainEffect(1))==combi{i}(1),:);
                meansData{i}=groupBysub(meansData{i},sub(indicesEffects(:,mainEffect(1))==combi{i}(1)));
                legendPlot=[legendPlot,{char(modalitiesAll{mainEffect(1)}(combi{i}(1)))}];
                posthoc{mainEffect(1)}.data.names{i}=[char(modalitiesAll{mainEffect(1)}(combi{i}(1)))];
            end


            % full plot of means
            clPlot=chooseCL(colorLine,lineStyle,mainEffect(1));
            plotmean(meansData,IC,xlab,ylab,Fs,xlimits,nx,ny,clPlot,imageFontSize,imageSize,transparancy1D,ylimits,xLine,yLine,xGrid,yGrid)
            legend(legendPlot,'Location','eastoutside','box','off')
            print('-dtiff',imageResolution,[savedir verifSaveName(eNames{mainEffect(1)}) '/' verifSaveName(eNames{mainEffect(1)})])
            savefig([savedir verifSaveName(eNames{mainEffect(1)}) '/FIG/' verifSaveName(eNames{mainEffect(1)})])
            close

            posthoc{mainEffect(1)}.data.continuum=meansData;
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
            pBonferroni=alphaT/nComp;

            for comp=1:nComp

                for i=1:2
                    % comparison + name
                    DATA{i}=maps1d(indicesEffects(:,mainEffect(1))==combi{Comp{comp}(i)}(1),:);
                    DATA{i}=groupBysub(DATA{i},sub(indicesEffects(:,mainEffect(1))==combi{Comp{comp}(i)}(1)));
                    posthoc{mainEffect(1)}.differences.names{i,comp}=[char(modalitiesAll{mainEffect(1)}(combi{Comp{comp}(i)}(1)))];
                end

                % t-test
                if typeEffectsAll(mainEffect)==1
                    differencesData{1}=DATA{1}-DATA{2};
                    relativeDifferencesData{1}=100*(DATA{1}-DATA{2})./DATA{2};

                    posthoc{mainEffect(1)}.differences.continuum{1,comp}=differencesData{1};
                    posthoc{mainEffect(1)}.differences.continuumRelative{1,comp}=relativeDifferencesData{1};

                    Ttest=spm1d.stats.nonparam.ttest_paired(DATA{1},DATA{2});
                    posthoc{mainEffect(1)}.tTests.type{comp}='paired';
                    [posthoc{mainEffect(1)}.differences.ES{comp},posthoc{mainEffect(1)}.differences.ESsd{comp}]=esCalculation(DATA);

                else

                    % differences
                    differencesData{1}=mean(DATA{1})-mean(DATA{2});
                    relativeDifferencesData{1}=100*(mean(DATA{1})-mean(DATA{2}))./mean(DATA{2});

                    posthoc{mainEffect(1)}.differences.continuum{1,comp}=differencesData{1};
                    posthoc{mainEffect(1)}.differences.continuumRelative{1,comp}=relativeDifferencesData{1};

                    Ttest=spm1d.stats.nonparam.ttest2(DATA{1},DATA{2});
                    posthoc{mainEffect(1)}.tTests.type{comp}='independant';
                    [posthoc{mainEffect(1)}.differences.ES{comp},posthoc{mainEffect(1)}.differences.ESsd{comp}]=esCalculation(DATA);
                end

                plotmean(differencesData,IC,xlab,ylab,Fs,xlimits,nx,[],[],imageFontSize,imageSize,transparancy1D,[],[],[],0,0)
                legend([posthoc{mainEffect(1)}.differences.names{1,comp} ' - ' posthoc{mainEffect(1)}.differences.names{2,comp}],'Location','eastoutside','box','off')
                print('-dtiff',imageResolution,[savedir verifSaveName(eNames{mainEffect(1)}) '/DIFF/'  verifSaveName([char(posthoc{mainEffect(1)}.differences.names{1,comp}) ' - ' char(posthoc{mainEffect(1)}.differences.names{2,comp})])])
                savefig([savedir verifSaveName(eNames{mainEffect(1)}) '/FIG/DIFF/'  verifSaveName([char(posthoc{mainEffect(1)}.differences.names{1,comp}) ' - ' char(posthoc{mainEffect(1)}.differences.names{2,comp})])])
                close

                plotmean(relativeDifferencesData,IC,xlab,'Differences (%)',Fs,xlimits,nx,[],[],imageFontSize,imageSize,transparancy1D,[],[],[],0,0)
                legend([posthoc{mainEffect(1)}.differences.names{1,comp} ' - ' posthoc{mainEffect(1)}.differences.names{2,comp}],'Location','eastoutside','box','off')
                savefig([savedir verifSaveName(eNames{mainEffect(1)}) '/FIG/DIFF/'  verifSaveName([char(posthoc{mainEffect(1)}.differences.names{1,comp}) ' - ' char(posthoc{mainEffect(1)}.differences.names{2,comp})]) '%'])
                print('-dtiff',imageResolution,[savedir verifSaveName(eNames{mainEffect(1)}) '/DIFF/'  verifSaveName([char(posthoc{mainEffect(1)}.differences.names{1,comp}) ' - ' char(posthoc{mainEffect(1)}.differences.names{2,comp})]) ' %'])
                close

                % inference
                posthoc{mainEffect(1)}.tTests.names=posthoc{mainEffect(1)}.differences.names;
                [posthoc{mainEffect(1)}.tTests.nWarning{comp},permutations,alpha]=fctWarningPermutations(Ttest,pBonferroni,multiPerm,maximalPerm,Perm);
                posthoc{mainEffect(1)}.tTests.alpha=alphaT;
                if warnT==1
                    posthoc{mainEffect(1)}.tTests.warning="alpha is not valid";
                end
                posthoc{mainEffect(1)}.tTests.pBonferroni=pBonferroni;
                posthoc{mainEffect(1)}.tTests.pCritical{comp}=alpha;
                posthoc{mainEffect(1)}.tTests.nPermutations{comp}=permutations;
                Ttest_inf=Ttest.inference(alpha,'iterations',permutations,'force_iterations',logical(1),'two_tailed',logical(1));
                posthoc{mainEffect(1)}.tTests.maxPermutations{comp}=Ttest_inf.nPermUnique;
                posthoc{mainEffect(1)}.tTests.Tthreshold{comp}=Ttest_inf.zstar;
                posthoc{mainEffect(1)}.tTests.Tsignificant{1,comp}=zeros(dimensions(1),dimensions(2));
                posthoc{mainEffect(1)}.tTests.Tcontinuum{1,comp}=reshape(Ttest_inf.z,dimensions(1),dimensions(2));
                mapLogical=abs(posthoc{mainEffect(1)}.tTests.Tcontinuum{1,comp})>=posthoc{mainEffect(1)}.tTests.Tthreshold{comp};
                posthoc{mainEffect(1)}.tTests.Tsignificant{1,comp}(anovaEffects{mainEffect})=mapLogical(anovaEffects{mainEffect});
                clustersT=extractClusterData(Ttest_inf.clusters);
                for c=1:numel(clustersT)
                    posthoc{mainEffect(1)}.tTests.clusterLocation{comp}{c}=clustersT{c}.endpoints;
                    posthoc{mainEffect(1)}.tTests.clusterP{comp}(c)=clustersT{c}.P*nComp;
                end
                % plot of SnPM analysis
                plotTtest(posthoc{mainEffect(1)}.tTests.Tcontinuum{1,comp},posthoc{mainEffect(1)}.tTests.Tthreshold{comp},posthoc{mainEffect(1)}.tTests.Tsignificant{1,comp},Fs,xlab,ylab,ylimits,dimensions,nx,ny,xlimits,imageFontSize,imageSize)
                title([char(posthoc{mainEffect(1)}.differences.names{1,comp}) ' - ' char(posthoc{mainEffect(1)}.differences.names{2,comp})])
                savefig([savedir verifSaveName(eNames{mainEffect(1)}) '/FIG/SnPM/'  verifSaveName([char(posthoc{mainEffect(1)}.differences.names{1,comp}) ' - ' char(posthoc{mainEffect(1)}.differences.names{2,comp})])])
                print('-dtiff',imageResolution,[savedir verifSaveName(eNames{mainEffect(1)}) '/SnPM/'  verifSaveName([char(posthoc{mainEffect(1)}.differences.names{1,comp}) ' - ' char(posthoc{mainEffect(1)}.differences.names{2,comp})])])
                close

                %  ES
                plotES(posthoc{mainEffect(1)}.differences.ES{comp},posthoc{mainEffect(1)}.differences.ESsd{comp},posthoc{mainEffect(1)}.tTests.Tsignificant{1,comp},Fs,xlab,nx,xlimits,imageFontSize,imageSize,transparancy1D,yLimitES)
                title([char(posthoc{mainEffect(1)}.differences.names{1,comp}) ' - ' char(posthoc{mainEffect(1)}.differences.names{2,comp})])
                savefig([savedir verifSaveName(eNames{mainEffect(1)}) '/FIG/ES/'  verifSaveName([char(posthoc{mainEffect(1)}.differences.names{1,comp}) ' - ' char(posthoc{mainEffect(1)}.differences.names{2,comp})])])
                print('-dtiff',imageResolution,[savedir verifSaveName(eNames{mainEffect(1)}) '/ES/'  verifSaveName([char(posthoc{mainEffect(1)}.differences.names{1,comp}) ' - ' char(posthoc{mainEffect(1)}.differences.names{2,comp})])])
                close

            end

            % full plot of means + SnPM
            plotmeanSnPM(posthoc{mainEffect(1)}.data.continuum,posthoc{mainEffect(1)}.tTests.Tcontinuum,posthoc{mainEffect(1)}.tTests.Tsignificant,legendPlot,posthoc{mainEffect(1)}.differences.names,IC,xlab,ylab,Fs,xlimits,nx,ny,clPlot,imageFontSize,imageSize,transparancy1D,ylimits,anovaEffects(mainEffect),eNames(mainEffect),ratioSnPM,SnPMPos,aovColor,xLine,yLine,xGrid,yGrid)
            print('-dtiff',imageResolution,[savedir verifSaveName(eNames{mainEffect(1)}) '/' verifSaveName(eNames{mainEffect(1)}) ' + SnPM'])
            savefig([savedir verifSaveName(eNames{mainEffect(1)}) '/FIG/' verifSaveName(eNames{mainEffect(1)}) ' + SnPM'])
            close

            plotmeanSnPM(posthoc{mainEffect(1)}.data.continuum,posthoc{mainEffect(1)}.tTests.Tcontinuum,posthoc{mainEffect(1)}.tTests.Tsignificant,legendPlot,posthoc{mainEffect(1)}.differences.names,IC,xlab,ylab,Fs,xlimits,nx,ny,clPlot,imageFontSize,imageSize,transparancy1D,ylimits,[],[],ratioSnPM,SnPMPos,aovColor,xLine,yLine,xGrid,yGrid)
            print('-dtiff',imageResolution,[savedir verifSaveName(eNames{mainEffect(1)}) '/' verifSaveName(eNames{mainEffect(1)}) ' + SnPMnoAOV'])
            savefig([savedir verifSaveName(eNames{mainEffect(1)}) '/FIG/' verifSaveName(eNames{mainEffect(1)}) ' + SnPMnoAOV'])
            close

            plotmeanSnPMsub(posthoc{mainEffect(1)}.data.continuum,posthoc{mainEffect(1)}.tTests.Tcontinuum,posthoc{mainEffect(1)}.tTests.Tsignificant,legendPlot,posthoc{mainEffect(1)}.differences.names,IC,xlab,ylab,Fs,xlimits,nx,ny,clPlot,imageFontSize,imageSize,transparancy1D,ylimits,anovaEffects(mainEffect),eNames(mainEffect),ratioSnPM,SnPMPos,aovColor,xLine,yLine,xGrid,yGrid)
            print('-dtiff',imageResolution,[savedir verifSaveName(eNames{mainEffect(1)}) '/' verifSaveName(eNames{mainEffect(1)}) ' + SnPMsub'])
            savefig([savedir verifSaveName(eNames{mainEffect(1)}) '/FIG/' verifSaveName(eNames{mainEffect(1)}) ' + SnPMsub'])
            close

            plotmeanSnPMsub(posthoc{mainEffect(1)}.data.continuum,posthoc{mainEffect(1)}.tTests.Tcontinuum,posthoc{mainEffect(1)}.tTests.Tsignificant,legendPlot,posthoc{mainEffect(1)}.differences.names,IC,xlab,ylab,Fs,xlimits,nx,ny,clPlot,imageFontSize,imageSize,transparancy1D,ylimits,[],[],ratioSnPM,SnPMPos,aovColor,xLine,yLine,xGrid,yGrid)
            print('-dtiff',imageResolution,[savedir verifSaveName(eNames{mainEffect(1)}) '/' verifSaveName(eNames{mainEffect(1)}) ' + SnPMsubNoAOV'])
            savefig([savedir verifSaveName(eNames{mainEffect(1)}) '/FIG/' verifSaveName(eNames{mainEffect(1)}) ' + SnPMsubNoAOV'])
            close

            mainForInteraction{mainEffect}=posthoc{mainEffect(1)}.tTests.Tsignificant;
            clear Comp combi legendPlot DATA

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
            posthoc{mainEffect(1)}.name=eNames{mainEffect(1)};

            loop=0;
            for i=1:max(indicesEffects(:,mainEffect(1)))
                loop=loop+1;
                combi{loop}=i;
            end
            nCombi=size(combi,2);

            legendPlot=[];
            for i=1:nCombi
                meansData{i}=maps1d(indicesEffects(:,mainEffect(1))==combi{i}(1),:);
                meansData{i}=groupBysub(meansData{i},sub(indicesEffects(:,mainEffect(1))==combi{i}(1),:));
                legendPlot=[legendPlot,{char(modalitiesAll{mainEffect(1)}(combi{i}(1)))}];
                posthoc{mainEffect(1)}.data.names{i}=[char(modalitiesAll{mainEffect(1)}(combi{i}(1)))];
            end

            % full plot of means
            clPlot=chooseCL(colorLine,lineStyle,mainEffect(1));
            plotmean(meansData,IC,xlab,ylab,Fs,xlimits,nx,ny,clPlot,imageFontSize,imageSize,transparancy1D,ylimits,xLine,yLine,xGrid,yGrid)
            legend(legendPlot,'Location','eastoutside','box','off')
            print('-dtiff',imageResolution,[savedir verifSaveName(eNames{mainEffect(1)}) '/' verifSaveName(eNames{mainEffect(1)})])
            savefig([savedir verifSaveName(eNames{mainEffect(1)}) '/FIG/' verifSaveName(eNames{mainEffect(1)})])
            close

            posthoc{mainEffect(1)}.data.continuum=meansData;
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
            pBonferroni=alphaT/nComp;

            for comp=1:nComp

                for i=1:2
                    % comparison + name
                    DATA{i}=maps1d(indicesEffects(:,mainEffect(1))==combi{Comp{comp}(i)}(1),:);
                    DATA{i}=groupBysub(DATA{i},sub(indicesEffects(:,mainEffect(1))==combi{Comp{comp}(i)}(1),:));
                    posthoc{mainEffect(1)}.differences.names{i,comp}=[char(modalitiesAll{mainEffect(1)}(combi{Comp{comp}(i)}(1)))];
                end


                %t-test
                if typeEffectsAll(mainEffect)==1
                    differencesData{1}=DATA{1}-DATA{2};
                    relativeDifferencesData{1}=100*(DATA{1}-DATA{2})./DATA{2};

                    posthoc{mainEffect(1)}.differences.continuum{1,comp}=differencesData{1};
                    posthoc{mainEffect(1)}.differences.continuumRelative{1,comp}=relativeDifferencesData{1};

                    Ttest=spm1d.stats.nonparam.ttest_paired(DATA{1},DATA{2});
                    posthoc{mainEffect(1)}.tTests.type{comp}='paired';
                    [posthoc{mainEffect(1)}.differences.ES{comp},posthoc{mainEffect(1)}.differences.ESsd{comp}]=esCalculation(DATA);

                else

                    % differences
                    differencesData{1}=mean(DATA{1})-mean(DATA{2});
                    relativeDifferencesData{1}=100*(mean(DATA{1})-mean(DATA{2}))./mean(DATA{2});

                    posthoc{mainEffect(1)}.differences.continuum{1,comp}=differencesData{1};
                    posthoc{mainEffect(1)}.differences.continuumRelative{1,comp}=relativeDifferencesData{1};

                    Ttest=spm1d.stats.nonparam.ttest2(DATA{1},DATA{2});
                    posthoc{mainEffect(1)}.tTests.type{comp}='independant';
                    [posthoc{mainEffect(1)}.differences.ES{comp},posthoc{mainEffect(1)}.differences.ESsd{comp}]=esCalculation(DATA);
                end

                plotmean(differencesData,IC,xlab,ylab,Fs,xlimits,nx,[],[],imageFontSize,imageSize,transparancy1D,[],[],[],0,0)
                legend([posthoc{mainEffect(1)}.differences.names{1,comp} ' - ' posthoc{mainEffect(1)}.differences.names{2,comp}],'Location','eastoutside','box','off')
                savefig([savedir verifSaveName(eNames{mainEffect(1)}) '/FIG/DIFF/'  verifSaveName([char(posthoc{mainEffect(1)}.differences.names{1,comp}) ' - ' char(posthoc{mainEffect(1)}.differences.names{2,comp})])])
                print('-dtiff',imageResolution,[savedir verifSaveName(eNames{mainEffect(1)}) '/DIFF/'  verifSaveName([char(posthoc{mainEffect(1)}.differences.names{1,comp}) ' - ' char(posthoc{mainEffect(1)}.differences.names{2,comp})])])
                close

                plotmean(relativeDifferencesData,IC,xlab,'Differences (%)',Fs,xlimits,nx,[],[],imageFontSize,imageSize,transparancy1D,[],[],[],0,0)
                legend([posthoc{mainEffect(1)}.differences.names{1,comp} ' - ' posthoc{mainEffect(1)}.differences.names{2,comp}],'Location','eastoutside','box','off')
                savefig([savedir verifSaveName(eNames{mainEffect(1)}) '/FIG/DIFF/'  verifSaveName([char(posthoc{mainEffect(1)}.differences.names{1,comp}) ' - ' char(posthoc{mainEffect(1)}.differences.names{2,comp})]) '%'])
                print('-dtiff',imageResolution,[savedir verifSaveName(eNames{mainEffect(1)}) '/DIFF/'  verifSaveName([char(posthoc{mainEffect(1)}.differences.names{1,comp}) ' - ' char(posthoc{mainEffect(1)}.differences.names{2,comp})]) ' %'])
                close


                % inference
                posthoc{mainEffect(1)}.tTests.names=posthoc{mainEffect(1)}.differences.names;
                [posthoc{mainEffect(1)}.tTests.nWarning{comp},permutations,alpha]=fctWarningPermutations(Ttest,pBonferroni,multiPerm,maximalPerm,Perm);
                posthoc{mainEffect(1)}.tTests.alpha=alphaT;
                if warnT==1
                    posthoc{mainEffect(1)}.tTests.warning="alpha is not valid";
                end
                posthoc{mainEffect(1)}.tTests.pBonferroni=pBonferroni;
                posthoc{mainEffect(1)}.tTests.pCritical{comp}=alpha;
                posthoc{mainEffect(1)}.tTests.nPermutations{comp}=permutations;
                Ttest_inf=Ttest.inference(alpha,'iterations',permutations,'force_iterations',logical(1),'two_tailed',logical(1));
                posthoc{mainEffect(1)}.tTests.maxPermutations{comp}=Ttest_inf.nPermUnique;
                posthoc{mainEffect(1)}.tTests.Tthreshold{comp}=Ttest_inf.zstar;
                posthoc{mainEffect(1)}.tTests.Tsignificant{1,comp}=zeros(dimensions(1),dimensions(2));
                posthoc{mainEffect(1)}.tTests.Tcontinuum{1,comp}=reshape(Ttest_inf.z,dimensions(1),dimensions(2));
                mapLogical=abs(posthoc{mainEffect(1)}.tTests.Tcontinuum{1,comp})>=posthoc{mainEffect(1)}.tTests.Tthreshold{comp};
                posthoc{mainEffect(1)}.tTests.Tsignificant{1,comp}(anovaEffects{mainEffect})=mapLogical(anovaEffects{mainEffect});
                clustersT=extractClusterData(Ttest_inf.clusters);
                for c=1:numel(clustersT)
                    posthoc{mainEffect(1)}.tTests.clusterLocation{comp}{c}=clustersT{c}.endpoints;
                    posthoc{mainEffect(1)}.tTests.clusterP{comp}(c)=clustersT{c}.P*nComp;
                end


                % plot of SnPM analysis
                plotTtest(posthoc{mainEffect(1)}.tTests.Tcontinuum{1,comp},posthoc{mainEffect(1)}.tTests.Tthreshold{comp},posthoc{mainEffect(1)}.tTests.Tsignificant{1,comp},Fs,xlab,ylab,ylimits,dimensions,nx,ny,xlimits,imageFontSize,imageSize)
                title(strrep([char(posthoc{mainEffect(1)}.differences.names{1,comp}) ' - ' char(posthoc{mainEffect(1)}.differences.names{2,comp})],' x ',' \cap '))
                savefig([savedir verifSaveName(eNames{mainEffect(1)}) '/FIG/SnPM/'  verifSaveName([char(posthoc{mainEffect(1)}.differences.names{1,comp}) ' - ' char(posthoc{mainEffect(1)}.differences.names{2,comp})])])
                print('-dtiff',imageResolution,[savedir verifSaveName(eNames{mainEffect(1)}) '/SnPM/'  verifSaveName([char(posthoc{mainEffect(1)}.differences.names{1,comp}) ' - ' char(posthoc{mainEffect(1)}.differences.names{2,comp})])])
                close

                % ES
                plotES(posthoc{mainEffect(1)}.differences.ES{comp},posthoc{mainEffect(1)}.differences.ESsd{comp},posthoc{mainEffect(1)}.tTests.Tsignificant{1,comp},Fs,xlab,nx,xlimits,imageFontSize,imageSize,transparancy1D,yLimitES)
                title(strrep([char(posthoc{mainEffect(1)}.differences.names{1,comp}) ' - ' char(posthoc{mainEffect(1)}.differences.names{2,comp})],' x ',' \cap '))
                savefig([savedir verifSaveName(eNames{mainEffect(1)}) '/FIG/ES/'  verifSaveName([char(posthoc{mainEffect(1)}.differences.names{1,comp}) ' - ' char(posthoc{mainEffect(1)}.differences.names{2,comp})])])
                print('-dtiff',imageResolution,[savedir verifSaveName(eNames{mainEffect(1)}) '/ES/'  verifSaveName([char(posthoc{mainEffect(1)}.differences.names{1,comp}) ' - ' char(posthoc{mainEffect(1)}.differences.names{2,comp})])])
                close

            end

            % full plot of means + SnPM
            plotmeanSnPM(posthoc{mainEffect(1)}.data.continuum,posthoc{mainEffect(1)}.tTests.Tcontinuum,posthoc{mainEffect(1)}.tTests.Tsignificant,legendPlot,posthoc{mainEffect(1)}.differences.names,IC,xlab,ylab,Fs,xlimits,nx,ny,clPlot,imageFontSize,imageSize,transparancy1D,ylimits,anovaEffects(mainEffect(1)),eNames(mainEffect(1)),ratioSnPM,SnPMPos,aovColor,xLine,yLine,xGrid,yGrid)
            print('-dtiff',imageResolution,[savedir verifSaveName(eNames{mainEffect(1)}) '/' verifSaveName(eNames{mainEffect(1)}) ' + SnPM'])
            savefig([savedir verifSaveName(eNames{mainEffect(1)}) '/FIG/' verifSaveName(eNames{mainEffect(1)}) ' + SnPM'])
            close

            plotmeanSnPM(posthoc{mainEffect(1)}.data.continuum,posthoc{mainEffect(1)}.tTests.Tcontinuum,posthoc{mainEffect(1)}.tTests.Tsignificant,legendPlot,posthoc{mainEffect(1)}.differences.names,IC,xlab,ylab,Fs,xlimits,nx,ny,clPlot,imageFontSize,imageSize,transparancy1D,ylimits,[],[],ratioSnPM,SnPMPos,aovColor,xLine,yLine,xGrid,yGrid)
            print('-dtiff',imageResolution,[savedir verifSaveName(eNames{mainEffect(1)}) '/' verifSaveName(eNames{mainEffect(1)}) ' + SnPMnoAOV'])
            savefig([savedir verifSaveName(eNames{mainEffect(1)}) '/FIG/' verifSaveName(eNames{mainEffect(1)}) ' + SnPMnoAOV'])
            close

            plotmeanSnPMsub(posthoc{mainEffect(1)}.data.continuum,posthoc{mainEffect(1)}.tTests.Tcontinuum,posthoc{mainEffect(1)}.tTests.Tsignificant,legendPlot,posthoc{mainEffect(1)}.differences.names,IC,xlab,ylab,Fs,xlimits,nx,ny,clPlot,imageFontSize,imageSize,transparancy1D,ylimits,anovaEffects(mainEffect(1)),eNames(mainEffect(1)),ratioSnPM,SnPMPos,aovColor,xLine,yLine,xGrid,yGrid)
            print('-dtiff',imageResolution,[savedir verifSaveName(eNames{mainEffect(1)}) '/' verifSaveName(eNames{mainEffect(1)}) ' + SnPMsub'])
            savefig([savedir verifSaveName(eNames{mainEffect(1)}) '/FIG/' verifSaveName(eNames{mainEffect(1)}) ' + SnPMsub'])
            close

            plotmeanSnPMsub(posthoc{mainEffect(1)}.data.continuum,posthoc{mainEffect(1)}.tTests.Tcontinuum,posthoc{mainEffect(1)}.tTests.Tsignificant,legendPlot,posthoc{mainEffect(1)}.differences.names,IC,xlab,ylab,Fs,xlimits,nx,ny,clPlot,imageFontSize,imageSize,transparancy1D,ylimits,[],[],ratioSnPM,SnPMPos,aovColor,xLine,yLine,xGrid,yGrid)
            print('-dtiff',imageResolution,[savedir verifSaveName(eNames{mainEffect(1)}) '/' verifSaveName(eNames{mainEffect(1)}) ' + SnPMsubNoAOV'])
            savefig([savedir verifSaveName(eNames{mainEffect(1)}) '/FIG/' verifSaveName(eNames{mainEffect(1)}) ' + SnPMsubNoAOV'])
            close

            mainForInteraction{mainEffect}=posthoc{mainEffect(1)}.tTests.Tsignificant;
            clear Comp combi legendPlot DATA

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

            posthoc{3+anovaFixedCorr(fixedEffect)}.name=[eNames{mainEffect(1)} ' x ' eNames{mainEffect(2)}];

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
                meansData{i}=groupBysub(meansData{i},sub(indicesEffects(:,mainEffect(1))==combi{i}(1) & indicesEffects(:,mainEffect(2))==combi{i}(2),:));
                legendPlot=[legendPlot,{[char(modalitiesAll{mainEffect(1)}(combi{i}(1))) ' \cap ' char(modalitiesAll{mainEffect(2)}(combi{i}(2)))]}];
                posthoc{3+anovaFixedCorr(fixedEffect)}.data.names{i}=[char(modalitiesAll{mainEffect(1)}(combi{i}(1))) ' \cap ' char(modalitiesAll{mainEffect(2)}(combi{i}(2)))];
            end

            % full plot of means
            [nPlot,whichPlot,whichFixed,whichModal]=findNPlot(combi);
            for p=1:nPlot
                clPlot=chooseCL(colorLine,lineStyle,mainEffect(whichFixed(2,p)));
                plotmean(meansData(whichPlot{p}),IC,xlab,ylab,Fs,xlimits,nx,ny,clPlot,imageFontSize,imageSize,transparancy1D,ylimits,xLine,yLine,xGrid,yGrid)
                legend(legendPlot(whichPlot{p}),'Location','eastoutside','box','off')
                print('-dtiff',imageResolution,[savedir verifSaveName([eNames{mainEffect(1)} ' x ' eNames{mainEffect(2)}]) '/' verifSaveName(eNames{mainEffect(whichFixed(2,p))}) '/' verifSaveName(modalitiesAll{mainEffect(whichFixed(1,p))}{whichModal(p)})])
                savefig([savedir verifSaveName([eNames{mainEffect(1)} ' x ' eNames{mainEffect(2)}]) '/' verifSaveName(eNames{mainEffect(whichFixed(2,p))}) '/FIG/' verifSaveName(modalitiesAll{mainEffect(whichFixed(1,p))}{whichModal(p)})])
                close
            end

            posthoc{3+anovaFixedCorr(fixedEffect)}.data.continuum=meansData;
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
            pBonferroni=alphaT/nComp;

            for comp=1:nComp

                for i=1:2
                    % comparison + name
                    DATA{i}=maps1d(indicesEffects(:,mainEffect(1))==combi{Comp{comp}(i)}(1) & indicesEffects(:,mainEffect(2))==combi{Comp{comp}(i)}(2),:);
                    DATA{i}=groupBysub(DATA{i},sub(indicesEffects(:,mainEffect(1))==combi{Comp{comp}(i)}(1) & indicesEffects(:,mainEffect(2))==combi{Comp{comp}(i)}(2),:));

                    intForInteractions{anovaFixedCorr(effectFixed)}.comp{comp}(i,:)=combi{Comp{comp}(i)};
                end
                [eFixed,eTested,modalFixed,modalTested]=findWhichTitle([combi{Comp{comp}(1)};combi{Comp{comp}(2)}]);
                posthoc{3+anovaFixedCorr(fixedEffect)}.differences.names{comp}=char([modalitiesAll{mainEffect(eFixed)}{modalFixed} ' (' modalitiesAll{mainEffect(eTested)}{modalTested(1)} ' - ' modalitiesAll{mainEffect(eTested)}{modalTested(2)} ')']);


                % t-test
                if typeEffectsAll(mainEffect(eTested))==1
                    differencesData{1}=DATA{1}-DATA{2};
                    relativeDifferencesData{1}=100*(DATA{1}-DATA{2})./DATA{2};

                    posthoc{3+anovaFixedCorr(fixedEffect)}.differences.continuum{1,comp}=differencesData{1};
                    posthoc{3+anovaFixedCorr(fixedEffect)}.differences.continuumRelative{1,comp}=relativeDifferencesData{1};

                    Ttest=spm1d.stats.nonparam.ttest_paired(DATA{1},DATA{2});
                    posthoc{3+anovaFixedCorr(fixedEffect)}.tTests.type{comp}='paired';
                    [posthoc{3+anovaFixedCorr(fixedEffect)}.differences.ES{comp},posthoc{3+anovaFixedCorr(fixedEffect)}.differences.ESsd{comp}]=esCalculation(DATA);

                else

                    % differences
                    differencesData{1}=mean(DATA{1})-mean(DATA{2});
                    relativeDifferencesData{1}=100*(mean(DATA{1})-mean(DATA{2}))./mean(DATA{2});

                    posthoc{3+anovaFixedCorr(fixedEffect)}.differences.continuum{1,comp}=differencesData{1};
                    posthoc{3+anovaFixedCorr(fixedEffect)}.differences.continuumRelative{1,comp}=relativeDifferencesData{1};

                    Ttest=spm1d.stats.nonparam.ttest2(DATA{1},DATA{2});
                    posthoc{3+anovaFixedCorr(fixedEffect)}.tTests.type{comp}='independant';
                    [posthoc{3+anovaFixedCorr(fixedEffect)}.differences.ES{comp},posthoc{3+anovaFixedCorr(fixedEffect)}.differences.ESsd{comp}]=esCalculation(DATA);
                end

                plotmean(differencesData,IC,xlab,ylab,Fs,xlimits,nx,[],[],imageFontSize,imageSize,transparancy1D,[],[],[],0,0)
                legend([posthoc{3+anovaFixedCorr(fixedEffect)}.differences.names{comp}],'Location','eastoutside','box','off')
                savefig([savedir verifSaveName([eNames{mainEffect(1)} ' x ' eNames{mainEffect(2)}]) '/' verifSaveName(eNames{mainEffect(eTested)}) '/FIG/DIFF/' verifSaveName(posthoc{3+anovaFixedCorr(fixedEffect)}.differences.names{comp})])
                print('-dtiff',imageResolution,[savedir verifSaveName([eNames{mainEffect(1)} ' x ' eNames{mainEffect(2)}]) '/' verifSaveName(eNames{mainEffect(eTested)}) '/DIFF/' verifSaveName(posthoc{3+anovaFixedCorr(fixedEffect)}.differences.names{comp})])
                close

                plotmean(relativeDifferencesData,IC,xlab,'Differences (%)',Fs,xlimits,nx,[],[],imageFontSize,imageSize,transparancy1D,[],[],[],0,0)
                legend([posthoc{3+anovaFixedCorr(fixedEffect)}.differences.names{comp}],'Location','eastoutside','box','off')
                savefig([savedir verifSaveName([eNames{mainEffect(1)} ' x ' eNames{mainEffect(2)}]) '/' verifSaveName(eNames{mainEffect(eTested)}) '/FIG/DIFF/' verifSaveName(posthoc{3+anovaFixedCorr(fixedEffect)}.differences.names{comp}) '%'])
                print('-dtiff',imageResolution,[savedir verifSaveName([eNames{mainEffect(1)} ' x ' eNames{mainEffect(2)}]) '/' verifSaveName(eNames{mainEffect(eTested)}) '/DIFF/' verifSaveName(posthoc{3+anovaFixedCorr(fixedEffect)}.differences.names{comp}) ' %'])
                close

                % inference
                posthoc{3+anovaFixedCorr(fixedEffect)}.tTests.names=posthoc{3+anovaFixedCorr(fixedEffect)}.differences.names;
                [posthoc{3+anovaFixedCorr(fixedEffect)}.tTests.nWarning{comp},permutations,alpha]=fctWarningPermutations(Ttest,pBonferroni,multiPerm,maximalPerm,Perm);
                posthoc{3+anovaFixedCorr(fixedEffect)}.tTests.alpha=alphaT;
                if warnT==1
                    posthoc{3+anovaFixedCorr(fixedEffect)}.tTests.warning="alpha is not valid";
                end
                posthoc{3+anovaFixedCorr(fixedEffect)}.tTests.pBonferroni=pBonferroni;
                posthoc{3+anovaFixedCorr(fixedEffect)}.tTests.pCritical{comp}=alpha;
                posthoc{3+anovaFixedCorr(fixedEffect)}.tTests.nPermutations{comp}=permutations;
                Ttest_inf=Ttest.inference(alpha,'iterations',permutations,'force_iterations',logical(1),'two_tailed',logical(1));
                posthoc{3+anovaFixedCorr(fixedEffect)}.tTests.maxPermutations{comp}=Ttest_inf.nPermUnique;
                posthoc{3+anovaFixedCorr(fixedEffect)}.tTests.Tthreshold{comp}=Ttest_inf.zstar;
                posthoc{3+anovaFixedCorr(fixedEffect)}.tTests.Tsignificant{1,comp}=zeros(dimensions(1),dimensions(2));
                posthoc{3+anovaFixedCorr(fixedEffect)}.tTests.Tcontinuum{1,comp}=reshape(Ttest_inf.z,dimensions(1),dimensions(2));
                mapLogical=abs(posthoc{3+anovaFixedCorr(fixedEffect)}.tTests.Tcontinuum{1,comp})>=posthoc{3+anovaFixedCorr(fixedEffect)}.tTests.Tthreshold{comp};
                effectCorr=anovaEffects{3+anovaFixedCorr(fixedEffect)}(:);
                posthoc{3+anovaFixedCorr(fixedEffect)}.tTests.Tsignificant{1,comp}(effectCorr)=mapLogical(effectCorr);
                indiceMain=findWhichMain(modalitiesAll{mainEffect(testedEffect{comp})},combi{Comp{comp}(1)}(testedEffect{comp}),combi{Comp{comp}(2)}(testedEffect{comp}));
                tMainEffect=abs(mainForInteraction{mainEffect(testedEffect{comp})}{indiceMain})>0;
                tMainEffect(effectCorr==1)=0;
                realEffect{comp}=reshape(max([tMainEffect(:)';posthoc{3+anovaFixedCorr(fixedEffect)}.tTests.Tsignificant{1,comp}(:)']),dimensions(1),dimensions(2));
                posthoc{3+anovaFixedCorr(fixedEffect)}.tTests.Tsignificant{1,comp}=realEffect{comp};
                clustersT=extractClusterData(Ttest_inf.clusters);
                for c=1:numel(clustersT)
                    posthoc{3+anovaFixedCorr(fixedEffect)}.tTests.clusterLocation{comp}{c}=clustersT{c}.endpoints;
                    posthoc{3+anovaFixedCorr(fixedEffect)}.tTests.clusterP{comp}(c)=clustersT{c}.P*nComp;
                end

                % plot of SnPM analysis
                plotTtest(posthoc{3+anovaFixedCorr(fixedEffect)}.tTests.Tcontinuum{1,comp},posthoc{3+anovaFixedCorr(fixedEffect)}.tTests.Tthreshold{comp},posthoc{3+anovaFixedCorr(fixedEffect)}.tTests.Tsignificant{1,comp},Fs,xlab,ylab,ylimits,dimensions,nx,ny,xlimits,imageFontSize,imageSize)
                title(posthoc{3+anovaFixedCorr(fixedEffect)}.differences.names{comp})
                savefig([savedir verifSaveName([eNames{mainEffect(1)} ' x ' eNames{mainEffect(2)}]) '/' verifSaveName(eNames{mainEffect(eTested)}) '/FIG/SnPM/' verifSaveName(posthoc{3+anovaFixedCorr(fixedEffect)}.differences.names{comp})])
                print('-dtiff',imageResolution,[savedir verifSaveName([eNames{mainEffect(1)} ' x ' eNames{mainEffect(2)}]) '/' verifSaveName(eNames{mainEffect(eTested)}) '/SnPM/' verifSaveName(posthoc{3+anovaFixedCorr(fixedEffect)}.differences.names{comp})])
                close

                %   ES
                plotES(posthoc{3+anovaFixedCorr(fixedEffect)}.differences.ES{comp},posthoc{3+anovaFixedCorr(fixedEffect)}.differences.ESsd{comp},posthoc{3+anovaFixedCorr(fixedEffect)}.tTests.Tsignificant{1,comp},Fs,xlab,nx,xlimits,imageFontSize,imageSize,transparancy1D,yLimitES)
                title(posthoc{3+anovaFixedCorr(fixedEffect)}.differences.names{comp})
                savefig([savedir verifSaveName([eNames{mainEffect(1)} ' x ' eNames{mainEffect(2)}]) '/' verifSaveName(eNames{mainEffect(eTested)}) '/FIG/ES/' verifSaveName(posthoc{3+anovaFixedCorr(fixedEffect)}.differences.names{comp})])
                print('-dtiff',imageResolution,[savedir verifSaveName([eNames{mainEffect(1)} ' x ' eNames{mainEffect(2)}]) '/' verifSaveName(eNames{mainEffect(eTested)}) '/ES/' verifSaveName(posthoc{3+anovaFixedCorr(fixedEffect)}.differences.names{comp})])
                close

            end


            % full plot of means + SnPM
            for p=1:nPlot
                data4empty=posthoc{3+anovaFixedCorr(fixedEffect)}.data.continuum(whichPlot{p});
                for i=1:numel(whichPlot{p})
                    isEmptydata(i)=~isempty(data4empty{i});
                end

                for nC=1:numel(whichPlot{p})
                    findT(nC)=posthoc{3+anovaFixedCorr(fixedEffect)}.data.names(whichPlot{p}(nC));
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
                for nC=1:numel(posthoc{3+anovaFixedCorr(fixedEffect)}.differences.names)
                    nameCompare=[posthoc{3+anovaFixedCorr(fixedEffect)}.differences.names{nC} '___________________________'];
                    whichCompare(nC)=string([sameName ' '])==string(nameCompare(1:sizeSname+1));
                end

                clPlot=chooseCL(colorLine,lineStyle,mainEffect(whichFixed(2,p)));
                nAnova=whichAnova(mainEffect);

                plotmeanSnPM(posthoc{3+anovaFixedCorr(fixedEffect)}.data.continuum(whichPlot{p}),posthoc{3+anovaFixedCorr(fixedEffect)}.tTests.Tcontinuum(:,whichCompare),posthoc{3+anovaFixedCorr(fixedEffect)}.tTests.Tsignificant(:,whichCompare),legendPlot(whichPlot{p}),posthoc{3+anovaFixedCorr(fixedEffect)}.differences.names(whichCompare),IC,xlab,ylab,Fs,xlimits,nx,ny,clPlot,imageFontSize,imageSize,transparancy1D,ylimits,anovaEffects([mainEffect(whichFixed(2,p)), nAnova]),{eNames{mainEffect(whichFixed(2,p))},[eNames{mainEffect(1)} ' x ' eNames{mainEffect(2)}]},ratioSnPM,SnPMPos,aovColor,xLine,yLine,xGrid,yGrid)
                print('-dtiff',imageResolution,[savedir verifSaveName([eNames{mainEffect(1)} ' x ' eNames{mainEffect(2)}]) '/' verifSaveName(eNames{mainEffect(whichFixed(2,p))}) '/' verifSaveName(modalitiesAll{mainEffect(whichFixed(1,p))}{whichModal(p)}) ' + SnPM'])
                savefig([savedir verifSaveName([eNames{mainEffect(1)} ' x ' eNames{mainEffect(2)}]) '/' verifSaveName(eNames{mainEffect(whichFixed(2,p))}) '/FIG/' verifSaveName(modalitiesAll{mainEffect(whichFixed(1,p))}{whichModal(p)}) ' +SnPM'])
                close

                plotmeanSnPM(posthoc{3+anovaFixedCorr(fixedEffect)}.data.continuum(whichPlot{p}),posthoc{3+anovaFixedCorr(fixedEffect)}.tTests.Tcontinuum(:,whichCompare),posthoc{3+anovaFixedCorr(fixedEffect)}.tTests.Tsignificant(:,whichCompare),legendPlot(whichPlot{p}),posthoc{3+anovaFixedCorr(fixedEffect)}.differences.names(whichCompare),IC,xlab,ylab,Fs,xlimits,nx,ny,clPlot,imageFontSize,imageSize,transparancy1D,ylimits,[],[],ratioSnPM,SnPMPos,aovColor,xLine,yLine,xGrid,yGrid)
                print('-dtiff',imageResolution,[savedir verifSaveName([eNames{mainEffect(1)} ' x ' eNames{mainEffect(2)}]) '/' verifSaveName(eNames{mainEffect(whichFixed(2,p))}) '/' verifSaveName(modalitiesAll{mainEffect(whichFixed(1,p))}{whichModal(p)}) ' + SnPMnoAOV'])
                savefig([savedir verifSaveName([eNames{mainEffect(1)} ' x ' eNames{mainEffect(2)}]) '/' verifSaveName(eNames{mainEffect(whichFixed(2,p))}) '/FIG/' verifSaveName(modalitiesAll{mainEffect(whichFixed(1,p))}{whichModal(p)}) ' +SnPMnoAOV'])
                close

                plotmeanSnPMsub(posthoc{3+anovaFixedCorr(fixedEffect)}.data.continuum(whichPlot{p}),posthoc{3+anovaFixedCorr(fixedEffect)}.tTests.Tcontinuum(:,whichCompare),posthoc{3+anovaFixedCorr(fixedEffect)}.tTests.Tsignificant(:,whichCompare),legendPlot(whichPlot{p}),posthoc{3+anovaFixedCorr(fixedEffect)}.differences.names(whichCompare),IC,xlab,ylab,Fs,xlimits,nx,ny,clPlot,imageFontSize,imageSize,transparancy1D,ylimits,anovaEffects([mainEffect(whichFixed(2,p)), nAnova]),{eNames{mainEffect(whichFixed(2,p))},[eNames{mainEffect(1)} ' x ' eNames{mainEffect(2)}]},ratioSnPM,SnPMPos,aovColor,xLine,yLine,xGrid,yGrid)
                print('-dtiff',imageResolution,[savedir verifSaveName([eNames{mainEffect(1)} ' x ' eNames{mainEffect(2)}]) '/' verifSaveName(eNames{mainEffect(whichFixed(2,p))}) '/' verifSaveName(modalitiesAll{mainEffect(whichFixed(1,p))}{whichModal(p)}) ' + SnPMsub'])
                savefig([savedir verifSaveName([eNames{mainEffect(1)} ' x ' eNames{mainEffect(2)}]) '/' verifSaveName(eNames{mainEffect(whichFixed(2,p))}) '/FIG/' verifSaveName(modalitiesAll{mainEffect(whichFixed(1,p))}{whichModal(p)}) ' +SnPMsub'])
                close

                plotmeanSnPMsub(posthoc{3+anovaFixedCorr(fixedEffect)}.data.continuum(whichPlot{p}),posthoc{3+anovaFixedCorr(fixedEffect)}.tTests.Tcontinuum(:,whichCompare),posthoc{3+anovaFixedCorr(fixedEffect)}.tTests.Tsignificant(:,whichCompare),legendPlot(whichPlot{p}),posthoc{3+anovaFixedCorr(fixedEffect)}.differences.names(whichCompare),IC,xlab,ylab,Fs,xlimits,nx,ny,clPlot,imageFontSize,imageSize,transparancy1D,ylimits,[],[],ratioSnPM,SnPMPos,aovColor,xLine,yLine,xGrid,yGrid)
                print('-dtiff',imageResolution,[savedir verifSaveName([eNames{mainEffect(1)} ' x ' eNames{mainEffect(2)}]) '/' verifSaveName(eNames{mainEffect(whichFixed(2,p))}) '/' verifSaveName(modalitiesAll{mainEffect(whichFixed(1,p))}{whichModal(p)}) ' + SnPMsubNoAOV'])
                savefig([savedir verifSaveName([eNames{mainEffect(1)} ' x ' eNames{mainEffect(2)}]) '/' verifSaveName(eNames{mainEffect(whichFixed(2,p))}) '/FIG/' verifSaveName(modalitiesAll{mainEffect(whichFixed(1,p))}{whichModal(p)}) ' +SnPMsubNoAOV'])
                close

                clear isEmptydata findT capPos whichCompare

            end

            posthoc{3+anovaFixedCorr(fixedEffect)}.tTests.combi=combi;
            intForInteractions{anovaFixedCorr(effectFixed)}.t=realEffect;
            clear Comp combi legendPlot DATA

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
            pos=3;
            posthoc{pos}.name=[eNames{1} ' x ' eNames{2}];
        end
        figname =verifSaveName([eNames{1} ' x ' eNames{2}]);
    elseif nEffects==3
        isInteraction=max(anovaEffects{7});
        savedir2=[verifSaveName([eNames{1} ' x ' eNames{2} ' x ' eNames{3}]) '/'];
        if isInteraction==1 | doAllInteractions==1
            createSavedir([savedir savedir2 verifSaveName(eNames{1})])
            createSavedir([savedir savedir2 verifSaveName(eNames{2})])
            createSavedir([savedir savedir2 verifSaveName(eNames{3})])
            pos=7;
            posthoc{pos}.name=[eNames{1} ' x ' eNames{2} ' x ' eNames{3}];
        end
        figname=verifSaveName([eNames{1} ' x ' eNames{2} ' x ' eNames{3}]);
    end

    if isInteraction==1 | doAllInteractions==1

        loop=0;

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
                meansData{i}=groupBysub(meansData{i},sub(indicesEffects(:,1)==combi{i}(1) & indicesEffects(:,2)==combi{i}(2),:));
                legendPlot=[legendPlot,{[char(modalitiesAll{1}(combi{i}(1))) ' \cap ' char(modalitiesAll{2}(combi{i}(2)))]}];
                posthoc{pos}.data.names{i}=[char(modalitiesAll{1}(combi{i}(1))) ' \cap ' char(modalitiesAll{2}(combi{i}(2)))];
            end

            % full plot of means
            [nPlot,whichPlot,whichFixed,whichModal]=findNPlot(combi);
            for p=1:nPlot
                clPlot=chooseCL(colorLine,lineStyle,whichFixed(2,p));
                plotmean(meansData(whichPlot{p}),IC,xlab,ylab,Fs,xlimits,nx,ny,clPlot,imageFontSize,imageSize,transparancy1D,ylimits,xLine,yLine,xGrid,yGrid)
                data4empty=meansData(whichPlot{p});
                for i=1:numel(whichPlot{p})
                    isEmptydata(i)=~isempty(data4empty{i});
                end
                legend(legendPlot(whichPlot{p}(isEmptydata)),'Location','eastoutside','box','off')
                print('-dtiff',imageResolution,[savedir savedir2 verifSaveName(eNames{whichFixed(2,p)}) '/' verifSaveName(modalitiesAll{whichFixed(1,p)}{whichModal(1,p)})])
                savefig([savedir savedir2 verifSaveName(eNames{whichFixed(2,p)}) '/FIG/' verifSaveName(modalitiesAll{whichFixed(1,p)}{whichModal(1,p)})])
                close
                clear isEmptydata
            end

            posthoc{pos}.data.continuum=meansData;
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
                meansData{i}=groupBysub(meansData{i},sub(indicesEffects(:,1)==combi{i}(1) & indicesEffects(:,2)==combi{i}(2) & indicesEffects(:,3)==combi{i}(3),:));
                legendPlot=[legendPlot,{[char(modalitiesAll{1}(combi{i}(1))) ' \cap ' char(modalitiesAll{2}(combi{i}(2))) ' \cap ' char(modalitiesAll{3}(combi{i}(3)))]}];
                posthoc{pos}.data.names{i}=[char(modalitiesAll{1}(combi{i}(1))) ' \cap ' char(modalitiesAll{2}(combi{i}(2))) ' \cap ' char(modalitiesAll{3}(combi{i}(3)))];
            end

            [nPlot,whichPlot,whichFixed,whichModal]=findNPlot(combi);
            for p=1:nPlot
                clPlot=chooseCL(colorLine,lineStyle,whichFixed(1,p));
                plotmean(meansData(whichPlot{p}),IC,xlab,ylab,Fs,xlimits,nx,ny,clPlot,imageFontSize,imageSize,transparancy1D,ylimits,xLine,yLine,xGrid,yGrid)
                data4empty=meansData(whichPlot{p});
                for i=1:numel(whichPlot{p})
                    isEmptydata(i)=~isempty(data4empty{i});
                end
                legend(legendPlot(whichPlot{p}(isEmptydata)),'Location','eastoutside','box','off')
                print('-dtiff',imageResolution,[savedir savedir2 verifSaveName(eNames{whichFixed(1,p)}) '/' verifSaveName([modalitiesAll{whichFixed(2,p)}{whichModal(1,p)} ' x ' modalitiesAll{whichFixed(3,p)}{whichModal(2,p)}])])
                savefig([savedir savedir2 verifSaveName(eNames{whichFixed(1,p)}) '/FIG/' verifSaveName([modalitiesAll{whichFixed(2,p)}{whichModal(1,p)} ' x ' modalitiesAll{whichFixed(3,p)}{whichModal(2,p)}])])
                close
                clear isEmptydata
            end
            posthoc{pos}.data.continuum=meansData;
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
        pBonferroni=alphaT/nComp;

        for comp=1:nComp

            for i=1:2
                % comparison + name
                if nEffects==2
                    DATA{i}=maps1d(indicesEffects(:,1)==combi{Comp{comp}(i)}(1) & indicesEffects(:,2)==combi{Comp{comp}(i)}(2),:);
                    DATA{i}=groupBysub(DATA{i},sub(indicesEffects(:,1)==combi{Comp{comp}(i)}(1) & indicesEffects(:,2)==combi{Comp{comp}(i)}(2),:));
                    [eFixed,eTested,modalFixed,modalTested]=findWhichTitle([combi{Comp{comp}(1)};combi{Comp{comp}(2)}]);
                    posthoc{pos}.differences.names{comp}=char([modalitiesAll{eFixed}{modalFixed} ' (' modalitiesAll{eTested}{modalTested(1)} ' - ' modalitiesAll{eTested}{modalTested(2)} ')']);
                elseif nEffects==3
                    DATA{i}=maps1d(indicesEffects(:,1)==combi{Comp{comp}(i)}(1) & indicesEffects(:,2)==combi{Comp{comp}(i)}(2) & indicesEffects(:,3)==combi{Comp{comp}(i)}(3),:);
                    DATA{i}=groupBysub(DATA{i},sub(indicesEffects(:,1)==combi{Comp{comp}(i)}(1) & indicesEffects(:,2)==combi{Comp{comp}(i)}(2) & indicesEffects(:,3)==combi{Comp{comp}(i)}(3),:));
                    [eFixed,eTested,modalFixed,modalTested]=findWhichTitle([combi{Comp{comp}(1)};combi{Comp{comp}(2)}]);
                    posthoc{pos}.differences.names{comp}=char([modalitiesAll{eFixed(1)}{modalFixed(1)} ' x ' modalitiesAll{eFixed(2)}{modalFixed(2)} ' (' modalitiesAll{eTested}{modalTested(1)} ' - ' modalitiesAll{eTested}{modalTested(2)} ')']);
                end
            end


            % t-test
            if typeEffectsAll(eTested)==1
                differencesData{1}=DATA{1}-DATA{2};
                relativeDifferencesData{1}=100*(DATA{1}-DATA{2})./DATA{2};

                posthoc{pos}.differences.continuum{1,comp}=differencesData{1};
                posthoc{pos}.differences.continuumRelative{1,comp}=relativeDifferencesData{1};

                Ttest=spm1d.stats.nonparam.ttest_paired(DATA{1},DATA{2});
                posthoc{pos}.tTests.type{comp}='paired';
                [posthoc{pos}.differences.ES{comp},posthoc{pos}.differences.ESsd{comp}]=esCalculation(DATA);

            else

                % differences
                differencesData{1}=mean(DATA{1})-mean(DATA{2});
                relativeDifferencesData{1}=100*(mean(DATA{1})-mean(DATA{2}))./mean(DATA{2});

                posthoc{pos}.differences.continuum{1,comp}=differencesData{1};
                posthoc{pos}.differences.continuumRelative{1,comp}=relativeDifferencesData{1};

                Ttest=spm1d.stats.nonparam.ttest2(DATA{1},DATA{2});
                posthoc{pos}.tTests.type{comp}='independant';
                [posthoc{pos}.differences.ES{comp},posthoc{pos}.differences.ESsd{comp}]=esCalculation(DATA);
            end

            plotmean(differencesData,IC,xlab,ylab,Fs,xlimits,nx,[],[],imageFontSize,imageSize,transparancy1D,[],[],[],0,0)
            legend([posthoc{pos}.differences.names{comp}],'Location','eastoutside','box','off')
            savefig([savedir savedir2 verifSaveName(eNames{testedEffect{comp}}) '/FIG/DIFF/' verifSaveName(posthoc{pos}.differences.names{comp})])
            print('-dtiff',imageResolution,[savedir savedir2 verifSaveName(eNames{testedEffect{comp}}) '/DIFF/' verifSaveName(posthoc{pos}.differences.names{comp})])
            close

            plotmean(relativeDifferencesData,IC,xlab,'Differences (%)',Fs,xlimits,nx,[],[],imageFontSize,imageSize,transparancy1D,[],[],[],0,0)
            legend([posthoc{pos}.differences.names{comp}],'Location','eastoutside','box','off')
            savefig([savedir savedir2 verifSaveName(eNames{testedEffect{comp}}) '/FIG/DIFF/' verifSaveName(posthoc{pos}.differences.names{comp}) '%'])
            print('-dtiff',imageResolution,[savedir savedir2 verifSaveName(eNames{testedEffect{comp}}) '/DIFF/' verifSaveName(posthoc{pos}.differences.names{comp}) ' %'])
            close

            % inference
            posthoc{pos}.tTests.names=posthoc{pos}.differences.names;
            [posthoc{pos}.tTests.nWarning{comp},permutations,alpha]=fctWarningPermutations(Ttest,pBonferroni,multiPerm,maximalPerm,Perm);
            posthoc{pos}.tTests.alpha=alphaT;
            if warnT==1
                posthoc{pos}.tTests.warning="alpha is not valid";
            end
            posthoc{pos}.tTests.pBonferroni=pBonferroni;
            posthoc{pos}.tTests.pCritical{comp}=alpha;
            posthoc{pos}.tTests.nPermutations{comp}=permutations;
            Ttest_inf=Ttest.inference(alpha,'iterations',permutations,'force_iterations',logical(1),'two_tailed',logical(1));
            posthoc{pos}.tTests.maxPermutations{comp}=Ttest_inf.nPermUnique;
            posthoc{pos}.tTests.Tthreshold{comp}=Ttest_inf.zstar;
            posthoc{pos}.tTests.Tcontinuum{1,comp}=reshape(Ttest_inf.z,dimensions(1),dimensions(2));
            posthoc{pos}.tTests.Tsignificant{1,comp}=zeros(dimensions(1),dimensions(2));
            posthoc{pos}.tTests.Tcontinuum{1,comp}=reshape(Ttest_inf.z,dimensions(1),dimensions(2));
            mapLogical=abs(posthoc{pos}.tTests.Tcontinuum{1,comp})>=posthoc{pos}.tTests.Tthreshold{comp};

            clustersT=extractClusterData(Ttest_inf.clusters);
            for c=1:numel(clustersT)
                posthoc{pos}.tTests.clusterLocation{comp}{c}=clustersT{c}.endpoints;
                posthoc{pos}.tTests.clusterP{comp}(c)=clustersT{c}.P*nComp;
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

            posthoc{pos}.tTests.Tsignificant{1,comp}(effectCorr)=mapLogical(effectCorr);
            if nEffects==2
                tMainEffect(effectCorr==1)=0;
                realEffect{comp}=reshape(max([tMainEffect(:)';posthoc{pos}.tTests.Tsignificant{1,comp}(:)']),dimensions(1),dimensions(2));
            else
                for interactions=1:2
                    tInteractionEffect{interactions}(effectCorr==1)=0;
                end
                realEffect{comp}=reshape(max([tInteractionEffect{1}';tInteractionEffect{2}';posthoc{pos}.tTests.Tsignificant{1,comp}(:)']),dimensions(1),dimensions(2));
            end
            posthoc{pos}.tTests.Tsignificant{1,comp}=realEffect{comp};

            % full plot of SnPM analysis
            plotTtest(posthoc{pos}.tTests.Tcontinuum{1,comp},posthoc{pos}.tTests.Tthreshold{comp},posthoc{pos}.tTests.Tsignificant{1,comp},Fs,xlab,ylab,ylimits,dimensions,nx,ny,xlimits,imageFontSize,imageSize)
            title(posthoc{pos}.differences.names{comp})
            savefig([savedir savedir2 verifSaveName(eNames{testedEffect{comp}}) '/FIG/SnPM/' verifSaveName(posthoc{pos}.differences.names{comp})])
            print('-dtiff',imageResolution,[savedir savedir2 verifSaveName(eNames{testedEffect{comp}}) '/SnPM/' verifSaveName(posthoc{pos}.differences.names{comp})])
            close

            % ES
            plotES(posthoc{pos}.differences.ES{comp},posthoc{pos}.differences.ESsd{comp},posthoc{pos}.tTests.Tsignificant{1,comp},Fs,xlab,nx,xlimits,imageFontSize,imageSize,transparancy1D,yLimitES)
            title(posthoc{pos}.differences.names{comp})
            savefig([savedir savedir2 verifSaveName(eNames{testedEffect{comp}}) '/FIG/ES/' verifSaveName(posthoc{pos}.differences.names{comp})])
            print('-dtiff',imageResolution,[savedir savedir2 verifSaveName(eNames{testedEffect{comp}}) '/ES/' verifSaveName(posthoc{pos}.differences.names{comp})])
            close

        end


        for p=1:nPlot

            data4empty=posthoc{pos}.data.continuum(whichPlot{p});
            for i=1:numel(whichPlot{p})
                isEmptydata(i)=~isempty(data4empty{i});
            end

            for nC=1:numel(whichPlot{p})
                findT(nC)=posthoc{pos}.data.names(whichPlot{p}(nC));
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
            for nC=1:numel(posthoc{pos}.differences.names)
                nameCompare=[posthoc{pos}.differences.names{nC} '___________________________'];
                whichCompare(nC)=string([sameName ' '])==string(nameCompare(1:sizeSname+1));
            end

            if nEffects==2
                clPlot=chooseCL(colorLine,lineStyle,whichFixed(2,p));
            else
                clPlot=chooseCL(colorLine,lineStyle,whichFixed(1,p));
            end

            if nEffects==2
                plotmeanSnPM(posthoc{pos}.data.continuum(whichPlot{p}),posthoc{pos}.tTests.Tcontinuum(:,whichCompare),posthoc{pos}.tTests.Tsignificant(:,whichCompare),legendPlot(whichPlot{p}(isEmptydata)),posthoc{pos}.differences.names(whichCompare),IC,xlab,ylab,Fs,xlimits,nx,ny,clPlot,imageFontSize,imageSize,transparancy1D,ylimits,anovaEffects([whichFixed(2,p) 3]),{eNames{whichFixed(2,p)},[eNames{1} ' x ' eNames{2}]},ratioSnPM,SnPMPos,aovColor,xLine,yLine,xGrid,yGrid)
                print('-dtiff',imageResolution,[savedir savedir2 verifSaveName(eNames{whichFixed(2,p)}) '/' verifSaveName(modalitiesAll{whichFixed(1,p)}{whichModal(1,p)}) ' + SnPM'])
                savefig([savedir savedir2 verifSaveName(eNames{whichFixed(2,p)}) '/FIG/' verifSaveName(modalitiesAll{whichFixed(1,p)}{whichModal(1,p)}) ' + SnPM'])
                close

                plotmeanSnPM(posthoc{pos}.data.continuum(whichPlot{p}),posthoc{pos}.tTests.Tcontinuum(:,whichCompare),posthoc{pos}.tTests.Tsignificant(:,whichCompare),legendPlot(whichPlot{p}(isEmptydata)),posthoc{pos}.differences.names(whichCompare),IC,xlab,ylab,Fs,xlimits,nx,ny,clPlot,imageFontSize,imageSize,transparancy1D,ylimits,[],[],ratioSnPM,SnPMPos,aovColor,xLine,yLine,xGrid,yGrid)
                print('-dtiff',imageResolution,[savedir savedir2 verifSaveName(eNames{whichFixed(2,p)}) '/' verifSaveName(modalitiesAll{whichFixed(1,p)}{whichModal(1,p)}) ' + SnPMnoAOV'])
                savefig([savedir savedir2 verifSaveName(eNames{whichFixed(2,p)}) '/FIG/' verifSaveName(modalitiesAll{whichFixed(1,p)}{whichModal(1,p)}) ' + SnPMnoAOV'])
                close

                plotmeanSnPMsub(posthoc{pos}.data.continuum(whichPlot{p}),posthoc{pos}.tTests.Tcontinuum(:,whichCompare),posthoc{pos}.tTests.Tsignificant(:,whichCompare),legendPlot(whichPlot{p}(isEmptydata)),posthoc{pos}.differences.names(whichCompare),IC,xlab,ylab,Fs,xlimits,nx,ny,clPlot,imageFontSize,imageSize,transparancy1D,ylimits,anovaEffects([whichFixed(2,p) 3]),{eNames{whichFixed(2,p)},[eNames{1} ' x ' eNames{2}]},ratioSnPM,SnPMPos,aovColor,xLine,yLine,xGrid,yGrid)
                print('-dtiff',imageResolution,[savedir savedir2 verifSaveName(eNames{whichFixed(2,p)}) '/' verifSaveName(modalitiesAll{whichFixed(1,p)}{whichModal(1,p)}) ' + SnPMsub'])
                savefig([savedir savedir2 verifSaveName(eNames{whichFixed(2,p)}) '/FIG/' verifSaveName(modalitiesAll{whichFixed(1,p)}{whichModal(1,p)}) ' + SnPMsub'])
                close

                plotmeanSnPMsub(posthoc{pos}.data.continuum(whichPlot{p}),posthoc{pos}.tTests.Tcontinuum(:,whichCompare),posthoc{pos}.tTests.Tsignificant(:,whichCompare),legendPlot(whichPlot{p}(isEmptydata)),posthoc{pos}.differences.names(whichCompare),IC,xlab,ylab,Fs,xlimits,nx,ny,clPlot,imageFontSize,imageSize,transparancy1D,ylimits,[],[],ratioSnPM,SnPMPos,aovColor,xLine,yLine,xGrid,yGrid)
                print('-dtiff',imageResolution,[savedir savedir2 verifSaveName(eNames{whichFixed(2,p)}) '/' verifSaveName(modalitiesAll{whichFixed(1,p)}{whichModal(1,p)}) ' + SnPMsubNoAOV'])
                savefig([savedir savedir2 verifSaveName(eNames{whichFixed(2,p)}) '/FIG/' verifSaveName(modalitiesAll{whichFixed(1,p)}{whichModal(1,p)}) ' + SnPMsubNoAOV'])
                close
            else
                [nAnovaInt,nNames]=whichAnovaInt(whichFixed(1,p));

                plotmeanSnPM(posthoc{pos}.data.continuum(whichPlot{p}),posthoc{pos}.tTests.Tcontinuum(:,whichCompare),posthoc{pos}.tTests.Tsignificant(:,whichCompare),legendPlot(whichPlot{p}(isEmptydata)),posthoc{pos}.differences.names(whichCompare),IC,xlab,ylab,Fs,xlimits,nx,ny,clPlot,imageFontSize,imageSize,transparancy1D,ylimits,...
                    anovaEffects([whichFixed(1,p) nAnovaInt 7]),{eNames{whichFixed(1,p)},[eNames{nNames(1,1)} ' x ' eNames{nNames(1,2)}], [eNames{nNames(2,1)} ' x ' eNames{nNames(2,2)}],[eNames{1} ' x ' eNames{2} ' x ' eNames{3}]},ratioSnPM,SnPMPos,aovColor,xLine,yLine,xGrid,yGrid)
                print('-dtiff',imageResolution,[savedir savedir2 verifSaveName(eNames{whichFixed(1,p)}) '/' verifSaveName([modalitiesAll{whichFixed(2,p)}{whichModal(1,p)} ' x ' modalitiesAll{whichFixed(3,p)}{whichModal(2,p)}]) ' + SnPM'])
                savefig([savedir savedir2 verifSaveName(eNames{whichFixed(1,p)}) '/FIG/' verifSaveName([modalitiesAll{whichFixed(2,p)}{whichModal(1,p)} ' x ' modalitiesAll{whichFixed(3,p)}{whichModal(2,p)}]) ' + SnPM'])
                close

                plotmeanSnPM(posthoc{pos}.data.continuum(whichPlot{p}),posthoc{pos}.tTests.Tcontinuum(:,whichCompare),posthoc{pos}.tTests.Tsignificant(:,whichCompare),legendPlot(whichPlot{p}(isEmptydata)),posthoc{pos}.differences.names(whichCompare),IC,xlab,ylab,Fs,xlimits,nx,ny,clPlot,imageFontSize,imageSize,transparancy1D,ylimits,[],[],ratioSnPM,SnPMPos,aovColor,xLine,yLine,xGrid,yGrid)
                print('-dtiff',imageResolution,[savedir savedir2 verifSaveName(eNames{whichFixed(1,p)}) '/' verifSaveName([modalitiesAll{whichFixed(2,p)}{whichModal(1,p)} ' x ' modalitiesAll{whichFixed(3,p)}{whichModal(2,p)}]) ' + SnPMnoAOV'])
                savefig([savedir savedir2 verifSaveName(eNames{whichFixed(1,p)}) '/FIG/' verifSaveName([modalitiesAll{whichFixed(2,p)}{whichModal(1,p)} ' x ' modalitiesAll{whichFixed(3,p)}{whichModal(2,p)}]) ' + SnPMnoAOV'])
                close

                plotmeanSnPMsub(posthoc{pos}.data.continuum(whichPlot{p}),posthoc{pos}.tTests.Tcontinuum(:,whichCompare),posthoc{pos}.tTests.Tsignificant(:,whichCompare),legendPlot(whichPlot{p}(isEmptydata)),posthoc{pos}.differences.names(whichCompare),IC,xlab,ylab,Fs,xlimits,nx,ny,clPlot,imageFontSize,imageSize,transparancy1D,ylimits,...
                    anovaEffects([whichFixed(1,p) nAnovaInt 7]),{eNames{whichFixed(1,p)},[eNames{nNames(1,1)} ' x ' eNames{nNames(1,2)}], [eNames{nNames(2,1)} ' x ' eNames{nNames(2,2)}],[eNames{1} ' x ' eNames{2} ' x ' eNames{3}]},ratioSnPM,SnPMPos,aovColor,xLine,yLine,xGrid,yGrid)
                print('-dtiff',imageResolution,[savedir savedir2 verifSaveName(eNames{whichFixed(1,p)}) '/' verifSaveName([modalitiesAll{whichFixed(2,p)}{whichModal(1,p)} ' x ' modalitiesAll{whichFixed(3,p)}{whichModal(2,p)}]) ' + SnPMsub'])
                savefig([savedir savedir2 verifSaveName(eNames{whichFixed(1,p)}) '/FIG/' verifSaveName([modalitiesAll{whichFixed(2,p)}{whichModal(1,p)} ' x ' modalitiesAll{whichFixed(3,p)}{whichModal(2,p)}]) ' + SnPMsub'])
                close

                plotmeanSnPMsub(posthoc{pos}.data.continuum(whichPlot{p}),posthoc{pos}.tTests.Tcontinuum(:,whichCompare),posthoc{pos}.tTests.Tsignificant(:,whichCompare),legendPlot(whichPlot{p}(isEmptydata)),posthoc{pos}.differences.names(whichCompare),IC,xlab,ylab,Fs,xlimits,nx,ny,clPlot,imageFontSize,imageSize,transparancy1D,ylimits,[],[],ratioSnPM,SnPMPos,aovColor,xLine,yLine,xGrid,yGrid)
                print('-dtiff',imageResolution,[savedir savedir2 verifSaveName(eNames{whichFixed(1,p)}) '/' verifSaveName([modalitiesAll{whichFixed(2,p)}{whichModal(1,p)} ' x ' modalitiesAll{whichFixed(3,p)}{whichModal(2,p)}]) ' + SnPMsubNoAOV'])
                savefig([savedir savedir2 verifSaveName(eNames{whichFixed(1,p)}) '/FIG/' verifSaveName([modalitiesAll{whichFixed(2,p)}{whichModal(1,p)} ' x ' modalitiesAll{whichFixed(3,p)}{whichModal(2,p)}]) ' + SnPMsubNoAOV'])
                close
            end

            clear isEmptydata findT capPos whichCompare
        end

        posthoc{pos}.tTests.combi=combi;
        clear Comp combi legendPlot DATA
    end

end
end