function posthoc=fctPostHoc1dS(nEffects,indicesEffects,maps1d,dimensions,modalitiesAll,typeEffectsAll,eNames,multiIterations,IT,anovaEffects,maximalIT,doAllInteractions,alphaT,alphaAOV)

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
            legendPlot=[legendPlot,{char(modalitiesAll{1}(combi{i}(1)))}];
            posthoc{1}.data.names{i}=[char(modalitiesAll{1}(combi{i}(1)))];
            
        end
        
        
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
            [posthoc{1}.tTests.nWarning{comp},iterations,alpha]=fctWarningIterations(Ttest,pBonferroni,multiIterations,maximalIT,IT);
            posthoc{1}.tTests.alpha=alphaT;
            if warnT==1
                posthoc{1}.tTests.warning="alpha is not valid";
            end
            posthoc{1}.tTests.pBonferroni=pBonferroni;
            posthoc{1}.tTests.pCritical{comp}=alpha;
            posthoc{1}.tTests.nIterations{comp}=iterations;
            Ttest_inf=Ttest.inference(alpha,'iterations',iterations,'force_iterations',logical(1),'two_tailed',logical(1));
            posthoc{1}.tTests.maxIterations{comp}=Ttest_inf.nPermUnique;
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
        end
        
        clear comp combi
        
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
                legendPlot=[legendPlot,{char(modalitiesAll{mainEffect(1)}(combi{i}(1)))}];
                posthoc{mainEffect(1)}.data.names{i}=[char(modalitiesAll{mainEffect(1)}(combi{i}(1)))];
            end
            
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
                
                % inference
                posthoc{mainEffect(1)}.tTests.names=posthoc{mainEffect(1)}.differences.names;
                [posthoc{mainEffect(1)}.tTests.nWarning{comp},iterations,alpha]=fctWarningIterations(Ttest,pBonferroni,multiIterations,maximalIT,IT);
                posthoc{mainEffect(1)}.tTests.alpha=alphaT;
                if warnT==1
                    posthoc{mainEffect(1)}.tTests.warning="alpha is not valid";
                end
                posthoc{mainEffect(1)}.tTests.pBonferroni=pBonferroni;
                posthoc{mainEffect(1)}.tTests.pCritical{comp}=alpha;
                posthoc{mainEffect(1)}.tTests.nIterations{comp}=iterations;
                Ttest_inf=Ttest.inference(alpha,'iterations',iterations,'force_iterations',logical(1),'two_tailed',logical(1));
                posthoc{mainEffect(1)}.tTests.maxIterations{comp}=Ttest_inf.nPermUnique;
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
                
                mainForInteraction{mainEffect}=posthoc{mainEffect(1)}.tTests.Tsignificant;
                clear Comp combi legendPlot
                
            end
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
                legendPlot=[legendPlot,{char(modalitiesAll{mainEffect(1)}(combi{i}(1)))}];
                posthoc{mainEffect(1)}.data.names{i}=[char(modalitiesAll{mainEffect(1)}(combi{i}(1)))];
            end
            
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
                
                % inference
                posthoc{mainEffect(1)}.tTests.names=posthoc{mainEffect(1)}.differences.names;
                [posthoc{mainEffect(1)}.tTests.nWarning{comp},iterations,alpha]=fctWarningIterations(Ttest,pBonferroni,multiIterations,maximalIT,IT);
                posthoc{mainEffect(1)}.tTests.alpha=alphaT;
                if warnT==1
                    posthoc{mainEffect(1)}.tTests.warning="alpha is not valid";
                end
                posthoc{mainEffect(1)}.tTests.pBonferroni=pBonferroni;
                posthoc{mainEffect(1)}.tTests.pCritical{comp}=alpha;
                posthoc{mainEffect(1)}.tTests.nIterations{comp}=iterations;
                Ttest_inf=Ttest.inference(alpha,'iterations',iterations,'force_iterations',logical(1),'two_tailed',logical(1));
                posthoc{mainEffect(1)}.tTests.maxIterations{comp}=Ttest_inf.nPermUnique;
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
                
            end
            
            mainForInteraction{mainEffect}=posthoc{mainEffect(1)}.tTests.Tsignificant;
            clear Comp combi legendPlot
            
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
                posthoc{3+anovaFixedCorr(fixedEffect)}.data.names{i}=[char(modalitiesAll{mainEffect(1)}(combi{i}(1))) ' \cap ' char(modalitiesAll{mainEffect(2)}(combi{i}(2)))];
            end
            
            % full plot of means
            [nPlot,whichPlot,whichFixed,whichModal]=findNPlot(combi);
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
                
                % inference
                posthoc{3+anovaFixedCorr(fixedEffect)}.tTests.names=posthoc{3+anovaFixedCorr(fixedEffect)}.differences.names;
                [posthoc{3+anovaFixedCorr(fixedEffect)}.tTests.nWarning{comp},iterations,alpha]=fctWarningIterations(Ttest,pBonferroni,multiIterations,maximalIT,IT);
                posthoc{3+anovaFixedCorr(fixedEffect)}.tTests.alpha=alphaT;
                if warnT==1
                    posthoc{3+anovaFixedCorr(fixedEffect)}.tTests.warning="alpha is not valid";
                end
                posthoc{3+anovaFixedCorr(fixedEffect)}.tTests.pBonferroni=pBonferroni;
                posthoc{3+anovaFixedCorr(fixedEffect)}.tTests.pCritical{comp}=alpha;
                posthoc{3+anovaFixedCorr(fixedEffect)}.tTests.nIterations{comp}=iterations;
                Ttest_inf=Ttest.inference(alpha,'iterations',iterations,'force_iterations',logical(1),'two_tailed',logical(1));
                posthoc{3+anovaFixedCorr(fixedEffect)}.tTests.maxIterations{comp}=Ttest_inf.nPermUnique;
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
            end
            
            intForInteractions{anovaFixedCorr(effectFixed)}.t=realEffect;
            posthoc{3+anovaFixedCorr(fixedEffect)}.tTests.combi=combi;
            clear Comp combi legendPlot
            
        end
    end
end

%% T-TESTS ALL INTERACTIONS (ANOVA 2 and 3)
if nEffects>1
    
    if nEffects==2
        isInteraction=max(anovaEffects{3});
        pos=3;
        posthoc{pos}.name=[eNames{1} ' x ' eNames{2}];
    elseif nEffects==3
        isInteraction=max(anovaEffects{7});
        pos=7;
        posthoc{pos}.name=[eNames{1} ' x ' eNames{2} ' x ' eNames{3}];
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
                legendPlot=[legendPlot,{[char(modalitiesAll{1}(combi{i}(1))) ' \cap ' char(modalitiesAll{2}(combi{i}(2)))]}];
                posthoc{pos}.data.names{i}=[char(modalitiesAll{1}(combi{i}(1))) ' \cap ' char(modalitiesAll{2}(combi{i}(2)))];
            end
            
            % full plot of means
            [nPlot,whichPlot,whichFixed,whichModal]=findNPlot(combi);
            
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
                legendPlot=[legendPlot,{[char(modalitiesAll{1}(combi{i}(1))) ' \cap ' char(modalitiesAll{2}(combi{i}(2))) ' \cap ' char(modalitiesAll{3}(combi{i}(3)))]}];
                posthoc{pos}.data.names{i}=[char(modalitiesAll{1}(combi{i}(1))) ' \cap ' char(modalitiesAll{2}(combi{i}(2))) ' \cap ' char(modalitiesAll{3}(combi{i}(3)))];
            end
            
            [nPlot,whichPlot,whichFixed,whichModal]=findNPlot(combi);
            
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
                    [eFixed,eTested,modalFixed,modalTested]=findWhichTitle([combi{Comp{comp}(1)};combi{Comp{comp}(2)}]);
                    posthoc{pos}.differences.names{comp}=char([modalitiesAll{eFixed}{modalFixed} ' (' modalitiesAll{eTested}{modalTested(1)} ' - ' modalitiesAll{eTested}{modalTested(2)} ')']);
                elseif nEffects==3
                    DATA{i}=maps1d(indicesEffects(:,1)==combi{Comp{comp}(i)}(1) & indicesEffects(:,2)==combi{Comp{comp}(i)}(2) & indicesEffects(:,3)==combi{Comp{comp}(i)}(3),:);
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
            
            % inference
            posthoc{pos}.tTests.names=posthoc{pos}.differences.names;
            [posthoc{pos}.tTests.nWarning{comp},iterations,alpha]=fctWarningIterations(Ttest,pBonferroni,multiIterations,maximalIT,IT);
            posthoc{pos}.tTests.alpha=alphaT;
            if warnT==1
                posthoc{pos}.tTests.warning="alpha is not valid";
            end
            posthoc{pos}.tTests.pBonferroni=pBonferroni;
            posthoc{pos}.tTests.pCritical{comp}=alpha;
            posthoc{pos}.tTests.nIterations{comp}=iterations;
            Ttest_inf=Ttest.inference(alpha,'iterations',iterations,'force_iterations',logical(1),'two_tailed',logical(1));
            posthoc{pos}.tTests.maxIterations{comp}=Ttest_inf.nPermUnique;
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
            
        end
    end
    
    posthoc{pos}.tTests.combi=combi;
    clear Comp combi legendPlot
end

end