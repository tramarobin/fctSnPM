function posthoc=fctPostHoc2d(nEffects,indicesEffects,maps1d,dimensions,modalitiesAll,typeEffectsAll,eNames,contourColor,savedir,multiPerm,Perm,xlab,ylab,Fs,ylimits,nx,ny,colorbarLabel,imageResolution,displayContour,limitMeanMaps,xlimits,anovaEffects,maximalPerm,doAllInteractions,dashedColor,transparency,lineWidth,imageFontSize,imageSize,colorMap,colorMapDiff,diffRatio,relativeRatio,alphaT,alphaAOV,linestyle,equalAxis,deleteAxis,statLimit)
close all
if isempty(nx)
    nx=5;
end
if isempty(ny)
    ny=4;
end
savedir=fullfile(savedir, 'Post hoc');

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

    createSavedir2d(savedir)
    posthoc{1}.name=eNames{1};

    loop=0;
    for i=1:max(indicesEffects)
        loop=loop+1;
        combi{loop}=i;
    end
    nCombi=size(combi,2);

    positionDiffPlot=[];
    positionSnPMPlot=[];

    if isempty(imageSize)
        f1=figure('Units', 'Pixels', 'OuterPosition', [0, 0, 720, 480],'visible','off');
    elseif max(size(imageSize))==1
        f1=figure('Units', 'Centimeter', 'OuterPosition', [0, 0, imageSize, imageSize],'visible','off');
    else
        f1=figure('Units', 'Centimeter', 'OuterPosition', [0, 0, imageSize(1), imageSize(2)],'visible','off');
    end

    for i=1:nCombi

        % means
        meansData=reshape(mean(maps1d(indicesEffects==combi{i}(1),:)),dimensions(1),dimensions(2));
        stdData=reshape(std(maps1d(indicesEffects==combi{i}(1),:)),dimensions(1),dimensions(2));
        posthoc{1}.data.names{i}=[char(modalitiesAll{1}(combi{i}(1)))];
        posthoc{1}.data.meanContinuum{i}=meansData;
        posthoc{1}.data.sdContinuum{i}=stdData;
        positionDiffPlot=[positionDiffPlot,(i-1)*nCombi+i+1:(i-1)*nCombi+i+1+nCombi-i-1];
        positionSnPMPlot=[positionSnPMPlot,(i)*nCombi+i:nCombi:nCombi.^2-1];

        % full plot mean
        displayMeanMaps(meansData,Fs,xlab,ylab,ylimits,nx,ny,limitMeanMaps,xlimits,imageFontSize,imageSize,colorbarLabel,colorMap,equalAxis,deleteAxis)
        title(char(modalitiesAll{1}(combi{i}(1))))
        exportgraphics(gcf,fullfile(savedir, [verifSaveName(char(modalitiesAll{1}(combi{i}(1)))) '.tif']),'Resolution',imageResolution)
        savefig(fullfile(savedir, 'FIG', verifSaveName(char(modalitiesAll{1}(combi{i}(1))))))
        close

        % full plot sd
        displayMeanMaps(stdData,Fs,xlab,ylab,ylimits,nx,ny,[],xlimits,imageFontSize,imageSize,colorbarLabel,colorMap,equalAxis,deleteAxis)
        title(char(modalitiesAll{1}(combi{i}(1))))
        exportgraphics(gcf,fullfile(savedir, 'SD', [verifSaveName(char(modalitiesAll{1}(combi{i}(1)))) '.tif']),'Resolution',imageResolution)
        savefig(fullfile(savedir, 'FIG', 'SD', verifSaveName(char(modalitiesAll{1}(combi{i}(1))))))
        close

        % subplot
        set(0, 'currentfigure', f1);
        subplot(nCombi,nCombi,nCombi*(i-1)+i);
        displayMeanMaps_sub(meansData,Fs,limitMeanMaps,colorMap,equalAxis,deleteAxis)
        title(char(modalitiesAll{1}(combi{i}(1))))

    end

    loop=0;
    for i=1:size(combi,2)
        for j=1:size(combi,2)
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
        end
        posthoc{1}.differences.names{1,comp}=char([modalitiesAll{1}{combi{Comp{comp}(1)}(1)} ' - ' modalitiesAll{1}{combi{Comp{comp}(2)}(1)}]);

        if typeEffectsAll>0

            % differences
            differencesData=reshape(mean(DATA{1}-DATA{2}),dimensions(1),dimensions(2));
            relativeDifferencesData=reshape(100*mean((DATA{1}-DATA{2})./DATA{2}),dimensions(1),dimensions(2));

            posthoc{1}.differences.continuum{1,comp}=differencesData;
            posthoc{1}.differences.continuumRelative{1,comp}=relativeDifferencesData;

            Ttest=spm1d.stats.nonparam.ttest_paired(DATA{1},DATA{2});
            posthoc{1}.tTests.type{comp}='paired';
            [posthoc{1}.differences.ES{comp},posthoc{1}.differences.ESsd{comp}]=esCalculation(DATA);

        else

            % differences
            differencesData=reshape(mean(DATA{1})-mean(DATA{2}),dimensions(1),dimensions(2));
            relativeDifferencesData=reshape(100*(mean(DATA{1})-mean(DATA{2}))./mean(DATA{2}),dimensions(1),dimensions(2));

            posthoc{1}.differences.continuum{1,comp}=differencesData;
            posthoc{1}.differences.continuumRelative{1,comp}=relativeDifferencesData;

            Ttest=spm1d.stats.nonparam.ttest2(DATA{1},DATA{2});
            posthoc{1}.tTests.type{comp}='independant';
            [posthoc{1}.differences.ES{comp},posthoc{1}.differences.ESsd{comp}]=esCalculation(DATA);
        end

        posthoc{1}.differences.ES{comp}=reshape(posthoc{1}.differences.ES{comp},dimensions(1),dimensions(2));
        posthoc{1}.differences.ESsd{comp}=reshape(posthoc{1}.differences.ESsd{comp},dimensions(1),dimensions(2));

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
        posthoc{1}.tTests.Tcontinuum{1,comp}=reshape(Ttest_inf.z,dimensions(1),dimensions(2));
        mapLogical=abs(posthoc{1}.tTests.Tcontinuum{1,comp})>=posthoc{1}.tTests.Tthreshold{comp};
        posthoc{1}.tTests.Tsignificant{1,comp}=zeros(dimensions(1),dimensions(2));
        posthoc{1}.tTests.Tsignificant{1,comp}(anovaEffects{1})=mapLogical(anovaEffects{1});
        posthoc{1}.tTests.contourSignificant{1,comp}=zeros(dimensions(1),dimensions(2));
        posthoc{1}.tTests.contourSignificant{1,comp}(find(posthoc{1}.tTests.Tsignificant{1,comp}==1))=abs(posthoc{1}.tTests.Tcontinuum{1,comp}(find(posthoc{1}.tTests.Tsignificant{1,comp}==1)));
        datanoAnova=abs(posthoc{1}.tTests.Tcontinuum{1,comp}(find(posthoc{1}.tTests.Tsignificant{1,comp}==0)));
        datanoAnova(find(datanoAnova>=posthoc{1}.tTests.Tthreshold{comp}))=posthoc{1}.tTests.Tthreshold{comp}-0.01*posthoc{1}.tTests.Tthreshold{comp};
        posthoc{1}.tTests.contourSignificant{1,comp}(find(posthoc{1}.tTests.Tsignificant{1,comp}==0))=datanoAnova;
        posthoc{1}.tTests.contourSignificant{1,comp}=reshape(posthoc{1}.tTests.contourSignificant{1,comp},dimensions(1),dimensions(2));

        % full plot of difference
        displayDiffMaps(differencesData,Fs,xlab,ylab,ylimits,nx,ny,limitMeanMaps,xlimits,imageFontSize,imageSize,colorbarLabel,colorMapDiff,diffRatio,equalAxis,deleteAxis)
        if displayContour
            dispContour(abs(posthoc{1}.tTests.contourSignificant{1,comp}),posthoc{1}.tTests.Tthreshold{comp},contourColor,dashedColor,transparency,lineWidth,linestyle)
        end
        title(posthoc{1}.differences.names{1,comp})
        exportgraphics(gcf,fullfile(savedir, 'DIFF', [verifSaveName(posthoc{1}.differences.names{1,comp}) '.tif']),'Resolution',imageResolution)
        savefig(fullfile(savedir, 'FIG', 'DIFF', verifSaveName(posthoc{1}.differences.names{1,comp})))
        close

        displayRelativeDiffMaps(relativeDifferencesData,Fs,xlab,ylab,ylimits,nx,ny,xlimits,imageFontSize,imageSize,colorMapDiff,relativeRatio,equalAxis,deleteAxis)
        if displayContour
            dispContour(abs(posthoc{1}.tTests.contourSignificant{1,comp}),posthoc{1}.tTests.Tthreshold{comp},contourColor,dashedColor,transparency,lineWidth,linestyle)
        end
        title(posthoc{1}.differences.names{1,comp})
        exportgraphics(gcf,fullfile(savedir, 'DIFF', [verifSaveName(posthoc{1}.differences.names{1,comp}) ' %.tif']),'Resolution',imageResolution)
        savefig(fullfile(savedir, 'FIG', 'DIFF', [verifSaveName(posthoc{1}.differences.names{1,comp}) ' %']))
        close

        % subplot of differences
        set(0, 'currentfigure', f1);
        ax=subplot(nCombi,nCombi,positionDiffPlot(comp));
        displayDiffMaps_sub(differencesData,Fs,limitMeanMaps,diffRatio,colorMapDiff,ax,equalAxis,deleteAxis)
        if displayContour
            dispContour(abs(posthoc{1}.tTests.contourSignificant{1,comp}),posthoc{1}.tTests.Tthreshold{comp},contourColor,dashedColor,transparency,1,linestyle)
        end

        % full plot of SnPM analysis
        displayTtest(posthoc{1}.tTests.Tcontinuum{1,comp},posthoc{1}.tTests.Tthreshold{comp},[],Fs,xlab,ylab,ylimits,dimensions,nx,ny,xlimits,imageFontSize,imageSize,colorMapDiff,equalAxis,deleteAxis,statLimit)
        if displayContour
            dispContour(abs(posthoc{1}.tTests.Tcontinuum{1,comp}),posthoc{1}.tTests.Tthreshold{comp},contourColor,dashedColor,transparency,lineWidth,linestyle)
        end
        title(posthoc{1}.differences.names{1,comp})
        exportgraphics(gcf,fullfile(savedir, 'SnPM', [verifSaveName(posthoc{1}.differences.names{1,comp}) '.tif']),'Resolution',imageResolution)
        savefig(fullfile(savedir, 'FIG', 'SnPM', verifSaveName(posthoc{1}.differences.names{1,comp})))
        close

        % subplot of SnPM analysis
        set(0, 'currentfigure', f1);
        ax=subplot(nCombi,nCombi,positionSnPMPlot(comp));
        displayTtest_sub(posthoc{1}.tTests.Tcontinuum{1,comp},posthoc{1}.tTests.Tthreshold{comp},Fs,colorMapDiff,ax,equalAxis,deleteAxis,statLimit)

        %   ES
        displayMapsES(posthoc{1}.differences.ES{comp},Fs,xlab,ylab,ylimits,nx,ny,xlimits,imageFontSize,imageSize,colorMap,equalAxis,deleteAxis)
        title(posthoc{1}.differences.names{1,comp})
        if displayContour
            dispContour(abs(posthoc{1}.tTests.contourSignificant{1,comp}),posthoc{1}.tTests.Tthreshold{comp},contourColor,dashedColor,transparency,lineWidth,linestyle)
        end
        exportgraphics(gcf,fullfile(savedir, 'ES', [verifSaveName(posthoc{1}.differences.names{1,comp}) '.tif']),'Resolution',imageResolution)
        savefig(fullfile(savedir, 'FIG', 'ES', verifSaveName(posthoc{1}.differences.names{1,comp})))
        close

    end

    % save
    set(0, 'currentfigure', f1);
    exportgraphics(gcf,fullfile(savedir, [verifSaveName(eNames{1}) '.tif']),'Resolution',imageResolution)
    savefig(fullfile(savedir, 'FIG', verifSaveName(eNames{1})))
    close

    clear Comp combi isPlot

end

%% T-TESTS 2 EFFECTS - 1 FIXED = 2 MAIN EFFECTS
if nEffects==2
    % choose fixed effect and main effect (tested)
    eff=[1;2];
    for eff_fixed=1:size(eff,1)
        fixedEffect=eff(eff_fixed,:);
        mainEffect=1:size(eff,1);
        mainEffect(fixedEffect)=[];

        createSavedir2d(fullfile(savedir, eNames{mainEffect(1)}))
        posthoc{mainEffect(1)}.name=eNames{mainEffect(1)};

        loop=0;
        for i=1:max(indicesEffects(:,mainEffect(1)))
            loop=loop+1;
            combi{loop}=i;
        end
        nCombi=size(combi,2);

        positionDiffPlot=[];
        positionSnPMPlot=[];
        if isempty(imageSize)
            f1=figure('Units', 'Pixels', 'OuterPosition', [0, 0, 720, 480],'visible','off');
        elseif max(size(imageSize))==1
            f1=figure('Units', 'Centimeter', 'OuterPosition', [0, 0, imageSize, imageSize],'visible','off');
        else
            f1=figure('Units', 'Centimeter', 'OuterPosition', [0, 0, imageSize(1), imageSize(2)],'visible','off');
        end
        for i=1:nCombi
            % means
            meansData=reshape(mean(maps1d(indicesEffects(:,mainEffect(1))==combi{i}(1),:)),dimensions(1),dimensions(2));
            stdData=reshape(std(maps1d(indicesEffects(:,mainEffect(1))==combi{i}(1),:)),dimensions(1),dimensions(2));
            posthoc{mainEffect(1)}.data.names{i}=[char(modalitiesAll{mainEffect(1)}(combi{i}(1)))];
            posthoc{mainEffect(1)}.data.meanContinuum{i}=meansData;
            posthoc{mainEffect(1)}.data.sdContinuum{i}=stdData;
            positionDiffPlot=[positionDiffPlot,(i-1)*nCombi+i+1:(i-1)*nCombi+i+1+nCombi-i-1];
            positionSnPMPlot=[positionSnPMPlot,(i)*nCombi+i:nCombi:nCombi.^2-1];

            % full plot of mean
            displayMeanMaps(meansData,Fs,xlab,ylab,ylimits,nx,ny,limitMeanMaps,xlimits,imageFontSize,imageSize,colorbarLabel,colorMap,equalAxis,deleteAxis)
            title(char(modalitiesAll{mainEffect(1)}(combi{i}(1))))
            exportgraphics(gcf,fullfile(savedir, verifSaveName(eNames{mainEffect(1)}), [verifSaveName(char(modalitiesAll{mainEffect(1)}(combi{i}(1)))) '.tif']),'Resolution',imageResolution)
            savefig(fullfile(savedir, verifSaveName(eNames{mainEffect(1)}), 'FIG', verifSaveName(char(modalitiesAll{mainEffect(1)}(combi{i}(1))))))
            close

            % full plot of sd
            displayMeanMaps(stdData,Fs,xlab,ylab,ylimits,nx,ny,[],xlimits,imageFontSize,imageSize,colorbarLabel,colorMap,equalAxis,deleteAxis)
            title(char(modalitiesAll{mainEffect(1)}(combi{i}(1))))
            exportgraphics(gcf,fullfile(savedir, verifSaveName(eNames{mainEffect(1)}), 'SD', [verifSaveName(char(modalitiesAll{mainEffect(1)}(combi{i}(1)))) '.tif']),'Resolution',imageResolution)
            savefig(fullfile(savedir, verifSaveName(eNames{mainEffect(1)}), 'FIG', 'SD', verifSaveName(char(modalitiesAll{mainEffect(1)}(combi{i}(1))))))
            close

            % subplot
            set(0, 'currentfigure', f1);
            subplot(nCombi,nCombi,nCombi*(i-1)+i)
            displayMeanMaps_sub(meansData,Fs,limitMeanMaps,colorMap,equalAxis,deleteAxis)
            title(char(modalitiesAll{mainEffect(1)}(combi{i}(1))))

        end

        loop=0;
        for i=1:size(combi,2)
            for j=1:size(combi,2)
                if i<j
                    loop=loop+1;
                    Comp{loop}=[i j];
                end
            end
        end

        nComp=size(Comp,2);
        pBonferroni=alphaT/nComp;

        for comp=1:nComp
            pBonferroni=alphaT/nComp;
            for i=1:2
                % comparison + name
                DATA{i}=maps1d(indicesEffects(:,mainEffect(1))==combi{Comp{comp}(i)}(1),:);
            end
            posthoc{mainEffect(1)}.differences.names{1,comp}=char([modalitiesAll{mainEffect(1)}{combi{Comp{comp}(1)}(1)} ' - ' modalitiesAll{mainEffect(1)}{combi{Comp{comp}(2)}(1)}]);

            % t-test
            if typeEffectsAll(mainEffect)==1

                % differences
                differencesData=reshape(mean(DATA{1}-DATA{2}),dimensions(1),dimensions(2));
                relativeDifferencesData=reshape(100*mean((DATA{1}-DATA{2})./DATA{2}),dimensions(1),dimensions(2));

                posthoc{mainEffect(1)}.differences.continuum{1,comp}=differencesData;
                posthoc{mainEffect(1)}.differences.continuumRelative{1,comp}=relativeDifferencesData;

                Ttest=spm1d.stats.nonparam.ttest_paired(DATA{1},DATA{2});
                posthoc{mainEffect(1)}.tTests.type{comp}='paired';
                [posthoc{mainEffect(1)}.differences.ES{comp},posthoc{mainEffect(1)}.differences.ESsd{comp}]=esCalculation(DATA);

            else

                % differences
                differencesData=reshape(mean(DATA{1})-mean(DATA{2}),dimensions(1),dimensions(2));
                relativeDifferencesData=reshape(100*(mean(DATA{1})-mean(DATA{2}))./mean(DATA{2}),dimensions(1),dimensions(2));

                posthoc{mainEffect(1)}.differences.continuum{1,comp}=differencesData;
                posthoc{mainEffect(1)}.differences.continuumRelative{1,comp}=relativeDifferencesData;

                Ttest=spm1d.stats.nonparam.ttest2(DATA{1},DATA{2});
                posthoc{mainEffect(1)}.tTests.type{comp}='independant';
                [posthoc{mainEffect(1)}.differences.ES{comp},posthoc{mainEffect(1)}.differences.ESsd{comp}]=esCalculation(DATA);
            end

            posthoc{mainEffect(1)}.differences.ES{comp}=reshape(posthoc{mainEffect(1)}.differences.ES{comp},dimensions(1),dimensions(2));
            posthoc{mainEffect(1)}.differences.ESsd{comp}=reshape(posthoc{mainEffect(1)}.differences.ESsd{comp},dimensions(1),dimensions(2));

            % inference
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
            posthoc{mainEffect(1)}.tTests.contourSignificant{1,comp}=zeros(dimensions(1),dimensions(2));
            posthoc{mainEffect(1)}.tTests.contourSignificant{1,comp}(find(posthoc{mainEffect(1)}.tTests.Tsignificant{1,comp}==1))=abs(posthoc{mainEffect(1)}.tTests.Tcontinuum{1,comp}(find(posthoc{mainEffect(1)}.tTests.Tsignificant{1,comp}==1)));
            datanoAnova=abs(posthoc{mainEffect(1)}.tTests.Tcontinuum{1,comp}(find(posthoc{mainEffect(1)}.tTests.Tsignificant{1,comp}==0)));
            datanoAnova(find(datanoAnova>=posthoc{mainEffect(1)}.tTests.Tthreshold{comp}))=posthoc{mainEffect(1)}.tTests.Tthreshold{comp}-0.01*posthoc{mainEffect(1)}.tTests.Tthreshold{comp};
            posthoc{mainEffect(1)}.tTests.contourSignificant{1,comp}(find(posthoc{mainEffect(1)}.tTests.Tsignificant{1,comp}==0))=datanoAnova;
            posthoc{mainEffect(1)}.tTests.contourSignificant{1,comp}=reshape(posthoc{mainEffect(1)}.tTests.contourSignificant{1,comp},dimensions(1),dimensions(2));

            % full plot of differences
            displayDiffMaps(differencesData,Fs,xlab,ylab,ylimits,nx,ny,limitMeanMaps,xlimits,imageFontSize,imageSize,colorbarLabel,colorMapDiff,diffRatio,equalAxis,deleteAxis)
            if displayContour
                dispContour(abs(posthoc{mainEffect(1)}.tTests.contourSignificant{1,comp}),posthoc{mainEffect(1)}.tTests.Tthreshold{comp},contourColor,dashedColor,transparency,lineWidth,linestyle)
            end
            title(posthoc{mainEffect(1)}.differences.names{1,comp})
            exportgraphics(gcf,fullfile(savedir, verifSaveName(eNames{mainEffect(1)}), 'DIFF', [verifSaveName(posthoc{mainEffect(1)}.differences.names{1,comp}) '.tif']),'Resolution',imageResolution)
            savefig(fullfile(savedir, verifSaveName(eNames{mainEffect(1)}), 'FIG', 'DIFF', verifSaveName(posthoc{mainEffect(1)}.differences.names{1,comp})))
            close

            displayRelativeDiffMaps(relativeDifferencesData,Fs,xlab,ylab,ylimits,nx,ny,xlimits,imageFontSize,imageSize,colorMapDiff,relativeRatio,equalAxis,deleteAxis)
            if displayContour
                dispContour(abs(posthoc{mainEffect(1)}.tTests.contourSignificant{1,comp}),posthoc{mainEffect(1)}.tTests.Tthreshold{comp},contourColor,dashedColor,transparency,lineWidth,linestyle)
            end
            title(posthoc{mainEffect(1)}.differences.names{1,comp})
            exportgraphics(gcf,fullfile(savedir, verifSaveName(eNames{mainEffect(1)}), 'DIFF', [verifSaveName(posthoc{mainEffect(1)}.differences.names{1,comp}) ' %.tif']),'Resolution',imageResolution)
            savefig(fullfile(savedir, verifSaveName(eNames{mainEffect(1)}), 'FIG', 'DIFF', [verifSaveName(posthoc{mainEffect(1)}.differences.names{1,comp}) ' %']))
            close

            % subplot of differences
            set(0, 'currentfigure', f1);
            ax=subplot(nCombi,nCombi,positionDiffPlot(comp));
            displayDiffMaps_sub(differencesData,Fs,limitMeanMaps,diffRatio,colorMapDiff,ax,equalAxis,deleteAxis)
            if displayContour
                dispContour(abs(posthoc{mainEffect(1)}.tTests.contourSignificant{1,comp}),posthoc{mainEffect(1)}.tTests.Tthreshold{comp},contourColor,dashedColor,transparency,1,linestyle)
            end

            % full plot of SnPM analysis
            displayTtest(posthoc{mainEffect(1)}.tTests.Tcontinuum{1,comp},posthoc{mainEffect(1)}.tTests.Tthreshold{comp},[],Fs,xlab,ylab,ylimits,dimensions,nx,ny,xlimits,imageFontSize,imageSize,colorMapDiff,equalAxis,deleteAxis,statLimit)
            if displayContour
                dispContour(abs(posthoc{mainEffect(1)}.tTests.Tcontinuum{1,comp}),posthoc{mainEffect(1)}.tTests.Tthreshold{comp},contourColor,dashedColor,transparency,lineWidth,linestyle)
            end
            title(posthoc{mainEffect(1)}.differences.names{1,comp})
            exportgraphics(gcf,fullfile(savedir, verifSaveName(eNames{mainEffect(1)}), 'SnPM', [verifSaveName(posthoc{mainEffect(1)}.differences.names{1,comp}) '.tif']),'Resolution',imageResolution)
            savefig(fullfile(savedir, verifSaveName(eNames{mainEffect(1)}), 'FIG', 'SnPM', verifSaveName(posthoc{mainEffect(1)}.differences.names{1,comp})))
            close

            %   ES
            displayMapsES(posthoc{mainEffect(1)}.differences.ES{comp},Fs,xlab,ylab,ylimits,nx,ny,xlimits,imageFontSize,imageSize,colorMap,equalAxis,deleteAxis)
            title(posthoc{mainEffect(1)}.differences.names{1,comp})
            if displayContour
                dispContour(abs(posthoc{mainEffect(1)}.tTests.contourSignificant{1,comp}),posthoc{mainEffect(1)}.tTests.Tthreshold{comp},contourColor,dashedColor,transparency,lineWidth,linestyle)
            end
            exportgraphics(gcf,fullfile(savedir, verifSaveName(eNames{mainEffect(1)}), 'ES', [verifSaveName(posthoc{mainEffect(1)}.differences.names{1,comp}) '.tif']),'Resolution',imageResolution)
            savefig(fullfile(savedir, verifSaveName(eNames{mainEffect(1)}), 'FIG', 'ES', verifSaveName(posthoc{mainEffect(1)}.differences.names{1,comp})))
            close

            % subplot of SnPM analysis
            set(0, 'currentfigure', f1);
            ax=subplot(nCombi,nCombi,positionSnPMPlot(comp));
            displayTtest_sub(posthoc{mainEffect(1)}.tTests.Tcontinuum{1,comp},posthoc{mainEffect(1)}.tTests.Tthreshold{comp},Fs,colorMapDiff,ax,equalAxis,deleteAxis,statLimit)

        end

        % save
        set(0, 'currentfigure', f1);
        exportgraphics(gcf,fullfile(savedir, verifSaveName(eNames{mainEffect(1)}), [verifSaveName(eNames{mainEffect(1)}) '.tif']),'Resolution',imageResolution)
        savefig(fullfile(savedir, verifSaveName(eNames{mainEffect(1)}), 'FIG', verifSaveName(eNames{mainEffect(1)})))
        close

        mainForInteraction{mainEffect}=posthoc{mainEffect(1)}.tTests.Tsignificant;
        clear Comp combi isPlot

    end

end
%% T-TESTS 3 EFFECTS - 2 FIXED = 3 MAIN EFFECTS
if nEffects==3

    % choose fixed effects and main effect (tested)
    eff=[1 2; 1 3; 2 3];
    for eff_fixed=1:size(eff,1)
        fixedEffect=eff(eff_fixed,:);
        mainEffect=1:size(eff,1);
        mainEffect(fixedEffect)=[];

        createSavedir2d(fullfile(savedir, verifSaveName(eNames{mainEffect(1)})))
        posthoc{mainEffect(1)}.name=eNames{mainEffect(1)};

        loop=0;
        for i=1:max(indicesEffects(:,mainEffect(1)))
            loop=loop+1;
            combi{loop}=i;
        end
        nCombi=size(combi,2);

        positionDiffPlot=[];
        positionSnPMPlot=[];

        if isempty(imageSize)
            f1=figure('Units', 'Pixels', 'OuterPosition', [0, 0, 720, 480],'visible','off');
        elseif max(size(imageSize))==1
            f1=figure('Units', 'Centimeter', 'OuterPosition', [0, 0, imageSize, imageSize],'visible','off');
        else
            f1=figure('Units', 'Centimeter', 'OuterPosition', [0, 0, imageSize(1), imageSize(2)],'visible','off');
        end

        for i=1:nCombi

            % means
            meansData=reshape(mean(maps1d(indicesEffects(:,mainEffect(1))==combi{i}(1),:)),dimensions(1),dimensions(2));
            stdData=reshape(std(maps1d(indicesEffects(:,mainEffect(1))==combi{i}(1),:)),dimensions(1),dimensions(2));
            posthoc{mainEffect(1)}.data.names{i}=[char(modalitiesAll{mainEffect(1)}(combi{i}(1)))];
            posthoc{mainEffect(1)}.data.meanContinuum{i}=meansData;
            posthoc{mainEffect(1)}.data.sdContinuum{i}=stdData;
            positionDiffPlot=[positionDiffPlot,(i-1)*nCombi+i+1:(i-1)*nCombi+i+1+nCombi-i-1];
            positionSnPMPlot=[positionSnPMPlot,(i)*nCombi+i:nCombi:nCombi.^2-1];

            % full plot of means
            displayMeanMaps(meansData,Fs,xlab,ylab,ylimits,nx,ny,limitMeanMaps,xlimits,imageFontSize,imageSize,colorbarLabel,colorMap,equalAxis,deleteAxis)
            title(char(modalitiesAll{mainEffect(1)}(combi{i}(1))))
            exportgraphics(gcf,fullfile(savedir, verifSaveName(eNames{mainEffect(1)}), [verifSaveName(char(modalitiesAll{mainEffect(1)}(combi{i}(1)))) '.tif']),'Resolution',imageResolution)
            savefig(fullfile(savedir, verifSaveName(eNames{mainEffect(1)}), 'FIG', verifSaveName(char(modalitiesAll{mainEffect(1)}(combi{i}(1))))))
            close

            % full plot of sd
            displayMeanMaps(stdData,Fs,xlab,ylab,ylimits,nx,ny,[],xlimits,imageFontSize,imageSize,colorbarLabel,colorMap,equalAxis,deleteAxis)
            title([char(modalitiesAll{mainEffect(1)}(combi{i}(1)))])
            exportgraphics(gcf,fullfile(savedir, verifSaveName(eNames{mainEffect(1)}), 'SD', [verifSaveName(char(modalitiesAll{mainEffect(1)}(combi{i}(1)))) '.tif']),'Resolution',imageResolution)
            savefig(fullfile(savedir, verifSaveName(eNames{mainEffect(1)}), 'FIG', 'SD', verifSaveName(char(modalitiesAll{mainEffect(1)}(combi{i}(1))))))
            close

            % subplot of means
            set(0, 'currentfigure', f1);
            subplot(nCombi,nCombi,nCombi*(i-1)+i)
            displayMeanMaps_sub(meansData,Fs,limitMeanMaps,colorMap,equalAxis,deleteAxis)
            title(char(modalitiesAll{mainEffect(1)}(combi{i}(1))))

        end

        loop=0;
        for i=1:size(combi,2)
            for j=1:size(combi,2)
                if i<j
                    loop=loop+1;
                    Comp{loop}=[i j];
                end
            end
        end

        nComp=size(Comp,2);
        pBonferroni=alphaT/nComp;

        for comp=1:nComp
            pBonferroni=alphaT/nComp;

            for i=1:2
                % comparison + name
                DATA{i}=maps1d(indicesEffects(:,mainEffect(1))==combi{Comp{comp}(i)}(1),:);
            end
            posthoc{mainEffect(1)}.differences.names{1,comp}=char([modalitiesAll{mainEffect(1)}{combi{Comp{comp}(1)}(1)} ' - ' modalitiesAll{mainEffect(1)}{combi{Comp{comp}(2)}(1)}]);


            % t-test
            if typeEffectsAll(mainEffect)==1
                differencesData=reshape(mean(DATA{1}-DATA{2}),dimensions(1),dimensions(2));
                relativeDifferencesData=reshape(100*mean((DATA{1}-DATA{2})./DATA{2}),dimensions(1),dimensions(2));

                posthoc{mainEffect(1)}.differences.continuum{1,comp}=differencesData;
                posthoc{mainEffect(1)}.differences.continuumRelative{1,comp}=relativeDifferencesData;

                Ttest=spm1d.stats.nonparam.ttest_paired(DATA{1},DATA{2});
                posthoc{mainEffect(1)}.tTests.type{comp}='paired';
                [posthoc{mainEffect(1)}.differences.ES{comp},posthoc{mainEffect(1)}.differences.ESsd{comp}]=esCalculation(DATA);
            else
                differencesData=reshape(mean(DATA{1})-mean(DATA{2}),dimensions(1),dimensions(2));
                relativeDifferencesData=reshape(100*(mean(DATA{1})-mean(DATA{2}))./mean(DATA{2}),dimensions(1),dimensions(2));

                posthoc{mainEffect(1)}.differences.continuum{1,comp}=differencesData;
                posthoc{mainEffect(1)}.differences.continuumRelative{1,comp}=relativeDifferencesData;

                Ttest=spm1d.stats.nonparam.ttest2(DATA{1},DATA{2});
                posthoc{mainEffect(1)}.tTests.type{comp}='independant';
                [posthoc{mainEffect(1)}.differences.ES{comp},posthoc{mainEffect(1)}.differences.ESsd{comp}]=esCalculation(DATA);
            end

            posthoc{mainEffect(1)}.differences.ES{comp}=reshape(posthoc{mainEffect(1)}.differences.ES{comp},dimensions(1),dimensions(2));
            posthoc{mainEffect(1)}.differences.ESsd{comp}=reshape(posthoc{mainEffect(1)}.differences.ESsd{comp},dimensions(1),dimensions(2));

            % inference
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
            posthoc{mainEffect(1)}.tTests.contourSignificant{1,comp}=zeros(dimensions(1),dimensions(2));
            posthoc{mainEffect(1)}.tTests.contourSignificant{1,comp}(find(posthoc{mainEffect(1)}.tTests.Tsignificant{1,comp}==1))=abs(posthoc{mainEffect(1)}.tTests.Tcontinuum{1,comp}(find(posthoc{mainEffect(1)}.tTests.Tsignificant{1,comp}==1)));
            datanoAnova=abs(posthoc{mainEffect(1)}.tTests.Tcontinuum{1,comp}(find(posthoc{mainEffect(1)}.tTests.Tsignificant{1,comp}==0)));
            datanoAnova(find(datanoAnova>=posthoc{mainEffect(1)}.tTests.Tthreshold{comp}))=posthoc{mainEffect(1)}.tTests.Tthreshold{comp}-0.01*posthoc{mainEffect(1)}.tTests.Tthreshold{comp};
            posthoc{mainEffect(1)}.tTests.contourSignificant{1,comp}(find(posthoc{mainEffect(1)}.tTests.Tsignificant{1,comp}==0))=datanoAnova;
            posthoc{mainEffect(1)}.tTests.contourSignificant{1,comp}=reshape(posthoc{mainEffect(1)}.tTests.contourSignificant{1,comp},dimensions(1),dimensions(2));

            % full plot of differences
            displayDiffMaps(differencesData,Fs,xlab,ylab,ylimits,nx,ny,limitMeanMaps,xlimits,imageFontSize,imageSize,colorbarLabel,colorMapDiff,diffRatio,equalAxis,deleteAxis)
            if displayContour
                dispContour(abs(posthoc{mainEffect(1)}.tTests.contourSignificant{1,comp}),posthoc{mainEffect(1)}.tTests.Tthreshold{comp},contourColor,dashedColor,transparency,lineWidth,linestyle)
            end
            title(posthoc{mainEffect(1)}.differences.names{1,comp})
            exportgraphics(gcf,fullfile(savedir, verifSaveName(eNames{mainEffect(1)}), 'DIFF', [verifSaveName(posthoc{mainEffect(1)}.differences.names{1,comp}) '.tif']),'Resolution',imageResolution)
            savefig(fullfile(savedir, verifSaveName(eNames{mainEffect(1)}), 'FIG', 'DIFF', verifSaveName(posthoc{mainEffect(1)}.differences.names{1,comp})))
            close

            displayRelativeDiffMaps(relativeDifferencesData,Fs,xlab,ylab,ylimits,nx,ny,xlimits,imageFontSize,imageSize,colorMapDiff,relativeRatio,equalAxis,deleteAxis)
            if displayContour
                dispContour(abs(posthoc{mainEffect(1)}.tTests.contourSignificant{1,comp}),posthoc{mainEffect(1)}.tTests.Tthreshold{comp},contourColor,dashedColor,transparency,lineWidth,linestyle)
            end
            title(posthoc{mainEffect(1)}.differences.names{1,comp})
            exportgraphics(gcf,fullfile(savedir, verifSaveName(eNames{mainEffect(1)}), 'DIFF', [verifSaveName(posthoc{mainEffect(1)}.differences.names{1,comp}) ' %.tif']),'Resolution',imageResolution)
            savefig(fullfile(savedir, verifSaveName(eNames{mainEffect(1)}), 'FIG', 'DIFF', [verifSaveName(posthoc{mainEffect(1)}.differences.names{1,comp}) ' %']))
            close

            % subplot of differences
            set(0, 'currentfigure', f1);
            ax=subplot(nCombi,nCombi,positionDiffPlot(comp));
            displayDiffMaps_sub(differencesData,Fs,limitMeanMaps,diffRatio,colorMapDiff,ax,equalAxis,deleteAxis)
            if displayContour
                dispContour(abs(posthoc{mainEffect(1)}.tTests.contourSignificant{1,comp}),posthoc{mainEffect(1)}.tTests.Tthreshold{comp},contourColor,dashedColor,transparency,1,linestyle)
            end

            % full plot of SnPM analysis
            displayTtest(posthoc{mainEffect(1)}.tTests.Tcontinuum{1,comp},posthoc{mainEffect(1)}.tTests.Tthreshold{comp},[],Fs,xlab,ylab,ylimits,dimensions,nx,ny,xlimits,imageFontSize,imageSize,colorMapDiff,equalAxis,deleteAxis,statLimit)
            if displayContour
                dispContour(abs(posthoc{mainEffect(1)}.tTests.Tcontinuum{1,comp}),posthoc{mainEffect(1)}.tTests.Tthreshold{comp},contourColor,dashedColor,transparency,lineWidth,linestyle)
            end
            title(posthoc{mainEffect(1)}.differences.names{1,comp})
            exportgraphics(gcf,fullfile(savedir, verifSaveName(eNames{mainEffect(1)}), 'SnPM', [verifSaveName(posthoc{mainEffect(1)}.differences.names{1,comp}) '.tif']),'Resolution',imageResolution)
            savefig(fullfile(savedir, verifSaveName(eNames{mainEffect(1)}), 'FIG', 'SnPM', verifSaveName(posthoc{mainEffect(1)}.differences.names{1,comp})))
            close

            %   ES
            displayMapsES(posthoc{mainEffect(1)}.differences.ES{comp},Fs,xlab,ylab,ylimits,nx,ny,xlimits,imageFontSize,imageSize,colorMap,equalAxis,deleteAxis)
            title(posthoc{mainEffect(1)}.differences.names{1,comp})
            if displayContour
                dispContour(abs(posthoc{mainEffect(1)}.tTests.contourSignificant{1,comp}),posthoc{mainEffect(1)}.tTests.Tthreshold{comp},contourColor,dashedColor,transparency,lineWidth,linestyle)
            end
            exportgraphics(gcf,fullfile(savedir, verifSaveName(eNames{mainEffect(1)}), 'ES', [verifSaveName(posthoc{mainEffect(1)}.differences.names{1,comp}) '.tif']),'Resolution',imageResolution)
            savefig(fullfile(savedir, verifSaveName(eNames{mainEffect(1)}), 'FIG', 'ES', verifSaveName(posthoc{mainEffect(1)}.differences.names{1,comp})))
            close

            % subplot of SnPM analysis
            set(0, 'currentfigure', f1);
            ax=subplot(nCombi,nCombi,positionSnPMPlot(comp));
            displayTtest_sub(posthoc{mainEffect(1)}.tTests.Tcontinuum{1,comp},posthoc{mainEffect(1)}.tTests.Tthreshold{comp},Fs,colorMapDiff,ax,equalAxis,deleteAxis,statLimit)

        end

        % save
        set(0, 'currentfigure', f1);
        exportgraphics(gcf,fullfile(savedir, verifSaveName(eNames{mainEffect(1)}), [verifSaveName(eNames{mainEffect(1)}) '.tif']),'Resolution',imageResolution)
        savefig(fullfile(savedir, verifSaveName(eNames{mainEffect(1)}), 'FIG', verifSaveName(eNames{mainEffect(1)})))
        close

        mainForInteraction{mainEffect}=posthoc{mainEffect(1)}.tTests.Tsignificant;
        clear Comp combi isPlot

    end
end
%% T-TESTS 3 EFFECTS - 1 FIXED = INTERACTION
if nEffects==3

    % chose fixed effect and the interation effects
    for eff_fixed=1:3
        fixedEffect=eff_fixed;
        mainEffect=1:3;
        mainEffect(eff_fixed)=[];
        anovaFixedCorr=[3 2 1];

        if max(anovaEffects{3+anovaFixedCorr(fixedEffect)})==1 | doAllInteractions==1

            posthoc{3+anovaFixedCorr(fixedEffect)}.name=[eNames{mainEffect(1)} ' x ' eNames{mainEffect(2)}];

            for e=1:2
                createSavedir2dInt(fullfile(savedir, verifSaveName([eNames{mainEffect(1)} ' x ' eNames{mainEffect(2)}]), verifSaveName(eNames{mainEffect(e)})))
            end
            mkdir(fullfile(savedir, verifSaveName([eNames{mainEffect(1)} ' x ' eNames{mainEffect(2)}]), 'SD'));
            mkdir(fullfile(savedir, verifSaveName([eNames{mainEffect(1)} ' x ' eNames{mainEffect(2)}]), 'FIG', 'SD'));

            loop=0;
            for i=1:max(indicesEffects(:,mainEffect(1)))
                for j=1:max(indicesEffects(:,mainEffect(2)))
                    loop=loop+1;
                    combi{loop}=[i j];
                end
            end
            nCombi=size(combi,2);

            positionDiffPlot=[];
            positionSnPMPlot=[];


            if isempty(imageSize)
                f1=figure('Units', 'Pixels', 'OuterPosition', [0, 0, 720, 480],'visible','off');
            elseif max(size(imageSize))==1
                f1=figure('Units', 'Centimeter', 'OuterPosition', [0, 0, imageSize, imageSize],'visible','off');
            else
                f1=figure('Units', 'Centimeter', 'OuterPosition', [0, 0, imageSize(1), imageSize(2)],'visible','off');
            end

            for i=1:nCombi

                % means
                meansData=reshape(mean(maps1d(indicesEffects(:,mainEffect(1))==combi{i}(1) & indicesEffects(:,mainEffect(2))==combi{i}(2),:)),dimensions(1),dimensions(2));
                stdData=reshape(std(maps1d(indicesEffects(:,mainEffect(1))==combi{i}(1) & indicesEffects(:,mainEffect(2))==combi{i}(2),:)),dimensions(1),dimensions(2));
                posthoc{3+anovaFixedCorr(fixedEffect)}.data.names{i}=[char(modalitiesAll{mainEffect(1)}(combi{i}(1))) ' x ' char(modalitiesAll{mainEffect(2)}(combi{i}(2)))];
                posthoc{3+anovaFixedCorr(fixedEffect)}.data.meanContinuum{i}=meansData;
                posthoc{3+anovaFixedCorr(fixedEffect)}.data.sdContinuum{i}=stdData;
                positionDiffPlot=[positionDiffPlot,(i-1)*nCombi+i+1:(i-1)*nCombi+i+1+nCombi-i-1];
                positionSnPMPlot=[positionSnPMPlot,(i)*nCombi+i:nCombi:nCombi.^2-1];

                % full plot of means
                displayMeanMaps(meansData,Fs,xlab,ylab,ylimits,nx,ny,limitMeanMaps,xlimits,imageFontSize,imageSize,colorbarLabel,colorMap,equalAxis,deleteAxis)
                title([char(modalitiesAll{mainEffect(1)}(combi{i}(1))) ' \cap ' char(modalitiesAll{mainEffect(2)}(combi{i}(2)))])
                exportgraphics(gcf,fullfile(savedir, verifSaveName([eNames{mainEffect(1)} ' x ' eNames{mainEffect(2)}]), [verifSaveName([char(modalitiesAll{mainEffect(1)}(combi{i}(1))) ' x ' char(modalitiesAll{mainEffect(2)}(combi{i}(2)))]) '.tif']),'Resolution',imageResolution)
                savefig(fullfile(savedir, verifSaveName([eNames{mainEffect(1)} ' x ' eNames{mainEffect(2)}]), 'FIG', verifSaveName([char(modalitiesAll{mainEffect(1)}(combi{i}(1))) ' x ' char(modalitiesAll{mainEffect(2)}(combi{i}(2)))])))
                close

                % full plot of std
                displayMeanMaps(stdData,Fs,xlab,ylab,ylimits,nx,ny,[],xlimits,imageFontSize,imageSize,colorbarLabel,colorMap,equalAxis,deleteAxis)
                title([char(modalitiesAll{mainEffect(1)}(combi{i}(1))) ' \cap ' char(modalitiesAll{mainEffect(2)}(combi{i}(2)))])
                exportgraphics(gcf,fullfile(savedir, verifSaveName([eNames{mainEffect(1)} ' x ' eNames{mainEffect(2)}]), 'SD', [verifSaveName([char(modalitiesAll{mainEffect(1)}(combi{i}(1))) ' x ' char(modalitiesAll{mainEffect(2)}(combi{i}(2)))]) '.tif']),'Resolution',imageResolution)
                savefig(fullfile(savedir, verifSaveName([eNames{mainEffect(1)} ' x ' eNames{mainEffect(2)}]), 'FIG', 'SD', verifSaveName([char(modalitiesAll{mainEffect(1)}(combi{i}(1))) ' x ' char(modalitiesAll{mainEffect(2)}(combi{i}(2)))])))
                close

                % subplot of means
                set(0, 'currentfigure', f1);
                subplot(nCombi,nCombi,nCombi*(i-1)+i)
                displayMeanMaps_sub(meansData,Fs,limitMeanMaps,colorMap,equalAxis,deleteAxis)
                title([char(modalitiesAll{mainEffect(1)}(combi{i}(1))) ' \cap ' char(modalitiesAll{mainEffect(2)}(combi{i}(2)))])

            end

            loop=0;
            loopForPlot=0;
            for i=1:size(combi,2)
                for j=1:size(combi,2)
                    if i<j
                        loopForPlot=loopForPlot+1;
                        if max(size(find(combi{i}~=combi{j})))==1
                            loop=loop+1;
                            Comp{loop}=[i j];
                            isPlot(loopForPlot)=1;
                            testedEffect{loop}=find(combi{i}~=combi{j});
                        end
                    end
                end
            end

            nComp=size(Comp,2);
            pBonferroni=alphaT/nComp;

            isPlot=find(isPlot==1);

            for comp=1:nComp

                pBonferroni=alphaT/nComp;

                for i=1:2
                    % comparison + name
                    DATA{i}=maps1d(indicesEffects(:,mainEffect(1))==combi{Comp{comp}(i)}(1) & indicesEffects(:,mainEffect(2))==combi{Comp{comp}(i)}(2),:);
                    intForInteractions{anovaFixedCorr(eff_fixed)}.comp{comp}(i,:)=combi{Comp{comp}(i)};
                end
                [eFixed,eTested,modalFixed,modalTested]=findWhichTitle([combi{Comp{comp}(1)};combi{Comp{comp}(2)}]);
                posthoc{3+anovaFixedCorr(fixedEffect)}.differences.names{1,comp}=char([modalitiesAll{mainEffect(eFixed)}{modalFixed} ' (' modalitiesAll{mainEffect(eTested)}{modalTested(1)} ' - ' modalitiesAll{mainEffect(eTested)}{modalTested(2)} ')']);


                % t-test
                if typeEffectsAll(mainEffect(eTested))==1
                    differencesData=reshape(mean(DATA{1}-DATA{2}),dimensions(1),dimensions(2));
                    relativeDifferencesData=reshape(100*mean((DATA{1}-DATA{2})./DATA{2}),dimensions(1),dimensions(2));

                    posthoc{3+anovaFixedCorr(fixedEffect)}.differences.continuum{1,comp}=differencesData;
                    posthoc{3+anovaFixedCorr(fixedEffect)}.differences.continuumRelative{1,comp}=relativeDifferencesData;

                    Ttest=spm1d.stats.nonparam.ttest_paired(DATA{1},DATA{2});
                    posthoc{3+anovaFixedCorr(fixedEffect)}.tTests.type{comp}='paired';
                    [posthoc{3+anovaFixedCorr(fixedEffect)}.differences.ES{comp},posthoc{3+anovaFixedCorr(fixedEffect)}.differences.ESsd{comp}]=esCalculation(DATA);
                else
                    differencesData=reshape(mean(DATA{1})-mean(DATA{2}),dimensions(1),dimensions(2));
                    relativeDifferencesData=reshape(100*(mean(DATA{1})-mean(DATA{2}))./mean(DATA{2}),dimensions(1),dimensions(2));

                    posthoc{3+anovaFixedCorr(fixedEffect)}.differences.continuum{1,comp}=differencesData;
                    posthoc{3+anovaFixedCorr(fixedEffect)}.differences.continuumRelative{1,comp}=relativeDifferencesData;

                    Ttest=spm1d.stats.nonparam.ttest2(DATA{1},DATA{2});
                    posthoc{3+anovaFixedCorr(fixedEffect)}.tTests.type{comp}='independant';
                    [posthoc{3+anovaFixedCorr(fixedEffect)}.differences.ES{comp},posthoc{3+anovaFixedCorr(fixedEffect)}.differences.ESsd{comp}]=esCalculation(DATA);
                end

                posthoc{3+anovaFixedCorr(fixedEffect)}.differences.ES{comp}=reshape(posthoc{3+anovaFixedCorr(fixedEffect)}.differences.ES{comp},dimensions(1),dimensions(2));
                posthoc{3+anovaFixedCorr(fixedEffect)}.differences.ESsd{comp}=reshape(posthoc{3+anovaFixedCorr(fixedEffect)}.differences.ESsd{comp},dimensions(1),dimensions(2));

                % inference
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
                posthoc{3+anovaFixedCorr(fixedEffect)}.tTests.contourSignificant{1,comp}=zeros(dimensions(1),dimensions(2));
                posthoc{3+anovaFixedCorr(fixedEffect)}.tTests.contourSignificant{1,comp}(find(posthoc{3+anovaFixedCorr(fixedEffect)}.tTests.Tsignificant{1,comp}==1))=1.1*posthoc{3+anovaFixedCorr(fixedEffect)}.tTests.Tthreshold{comp};

                % full plot of differences
                displayDiffMaps(differencesData,Fs,xlab,ylab,ylimits,nx,ny,limitMeanMaps,xlimits,imageFontSize,imageSize,colorbarLabel,colorMapDiff,diffRatio,equalAxis,deleteAxis)
                if displayContour
                    dispContour(abs(posthoc{3+anovaFixedCorr(fixedEffect)}.tTests.contourSignificant{1,comp}),posthoc{3+anovaFixedCorr(fixedEffect)}.tTests.Tthreshold{comp},contourColor,dashedColor,transparency,lineWidth,linestyle)
                end
                title(posthoc{3+anovaFixedCorr(fixedEffect)}.differences.names{1,comp})
                exportgraphics(gcf,fullfile(savedir, verifSaveName([eNames{mainEffect(1)} ' x ' eNames{mainEffect(2)}]), verifSaveName(eNames{mainEffect(eTested)}), 'DIFF', [verifSaveName(posthoc{3+anovaFixedCorr(fixedEffect)}.differences.names{1,comp}) '.tif']),'Resolution',imageResolution)
                savefig(fullfile(savedir, verifSaveName([eNames{mainEffect(1)} ' x ' eNames{mainEffect(2)}]), verifSaveName(eNames{mainEffect(eTested)}), 'FIG', 'DIFF', verifSaveName(posthoc{3+anovaFixedCorr(fixedEffect)}.differences.names{1,comp})))
                close

                displayRelativeDiffMaps(relativeDifferencesData,Fs,xlab,ylab,ylimits,nx,ny,xlimits,imageFontSize,imageSize,colorMapDiff,relativeRatio,equalAxis,deleteAxis)
                if displayContour
                    dispContour(abs(posthoc{3+anovaFixedCorr(fixedEffect)}.tTests.contourSignificant{1,comp}),posthoc{3+anovaFixedCorr(fixedEffect)}.tTests.Tthreshold{comp},contourColor,dashedColor,transparency,lineWidth,linestyle)
                end
                title(posthoc{3+anovaFixedCorr(fixedEffect)}.differences.names{1,comp})
                exportgraphics(gcf,fullfile(savedir, verifSaveName([eNames{mainEffect(1)} ' x ' eNames{mainEffect(2)}]), verifSaveName(eNames{mainEffect(eTested)}), 'DIFF', [verifSaveName(posthoc{3+anovaFixedCorr(fixedEffect)}.differences.names{1,comp}) ' %.tif']),'Resolution',imageResolution)
                savefig(fullfile(savedir, verifSaveName([eNames{mainEffect(1)} ' x ' eNames{mainEffect(2)}]), verifSaveName(eNames{mainEffect(eTested)}), 'FIG', 'DIFF', [verifSaveName(posthoc{3+anovaFixedCorr(fixedEffect)}.differences.names{1,comp}) ' %']))
                close


                % subplot of differences
                set(0, 'currentfigure', f1);
                ax=subplot(nCombi,nCombi,positionDiffPlot(isPlot(comp)));
                displayDiffMaps_sub(differencesData,Fs,limitMeanMaps,diffRatio,colorMapDiff,ax,equalAxis,deleteAxis)
                if displayContour
                    dispContour(abs(posthoc{3+anovaFixedCorr(fixedEffect)}.tTests.contourSignificant{1,comp}),posthoc{3+anovaFixedCorr(fixedEffect)}.tTests.Tthreshold{comp},contourColor,dashedColor,transparency,1,linestyle)
                end

                % full plot of SnPM analysis
                displayTtest(posthoc{3+anovaFixedCorr(fixedEffect)}.tTests.Tcontinuum{1,comp},posthoc{3+anovaFixedCorr(fixedEffect)}.tTests.Tthreshold{comp},[],Fs,xlab,ylab,ylimits,dimensions,nx,ny,xlimits,imageFontSize,imageSize,colorMapDiff,equalAxis,deleteAxis,statLimit)
                if displayContour
                    dispContour(abs(posthoc{3+anovaFixedCorr(fixedEffect)}.tTests.Tcontinuum{1,comp}),posthoc{3+anovaFixedCorr(fixedEffect)}.tTests.Tthreshold{comp},contourColor,dashedColor,transparency,lineWidth,linestyle)
                end
                title(posthoc{3+anovaFixedCorr(fixedEffect)}.differences.names{1,comp})
                exportgraphics(gcf,fullfile(savedir, verifSaveName([eNames{mainEffect(1)} ' x ' eNames{mainEffect(2)}]), verifSaveName(eNames{mainEffect(eTested)}), 'SnPM', [verifSaveName(posthoc{3+anovaFixedCorr(fixedEffect)}.differences.names{1,comp}) '.tif']),'Resolution',imageResolution)
                savefig(fullfile(savedir, verifSaveName([eNames{mainEffect(1)} ' x ' eNames{mainEffect(2)}]), verifSaveName(eNames{mainEffect(eTested)}), 'FIG', 'SnPM', verifSaveName(posthoc{3+anovaFixedCorr(fixedEffect)}.differences.names{1,comp})))
                close

                %   ES
                displayMapsES(posthoc{3+anovaFixedCorr(fixedEffect)}.differences.ES{comp},Fs,xlab,ylab,ylimits,nx,ny,xlimits,imageFontSize,imageSize,colorMap,equalAxis,deleteAxis)
                title(posthoc{3+anovaFixedCorr(fixedEffect)}.differences.names{1,comp})
                if displayContour
                    dispContour(abs(posthoc{3+anovaFixedCorr(fixedEffect)}.tTests.contourSignificant{1,comp}),posthoc{3+anovaFixedCorr(fixedEffect)}.tTests.Tthreshold{comp},contourColor,dashedColor,transparency,lineWidth,linestyle)
                end
                exportgraphics(gcf,fullfile(savedir, verifSaveName([eNames{mainEffect(1)} ' x ' eNames{mainEffect(2)}]), verifSaveName(eNames{mainEffect(eTested)}), 'ES', [verifSaveName(posthoc{3+anovaFixedCorr(fixedEffect)}.differences.names{1,comp}) '.tif']),'Resolution',imageResolution)
                savefig(fullfile(savedir, verifSaveName([eNames{mainEffect(1)} ' x ' eNames{mainEffect(2)}]), verifSaveName(eNames{mainEffect(eTested)}), 'FIG', 'ES', verifSaveName(posthoc{3+anovaFixedCorr(fixedEffect)}.differences.names{1,comp})))
                close

                % subplot of SnPM analysis
                set(0, 'currentfigure', f1);
                ax=subplot(nCombi,nCombi,positionSnPMPlot(isPlot(comp)));
                displayTtest_sub(posthoc{3+anovaFixedCorr(fixedEffect)}.tTests.Tcontinuum{1,comp},posthoc{3+anovaFixedCorr(fixedEffect)}.tTests.Tthreshold{comp},Fs,colorMapDiff,ax,equalAxis,deleteAxis,statLimit)

            end

            % save
            set(0, 'currentfigure', f1);
            exportgraphics(gcf,fullfile(savedir, verifSaveName([eNames{mainEffect(1)} ' x ' eNames{mainEffect(2)}]) , [verifSaveName([eNames{mainEffect(1)} ' x ' eNames{mainEffect(2)}]) '.tif']),'Resolution',imageResolution)
            savefig(fullfile(savedir, verifSaveName([eNames{mainEffect(1)} ' x ' eNames{mainEffect(2)}]) , 'FIG', verifSaveName([eNames{mainEffect(1)} ' x ' eNames{mainEffect(2)}])))
            close

            intForInteractions{anovaFixedCorr(eff_fixed)}.t=realEffect;
            clear Comp combi isPlot realEffect

        end
    end
end

%% T-TESTS ALL INTERACTIONS (ANOVA 2 and 3)
if nEffects>1

    if nEffects==2
        isInteraction=max(anovaEffects{3});
        savedir2=[verifSaveName([eNames{1} ' x ' eNames{2}])] ;
        pos=3;
        posthoc{pos}.name=[eNames{1} ' x ' eNames{2}];
        if isInteraction==1 | doAllInteractions==1
            createSavedir2dInt(fullfile(savedir, savedir2, verifSaveName(eNames{1})))
            createSavedir2dInt(fullfile(savedir, savedir2, verifSaveName(eNames{2})))
        end
        figname =[verifSaveName([eNames{1} ' x ' eNames{2}])];
    elseif nEffects==3
        isInteraction=max(anovaEffects{7});
        savedir2=[verifSaveName([eNames{1} ' x ' eNames{2} ' x ' eNames{3}])];
        pos=7;
        posthoc{pos}.name=[eNames{1} ' x ' eNames{2} ' x ' eNames{3}];
        if isInteraction==1 | doAllInteractions==1
            createSavedir2dInt(fullfile(savedir, savedir2, verifSaveName(eNames{1})))
            createSavedir2dInt(fullfile(savedir, savedir2, verifSaveName(eNames{2})))
            createSavedir2dInt(fullfile(savedir, savedir2, verifSaveName(eNames{3})))
        end
        figname=[verifSaveName([eNames{1} ' x ' eNames{2} ' x ' eNames{3}])];
    end
    mkdir(fullfile(savedir, savedir2, 'SD'));
    mkdir(fullfile(savedir, savedir2, 'FIG', 'SD'));

    if isInteraction==1 | doAllInteractions==1

        loop=0;
        positionDiffPlot=[];
        positionSnPMPlot=[];


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

            for i=1:nCombi

                if size(maps1d(indicesEffects(:,1)==combi{i}(1) & indicesEffects(:,2)==combi{i}(2),:),1)>1
                    meansData=reshape(mean(maps1d(indicesEffects(:,1)==combi{i}(1) & indicesEffects(:,2)==combi{i}(2),:)),dimensions(1),dimensions(2));
                    stdData=reshape(std(maps1d(indicesEffects(:,1)==combi{i}(1) & indicesEffects(:,2)==combi{i}(2),:)),dimensions(1),dimensions(2));

                    % full plot of sd
                    displayMeanMaps(stdData,Fs,xlab,ylab,ylimits,nx,ny,[],xlimits,imageFontSize,imageSize,colorbarLabel,colorMap,equalAxis,deleteAxis)
                    title([char(modalitiesAll{1}(combi{i}(1))) ' \cap ' char(modalitiesAll{2}(combi{i}(2)))])
                    exportgraphics(gcf,fullfile(savedir, savedir2, 'SD', [verifSaveName([char(modalitiesAll{1}(combi{i}(1))) ' x ' char(modalitiesAll{2}(combi{i}(2)))]) '.tif']),'Resolution',imageResolution)
                    savefig(fullfile(savedir, savedir2, 'FIG', 'SD', verifSaveName([char(modalitiesAll{1}(combi{i}(1))) ' x ' char(modalitiesAll{2}(combi{i}(2)))])))
                    close
                else
                    meansData=reshape(maps1d(indicesEffects(:,1)==combi{i}(1) & indicesEffects(:,2)==combi{i}(2),:),dimensions(1),dimensions(2));
                end
                positionDiffPlot=[positionDiffPlot,(i-1)*nCombi+i+1:(i-1)*nCombi+i+1+nCombi-i-1];
                positionSnPMPlot=[positionSnPMPlot,(i)*nCombi+i:nCombi:nCombi.^2-1];

                posthoc{pos}.data.names{i}=[char(modalitiesAll{1}(combi{i}(1))) ' x ' char(modalitiesAll{2}(combi{i}(2)))];
                posthoc{pos}.data.meanContinuum{i}=meansData;
                posthoc{pos}.data.sdContinuum{i}=stdData;

                % full plot of means
                displayMeanMaps(meansData,Fs,xlab,ylab,ylimits,nx,ny,limitMeanMaps,xlimits,imageFontSize,imageSize,colorbarLabel,colorMap,equalAxis,deleteAxis)
                title([char(modalitiesAll{1}(combi{i}(1))) ' \cap ' char(modalitiesAll{2}(combi{i}(2)))])
                exportgraphics(gcf,fullfile(savedir, savedir2, [verifSaveName([char(modalitiesAll{1}(combi{i}(1))) ' x ' char(modalitiesAll{2}(combi{i}(2)))]) '.tif']),'Resolution',imageResolution)
                savefig(fullfile(savedir, savedir2, 'FIG', verifSaveName([char(modalitiesAll{1}(combi{i}(1))) ' x ' char(modalitiesAll{2}(combi{i}(2)))])))
                close

                % subplot of means
                set(0, 'currentfigure', f1);
                subplot(nCombi,nCombi,nCombi*(i-1)+i)
                displayMeanMaps_sub(meansData,Fs,limitMeanMaps,colorMap,equalAxis,deleteAxis)
                title([char(modalitiesAll{1}(combi{i}(1))) ' \cap ' char(modalitiesAll{2}(combi{i}(2)))])

            end

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

            for i=1:nCombi

                if size(maps1d(indicesEffects(:,1)==combi{i}(1) & indicesEffects(:,2)==combi{i}(2) & indicesEffects(:,3)==combi{i}(3),:),1)>1
                    meansData=reshape(mean(maps1d(indicesEffects(:,1)==combi{i}(1) & indicesEffects(:,2)==combi{i}(2) & indicesEffects(:,3)==combi{i}(3),:)),dimensions(1),dimensions(2));
                    stdData=reshape(std(maps1d(indicesEffects(:,1)==combi{i}(1) & indicesEffects(:,2)==combi{i}(2) & indicesEffects(:,3)==combi{i}(3),:)),dimensions(1),dimensions(2));
                    % full plot std
                    displayMeanMaps(stdData,Fs,xlab,ylab,ylimits,nx,ny,[],xlimits,imageFontSize,imageSize,colorbarLabel,colorMap,equalAxis,deleteAxis)
                    title([char(modalitiesAll{1}(combi{i}(1))) ' \cap ' char(modalitiesAll{2}(combi{i}(2))) ' \cap ' char(modalitiesAll{3}(combi{i}(3)))])
                    exportgraphics(gcf,fullfile(savedir, savedir2, 'SD', [verifSaveName([char(modalitiesAll{1}(combi{i}(1))) ' x ' char(modalitiesAll{2}(combi{i}(2))) ' x ' char(modalitiesAll{3}(combi{i}(3)))]) '.tif']),'Resolution',imageResolution)
                    savefig(fullfile(savedir, savedir2, 'FIG', 'SD', verifSaveName([char(modalitiesAll{1}(combi{i}(1))) ' x ' char(modalitiesAll{2}(combi{i}(2))) ' x ' char(modalitiesAll{3}(combi{i}(3)))])))
                    close
                else
                    meansData=reshape(maps1d(indicesEffects(:,1)==combi{i}(1) & indicesEffects(:,2)==combi{i}(2) & indicesEffects(:,3)==combi{i}(3),:),dimensions(1),dimensions(2));
                end
                positionDiffPlot=[positionDiffPlot,(i-1)*nCombi+i+1:(i-1)*nCombi+i+1+nCombi-i-1];
                positionSnPMPlot=[positionSnPMPlot,(i)*nCombi+i:nCombi:nCombi.^2-1];
                posthoc{pos}.data.names{i}=[char(modalitiesAll{1}(combi{i}(1))) ' x ' char(modalitiesAll{2}(combi{i}(2))) ' x ' char(modalitiesAll{3}(combi{i}(3)))];
                posthoc{pos}.data.meanContinuum{i}=meansData;
                posthoc{pos}.data.sdContinuum{i}=stdData;

                % full plot of means
                displayMeanMaps(meansData,Fs,xlab,ylab,ylimits,nx,ny,limitMeanMaps,xlimits,imageFontSize,imageSize,colorbarLabel,colorMap,equalAxis,deleteAxis)
                title([char(modalitiesAll{1}(combi{i}(1))) ' \cap ' char(modalitiesAll{2}(combi{i}(2))) ' \cap ' char(modalitiesAll{3}(combi{i}(3)))])
                exportgraphics(gcf,fullfile(savedir, savedir2, [verifSaveName([char(modalitiesAll{1}(combi{i}(1))) ' x ' char(modalitiesAll{2}(combi{i}(2))) ' x ' char(modalitiesAll{3}(combi{i}(3)))]) '.tif']),'Resolution',imageResolution)
                savefig(fullfile(savedir, savedir2, 'FIG', verifSaveName([char(modalitiesAll{1}(combi{i}(1))) ' x ' char(modalitiesAll{2}(combi{i}(2))) ' x ' char(modalitiesAll{3}(combi{i}(3)))])))
                close

                % subplot of means
                set(0, 'currentfigure', f1);
                subplot(nCombi,nCombi,nCombi*(i-1)+i)
                displayMeanMaps_sub(meansData,Fs,limitMeanMaps,colorMap,equalAxis,deleteAxis)
                title([char(modalitiesAll{1}(combi{i}(1))) ' \cap ' char(modalitiesAll{2}(combi{i}(2))) ' \cap ' char(modalitiesAll{3}(combi{i}(3)))])

            end

        end

        % number of comparisons + plot of each
        loop=0;
        loopForPlot=0;
        for i=1:size(combi,2)
            for j=1:size(combi,2)
                if i<j
                    loopForPlot=loopForPlot+1;
                    if max(size(find(combi{i}~=combi{j})))==1
                        loop=loop+1;
                        Comp{loop}=[i j];
                        isPlot(loopForPlot)=1;
                        testedEffect{loop}=find(combi{i}~=combi{j});
                    end
                end
            end
        end

        nComp=size(Comp,2);
        pBonferroni=alphaT/nComp;

        isPlot=find(isPlot==1);


        for comp=1:nComp


            for i=1:2
                % comparison + name
                if nEffects==2
                    DATA{i}=maps1d(indicesEffects(:,1)==combi{Comp{comp}(i)}(1) & indicesEffects(:,2)==combi{Comp{comp}(i)}(2),:);
                    [eFixed,eTested,modalFixed,modalTested]=findWhichTitle([combi{Comp{comp}(1)};combi{Comp{comp}(2)}]);
                    posthoc{pos}.differences.names{1,comp}=char([modalitiesAll{eFixed}{modalFixed} ' (' modalitiesAll{eTested}{modalTested(1)} ' - ' modalitiesAll{eTested}{modalTested(2)} ')']);
                elseif nEffects==3
                    DATA{i}=maps1d(indicesEffects(:,1)==combi{Comp{comp}(i)}(1) & indicesEffects(:,2)==combi{Comp{comp}(i)}(2) & indicesEffects(:,3)==combi{Comp{comp}(i)}(3),:);
                    [eFixed,eTested,modalFixed,modalTested]=findWhichTitle([combi{Comp{comp}(1)};combi{Comp{comp}(2)}]);
                    posthoc{pos}.differences.names{1,comp}=char([modalitiesAll{eFixed(1)}{modalFixed(1)} ' x ' modalitiesAll{eFixed(2)}{modalFixed(2)} ' (' modalitiesAll{eTested}{modalTested(1)} ' - ' modalitiesAll{eTested}{modalTested(2)} ')']);
                end
            end

            % t-test
            if typeEffectsAll(eTested)==1
                differencesData=reshape(mean(DATA{1}-DATA{2}),dimensions(1),dimensions(2));
                relativeDifferencesData=reshape(100*mean((DATA{1}-DATA{2})./DATA{2}),dimensions(1),dimensions(2));

                posthoc{pos}.differences.continuum{1,comp}=differencesData;
                posthoc{pos}.differences.continuumRelative{1,comp}=relativeDifferencesData;

                Ttest=spm1d.stats.nonparam.ttest_paired(DATA{1},DATA{2});
                posthoc{pos}.tTests.type{comp}='paired';
                [posthoc{pos}.differences.ES{comp},posthoc{pos}.differences.ESsd{comp}]=esCalculation(DATA);
            else
                differencesData=reshape(mean(DATA{1})-mean(DATA{2}),dimensions(1),dimensions(2));
                relativeDifferencesData=reshape(100*(mean(DATA{1})-mean(DATA{2}))./mean(DATA{2}),dimensions(1),dimensions(2));

                posthoc{pos}.differences.continuum{1,comp}=differencesData;
                posthoc{pos}.differences.continuumRelative{1,comp}=relativeDifferencesData;

                Ttest=spm1d.stats.nonparam.ttest2(DATA{1},DATA{2});
                posthoc{pos}.tTests.type{comp}='independant';
                [posthoc{pos}.differences.ES{comp},posthoc{pos}.differences.ESsd{comp}]=esCalculation(DATA);
            end

            posthoc{pos}.differences.ES{comp}=reshape(posthoc{pos}.differences.ES{comp},dimensions(1),dimensions(2));
            posthoc{pos}.differences.ESsd{comp}=reshape(posthoc{pos}.differences.ESsd{comp},dimensions(1),dimensions(2));

            % inference
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
            mapLogical=abs(posthoc{pos}.tTests.Tcontinuum{1,comp})>=posthoc{pos}.tTests.Tthreshold{comp}; % significant clusters
            if nEffects==2
                % main effect
                indiceMain=findWhichMain(modalitiesAll{testedEffect{comp}},combi{Comp{comp}(1)}(testedEffect{comp}),combi{Comp{comp}(2)}(testedEffect{comp}));
                tMainEffect=abs(mainForInteraction{testedEffect{comp}}{indiceMain})>0;
                % interaction effect
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
            posthoc{pos}.tTests.contourSignificant{1,comp}=zeros(dimensions(1),dimensions(2));
            posthoc{pos}.tTests.contourSignificant{1,comp}(find(posthoc{pos}.tTests.Tsignificant{1,comp}==1))=1.1*posthoc{pos}.tTests.Tthreshold{comp};

            % full plot of SnPM analysis
            displayTtest(posthoc{pos}.tTests.Tcontinuum{1,comp},posthoc{pos}.tTests.Tthreshold{comp},[],Fs,xlab,ylab,ylimits,dimensions,nx,ny,xlimits,imageFontSize,imageSize,colorMapDiff,equalAxis,deleteAxis,statLimit)
            if displayContour
                dispContour(abs(posthoc{pos}.tTests.Tcontinuum{1,comp}),posthoc{pos}.tTests.Tthreshold{comp},contourColor,dashedColor,transparency,lineWidth,linestyle)
            end
            title(posthoc{pos}.differences.names{1,comp})
            exportgraphics(gcf,fullfile(savedir, savedir2, verifSaveName(eNames{testedEffect{comp}}), 'SnPM', [verifSaveName(posthoc{pos}.differences.names{1,comp}) '.tif']),'Resolution',imageResolution)
            savefig(fullfile(savedir, savedir2, verifSaveName(eNames{testedEffect{comp}}), 'FIG', 'SnPM', verifSaveName(posthoc{pos}.differences.names{1,comp})))
            close

            % full plot of differences
            displayDiffMaps(differencesData,Fs,xlab,ylab,ylimits,nx,ny,limitMeanMaps,xlimits,imageFontSize,imageSize,colorbarLabel,colorMapDiff,diffRatio,equalAxis,deleteAxis)
            if displayContour
                dispContour(abs(posthoc{pos}.tTests.contourSignificant{1,comp}),posthoc{pos}.tTests.Tthreshold{comp},contourColor,dashedColor,transparency,lineWidth,linestyle)
            end
            title(posthoc{pos}.differences.names{1,comp})
            exportgraphics(gcf,fullfile(savedir, savedir2, verifSaveName(eNames{testedEffect{comp}}), 'DIFF', [verifSaveName(posthoc{pos}.differences.names{1,comp}) '.tif']),'Resolution',imageResolution)
            savefig(fullfile(savedir, savedir2, verifSaveName(eNames{testedEffect{comp}}), 'FIG', 'DIFF', verifSaveName(posthoc{pos}.differences.names{1,comp})))
            close

            displayRelativeDiffMaps(relativeDifferencesData,Fs,xlab,ylab,ylimits,nx,ny,xlimits,imageFontSize,imageSize,colorMapDiff,relativeRatio,equalAxis,deleteAxis)
            if displayContour
                dispContour(abs(posthoc{pos}.tTests.contourSignificant{1,comp}),posthoc{pos}.tTests.Tthreshold{comp},contourColor,dashedColor,transparency,lineWidth,linestyle)
            end
            title(posthoc{pos}.differences.names{1,comp})
            exportgraphics(gcf,fullfile(savedir, savedir2, verifSaveName(eNames{testedEffect{comp}}), 'DIFF', [verifSaveName(posthoc{pos}.differences.names{1,comp}) ' %.tif']),'Resolution',imageResolution)
            savefig(fullfile(savedir, savedir2, verifSaveName(eNames{testedEffect{comp}}), 'FIG', 'DIFF', [verifSaveName(posthoc{pos}.differences.names{1,comp}) ' %']))
            close

            %   ES
            displayMapsES(posthoc{pos}.differences.ES{comp},Fs,xlab,ylab,ylimits,nx,ny,xlimits,imageFontSize,imageSize,colorMap,equalAxis,deleteAxis)
            title(posthoc{pos}.differences.names{1,comp})
            if displayContour
                dispContour(abs(posthoc{pos}.tTests.contourSignificant{1,comp}),posthoc{pos}.tTests.Tthreshold{comp},contourColor,dashedColor,transparency,lineWidth,linestyle)
            end
            exportgraphics(gcf,fullfile(savedir, savedir2, verifSaveName(eNames{testedEffect{comp}}), 'ES', [verifSaveName(posthoc{pos}.differences.names{1,comp}) '.tif']),'Resolution',imageResolution)
            savefig(fullfile(savedir, savedir2, verifSaveName(eNames{testedEffect{comp}}), 'FIG', 'ES', verifSaveName(posthoc{pos}.differences.names{1,comp})))
            close

            % subplot of SnPM analysis
            set(0, 'currentfigure', f1);
            ax=subplot(nCombi,nCombi,positionSnPMPlot(isPlot(comp)));
            displayTtest_sub(posthoc{pos}.tTests.Tcontinuum{1,comp},posthoc{pos}.tTests.Tthreshold{comp},Fs,colorMapDiff,ax,equalAxis,deleteAxis,statLimit)

            % subplot of differences
            set(0, 'currentfigure', f1);
            ax=subplot(nCombi,nCombi,positionDiffPlot(isPlot(comp)));
            displayDiffMaps_sub(differencesData,Fs,limitMeanMaps,diffRatio,colorMapDiff,ax,equalAxis,deleteAxis)
            if displayContour
                dispContour(abs(posthoc{pos}.tTests.contourSignificant{1,comp}),posthoc{pos}.tTests.Tthreshold{comp},contourColor,dashedColor,transparency,1,linestyle)
            end

        end

        % save
        set(0, 'currentfigure', f1);
        exportgraphics(gcf,fullfile(savedir, savedir2, [figname '.tif']),'Resolution',imageResolution)
        savefig(fullfile(savedir, savedir2, 'FIG', figname))
        close

        clear Comp combi isPlot

    end

end

end

