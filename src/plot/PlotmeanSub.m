function PlotmeanSub(mapsAll,nameSub,effectsRm,effectNames,savedir,xlab,ylab,Fs,imageResolution,CI,ylimits,nx,ny,xlimits,imageFontSize,imageSize,colorLine,colorMap,colorbarLabel,limitMeanMaps,transparancy1D,equalAxis,deleteAxis)
warning('off', 'MATLAB:MKDIR:DirectoryExists');
mkdir([savedir '\MeanSub'])
nSuj=size(mapsAll,1);
if isempty(ny)
    ny=4;
end
if isempty(nameSub)
    for i=1:nSuj
        nameSub{i}=num2str(i);
    end
end
colorLine=[];
if isempty(effectsRm)
    nCond=1;
else
    nCond=size(effectsRm{1},2);
end
for i=1:nSuj
    for cond=1:nCond
        if min(size(mapsAll{i,cond}))==1
            Dataplot{1}=mapsAll{i,cond}';
            plotmean(Dataplot,CI,xlab,ylab,Fs,xlimits,nx,ny,colorLine,imageFontSize,imageSize,transparancy1D,ylimits)
        else
            Dataplot=mapsAll{i,cond};
            displayMeanMaps(Dataplot,Fs,xlab,ylab,ylimits,nx,ny,limitMeanMaps,xlimits,imageFontSize,imageSize,colorbarLabel,colorMap,equalAxis,deleteAxis)
        end
        t=[];
        for c=1:size(effectsRm,2)
            t=[t ' ' effectsRm{c}{cond}];
        end
        if ~isempty(t)
            t(1)=[];
            title(t)
        end
        if ~isempty(t)
            mkdir(fullfile(savedir, 'MeanSub', nameSub{i}))
            if min(size(mapsAll{i,cond}))==1
                print('-dtiff',imageResolution,[savedir '\MeanSub\' nameSub{i} '\' t '.tiff'])
            else
                exportgraphics(gcf,fullfile(savedir, 'MeanSub', verifSaveName(nameSub{i}), t, '.tif'),'Resolution',imageResolution)
            end
        else
            if min(size(mapsAll{i,cond}))==1
                print('-dtiff',imageResolution,[savedir '\MeanSub\' nameSub{i} '.tiff'])
            else
                exportgraphics(gcf,fullfile(savedir, 'MeanSub', [verifSaveName(nameSub{i}) '.tif']),'Resolution',imageResolution)
            end
        end
        close all

    end
end
end