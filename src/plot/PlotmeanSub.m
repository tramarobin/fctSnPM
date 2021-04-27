function PlotmeanSub(mapsAll,nameSub,effectsRm,effectNames,savedir,xlab,ylab,Fs,imageResolution,CI,ylimits,nTicksX,nTicksY,xlimits,imageFontSize,imageSize,colorLine,colorMap,colorbarLabel,limitMeanMaps,transparancy1D)
warning('off', 'MATLAB:MKDIR:DirectoryExists');
mkdir([savedir '\MeanSub'])
nSuj=size(mapsAll,1);
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
            plotmean(Dataplot,CI,xlab,ylab,Fs,xlimits,nTicksX,nTicksY,colorLine,imageFontSize,imageSize,transparancy1D,ylimits)
        else
            Dataplot=mapsAll{i,cond};
            displayMeanMaps(Dataplot,Fs,xlab,ylab,ylimits,nTicksX,nTicksY,limitMeanMaps,xlimits,imageFontSize,imageSize,colorbarLabel,colorMap)
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
            mkdir([savedir '\MeanSub\' nameSub{i}])
            print('-dtiff',imageResolution,[savedir '\MeanSub\' nameSub{i} '\' t '.tiff'])
        else
            print('-dtiff',imageResolution,[savedir '\MeanSub\' nameSub{i} '.tiff'])
        end
        close
        
    end
end


end