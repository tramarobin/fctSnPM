% Trama Robin (LIBM) 04/2021 --> JOSS
% trama.robin@gmail.com

% available at :
% - https://github.com/tramarobin/fctSnPM
% - https://www.mathworks.com/matlabcentral/fileexchange/77945-fctSnPM

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% save and plot the analysis obtain with `fctSnPM` and `fctSnPMS`.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% OUTPUTS
% snpmAnalysis is saved at savedir

% Figures
% ANOVA folder contains the ANOVA analysis, Post hoc folder contains the post hoc analysis

% ANOVA : 1 figure per effect
% * FIG folder contains the above mentionned folder with the figures in `.fig` format.

% Post hoc
% In one dimension
% Subfolders : Contains the pairewise comparison results (1 folder for ANOVA1, in 3 or 7 folders for ANOVA2 and ANOVA3)
% A figure with the name of the effect represent the means and standard deviations between subject for each condition.

% Subfolders :
% * DIFF: Differences plots. Filenames with '%' at the end are the relative differences
% * ES: Effect size plots. Bold blue lines are located at the significant differences (corrected with the ANOVA).
% * SnPM: Tcontinuum and statistical inferences plots. Bold blue lines are located at the significant differences (corrected with the ANOVA).
% * FIG folder contains the above mentionned folder with the figures in `.fig` format.


% ##### In two dimensions #####
% Subfolders : Contains the pairewise comparison results (1 folder for ANOVA1, in 3 or 7 folders for ANOVA2 and ANOVA3)
% Means maps for each condition are represented in one figure each.
% The global effect of the post hoc precedure is display on a figure with the name of the effect. Mean maps are represented on the diagonal, pairewise differences on the top-right panel, and pairewise SnPM inferences on the bottom-left panel.

% Subfolders :
% * SD : standard deviation of the maps for each condition.
% * DIFF: Differences plots. Filenames with '%' at the end are the relative differences. White clusters represent the significant effect (corrected with ANOVA)
% * ES: Effect size plots. Whites clusters represent the significant effect (corrected with ANOVA)
% * SnPM: Tcontinuum and statistical inferences plots. Whites clusters represent the significant effect (no correction with the ANOVA)
% * FIG folder contains the above mentionned folder with the figures in `.fig` format.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% INPUTS
% OBLIGATORY
% snpmAnalysis obtained with `fctSnPM` or `fctSnPMS`.

% OPTIONAL
% see the description at begining of the function (inputParser) or on GitHub (https://github.com/tramarobin/fctSnPM#optional-inputs)
% see ./fctSnPM/Examples for help


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function saveNplot(snpmAnalysis,varargin)

%% Optional inputs
p = inputParser;

% utilities
addParameter(p,'savedir',[]); % path to save directory

% general plot parameters
addParameter(p,'ylabel','',@ischar); % label of Y-axis
addParameter(p,'xlabel','',@ischar); % label of X-axis
addParameter(p,'samplefrequency',1,@isnumeric); % change xticks to correspond at the specified frequency
addParameter(p,'xlimits',[],@isnumeric); % change xticks to correspond to the specified range (can be negative)
% specified either samplefrequency or xlimits, but not both
addParameter(p,'nTicksX',5,@isnumeric); % number of xticks displayed
addParameter(p,'nTicksY',[],@isnumeric); % number of yticks displayed
addParameter(p,'imageResolution',96,@isnumeric); % resolution in ppp of the tiff images
addParameter(p,'imageSize',[],@isnumeric) % size of the image in cm. X --> X*X images, [X Y] X*Y imgages. By default the unit is pixels [0 0 720 480].
addParameter(p,'imageFontSize',12,@isnumeric) % font size of images
addParameter(p,'ylimits',[],@isnumeric); % change yticks to correspond to the specified range
addParameter(p,'linestyle','-') % In 1D : lineStyle for plots (default  is continuous) // Specify linestyle for each modality in cell, apply each style to each modality (independant effect first) // In 2D :linestyle of the contour plot

% 2d plot parameters
addParameter(p,'colorMap',cbrewer('seq','Reds', 64)) % colormap used for means and ANOVA and ES plots (0 to positive)
addParameter(p,'colorMapDiff',flipud(cbrewer('div','RdBu', 64))) % colormap used for differences and SnPM plot (0 centered)
addParameter(p,'colorbarLabel','',@ischar); % name of the colorbar label
addParameter(p,'limitMeanMaps',[],@isnumeric); % limit of the colorbar. the value of X will make the colorbar going from 0 to X for all plots (easier to compare). If not specified, the maps wont necessery be with the same range but will be automatically scaled
addParameter(p,'displaycontour',1,@isnumeric); % display contour map on differences and size effect maps (0 to not display)
addParameter(p,'contourcolor','w'); % color of the line for the contour plot
addParameter(p,'dashedColor',[0 0 0],@isnumeric) % color of the dashed zone of the contour plot (default is white)
addParameter(p,'transparancy',50,@isnumeric) % transparancy of the dashed zone (0=transparant, 255=opaque)
addParameter(p,'lineWidth',2.5,@isnumeric) % linewidth of the contour plot
addParameter(p,'diffRatio',0.33,@isnumeric) % the differences map will be scale at limitMeanMaps*diffRatio.
addParameter(p,'relativeRatio',[],@isnumeric) % the relative differences maps will be scale at +-relativeRatio

% 1d plot parameters
addParameter(p,'CI',[],@isnumeric); % confidence interval is used instead of standard deviation (0.7-->0.999), 0 to display SEM, , or negative value to not dispaly dispersion
addParameter(p,'colorLine',[]); % colorline for plots (default  is "lines") // rgb triplet, if in cell, apply each color to each effect (independant effect first)
addParameter(p,'transparancy1D',0.10); % transparancy of SD for 1D plot
addParameter(p,'yLimitES',[]); % y-axis limits for ES representation
addParameter(p,'ratioSnPM',[1 3]); % ratio of SnPM subplot relative to total figure (default if 1/3 of the figure)
addParameter(p,'SnPMPos',[]); % postion of SnPM plot, default is bottom, any value will set the position to up
addParameter(p,'aovColor','k'); % color of anova on SnPM plot (color or rgb)

parse(p,varargin{:});

contourColor=p.Results.contourcolor;
ylab=p.Results.ylabel;
xlab=p.Results.xlabel;
Fs=p.Results.samplefrequency;
savedir=p.Results.savedir;
ylimits=p.Results.ylimits;
xlimits=p.Results.xlimits;
nTicksX=p.Results.nTicksX;
nTicksY=p.Results.nTicksY;
displayContour=p.Results.displaycontour;
imageResolution=['-r' num2str(p.Results.imageResolution)];
colorbarLabel=p.Results.colorbarLabel;
limitMeanMaps=p.Results.limitMeanMaps;
CI=p.Results.CI;
dashedColor=p.Results.dashedColor;
transparancy=p.Results.transparancy;
lineWidth=p.Results.lineWidth;
imageSize=p.Results.imageSize;
imageFontSize=p.Results.imageFontSize;
colorMap=p.Results.colorMap;
colorMapDiff=p.Results.colorMapDiff;
diffRatio=p.Results.diffRatio;
relativeRatio=p.Results.relativeRatio;
lineStyle=p.Results.linestyle;
transparancy1D=p.Results.transparancy1D;
yLimitES=p.Results.yLimitES;
ratioSnPM=p.Results.ratioSnPM;
SnPMPos=p.Results.SnPMPos;
aovColor=p.Results.aovColor;
colorLine=p.Results.colorLine;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
close all
set(0, 'DefaultFigureVisible', 'off');
warning('off', 'MATLAB:MKDIR:DirectoryExists');

%% choose save directory if not specified
savedir=chooseSavedir(savedir);

%% SAVE
mkdir(savedir)
save([savedir '/snpmAnalysis'], 'snpmAnalysis')


%% ANOVA
if snpmAnalysis.anova.type~="no ANOVA"
    mkdir([savedir '/ANOVA/FIG/'])
    anova=snpmAnalysis.anova;
    if iscell(anova.Fcontinuum)
        dimensions=size(anova.Fcontinuum{1});
    else
        dimensions=size(anova.Fcontinuum);
    end
    
    if ischar(anova.effectNames)
        
        % Plot of Anova Results
        displayAnova(anova.Fcontinuum,anova.Fthreshold,anova.Fsignificant{1},Fs,xlab,ylab,ylimits,dimensions,nTicksX,nTicksY,xlimits,colorMap,imageSize,imageFontSize)
        if displayContour & size(anova.Fcontinuum,2)>1
            dispContour(anova.Fcontinuum,anova.Fthreshold,contourColor,dashedColor,transparancy,lineWidth,lineStyle)
        end
        title(anova.effectNames)
        print('-dtiff',imageResolution,[savedir '/ANOVA/' verifSaveName(anova.effectNames)])
        savefig([savedir '/ANOVA/FIG/' verifSaveName(anova.effectNames)])
        close
        
    else
        
        for k=1:numel(anova.effectNames)
            
            % Plot of the full anova results
            displayAnova(anova.Fcontinuum{k},anova.Fthreshold{k},anova.Fsignificant{k},Fs,xlab,ylab,ylimits,dimensions,nTicksX,nTicksY,xlimits,colorMap,imageSize,imageFontSize)
            if displayContour & size(anova.Fcontinuum{k},2)>1
                dispContour(anova.Fcontinuum{k},anova.Fthreshold{k},contourColor,dashedColor,transparancy,lineWidth,lineStyle)
            end
            title(anova.effectNames{k})
            print('-dtiff',imageResolution,[savedir '/ANOVA/' verifSaveName(anova.effectNames{k})])
            savefig([savedir '/ANOVA/FIG/' verifSaveName(anova.effectNames{k})])
            close
            
        end
        
    end
end

%% POST HOC 1D
posthoc=snpmAnalysis.posthoc;
dimensions=size(snpmAnalysis.posthoc{1}.tTests.Tcontinuum{1});
if min(dimensions)==1
    
    for np=1:numel(posthoc)
        
        savedir2=[savedir '/Post hoc/' posthoc{np}.name '/'];
        createSavedir(savedir2)
        
        %% pairewise plots
        
        for comp=1:numel(posthoc{np}.differences.continuum)
            
            % differences
            plotmean({posthoc{np}.differences.continuum{comp}},CI,xlab,ylab,Fs,xlimits,nTicksX,[],[],imageFontSize,imageSize,transparancy1D,[])
            if size(posthoc{np}.differences.names,1)>1
                legend([posthoc{np}.differences.names{1,comp} ' - ' posthoc{np}.differences.names{2,comp}],'Location','eastoutside','box','off')
                print('-dtiff',imageResolution,[savedir2 'DIFF/' verifSaveName([char(posthoc{np}.differences.names{1,comp}) ' - ' char(posthoc{np}.differences.names{2,comp})])])
                savefig([savedir2 '/FIG/DIFF/' verifSaveName([char(posthoc{np}.differences.names{1,comp}) ' - ' char(posthoc{np}.differences.names{2,comp})])])
            else
                legend(posthoc{np}.differences.names{comp},'Location','eastoutside','box','off')
                print('-dtiff',imageResolution,[savedir2 'DIFF/' verifSaveName(posthoc{np}.differences.names{comp})])
                savefig([savedir2 '/FIG/DIFF/' verifSaveName(posthoc{np}.differences.names{comp})])
            end
            close
            
            % relative differences
            plotmean({posthoc{np}.differences.continuumRelative{comp}},CI,xlab,'Differences (%)',Fs,xlimits,nTicksX,[],[],imageFontSize,imageSize,transparancy1D,[])
            if size(posthoc{np}.differences.names,1)>1
                legend([posthoc{np}.differences.names{1,comp} ' - ' posthoc{np}.differences.names{2,comp}],'Location','eastoutside','box','off')
                print('-dtiff',imageResolution,[savedir2 'DIFF/' verifSaveName([char(posthoc{np}.differences.names{1,comp}) ' - ' char(posthoc{np}.differences.names{2,comp})])])
                savefig([savedir2 '/FIG/DIFF/' verifSaveName([char(posthoc{np}.differences.names{1,comp}) ' - ' char(posthoc{np}.differences.names{2,comp})])])
            else
                legend(posthoc{np}.differences.names{comp},'Location','eastoutside','box','off')
                print('-dtiff',imageResolution,[savedir2 'DIFF/' verifSaveName(posthoc{np}.differences.names{comp}) '%'])
                savefig([savedir2 '/FIG/DIFF/' verifSaveName(posthoc{np}.differences.names{comp}) '%'])
            end
            close
            
            % plot of SnPM analysis
            displayTtest(posthoc{np}.tTests.Tcontinuum{1,comp},posthoc{np}.tTests.Tthreshold{comp},posthoc{np}.tTests.Tsignificant{1,comp},Fs,xlab,ylab,ylimits,dimensions,nTicksX,nTicksY,xlimits,imageFontSize,imageSize,transparancy1D)
            if size(posthoc{np}.differences.names,1)>1
                legend([posthoc{np}.differences.names{1,comp} ' - ' posthoc{np}.differences.names{2,comp}],'Location','eastoutside','box','off')
                print('-dtiff',imageResolution,[savedir2 'SnPM/' verifSaveName([char(posthoc{np}.differences.names{1,comp}) ' - ' char(posthoc{np}.differences.names{2,comp})])])
                savefig([savedir2 '/FIG/SnPM/' verifSaveName([char(posthoc{np}.differences.names{1,comp}) ' - ' char(posthoc{np}.differences.names{2,comp})])])
            else
                legend(posthoc{np}.differences.names{comp},'Location','eastoutside','box','off')
                print('-dtiff',imageResolution,[savedir2 'SnPM/' verifSaveName(posthoc{np}.differences.names{comp})])
                savefig([savedir2 '/FIG/SnPM/' verifSaveName(posthoc{np}.differences.names{comp})])
            end
            close
            
            % ES
            plotES(posthoc{np}.differences.ES{comp},posthoc{np}.differences.ESsd{comp},posthoc{np}.tTests.Tsignificant{1,comp},Fs,xlab,nTicksX,xlimits,imageFontSize,imageSize,transparancy1D,yLimitES)
            if size(posthoc{np}.differences.names,1)>1
                legend([posthoc{np}.differences.names{1,comp} ' - ' posthoc{np}.differences.names{2,comp}],'Location','eastoutside','box','off')
                print('-dtiff',imageResolution,[savedir2 'ES/' verifSaveName([char(posthoc{np}.differences.names{1,comp}) ' - ' char(posthoc{np}.differences.names{2,comp})])])
                savefig([savedir2 '/FIG/ES/' verifSaveName([char(posthoc{np}.differences.names{1,comp}) ' - ' char(posthoc{np}.differences.names{2,comp})])])
            else
                legend(posthoc{np}.differences.names{comp},'Location','eastoutside','box','off')
                print('-dtiff',imageResolution,[savedir2 'ES/' verifSaveName(posthoc{np}.differences.names{comp})])
                savefig([savedir2 '/FIG/ES/' verifSaveName(posthoc{np}.differences.names{comp})])
            end
            close
            
        end
    end
    
    %% Means + SnPM plots
    
    % T-TESTS and ANOVA1
    if numel(posthoc)==1
        
        clPlot=chooseCL(colorLine,lineStyle,1);
        
        plotmean(posthoc{np}.data.continuum,CI,xlab,ylab,Fs,xlimits,nTicksX,nTicksY,clPlot,imageFontSize,imageSize,transparancy1D,ylimits)
        legend(posthoc{np}.data.names,'Location','eastoutside','box','off')
        print('-dtiff',imageResolution,[savedir2 verifSaveName(posthoc{np}.name)])
        savefig([savedir2 '/FIG/' verifSaveName(posthoc{np}.name)])
        close
        
        if snpmAnalysis.anova.type~="no ANOVA" % plot with aov
            plotmeanSnPM(posthoc{1}.data.continuum,posthoc{1}.tTests.Tcontinuum,posthoc{1}.tTests.Tsignificant,posthoc{1}.data.names,posthoc{1}.differences.names,CI,xlab,ylab,Fs,xlimits,nTicksX,nTicksY,clPlot,imageFontSize,imageSize,transparancy1D,ylimits,anova.Fsignificant,{posthoc{1}.name},ratioSnPM,SnPMPos,aovColor)
            print('-dtiff',imageResolution,[savedir2 verifSaveName(posthoc{1}.name) ' + SnPM'])
            savefig([savedir2 '/FIG/' verifSaveName(posthoc{1}.name) ' + SnPM'])
            close
        end
        
        plotmeanSnPM(posthoc{1}.data.continuum,posthoc{1}.tTests.Tcontinuum,posthoc{1}.tTests.Tsignificant,posthoc{1}.data.names,posthoc{1}.differences.names,CI,xlab,ylab,Fs,xlimits,nTicksX,nTicksY,clPlot,imageFontSize,imageSize,transparancy1D,ylimits,[],[],ratioSnPM,SnPMPos,aovColor)
        print('-dtiff',imageResolution,[savedir2 verifSaveName(posthoc{1}.name) ' + SnPMnoAOV'])
        savefig([savedir2 '/FIG/' verifSaveName(posthoc{1}.name) ' + SnPMnoAOV'])
        close
        
        if snpmAnalysis.anova.type~="no ANOVA" % plot with aov
            plotmeanSnPMsub(posthoc{1}.data.continuum,posthoc{1}.tTests.Tcontinuum,posthoc{1}.tTests.Tsignificant,posthoc{1}.data.names,posthoc{1}.differences.names,CI,xlab,ylab,Fs,xlimits,nTicksX,nTicksY,clPlot,imageFontSize,imageSize,transparancy1D,ylimits,anova.Fsignificant,{posthoc{1}.name},ratioSnPM,SnPMPos,aovColor)
            print('-dtiff',imageResolution,[savedir2 verifSaveName(posthoc{1}.name) ' + SnPMsub'])
            savefig([savedir2 '/FIG/' verifSaveName(posthoc{1}.name) ' + SnPMsub'])
            close
        end
        
        plotmeanSnPMsub(posthoc{1}.data.continuum,posthoc{1}.tTests.Tcontinuum,posthoc{1}.tTests.Tsignificant,posthoc{1}.data.names,posthoc{1}.differences.names,CI,xlab,ylab,Fs,xlimits,nTicksX,nTicksY,clPlot,imageFontSize,imageSize,transparancy1D,ylimits,[],[],ratioSnPM,SnPMPos,aovColor)
        print('-dtiff',imageResolution,[savedir2 verifSaveName(posthoc{1}.name) ' + SnPMsubNoAOV'])
        savefig([savedir2 '/FIG/' verifSaveName(posthoc{1}.name) ' + SnPMsubNoAOV'])
        close
        
        
        % MAIN EFFECT FOR ANOVA 2 and 3
    else
        
        if numel(posthoc)==3
            pMax=2;
        else
            pMax=3;
        end
        
        for np=1:pMax
            
            savedir2=[savedir '/Post hoc/'];
            clPlot=chooseCL(colorLine,lineStyle,np);
            
            plotmean(posthoc{np}.data.continuum,CI,xlab,ylab,Fs,xlimits,nTicksX,nTicksY,clPlot,imageFontSize,imageSize,transparancy1D,ylimits)
            legend(posthoc{np}.data.names,'Location','eastoutside','box','off')
            print('-dtiff',imageResolution,[savedir2 verifSaveName(posthoc{np}.name) '/' verifSaveName(posthoc{np}.name)])
            savefig([savedir2 verifSaveName(anova.effectNames{np}) '/FIG/' verifSaveName(posthoc{np}.name)])
            close
            
            plotmeanSnPM(posthoc{np}.data.continuum,posthoc{np}.tTests.Tcontinuum,posthoc{np}.tTests.Tsignificant,posthoc{np}.data.names,posthoc{np}.differences.names,CI,xlab,ylab,Fs,xlimits,nTicksX,nTicksY,clPlot,imageFontSize,imageSize,transparancy1D,ylimits,anova.Fsignificant(np),anova.effectNames(np),ratioSnPM,SnPMPos,aovColor)
            print('-dtiff',imageResolution,[savedir2 verifSaveName(anova.effectNames{np}) '/' verifSaveName(anova.effectNames{np}) ' + SnPM'])
            savefig([savedir2 verifSaveName(anova.effectNames{np}) '/FIG/' verifSaveName(anova.effectNames{np}) ' + SnPM'])
            close
            
            plotmeanSnPM(posthoc{np}.data.continuum,posthoc{np}.tTests.Tcontinuum,posthoc{np}.tTests.Tsignificant,posthoc{np}.data.names,posthoc{np}.differences.names,CI,xlab,ylab,Fs,xlimits,nTicksX,nTicksY,clPlot,imageFontSize,imageSize,transparancy1D,ylimits,[],[],ratioSnPM,SnPMPos,aovColor)
            print('-dtiff',imageResolution,[savedir2 verifSaveName(anova.effectNames{np}) '/' verifSaveName(anova.effectNames{np}) ' + SnPMnoAOV'])
            savefig([savedir2 verifSaveName(anova.effectNames{np}) '/FIG/' verifSaveName(anova.effectNames{np}) ' + SnPMnoAOV'])
            close
            
            plotmeanSnPMsub(posthoc{np}.data.continuum,posthoc{np}.tTests.Tcontinuum,posthoc{np}.tTests.Tsignificant,posthoc{np}.data.names,posthoc{np}.differences.names,CI,xlab,ylab,Fs,xlimits,nTicksX,nTicksY,clPlot,imageFontSize,imageSize,transparancy1D,ylimits,anova.Fsignificant(np),anova.effectNames(np),ratioSnPM,SnPMPos,aovColor)
            print('-dtiff',imageResolution,[savedir2 verifSaveName(anova.effectNames{np}) '/' verifSaveName(anova.effectNames{np}) ' + SnPMsub'])
            savefig([savedir2 verifSaveName(anova.effectNames{np}) '/FIG/' verifSaveName(anova.effectNames{np}) ' + SnPMsub'])
            close
            
            plotmeanSnPMsub(posthoc{np}.data.continuum,posthoc{np}.tTests.Tcontinuum,posthoc{np}.tTests.Tsignificant,posthoc{np}.data.names,posthoc{np}.differences.names,CI,xlab,ylab,Fs,xlimits,nTicksX,nTicksY,clPlot,imageFontSize,imageSize,transparancy1D,ylimits,[],[],ratioSnPM,SnPMPos,aovColor)
            print('-dtiff',imageResolution,[savedir2 verifSaveName(anova.effectNames{np}) '/' verifSaveName(anova.effectNames{np}) ' + SnPMsubNoAOV'])
            savefig([savedir2 verifSaveName(anova.effectNames{np}) '/FIG/' verifSaveName(anova.effectNames{np}) ' + SnPMsubNoAOV'])
            close
            
        end
        
        %% DOUBLE INTERACTION FOR ANOVA3
        if numel(posthoc)==7
            
            for effectFixed=1:3
                
                fixedEffect=effectFixed;
                mainEffect=1:3;
                mainEffect(fixedEffect)=[];
                anovaFixedCorr=[3 2 1];
                np=3+anovaFixedCorr(fixedEffect);
                
                savedir2=[savedir '/Post hoc/'];
                for e=1:2
                    mkdir([savedir2 verifSaveName([anova.effectNames{mainEffect(1)} ' x ' anova.effectNames{mainEffect(2)}]) '/' verifSaveName(anova.effectNames{mainEffect(e)}) '/FIG'])
                end
                
                combi=posthoc{np}.tTests.combi;
                [nPlot,whichPlot,whichFixed,whichModal]=findNPlot(combi);
                
                for p=1:nPlot
                    
                    clPlot=chooseCL(colorLine,lineStyle,mainEffect(whichFixed(2,p)));
                    
                    plotmean(posthoc{np}.data.continuum(whichPlot{p}),CI,xlab,ylab,Fs,xlimits,nTicksX,nTicksY,clPlot,imageFontSize,imageSize,transparancy1D,ylimits)
                    legend(posthoc{np}.data.names(whichPlot{p}),'Location','eastoutside','box','off')
                    print('-dtiff',imageResolution,[savedir2 verifSaveName([anova.effectNames{mainEffect(1)} ' x ' anova.effectNames{mainEffect(2)}]) '/' verifSaveName(anova.effectNames{mainEffect(whichFixed(2,p))}) '/' verifSaveName(posthoc{mainEffect(whichFixed(1,p))}.data.names{whichModal(p)})])
                    savefig([savedir2 verifSaveName([anova.effectNames{mainEffect(1)} ' x ' anova.effectNames{mainEffect(2)}]) '/' verifSaveName(anova.effectNames{mainEffect(whichFixed(2,p))}) '/FIG/' verifSaveName(posthoc{mainEffect(whichFixed(1,p))}.data.names{whichModal(p)})])
                    close
                    
                    data4empty=posthoc{np}.data.continuum(whichPlot{p});
                    for i=1:numel(whichPlot{p})
                        isEmptydata(i)=~isempty(data4empty{i});
                    end
                    
                    for nC=1:numel(whichPlot{p})
                        findT(nC)=posthoc{np}.data.names(whichPlot{p}(nC));
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
                    
                    for nC=1:numel(posthoc{np}.differences.names)
                        nameCompare=[posthoc{np}.differences.names{nC} '___________________________'];
                        whichCompare(nC)=string([sameName ' '])==string(nameCompare(1:sizeSname+1));
                    end
                    
                    nAnova=whichAnova(mainEffect);
                    
                    plotmeanSnPM(posthoc{np}.data.continuum(whichPlot{p}),posthoc{np}.tTests.Tcontinuum(:,whichCompare),posthoc{np}.tTests.Tsignificant(:,whichCompare),posthoc{np}.data.names(whichPlot{p}),posthoc{np}.differences.names(whichCompare),CI,xlab,ylab,Fs,xlimits,nTicksX,nTicksY,clPlot,imageFontSize,imageSize,transparancy1D,ylimits,anova.Fsignificant([mainEffect(whichFixed(2,p)), nAnova]),{anova.effectNames{mainEffect(whichFixed(2,p))},[anova.effectNames{mainEffect(1)} ' x ' anova.effectNames{mainEffect(2)}]},ratioSnPM,SnPMPos,aovColor)
                    print('-dtiff',imageResolution,[savedir2 verifSaveName([anova.effectNames{mainEffect(1)} ' x ' anova.effectNames{mainEffect(2)}]) '/' verifSaveName(anova.effectNames{mainEffect(whichFixed(2,p))}) '/' verifSaveName(posthoc{mainEffect(whichFixed(1,p))}.data.names{whichModal(p)}) ' + SnPM'])
                    savefig([savedir2 verifSaveName([anova.effectNames{mainEffect(1)} ' x ' anova.effectNames{mainEffect(2)}]) '/' verifSaveName(anova.effectNames{mainEffect(whichFixed(2,p))}) '/FIG/' verifSaveName(posthoc{mainEffect(whichFixed(1,p))}.data.names{whichModal(p)}) ' +SnPM'])
                    close
                    
                    plotmeanSnPM(posthoc{np}.data.continuum(whichPlot{p}),posthoc{np}.tTests.Tcontinuum(:,whichCompare),posthoc{np}.tTests.Tsignificant(:,whichCompare),posthoc{np}.data.names(whichPlot{p}),posthoc{np}.differences.names(whichCompare),CI,xlab,ylab,Fs,xlimits,nTicksX,nTicksY,clPlot,imageFontSize,imageSize,transparancy1D,ylimits,[],[],ratioSnPM,SnPMPos,aovColor)
                    print('-dtiff',imageResolution,[savedir2 verifSaveName([anova.effectNames{mainEffect(1)} ' x ' anova.effectNames{mainEffect(2)}]) '/' verifSaveName(anova.effectNames{mainEffect(whichFixed(2,p))}) '/' verifSaveName(posthoc{mainEffect(whichFixed(1,p))}.data.names{whichModal(p)}) ' + SnPMnoAOV'])
                    savefig([savedir2 verifSaveName([anova.effectNames{mainEffect(1)} ' x ' anova.effectNames{mainEffect(2)}]) '/' verifSaveName(anova.effectNames{mainEffect(whichFixed(2,p))}) '/FIG/' verifSaveName(posthoc{mainEffect(whichFixed(1,p))}.data.names{whichModal(p)}) ' +SnPMnoAOV'])
                    close
                    
                    plotmeanSnPMsub(posthoc{np}.data.continuum(whichPlot{p}),posthoc{np}.tTests.Tcontinuum(:,whichCompare),posthoc{np}.tTests.Tsignificant(:,whichCompare),posthoc{np}.data.names(whichPlot{p}),posthoc{np}.differences.names(whichCompare),CI,xlab,ylab,Fs,xlimits,nTicksX,nTicksY,clPlot,imageFontSize,imageSize,transparancy1D,ylimits,anova.Fsignificant([mainEffect(whichFixed(2,p)), nAnova]),{anova.effectNames{mainEffect(whichFixed(2,p))},[anova.effectNames{mainEffect(1)} ' x ' anova.effectNames{mainEffect(2)}]},ratioSnPM,SnPMPos,aovColor)
                    print('-dtiff',imageResolution,[savedir2 verifSaveName([anova.effectNames{mainEffect(1)} ' x ' anova.effectNames{mainEffect(2)}]) '/' verifSaveName(anova.effectNames{mainEffect(whichFixed(2,p))}) '/' verifSaveName(posthoc{mainEffect(whichFixed(1,p))}.data.names{whichModal(p)}) ' + SnPMsub'])
                    savefig([savedir2 verifSaveName([anova.effectNames{mainEffect(1)} ' x ' anova.effectNames{mainEffect(2)}]) '/' verifSaveName(anova.effectNames{mainEffect(whichFixed(2,p))}) '/FIG/' verifSaveName(posthoc{mainEffect(whichFixed(1,p))}.data.names{whichModal(p)}) ' +SnPMsub'])
                    close
                    
                    plotmeanSnPMsub(posthoc{np}.data.continuum(whichPlot{p}),posthoc{np}.tTests.Tcontinuum(:,whichCompare),posthoc{np}.tTests.Tsignificant(:,whichCompare),posthoc{np}.data.names(whichPlot{p}),posthoc{np}.differences.names(whichCompare),CI,xlab,ylab,Fs,xlimits,nTicksX,nTicksY,clPlot,imageFontSize,imageSize,transparancy1D,ylimits,[],[],ratioSnPM,SnPMPos,aovColor)
                    print('-dtiff',imageResolution,[savedir2 verifSaveName([anova.effectNames{mainEffect(1)} ' x ' anova.effectNames{mainEffect(2)}]) '/' verifSaveName(anova.effectNames{mainEffect(whichFixed(2,p))}) '/' verifSaveName(posthoc{mainEffect(whichFixed(1,p))}.data.names{whichModal(p)}) ' + SnPMsubNoAOV'])
                    savefig([savedir2 verifSaveName([anova.effectNames{mainEffect(1)} ' x ' anova.effectNames{mainEffect(2)}]) '/' verifSaveName(anova.effectNames{mainEffect(whichFixed(2,p))}) '/FIG/' verifSaveName(posthoc{mainEffect(whichFixed(1,p))}.data.names{whichModal(p)}) ' +SnPMsubNoAOV'])
                    close
                    
                    clear isEmptydata findT capPos whichCompare
                    
                end
            end
        end
        
        %% DOULE INTERACTION FOR ANOVA2 or TRIPLE INTERACTIONS FOR ANOVA3
        
        if numel(posthoc)==3
            pos=3;
            isInteraction=max(anova.Fsignificant{pos});
            savedir2=[verifSaveName([anova.effectNames{1} ' x ' anova.effectNames{2}]) '/'] ;
            mkdir([savedir '/Post hoc/' savedir2 verifSaveName(anova.effectNames{1}) '/FIG'])
            mkdir([savedir '/Post hoc/' savedir2 verifSaveName(anova.effectNames{2}) '/FIG'])
        elseif numel(posthoc)==7
            pos=7;
            isInteraction=max(anova.Fsignificant{pos});
            savedir2=[verifSaveName([anova.effectNames{1} ' x ' anova.effectNames{2} ' x ' anova.effectNames{3}]) '/'];
            mkdir([savedir '/Post hoc/' savedir2 verifSaveName(anova.effectNames{1}) '/FIG'])
            mkdir([savedir '/Post hoc/' savedir2 verifSaveName(anova.effectNames{2}) '/FIG'])
            mkdir([savedir '/Post hoc/' savedir2 verifSaveName(anova.effectNames{3}) '/FIG'])
        end
        
        combi=posthoc{pos}.tTests.combi;
        [nPlot,whichPlot,whichFixed,whichModal]=findNPlot(combi);
        
        if numel(posthoc)==3
            for p=1:nPlot
                clPlot=chooseCL(colorLine,lineStyle,whichFixed(2,p));
                plotmean(posthoc{pos}.data.continuum(whichPlot{p}),CI,xlab,ylab,Fs,xlimits,nTicksX,nTicksY,clPlot,imageFontSize,imageSize,transparancy1D,ylimits)
                data4empty=posthoc{pos}.data.continuum(whichPlot{p});
                for i=1:numel(whichPlot{p})
                    isEmptydata(i)=~isempty(data4empty{i});
                end
                legend(posthoc{pos}.data.names(whichPlot{p}(isEmptydata)),'Location','eastoutside','box','off')
                print('-dtiff',imageResolution,[savedir '/Post hoc/' savedir2 verifSaveName(anova.effectNames{whichFixed(2,p)}) '/' verifSaveName(posthoc{whichFixed(1,p)}.data.names{whichModal(1,p)})])
                savefig([savedir '/Post hoc/' savedir2 verifSaveName(anova.effectNames{whichFixed(2,p)}) '/FIG/' verifSaveName(posthoc{whichFixed(1,p)}.data.names{whichModal(1,p)})])
                close
                clear isEmptydata
            end
        elseif numel(posthoc)==7
            for p=1:nPlot
                clPlot=chooseCL(colorLine,lineStyle,whichFixed(1,p));
                plotmean(posthoc{pos}.data.continuum(whichPlot{p}),CI,xlab,ylab,Fs,xlimits,nTicksX,nTicksY,clPlot,imageFontSize,imageSize,transparancy1D,ylimits)
                data4empty=posthoc{pos}.data.continuum(whichPlot{p});
                for i=1:numel(whichPlot{p})
                    isEmptydata(i)=~isempty(data4empty{i});
                end
                legend(posthoc{pos}.data.names(whichPlot{p}(isEmptydata)),'Location','eastoutside','box','off')
                print('-dtiff',imageResolution,[savedir '/Post hoc/' savedir2 verifSaveName(anova.effectNames{whichFixed(1,p)}) '/' verifSaveName([posthoc{whichFixed(2,p)}.data.names{whichModal(1,p)} ' x ' posthoc{whichFixed(3,p)}.data.names{whichModal(2,p)}])])
                savefig([savedir '/Post hoc/' savedir2 verifSaveName(anova.effectNames{whichFixed(1,p)}) '/FIG/' verifSaveName([posthoc{whichFixed(2,p)}.data.names{whichModal(1,p)} ' x ' posthoc{whichFixed(3,p)}.data.names{whichModal(2,p)}])])
                close
                clear isEmptydata
            end
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
            
            if numel(posthoc)==3
                clPlot=chooseCL(colorLine,lineStyle,whichFixed(2,p));
            else
                clPlot=chooseCL(colorLine,lineStyle,whichFixed(1,p));
            end
            
            if numel(posthoc)==3
                plotmeanSnPM(posthoc{pos}.data.continuum(whichPlot{p}),posthoc{pos}.tTests.Tcontinuum(:,whichCompare),posthoc{pos}.tTests.Tsignificant(:,whichCompare),posthoc{pos}.data.names  (whichPlot{p}(isEmptydata)),posthoc{pos}.differences.names(whichCompare),CI,xlab,ylab,Fs,xlimits,nTicksX,nTicksY,clPlot,imageFontSize,imageSize,transparancy1D,ylimits,anova.Fsignificant([whichFixed(2,p) 3]),{anova.effectNames{whichFixed(2,p)},[anova.effectNames{1} ' x ' anova.effectNames{2}]},ratioSnPM,SnPMPos,aovColor)
                print('-dtiff',imageResolution,[savedir '/Post hoc/' savedir2 verifSaveName(anova.effectNames{whichFixed(2,p)}) '/' verifSaveName(posthoc{whichFixed(1,p)}.data.names{whichModal(1,p)}) ' + SnPM'])
                savefig([savedir '/Post hoc/' savedir2 verifSaveName(anova.effectNames{whichFixed(2,p)}) '/FIG/' verifSaveName(posthoc{whichFixed(1,p)}.data.names{whichModal(1,p)}) ' + SnPM'])
                close
                
                plotmeanSnPM(posthoc{pos}.data.continuum(whichPlot{p}),posthoc{pos}.tTests.Tcontinuum(:,whichCompare),posthoc{pos}.tTests.Tsignificant(:,whichCompare),posthoc{pos}.data.names  (whichPlot{p}(isEmptydata)),posthoc{pos}.differences.names(whichCompare),CI,xlab,ylab,Fs,xlimits,nTicksX,nTicksY,clPlot,imageFontSize,imageSize,transparancy1D,ylimits,[],[],ratioSnPM,SnPMPos,aovColor)
                print('-dtiff',imageResolution,[savedir '/Post hoc/' savedir2 verifSaveName(anova.effectNames{whichFixed(2,p)}) '/' verifSaveName(posthoc{whichFixed(1,p)}.data.names{whichModal(1,p)}) ' + SnPMnoAOV'])
                savefig([savedir '/Post hoc/' savedir2 verifSaveName(anova.effectNames{whichFixed(2,p)}) '/FIG/' verifSaveName(posthoc{whichFixed(1,p)}.data.names{whichModal(1,p)}) ' + SnPMnoAOV'])
                close
                
                plotmeanSnPMsub(posthoc{pos}.data.continuum(whichPlot{p}),posthoc{pos}.tTests.Tcontinuum(:,whichCompare),posthoc{pos}.tTests.Tsignificant(:,whichCompare),posthoc{pos}.data.names  (whichPlot{p}(isEmptydata)),posthoc{pos}.differences.names(whichCompare),CI,xlab,ylab,Fs,xlimits,nTicksX,nTicksY,clPlot,imageFontSize,imageSize,transparancy1D,ylimits,anova.Fsignificant([whichFixed(2,p) 3]),{anova.effectNames{whichFixed(2,p)},[anova.effectNames{1} ' x ' anova.effectNames{2}]},ratioSnPM,SnPMPos,aovColor)
                print('-dtiff',imageResolution,[savedir '/Post hoc/' savedir2 verifSaveName(anova.effectNames{whichFixed(2,p)}) '/' verifSaveName(posthoc{whichFixed(1,p)}.data.names{whichModal(1,p)}) ' + SnPMsub'])
                savefig([savedir '/Post hoc/' savedir2 verifSaveName(anova.effectNames{whichFixed(2,p)}) '/FIG/' verifSaveName(posthoc{whichFixed(1,p)}.data.names{whichModal(1,p)}) ' + SnPMsub'])
                close
                
                plotmeanSnPMsub(posthoc{pos}.data.continuum(whichPlot{p}),posthoc{pos}.tTests.Tcontinuum(:,whichCompare),posthoc{pos}.tTests.Tsignificant(:,whichCompare),posthoc{pos}.data.names  (whichPlot{p}(isEmptydata)),posthoc{pos}.differences.names(whichCompare),CI,xlab,ylab,Fs,xlimits,nTicksX,nTicksY,clPlot,imageFontSize,imageSize,transparancy1D,ylimits,[],[],ratioSnPM,SnPMPos,aovColor)
                print('-dtiff',imageResolution,[savedir '/Post hoc/' savedir2 verifSaveName(anova.effectNames{whichFixed(2,p)}) '/' verifSaveName(posthoc{whichFixed(1,p)}.data.names{whichModal(1,p)}) ' + SnPMsubNoAOV'])
                savefig([savedir '/Post hoc/' savedir2 verifSaveName(anova.effectNames{whichFixed(2,p)}) '/FIG/' verifSaveName(posthoc{whichFixed(1,p)}.data.names{whichModal(1,p)}) ' + SnPMsubNoAOV'])
                close
            else
                [nAnovaInt,nNames]=whichAnovaInt(whichFixed(1,p));
                
                plotmeanSnPM(posthoc{pos}.data.continuum(whichPlot{p}),posthoc{pos}.tTests.Tcontinuum(:,whichCompare),posthoc{pos}.tTests.Tsignificant(:,whichCompare),posthoc{pos}.data.names  (whichPlot{p}(isEmptydata)),posthoc{pos}.differences.names(whichCompare),CI,xlab,ylab,Fs,xlimits,nTicksX,nTicksY,clPlot,imageFontSize,imageSize,transparancy1D,ylimits,...
                    anova.Fsignificant([whichFixed(1,p) nAnovaInt 7]),{anova.effectNames{whichFixed(1,p)},[anova.effectNames{nNames(1,1)} ' x ' anova.effectNames{nNames(1,2)}], [anova.effectNames{nNames(2,1)} ' x ' anova.effectNames{nNames(2,2)}],[anova.effectNames{1} ' x ' anova.effectNames{2} ' x ' anova.effectNames{3}]},ratioSnPM,SnPMPos,aovColor)
                print('-dtiff',imageResolution,[savedir '/Post hoc/' savedir2 verifSaveName(anova.effectNames{whichFixed(1,p)}) '/' verifSaveName([posthoc{whichFixed(2,p)}.data.names{whichModal(1,p)} ' x ' posthoc{whichFixed(3,p)}.data.names{whichModal(2,p)}]) ' + SnPM'])
                savefig([savedir '/Post hoc/' savedir2 verifSaveName(anova.effectNames{whichFixed(1,p)}) '/FIG/' verifSaveName([posthoc{whichFixed(2,p)}.data.names{whichModal(1,p)} ' x ' posthoc{whichFixed(3,p)}.data.names{whichModal(2,p)}]) ' + SnPM'])
                close
                
                plotmeanSnPM(posthoc{pos}.data.continuum(whichPlot{p}),posthoc{pos}.tTests.Tcontinuum(:,whichCompare),posthoc{pos}.tTests.Tsignificant(:,whichCompare),posthoc{pos}.data.names  (whichPlot{p}(isEmptydata)),posthoc{pos}.differences.names(whichCompare),CI,xlab,ylab,Fs,xlimits,nTicksX,nTicksY,clPlot,imageFontSize,imageSize,transparancy1D,ylimits,[],[],ratioSnPM,SnPMPos,aovColor)
                print('-dtiff',imageResolution,[savedir '/Post hoc/' savedir2 verifSaveName(anova.effectNames{whichFixed(1,p)}) '/' verifSaveName([posthoc{whichFixed(2,p)}.data.names{whichModal(1,p)} ' x ' posthoc{whichFixed(3,p)}.data.names{whichModal(2,p)}]) ' + SnPMnoAOV'])
                savefig([savedir '/Post hoc/' savedir2 verifSaveName(anova.effectNames{whichFixed(1,p)}) '/FIG/' verifSaveName([posthoc{whichFixed(2,p)}.data.names{whichModal(1,p)} ' x ' posthoc{whichFixed(3,p)}.data.names{whichModal(2,p)}]) ' + SnPMnoAOV'])
                close
                
                plotmeanSnPMsub(posthoc{pos}.data.continuum(whichPlot{p}),posthoc{pos}.tTests.Tcontinuum(:,whichCompare),posthoc{pos}.tTests.Tsignificant(:,whichCompare),posthoc{pos}.data.names  (whichPlot{p}(isEmptydata)),posthoc{pos}.differences.names(whichCompare),CI,xlab,ylab,Fs,xlimits,nTicksX,nTicksY,clPlot,imageFontSize,imageSize,transparancy1D,ylimits,...
                    anova.Fsignificant([whichFixed(1,p) nAnovaInt 7]),{anova.effectNames{whichFixed(1,p)},[anova.effectNames{nNames(1,1)} ' x ' anova.effectNames{nNames(1,2)}], [anova.effectNames{nNames(2,1)} ' x ' anova.effectNames{nNames(2,2)}],[anova.effectNames{1} ' x ' anova.effectNames{2} ' x ' anova.effectNames{3}]},ratioSnPM,SnPMPos,aovColor)
                print('-dtiff',imageResolution,[savedir '/Post hoc/' savedir2 verifSaveName(anova.effectNames{whichFixed(1,p)}) '/' verifSaveName([posthoc{whichFixed(2,p)}.data.names{whichModal(1,p)} ' x ' posthoc{whichFixed(3,p)}.data.names{whichModal(2,p)}]) ' + SnPMsub'])
                savefig([savedir '/Post hoc/' savedir2 verifSaveName(anova.effectNames{whichFixed(1,p)}) '/FIG/' verifSaveName([posthoc{whichFixed(2,p)}.data.names{whichModal(1,p)} ' x ' posthoc{whichFixed(3,p)}.data.names{whichModal(2,p)}]) ' + SnPMsub'])
                close
                
                plotmeanSnPMsub(posthoc{pos}.data.continuum(whichPlot{p}),posthoc{pos}.tTests.Tcontinuum(:,whichCompare),posthoc{pos}.tTests.Tsignificant(:,whichCompare),posthoc{pos}.data.names  (whichPlot{p}(isEmptydata)),posthoc{pos}.differences.names(whichCompare),CI,xlab,ylab,Fs,xlimits,nTicksX,nTicksY,clPlot,imageFontSize,imageSize,transparancy1D,ylimits,[],[],ratioSnPM,SnPMPos,aovColor)
                print('-dtiff',imageResolution,[savedir '/Post hoc/' savedir2 verifSaveName(anova.effectNames{whichFixed(1,p)}) '/' verifSaveName([posthoc{whichFixed(2,p)}.data.names{whichModal(1,p)} ' x ' posthoc{whichFixed(3,p)}.data.names{whichModal(2,p)}]) ' + SnPMsubNoAOV'])
                savefig([savedir '/Post hoc/' savedir2 verifSaveName(anova.effectNames{whichFixed(1,p)}) '/FIG/' verifSaveName([posthoc{whichFixed(2,p)}.data.names{whichModal(1,p)} ' x ' posthoc{whichFixed(3,p)}.data.names{whichModal(2,p)}]) ' + SnPMsubNoAOV'])
                close
            end
            
            clear isEmptydata findT capPos whichCompare
        end
        
    end
end

%% POST HOC 2D
if min(dimensions)>1
    
    if isempty(nTicksX)
        nTicksX=5;
    end
    if isempty(nTicksY)
        nTicksY=4;
    end
    
    for np=1:numel(posthoc)
        
        savedir2=[savedir '/Post hoc/' posthoc{np}.name '/'];
        createSavedir2d(savedir2)
        
        for combi=1:numel(posthoc{np}.data.meanContinuum)
            
            % means
            displayMeanMaps(posthoc{np}.data.meanContinuum{combi},Fs,xlab,ylab,ylimits,nTicksX,nTicksY,limitMeanMaps,xlimits,imageFontSize,imageSize,colorbarLabel,colorMap)
            title(posthoc{np}.data.names{combi})
            print('-dtiff',imageResolution,[savedir2 '/' verifSaveName(posthoc{np}.data.names{combi})])
            savefig([savedir2 '/FIG/' verifSaveName(posthoc{np}.data.names{combi})])
            close
            
            % sd
            displayMeanMaps(posthoc{np}.data.sdContinuum{combi},Fs,xlab,ylab,ylimits,nTicksX,nTicksY,[],xlimits,imageFontSize,imageSize,colorbarLabel,colorMap)
            title(posthoc{np}.data.names{combi})
            print('-dtiff',imageResolution,[savedir2 '/SD/' verifSaveName(posthoc{np}.data.names{combi})])
            savefig([savedir2 '/FIG/SD/' verifSaveName(posthoc{np}.data.names{combi})])
            close
            
        end
        
        for comp=1:numel(posthoc{np}.differences.names)
            
            % differences
            displayDiffMaps(posthoc{np}.differences.continuum{comp},Fs,xlab,ylab,ylimits,nTicksX,nTicksY,limitMeanMaps,xlimits,imageFontSize,imageSize,colorbarLabel,colorMapDiff,diffRatio)
            if displayContour
                dispContour(abs(posthoc{np}.tTests.contourSignificant{comp}),posthoc{np}.tTests.Tthreshold{comp},contourColor,dashedColor,transparancy,lineWidth,lineStyle)
            end
            title(posthoc{np}.differences.names{comp})
            print('-dtiff',imageResolution,[savedir2 '/DIFF/' verifSaveName(posthoc{np}.differences.names{comp})])
            savefig([savedir2 '/FIG/DIFF/' verifSaveName(posthoc{np}.differences.names{comp})])
            close
            
            % relative differences
            displayRelativeDiffMaps(posthoc{np}.differences.continuumRelative{comp},Fs,xlab,ylab,ylimits,nTicksX,nTicksY,xlimits,imageFontSize,imageSize,colorMapDiff,relativeRatio)
            if displayContour
                dispContour(abs(posthoc{np}.tTests.contourSignificant{comp}),posthoc{np}.tTests.Tthreshold{comp},contourColor,dashedColor,transparancy,lineWidth,lineStyle)
            end
            title(posthoc{np}.differences.names{comp})
            print('-dtiff',imageResolution,[savedir2 '/DIFF/' verifSaveName(posthoc{np}.differences.names{comp}) ' %'])
            savefig([savedir2 '/FIG/DIFF/' verifSaveName(posthoc{np}.differences.names{comp}) ' %'])
            close
            
            % SnPM analysis
            displayTtest(posthoc{np}.tTests.Tcontinuum{comp},posthoc{np}.tTests.Tthreshold{comp},[],Fs,xlab,ylab,ylimits,dimensions,nTicksX,nTicksY,xlimits,imageFontSize,imageSize,colorMapDiff)
            if displayContour
                dispContour(abs(posthoc{np}.tTests.Tcontinuum{comp}),posthoc{np}.tTests.Tthreshold{comp},contourColor,dashedColor,transparancy,lineWidth,lineStyle)
            end
            title(posthoc{np}.differences.names{comp})
            print('-dtiff',imageResolution,[savedir2 '/SnPM/' verifSaveName(posthoc{np}.differences.names{comp})])
            savefig([savedir2 '/FIG/SnPM/' verifSaveName(posthoc{np}.differences.names{comp})])
            close
            
            % ES
            displayMapsES(posthoc{np}.differences.ES{comp},Fs,xlab,ylab,ylimits,nTicksX,nTicksY,xlimits,imageFontSize,imageSize,colorMap)
            title(posthoc{np}.differences.names{comp})
            if displayContour
                dispContour(abs(posthoc{np}.tTests.contourSignificant{comp}),posthoc{np}.tTests.Tthreshold{comp},contourColor,dashedColor,transparancy,lineWidth,lineStyle)
            end
            print('-dtiff',imageResolution,[savedir2 '/ES/' verifSaveName(posthoc{np}.differences.names{comp})])
            savefig([savedir2 '/FIG/ES/' verifSaveName(posthoc{np}.differences.names{comp})])
            close
            
        end
        
    end
end

end

%% Activate figure display
set(0, 'DefaultFigureVisible', 'on');