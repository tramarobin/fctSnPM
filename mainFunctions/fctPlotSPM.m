function []=fctPlotSPM(file,varargin)

%% Optional inputs
p = inputParser;

% utilities
addParameter(p,'savedir',[],@ischar); % save directory

% general plot parameters
addParameter(p,'ylabel','',@ischar); % name of the y label
addParameter(p,'xlabel','',@ischar); % name of the xlabel
addParameter(p,'samplefrequency',1,@isnumeric); % change xticks to correspond at the specified frequency
addParameter(p,'xlimits',[],@isnumeric); % change xticks to correspond to the specified range
% specified either samplefrequency or xlimits, but not both
addParameter(p,'nTicksX',5,@isnumeric); % number of xticks displayed
addParameter(p,'nTicksY',4,@isnumeric); % number of yticks displayed
addParameter(p,'imageresolution',100,@isnumeric); % resolution in ppp of the tiff images
addParameter(p,'imageSize',[],@isnumeric) % size of the image in cm. X --> X*X images, [X Y] X*Y imgages. By default the unit is normalized [0 0 1 1].
addParameter(p,'imageFontSize',12,@isnumeric) % font size of images

% 2d plot parameters
addParameter(p,'colorMap',jet) % colormap used for means and differences plot
addParameter(p,'colorbarLabel','',@ischar); % name of the colorbar mabel
addParameter(p,'ylimits',[],@isnumeric); % change yticks to correspond to the specified range
addParameter(p,'limitMeanMaps',[],@isnumeric); % limit of the colorbar. the value of X will make the colorbar goind to -X to X for all plots. If not specified, the maps wont necessery be with the same colorbar
addParameter(p,'displaycontour',logical(1),@islogical); % display contour map on differences and size effect maps (logical(0) to not display)
addParameter(p,'contourcolor','w'); % color of the contour for the differences maps
addParameter(p,'dashedColor',[0 0 0],@isnumeric) % color of the dashed zone of the contour plot
addParameter(p,'transparency',50,@isnumeric) % transparancy of the dashed zone (0=transparant, 255=opaque)
addParameter(p,'lineWidth',2.5,@isnumeric) % linewidth of the contour plot
addParameter(p,'linestyle','-') % linewidth of the contour plot
addParameter(p,'diffRatio',0.33,@isnumeric) % the differences map will be scale at limitMeanMaps*diffRatio.
addParameter(p,'relativeRatio',[],@isnumeric) % the relative differences maps will be scale at +-relativeRatio

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
imageResolution=['-r' num2str(p.Results.imageresolution)];
colorbarLabel=p.Results.colorbarLabel;
limitMeanMaps=p.Results.limitMeanMaps;
dashedColor=p.Results.dashedColor;
transparency=p.Results.transparency;
lineWidth=p.Results.lineWidth;
linestyle=p.Results.linestyle;
imageSize=p.Results.imageSize;
imageFontSize=p.Results.imageFontSize;
colorMap=p.Results.colorMap;
diffRatio=p.Results.diffRatio;
relativeRatio=p.Results.relativeRatio;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

load(file)

if isempty(savedir)
    directory=findstr(file,'\');
    savedir=[file(1:directory(end)) '\PLOTS' strrep(file(directory(end):end),'.mat','') ];
    mkdir(savedir)
else
    mkdir(savedir)
end

%% Means
for combi=1:size(mapsConditions,2)
    displayMeanMaps(mapsConditions{combi},Fs,xlab,ylab,ylimits,nTicksX,nTicksY,limitMeanMaps,xlimits,imageFontSize,imageSize,colorbarLabel,colorMap)
    title(strrep(namesConditions{combi},' x ',' \cap '))
    print('-dtiff',imageResolution,[savedir '\' namesConditions{combi} '.tiff'])
    close
end

for comp=1:size(mapsDifferences,2)
    
    %% Differences
    displayDiffMaps(mapsDifferences{1,comp},Fs,xlab,ylab,ylimits,nTicksX,nTicksY,limitMeanMaps,xlimits,imageFontSize,imageSize,colorbarLabel,colorMap,diffRatio)
    title(namesDifferences{comp})
    if displayContour
        dispContour(abs(mapsT{1,comp}),Tthreshold{comp},contourColor,dashedColor,transparency,lineWidth,linestyle)
    end
    print('-dtiff',imageResolution,[savedir '\' namesDifferences{comp} ' diff.tiff'])
    close
    
    %% Relative differences
    displayRelativeDiffMaps(mapsDifferences{2,comp},Fs,xlab,ylab,ylimits,nTicksX,nTicksY,xlimits,imageFontSize,imageSize,colorMap,relativeRatio)
    if displayContour
        dispContour(abs(mapsT{1,comp}),Tthreshold{comp},contourColor,dashedColor,transparency,lineWidth,linestyle)
    end
    title(namesDifferences{comp})
    print('-dtiff',imageResolution,[savedir '\' namesDifferences{comp} ' diff%.tiff'])
    close
    
    %% Size Effect
    displayMapsES(ES{comp},Fs,xlab,ylab,ylimits,nTicksX,nTicksY,xlimits,imageFontSize,imageSize,colorMap)
    title(namesDifferences{comp})
    if displayContour
        dispContour(abs(mapsT{1,comp}),Tthreshold{comp},contourColor,dashedColor,transparency,lineWidth,linestyle)
    end
    print('-dtiff',imageResolution,[savedir '\' namesDifferences{comp} ' ES.tiff'])
    close
    
    %% SPM
    displayTtest(mapsT{comp,1},Tthreshold{comp},[],Fs,xlab,ylab,ylimits,size(mapsT{comp}),nTicksX,nTicksY,xlimits,imageFontSize,imageSize,colorMap)
    if displayContour
        dispContour(abs(mapsT{1,comp}),Tthreshold{comp},contourColor,dashedColor,transparency,lineWidth,linestyle)
    end
    title(namesDifferences{comp})
    print('-dtiff',imageResolution,[savedir '\' namesDifferences{comp} ' spm.tiff'])
    close
    
    
end