% Trama Robin (LIBM) 19/04/2021 --> release 2.0
% trama.robin@gmail.com

% available at :
% - https://github.com/tramarobin/fctSPM
% - https://www.mathworks.com/matlabcentral/fileexchange/77945-fctspm

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% save and plot the analysis obtain with `fctSPM` and `fctSPMS`.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% OUTPUTS
% spmAnalysis is saved at savedir

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
% * SPM: Tcontinuum and statistical inferences plots. Bold blue lines are located at the significant differences (corrected with the ANOVA).
% * FIG folder contains the above mentionned folder with the figures in `.fig` format.


% ##### In two dimensions #####
% Subfolders : Contains the pairewise comparison results (1 folder for ANOVA1, in 3 or 7 folders for ANOVA2 and ANOVA3)
% Means maps for each condition are represented in one figure each.
% The global effect of the post hoc precedure is display on a figure with the name of the effect. Mean maps are represented on the diagonal, pairewise differences on the top-right panel, and pairewise spm inferences on the bottom-left panel.

% Subfolders :
% * SD : standard deviation of the maps for each condition.
% * DIFF: Differences plots. Filenames with '%' at the end are the relative differences. White clusters represent the significant effect (corrected with ANOVA)
% * ES: Effect size plots. Whites clusters represent the significant effect (corrected with ANOVA)
% * SPM: Tcontinuum and statistical inferences plots. Whites clusters represent the significant effect (no correction with the ANOVA)
% * FIG folder contains the above mentionned folder with the figures in `.fig` format.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% INPUTS
% OBLIGATORY
% spmAnalysis obtained with `fctSPM` or `fctSPMS`.

% OPTIONAL
% see the description at begining of the function (inputParser)
% see .\fctSPM\Examples for help


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function saveNplot(spmAnalysis,varargin)

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

% 2d plot parameters
addParameter(p,'colorMap',cbrewer('seq','Reds', 64)) % colormap used for means and ANOVA and ES plots (0 to positive)
addParameter(p,'colorMapDiff',flipud(cbrewer('div','RdBu', 64))) % colormap used for differences and SPM plot (0 centered)
addParameter(p,'colorbarLabel','',@ischar); % name of the colorbar label
addParameter(p,'limitMeanMaps',[],@isnumeric); % limit of the colorbar. the value of X will make the colorbar going from 0 to X for all plots (easier to compare). If not specified, the maps wont necessery be with the same range but will be automatically scaled
addParameter(p,'displaycontour',1,@isnumeric); % display contour map on differences and size effect maps (0 to not display)
addParameter(p,'contourcolor','w'); % color of the line for the contour plot
addParameter(p,'linestyle','-') % linestyle of the contour plot
addParameter(p,'dashedColor',[0 0 0],@isnumeric) % color of the dashed zone of the contour plot (default is white)
addParameter(p,'transparancy',50,@isnumeric) % transparancy of the dashed zone (0=transparant, 255=opaque)
addParameter(p,'lineWidth',2.5,@isnumeric) % linewidth of the contour plot
addParameter(p,'diffRatio',0.33,@isnumeric) % the differences map will be scale at limitMeanMaps*diffRatio.
addParameter(p,'relativeRatio',[],@isnumeric) % the relative differences maps will be scale at +-relativeRatio

% 1d plot parameters
addParameter(p,'CI',[],@isnumeric); % confidence interval is used instead of standard deviation (0.7-->0.999), 0 to display SEM
addParameter(p,'transparancy1D',0.10); % transparancy of SD for 1D plot
addParameter(p,'yLimitES',[]); % y-axis limits for ES representation

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
linestyle=p.Results.linestyle;
transparancy1D=p.Results.transparancy1D;
yLimitES=p.Results.yLimitES;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
close all
set(0, 'DefaultFigureVisible', 'off');
warning('off', 'MATLAB:MKDIR:DirectoryExists');

%% choose save directory if not specified
savedir=chooseSavedir(savedir);

%% SAVE
mkdir(savedir)
save([savedir '/spmAnalysis'], 'spmAnalysis')

%% PLOT SUB


%% ANOVA
if spmAnalysis.anova.type~="no ANOVA"
    mkdir([savedir '/ANOVA/FIG/'])
    anova=spmAnalysis.anova;
    if iscell(anova.Fcontinuum)
        dimensions=size(anova.Fcontinuum{1});
    else
        dimensions=size(anova.Fcontinuum);
    end
    
    if ischar(anova.effectNames)
        
        % Plot of Anova Results
        displayAnova(anova.Fcontinuum,anova.Fthreshold,anova.Fsignificant,Fs,xlab,ylab,ylimits,dimensions,nTicksX,nTicksY,xlimits,colorMap,imageSize,imageFontSize)
        if displayContour & size(anova.Fcontinuum,2)>1
            dispContour(anova.Fcontinuum,anova.Fthreshold,contourColor,dashedColor,transparancy,lineWidth,linestyle)
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
                dispContour(anova.Fcontinuum{k},anova.Fthreshold{k},contourColor,dashedColor,transparancy,lineWidth,linestyle)
            end
            title(anova.effectNames{k})
            print('-dtiff',imageResolution,[savedir '/ANOVA/' verifSaveName(anova.effectNames{k})])
            savefig([savedir '/ANOVA/FIG/' verifSaveName(anova.effectNames{k})])
            close
            
        end
        
    end
end
%% POST HOC 1D
posthoc=spmAnalysis.posthoc;
dimensions=size(spmAnalysis.posthoc{1}.tTests.Tcontinuum{1});
if min(dimensions)==1
    
    for np=1:numel(posthoc)
        
        savedir2=[savedir '/Post hoc/' posthoc{np}.name '/'];
        createSavedir(savedir2)
        
        % means
        colorPlot=[];
        plotmean(posthoc{np}.data.continuum,CI,xlab,ylab,Fs,xlimits,nTicksX,nTicksY,colorPlot,imageFontSize,imageSize,transparancy1D,ylimits)
        legend(posthoc{np}.data.names,'Location','eastoutside','box','off')
        print('-dtiff',imageResolution,[savedir2 verifSaveName(posthoc{np}.name)])
        savefig([savedir2 '/FIG/' verifSaveName(posthoc{np}.name)])
        close
        
        for comp=1:numel(posthoc{np}.differences.continuum)
            
            % differences
            plotmean({posthoc{np}.differences.continuum{comp}},CI,xlab,ylab,Fs,xlimits,nTicksX,[],[],imageFontSize,imageSize,transparancy1D,[])
            if min(size(posthoc{np}.differences.names{1,comp}))>1
                legend([posthoc{np}.differences.names{1,comp} ' - ' posthoc{np}.differences.names{2,comp}],'Location','eastoutside','box','off')
                print('-dtiff',imageResolution,[savedir2 'DIFF/' verifSaveName([posthoc{np}.name ' (' char(posthoc{np}.differences.names{1,comp}) ' - ' char(posthoc{np}.differences.names{2,comp}) ')'])])
                savefig([savedir2 '/FIG/DIFF/' verifSaveName([posthoc{np}.name ' (' char(posthoc{np}.differences.names{1,comp}) ' - ' char(posthoc{np}.differences.names{2,comp}) ')'])])
            else
                legend(posthoc{np}.differences.names{comp},'Location','eastoutside','box','off')
                print('-dtiff',imageResolution,[savedir2 'DIFF/' verifSaveName(posthoc{np}.differences.names{comp})])
                savefig([savedir2 '/FIG/DIFF/' verifSaveName(posthoc{np}.differences.names{comp})])
            end
            close
            
            % relative differences
            plotmean({posthoc{np}.differences.continuumRelative{comp}},CI,xlab,'Differences (%)',Fs,xlimits,nTicksX,[],[],imageFontSize,imageSize,transparancy1D,[])
            if min(size(posthoc{np}.differences.names{1,comp}))>1
                legend([posthoc{np}.differences.names{1,comp} ' - ' posthoc{np}.differences.names{2,comp}],'Location','eastoutside','box','off')
                print('-dtiff',imageResolution,[savedir2 'DIFF/' verifSaveName([posthoc{np}.name ' (' char(posthoc{np}.differences.names{1,comp}) ' - ' char(posthoc{np}.differences.names{2,comp}) ')'])])
                savefig([savedir2 '/FIG/DIFF/' verifSaveName([posthoc{np}.name ' (' char(posthoc{np}.differences.names{1,comp}) ' - ' char(posthoc{np}.differences.names{2,comp}) ')'])])
            else
                legend(posthoc{np}.differences.names{comp},'Location','eastoutside','box','off')
                print('-dtiff',imageResolution,[savedir2 'DIFF/' verifSaveName(posthoc{np}.differences.names{comp}) '%'])
                savefig([savedir2 '/FIG/DIFF/' verifSaveName(posthoc{np}.differences.names{comp}) '%'])
            end
            close
            
            % plot of spm analysis
            displayTtest(posthoc{np}.tTests.Tcontinuum{1,comp},posthoc{np}.tTests.Tthreshold{comp},posthoc{np}.tTests.Tsignificant{1,comp},Fs,xlab,ylab,ylimits,dimensions,nTicksX,nTicksY,xlimits,imageFontSize,imageSize,transparancy1D)
            if min(size(posthoc{np}.differences.names{1,comp}))>1
                legend([posthoc{np}.differences.names{1,comp} ' - ' posthoc{np}.differences.names{2,comp}],'Location','eastoutside','box','off')
                print('-dtiff',imageResolution,[savedir2 'SPM/' verifSaveName([posthoc{np}.name ' (' char(posthoc{np}.differences.names{1,comp}) ' - ' char(posthoc{np}.differences.names{2,comp}) ')'])])
                savefig([savedir2 '/FIG/SPM/' verifSaveName([posthoc{np}.name ' (' char(posthoc{np}.differences.names{1,comp}) ' - ' char(posthoc{np}.differences.names{2,comp}) ')'])])
            else
                legend(posthoc{np}.differences.names{comp},'Location','eastoutside','box','off')
                print('-dtiff',imageResolution,[savedir2 'SPM/' verifSaveName(posthoc{np}.differences.names{comp})])
                savefig([savedir2 '/FIG/SPM/' verifSaveName(posthoc{np}.differences.names{comp})])
            end
            close
            
            % ES
            plotES(posthoc{np}.differences.ES{comp},posthoc{np}.differences.ESsd{comp},posthoc{np}.tTests.Tsignificant{1,comp},Fs,xlab,nTicksX,xlimits,imageFontSize,imageSize,transparancy1D,yLimitES)
            if min(size(posthoc{np}.differences.names{1,comp}))>1
                legend([posthoc{np}.differences.names{1,comp} ' - ' posthoc{np}.differences.names{2,comp}],'Location','eastoutside','box','off')
                print('-dtiff',imageResolution,[savedir2 'ES/' verifSaveName([posthoc{np}.name ' (' char(posthoc{np}.differences.names{1,comp}) ' - ' char(posthoc{np}.differences.names{2,comp}) ')'])])
                savefig([savedir2 '/FIG/ES/' verifSaveName([posthoc{np}.name ' (' char(posthoc{np}.differences.names{1,comp}) ' - ' char(posthoc{np}.differences.names{2,comp}) ')'])])
            else
                legend(posthoc{np}.differences.names{comp},'Location','eastoutside','box','off')
                print('-dtiff',imageResolution,[savedir2 'ES/' verifSaveName(posthoc{np}.differences.names{comp})])
                savefig([savedir2 '/FIG/ES/' verifSaveName(posthoc{np}.differences.names{comp})])
            end
            close
            
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
                dispContour(abs(posthoc{np}.tTests.contourSignificant{comp}),posthoc{np}.tTests.Tthreshold{comp},contourColor,dashedColor,transparancy,lineWidth,linestyle)
            end
            title(posthoc{np}.differences.names{comp})
            print('-dtiff',imageResolution,[savedir2 '/DIFF/' verifSaveName(posthoc{np}.differences.names{comp})])
            savefig([savedir2 '/FIG/DIFF/' verifSaveName(posthoc{np}.differences.names{comp})])
            close
            
            % relative differences
            displayRelativeDiffMaps(posthoc{np}.differences.continuumRelative{comp},Fs,xlab,ylab,ylimits,nTicksX,nTicksY,xlimits,imageFontSize,imageSize,colorMapDiff,relativeRatio)
            if displayContour
                dispContour(abs(posthoc{np}.tTests.contourSignificant{comp}),posthoc{np}.tTests.Tthreshold{comp},contourColor,dashedColor,transparancy,lineWidth,linestyle)
            end
            title(posthoc{np}.differences.names{comp})
            print('-dtiff',imageResolution,[savedir2 '/DIFF/' verifSaveName(posthoc{np}.differences.names{comp}) ' %'])
            savefig([savedir2 '/FIG/DIFF/' verifSaveName(posthoc{np}.differences.names{comp}) ' %'])
            close
            
            % spm analysis
            displayTtest(posthoc{np}.tTests.Tcontinuum{comp},posthoc{np}.tTests.Tthreshold{comp},[],Fs,xlab,ylab,ylimits,dimensions,nTicksX,nTicksY,xlimits,imageFontSize,imageSize,colorMapDiff)
            if displayContour
                dispContour(abs(posthoc{np}.tTests.Tcontinuum{comp}),posthoc{np}.tTests.Tthreshold{comp},contourColor,dashedColor,transparancy,lineWidth,linestyle)
            end
            title(posthoc{np}.differences.names{comp})
            print('-dtiff',imageResolution,[savedir2 '/SPM/' verifSaveName(posthoc{np}.differences.names{comp})])
            savefig([savedir2 '/FIG/SPM/' verifSaveName(posthoc{np}.differences.names{comp})])
            close
            
            % ES
            displayMapsES(posthoc{np}.differences.ES{comp},Fs,xlab,ylab,ylimits,nTicksX,nTicksY,xlimits,imageFontSize,imageSize,colorMap)
            title(posthoc{np}.differences.names{comp})
            if displayContour
                dispContour(abs(posthoc{np}.tTests.contourSignificant{comp}),posthoc{np}.tTests.Tthreshold{comp},contourColor,dashedColor,transparancy,lineWidth,linestyle)
            end
            print('-dtiff',imageResolution,[savedir2 '/ES/' verifSaveName(posthoc{np}.differences.names{comp})])
            savefig([savedir2 '/FIG/ES/' verifSaveName(posthoc{np}.differences.names{comp})])
            close
            
        end
        
    end
end

end