% Trama Robin (LIBM) July 14th, 2021 --> JOSS
% Trama Robin (HPL) November 14th, 2022 --> The pressure update
% trama.robin@gmail.com

% available at :
% - https://github.com/tramarobin/fctSnPM
% - https://www.mathworks.com/matlabcentral/fileexchange/77945-fctSnPM

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% plot a part of the analysis obtain with `fctSnPM` and `fctSnPMS`.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% INPUTS
% OBLIGATORY
% snpmAnalysis obtained with `fctSnPM` or `fctSnPMS`.

% OPTIONAL
% see the description at begining of the function (inputParser) or on GitHub (https://github.com/tramarobin/fctSnPM#optional-inputs)
% see ./fctSnPM/Examples for help


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function onlyPlot(snpmAnalysis,varargin)

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
addParameter(p,'colorMapDiff',flipud(cbrewer('div','RdBu', 64))) % colormap used for differences and SnPM plot (0 centered)
addParameter(p,'colorbarLabel','',@ischar); % name of the colorbar label
addParameter(p,'limitMeanMaps',[],@isnumeric); % limit of the colorbar. the value of X will make the colorbar going from 0 to X for all plots (easier to compare). If not specified, the maps wont necessery be with the same range but will be automatically scaled
addParameter(p,'displaycontour',1,@isnumeric); % display contour map on differences and size effect maps (0 to not display)
addParameter(p,'contourcolor','w'); % color of the line for the contour plot
addParameter(p,'dashedColor',[0 0 0],@isnumeric) % color of the dashed zone of the contour plot (default is white)
addParameter(p,'transparancy',50,@isnumeric) % transparancy of the dashed zone (0=transparant, 255=opaque)
addParameter(p,'lineWidth',2.5,@isnumeric) % linewidth of the contour plot
addParameter(p,'equalAxis',0,@isnumeric) % enables the equal axis option for plots (useful for pressure/positional data). By default (0), the option is not enable. 1 to enable
addParameter(p,'deleteAxis',0,@isnumeric) % deletes the axes (useful for pressure data). By default (0), the axes are displayed. 1 to enable (also delete the title of the graph)
addParameter(p,'statLimit',0,@isnumeric) % default option set the colorbar limit of the stat maps at the significance threshold, 1 will set the limit to the max

% 1d plot parameters
addParameter(p,'CI',[],@isnumeric); % confidence interval is used instead of standard deviation (0.7-->0.999), 0 to display SEM, , or negative value to not dispaly dispersion
addParameter(p,'colorLine',[]); % colorline for plots (default  is "lines") // rgb triplet, if in cell, apply each color to each effect (independant effect first)
addParameter(p,'transparancy1D',0.10); % transparancy of SD for 1D plot
addParameter(p,'ratioSnPM',[1 3]); % ratio of SnPM subplot relative to total figure (default if 1/3 of the figure)
addParameter(p,'SnPMPos',[]); % postion of SnPM plot, default is bottom, any value will set the position to up
addParameter(p,'aovColor','k'); % color of anova on SnPM plot (color or rgb)
addParameter(p,'yLine',[]); % add vertical lines on mean plots. One line is contained in one cell (several lines can be plot is there are several cells). yLine{1}={50,'k--',2}; will plot a vertical black dotted line at the coordinate 50, with a linewidth of 2.
addParameter(p,'xLine',[]); % add horizontal lines on mean plots. Specify the coordinate, color, linewith, linestyle. One line is contained in one cell (several lines can be plot is there are several cells). xLine{1}={0,'b-',1}; will plot a horizontal blue full line at the coordinate 0, with a linewidth of 1.
addParameter(p,'yGrid',0); % 1 to display the vertical grid on mean plots. Default is 0 (no grid), 1 to plot grid.
addParameter(p,'xGrid',0); % 1 to display the horizontal grid on mean plots. Default is 0 (no grid), 1 to plot grid.

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
ratioSnPM=p.Results.ratioSnPM;
SnPMPos=p.Results.SnPMPos;
aovColor=p.Results.aovColor;
colorLine=p.Results.colorLine;
xLine=p.Results.xLine;
yLine=p.Results.yLine;
xGrid=p.Results.xGrid;
yGrid=p.Results.yGrid;
equalAxis=p.Results.equalAxis;
deleteAxis=p.Results.deleteAxis;
statLimit=p.Results.statLimit;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
close all
set(0, 'DefaultFigureVisible', 'on');
warning('off', 'MATLAB:MKDIR:DirectoryExists');


%% ANOVA
if snpmAnalysis.anova.type~="no ANOVA"
    anova=snpmAnalysis.anova;
    if iscell(anova.Fcontinuum)
        dimensions=size(anova.Fcontinuum{1});
    else
        dimensions=size(anova.Fcontinuum);
    end

    if ischar(anova.effectNames)

        % Plot of Anova Results
        displayAnovaOn(anova.Fcontinuum,anova.Fthreshold,anova.Fsignificant{1},Fs,xlab,ylab,ylimits,dimensions,nTicksX,nTicksY,xlimits,colorMap,imageSize,imageFontSize,equalAxis,deleteAxis,statLimit)
        if displayContour & size(anova.Fcontinuum,2)>1
            dispContour(anova.Fcontinuum,anova.Fthreshold,contourColor,dashedColor,transparancy,lineWidth,lineStyle)
        end
        title(anova.effectNames)

    else

        for k=1:numel(anova.effectNames)

            % Plot of the full anova results
            displayAnovaOn(anova.Fcontinuum{k},anova.Fthreshold{k},anova.Fsignificant{k},Fs,xlab,ylab,ylimits,dimensions,nTicksX,nTicksY,xlimits,colorMap,imageSize,imageFontSize,equalAxis,deleteAxis,statLimit)
            if displayContour & size(anova.Fcontinuum{k},2)>1
                dispContour(anova.Fcontinuum{k},anova.Fthreshold{k},contourColor,dashedColor,transparancy,lineWidth,lineStyle)
            end
            title(anova.effectNames{k})

        end

    end
end

%% POST HOC 1D
posthoc=snpmAnalysis.posthoc;
dimensions=size(snpmAnalysis.posthoc{1}.tTests.Tcontinuum{1});
if min(dimensions)==1


    %% Means + SnPM plots

    % T-TESTS and ANOVA1
    if numel(posthoc)==1

        clPlot=chooseCL(colorLine,lineStyle,1);

        if snpmAnalysis.anova.type~="no ANOVA" % plot with aov
            plotmeanSnPMon(posthoc{1}.data.continuum,posthoc{1}.tTests.Tcontinuum,posthoc{1}.tTests.Tsignificant,posthoc{1}.data.names,posthoc{1}.differences.names,CI,xlab,ylab,Fs,xlimits,nTicksX,nTicksY,clPlot,imageFontSize,imageSize,transparancy1D,ylimits,anova.Fsignificant,{posthoc{1}.name},ratioSnPM,SnPMPos,aovColor,xLine,yLine,xGrid,yGrid)
        else
            plotmeanSnPMon(posthoc{1}.data.continuum,posthoc{1}.tTests.Tcontinuum,posthoc{1}.tTests.Tsignificant,posthoc{1}.data.names,posthoc{1}.differences.names,CI,xlab,ylab,Fs,xlimits,nTicksX,nTicksY,clPlot,imageFontSize,imageSize,transparancy1D,ylimits,[],[],ratioSnPM,SnPMPos,aovColor,xLine,yLine,xGrid,yGrid)
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

            plotmeanSnPMon(posthoc{np}.data.continuum,posthoc{np}.tTests.Tcontinuum,posthoc{np}.tTests.Tsignificant,posthoc{np}.data.names,posthoc{np}.differences.names,CI,xlab,ylab,Fs,xlimits,nTicksX,nTicksY,clPlot,imageFontSize,imageSize,transparancy1D,ylimits,anova.Fsignificant(np),anova.effectNames(np),ratioSnPM,SnPMPos,aovColor,xLine,yLine,xGrid,yGrid)

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

                    plotmeanSnPMon(posthoc{np}.data.continuum(whichPlot{p}),posthoc{np}.tTests.Tcontinuum(:,whichCompare),posthoc{np}.tTests.Tsignificant(:,whichCompare),posthoc{np}.data.names(whichPlot{p}),posthoc{np}.differences.names(whichCompare),CI,xlab,ylab,Fs,xlimits,nTicksX,nTicksY,clPlot,imageFontSize,imageSize,transparancy1D,ylimits,anova.Fsignificant([mainEffect(whichFixed(2,p)), nAnova]),{anova.effectNames{mainEffect(whichFixed(2,p))},[anova.effectNames{mainEffect(1)} ' x ' anova.effectNames{mainEffect(2)}]},ratioSnPM,SnPMPos,aovColor,xLine,yLine,xGrid,yGrid)

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
                plotmeanSnPMon(posthoc{pos}.data.continuum(whichPlot{p}),posthoc{pos}.tTests.Tcontinuum(:,whichCompare),posthoc{pos}.tTests.Tsignificant(:,whichCompare),posthoc{pos}.data.names  (whichPlot{p}(isEmptydata)),posthoc{pos}.differences.names(whichCompare),CI,xlab,ylab,Fs,xlimits,nTicksX,nTicksY,clPlot,imageFontSize,imageSize,transparancy1D,ylimits,anova.Fsignificant([whichFixed(2,p) 3]),{anova.effectNames{whichFixed(2,p)},[anova.effectNames{1} ' x ' anova.effectNames{2}]},ratioSnPM,SnPMPos,aovColor,xLine,yLine,xGrid,yGrid)

            else
                [nAnovaInt,nNames]=whichAnovaInt(whichFixed(1,p));

                plotmeanSnPMon(posthoc{pos}.data.continuum(whichPlot{p}),posthoc{pos}.tTests.Tcontinuum(:,whichCompare),posthoc{pos}.tTests.Tsignificant(:,whichCompare),posthoc{pos}.data.names  (whichPlot{p}(isEmptydata)),posthoc{pos}.differences.names(whichCompare),CI,xlab,ylab,Fs,xlimits,nTicksX,nTicksY,clPlot,imageFontSize,imageSize,transparancy1D,ylimits,...
                    anova.Fsignificant([whichFixed(1,p) nAnovaInt 7]),{anova.effectNames{whichFixed(1,p)},[anova.effectNames{nNames(1,1)} ' x ' anova.effectNames{nNames(1,2)}], [anova.effectNames{nNames(2,1)} ' x ' anova.effectNames{nNames(2,2)}],[anova.effectNames{1} ' x ' anova.effectNames{2} ' x ' anova.effectNames{3}]},ratioSnPM,SnPMPos,aovColor,xLine,yLine,xGrid,yGrid)
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
            displayMeanMapsOn(posthoc{np}.data.meanContinuum{combi},Fs,xlab,ylab,ylimits,nTicksX,nTicksY,limitMeanMaps,xlimits,imageFontSize,imageSize,colorbarLabel,colorMap,equalAxis,deleteAxis)
            title(posthoc{np}.data.names{combi})


        end

        for comp=1:numel(posthoc{np}.differences.names)

            % SnPM analysis
            displayTtestOn(posthoc{np}.tTests.Tcontinuum{comp},posthoc{np}.tTests.Tthreshold{comp},[],Fs,xlab,ylab,ylimits,dimensions,nTicksX,nTicksY,xlimits,imageFontSize,imageSize,colorMapDiff,equalAxis,deleteAxis,statLimit)
            if displayContour
                dispContour(abs(posthoc{np}.tTests.Tcontinuum{comp}),posthoc{np}.tTests.Tthreshold{comp},contourColor,dashedColor,transparancy,lineWidth,lineStyle)
            end
            title(posthoc{np}.differences.names{comp})

        end

    end
end

end