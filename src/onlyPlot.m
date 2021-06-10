% Trama Robin (LIBM) 06/2021 --> JOSS
% trama.robin@gmail.com

% available at :
% - https://github.com/tramarobin/fctSPM
% - https://www.mathworks.com/matlabcentral/fileexchange/77945-fctspm

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% plot a part of the analysis obtain with `fctSPM` and `fctSPMS`.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% INPUTS
% OBLIGATORY
% spmAnalysis obtained with `fctSPM` or `fctSPMS`.

% OPTIONAL
% see the description at begining of the function (inputParser) or on GitHub (https://github.com/tramarobin/fctSPM#optional-inputs)
% see ./fctSPM/Examples for help


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function onlyPlot(spmAnalysis,varargin)

%% Optional inputs
p = inputParser;

% general plot parameters
addParameter(p,'ylabel','',@ischar); % label of Y-axis
addParameter(p,'xlabel','',@ischar); % label of X-axis
addParameter(p,'samplefrequency',1,@isnumeric); % change xticks to correspond at the specified frequency
addParameter(p,'xlimits',[],@isnumeric); % change xticks to correspond to the specified range (can be negative)
% specified either samplefrequency or xlimits, but not both
addParameter(p,'nTicksX',5,@isnumeric); % number of xticks displayed
addParameter(p,'nTicksY',[],@isnumeric); % number of yticks displayed
addParameter(p,'imageSize',[],@isnumeric) % size of the image in cm. X --> X*X images, [X Y] X*Y imgages. By default the unit is pixels [0 0 720 480].
addParameter(p,'imageFontSize',12,@isnumeric) % font size of images
addParameter(p,'ylimits',[],@isnumeric); % change yticks to correspond to the specified range
addParameter(p,'linestyle','-') % In 1D : lineStyle for plots (default  is continuous) // Specify linestyle for each modality in cell, apply each style to each modality (independant effect first) // In 2D :linestyle of the contour plot

% 2d plot parameters
addParameter(p,'colorMap',cbrewer('seq','Reds', 64)) % colormap used for means and ANOVA and ES plots (0 to positive)
addParameter(p,'colorMapDiff',flipud(cbrewer('div','RdBu', 64))) % colormap used for differences and SPM plot (0 centered)
addParameter(p,'colorbarLabel','',@ischar); % name of the colorbar label
addParameter(p,'limitMeanMaps',[],@isnumeric); % limit of the colorbar. the value of X will make the colorbar going from 0 to X for all plots (easier to compare). If not specified, the maps wont necessery be with the same range but will be automatically scaled
addParameter(p,'displaycontour',1,@isnumeric); % display contour map on differences and size effect maps (0 to not display)
addParameter(p,'contourcolor','w'); % color of the line for the contour plot
addParameter(p,'dashedColor',[0 0 0],@isnumeric) % color of the dashed zone of the contour plot (default is white)
addParameter(p,'transparancy',50,@isnumeric) % transparancy of the dashed zone (0=transparant, 255=opaque)
addParameter(p,'lineWidth',2.5,@isnumeric) % linewidth of the contour plot

% 1d plot parameters
addParameter(p,'CI',[],@isnumeric); % confidence interval is used instead of standard deviation (0.7-->0.999), 0 to display SEM, , or negative value to not dispaly dispersion
addParameter(p,'colorLine',[]); % colorline for plots (default  is "lines") // rgb triplet, if in cell, apply each color to each effect (independant effect first)
addParameter(p,'transparancy1D',0.10); % transparancy of SD for 1D plot
addParameter(p,'ratioSPM',[1 3]); % ratio of SPM subplot relative to total figure (default if 1/3 of the figure)
addParameter(p,'spmPos',[]); % postion of spm plot, default is bottom, any value will set the position to up
addParameter(p,'aovColor','k'); % color of anova on SPM plot (color or rgb)

parse(p,varargin{:});

contourColor=p.Results.contourcolor;
ylab=p.Results.ylabel;
xlab=p.Results.xlabel;
Fs=p.Results.samplefrequency;
ylimits=p.Results.ylimits;
xlimits=p.Results.xlimits;
nTicksX=p.Results.nTicksX;
nTicksY=p.Results.nTicksY;
displayContour=p.Results.displaycontour;
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
lineStyle=p.Results.linestyle;
transparancy1D=p.Results.transparancy1D;
ratioSPM=p.Results.ratioSPM;
spmPos=p.Results.spmPos;
aovColor=p.Results.aovColor;
colorLine=p.Results.colorLine;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
close all
set(0, 'DefaultFigureVisible', 'on');
warning('off', 'MATLAB:MKDIR:DirectoryExists');


%% ANOVA
if spmAnalysis.anova.type~="no ANOVA"
    anova=spmAnalysis.anova;
    if iscell(anova.Fcontinuum)
        dimensions=size(anova.Fcontinuum{1});
    else
        dimensions=size(anova.Fcontinuum);
    end
    
    if ischar(anova.effectNames)
        
        % Plot of Anova Results
        displayAnovaOn(anova.Fcontinuum,anova.Fthreshold,anova.Fsignificant{1},Fs,xlab,ylab,ylimits,dimensions,nTicksX,nTicksY,xlimits,colorMap,imageSize,imageFontSize)
        if displayContour & size(anova.Fcontinuum,2)>1
            dispContour(anova.Fcontinuum,anova.Fthreshold,contourColor,dashedColor,transparancy,lineWidth,lineStyle)
        end
        title(anova.effectNames)
        
    else
        
        for k=1:numel(anova.effectNames)
            
            % Plot of the full anova results
            displayAnovaOn(anova.Fcontinuum{k},anova.Fthreshold{k},anova.Fsignificant{k},Fs,xlab,ylab,ylimits,dimensions,nTicksX,nTicksY,xlimits,colorMap,imageSize,imageFontSize)
            if displayContour & size(anova.Fcontinuum{k},2)>1
                dispContour(anova.Fcontinuum{k},anova.Fthreshold{k},contourColor,dashedColor,transparancy,lineWidth,lineStyle)
            end
            title(anova.effectNames{k})
            
        end
        
    end
end

%% POST HOC 1D
posthoc=spmAnalysis.posthoc;
dimensions=size(spmAnalysis.posthoc{1}.tTests.Tcontinuum{1});
if min(dimensions)==1
    
    
    %% Means + SPM plots
    
    % T-TESTS and ANOVA1
    if numel(posthoc)==1
        
        clPlot=chooseCL(colorLine,lineStyle,1);
        
        if spmAnalysis.anova.type~="no ANOVA" % plot with aov
            plotmeanSPMon(posthoc{1}.data.continuum,posthoc{1}.tTests.Tcontinuum,posthoc{1}.tTests.Tsignificant,posthoc{1}.data.names,posthoc{1}.differences.names,CI,xlab,ylab,Fs,xlimits,nTicksX,nTicksY,clPlot,imageFontSize,imageSize,transparancy1D,ylimits,anova.Fsignificant,{posthoc{1}.name},ratioSPM,spmPos,aovColor)
        else
            plotmeanSPMon(posthoc{1}.data.continuum,posthoc{1}.tTests.Tcontinuum,posthoc{1}.tTests.Tsignificant,posthoc{1}.data.names,posthoc{1}.differences.names,CI,xlab,ylab,Fs,xlimits,nTicksX,nTicksY,clPlot,imageFontSize,imageSize,transparancy1D,ylimits,[],[],ratioSPM,spmPos,aovColor)
        end
        
        % MAIN EFFECT FOR ANOVA 2 and 3
    else
        
        if numel(posthoc)==3
            pMax=2;
        else
            pMax=3;
        end
        
        for np=1:pMax
            
            clPlot=chooseCL(colorLine,lineStyle,np);
            
            plotmeanSPMon(posthoc{np}.data.continuum,posthoc{np}.tTests.Tcontinuum,posthoc{np}.tTests.Tsignificant,posthoc{np}.data.names,posthoc{np}.differences.names,CI,xlab,ylab,Fs,xlimits,nTicksX,nTicksY,clPlot,imageFontSize,imageSize,transparancy1D,ylimits,anova.Fsignificant(np),anova.effectNames(np),ratioSPM,spmPos,aovColor)
            
        end
        
        %% DOUBLE INTERACTION FOR ANOVA3
        if numel(posthoc)==7
            
            for effectFixed=1:3
                
                fixedEffect=effectFixed;
                mainEffect=1:3;
                mainEffect(fixedEffect)=[];
                anovaFixedCorr=[3 2 1];
                np=3+anovaFixedCorr(fixedEffect);
                
                combi=posthoc{np}.tTests.combi;
                [nPlot,whichPlot,whichFixed,whichModal]=findNPlot(combi);
                
                for p=1:nPlot
                    
                    clPlot=chooseCL(colorLine,lineStyle,mainEffect(whichFixed(2,p)));
                    
                    
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
                    
                    plotmeanSPMon(posthoc{np}.data.continuum(whichPlot{p}),posthoc{np}.tTests.Tcontinuum(:,whichCompare),posthoc{np}.tTests.Tsignificant(:,whichCompare),posthoc{np}.data.names(whichPlot{p}),posthoc{np}.differences.names(whichCompare),CI,xlab,ylab,Fs,xlimits,nTicksX,nTicksY,clPlot,imageFontSize,imageSize,transparancy1D,ylimits,anova.Fsignificant([mainEffect(whichFixed(2,p)), nAnova]),{anova.effectNames{mainEffect(whichFixed(2,p))},[anova.effectNames{mainEffect(1)} ' x ' anova.effectNames{mainEffect(2)}]},ratioSPM,spmPos,aovColor)
                    
                    clear isEmptydata findT capPos whichCompare
                    
                end
            end
        end
        
        %% DOULE INTERACTION FOR ANOVA2 or TRIPLE INTERACTIONS FOR ANOVA3
        
        pos=numel(posthoc);
        combi=posthoc{pos}.tTests.combi;
        [nPlot,whichPlot,whichFixed,whichModal]=findNPlot(combi);
        
        
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
                plotmeanSPMon(posthoc{pos}.data.continuum(whichPlot{p}),posthoc{pos}.tTests.Tcontinuum(:,whichCompare),posthoc{pos}.tTests.Tsignificant(:,whichCompare),posthoc{pos}.data.names  (whichPlot{p}(isEmptydata)),posthoc{pos}.differences.names(whichCompare),CI,xlab,ylab,Fs,xlimits,nTicksX,nTicksY,clPlot,imageFontSize,imageSize,transparancy1D,ylimits,anova.Fsignificant([whichFixed(2,p) 3]),{anova.effectNames{whichFixed(2,p)},[anova.effectNames{1} ' x ' anova.effectNames{2}]},ratioSPM,spmPos,aovColor)
                
            else
                [nAnovaInt,nNames]=whichAnovaInt(whichFixed(1,p));
                
                plotmeanSPMon(posthoc{pos}.data.continuum(whichPlot{p}),posthoc{pos}.tTests.Tcontinuum(:,whichCompare),posthoc{pos}.tTests.Tsignificant(:,whichCompare),posthoc{pos}.data.names  (whichPlot{p}(isEmptydata)),posthoc{pos}.differences.names(whichCompare),CI,xlab,ylab,Fs,xlimits,nTicksX,nTicksY,clPlot,imageFontSize,imageSize,transparancy1D,ylimits,...
                    anova.Fsignificant([whichFixed(1,p) nAnovaInt 7]),{anova.effectNames{whichFixed(1,p)},[anova.effectNames{nNames(1,1)} ' x ' anova.effectNames{nNames(1,2)}], [anova.effectNames{nNames(2,1)} ' x ' anova.effectNames{nNames(2,2)}],[anova.effectNames{1} ' x ' anova.effectNames{2} ' x ' anova.effectNames{3}]},ratioSPM,spmPos,aovColor)
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
        
        
        for combi=1:numel(posthoc{np}.data.meanContinuum)
            
            % means
            displayMeanMapsOn(posthoc{np}.data.meanContinuum{combi},Fs,xlab,ylab,ylimits,nTicksX,nTicksY,limitMeanMaps,xlimits,imageFontSize,imageSize,colorbarLabel,colorMap)
            title(posthoc{np}.data.names{combi})
            
            
        end
        
        for comp=1:numel(posthoc{np}.differences.names)
            
            % spm analysis
            displayTtestOn(posthoc{np}.tTests.Tcontinuum{comp},posthoc{np}.tTests.Tthreshold{comp},[],Fs,xlab,ylab,ylimits,dimensions,nTicksX,nTicksY,xlimits,imageFontSize,imageSize,colorMapDiff)
            if displayContour
                dispContour(abs(posthoc{np}.tTests.Tcontinuum{comp}),posthoc{np}.tTests.Tthreshold{comp},contourColor,dashedColor,transparancy,lineWidth,lineStyle)
            end
            title(posthoc{np}.differences.names{comp})
            
        end
        
    end
end

end