function PlotmeanSub(mapsAll,nameSub,effectsRm,effectNames,savedir,xlab,ylab,Fs,imageResolution,CI,ylimits,nTicksX,nTicksY,xlimits,imageFontSize,imageSize,colorLine,colorMap,colorbarLabel,limitMeanMaps,transparancy1D)
nSuj=size(mapsAll,1);
if isempty(nameSub)
    for i=1:nSuj
        nameSub{i}=num2str(i);
    end
end
colorLine=[];
for i=1:nSuj
    for cond=1:size(effectsRm{1},2)
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
        t(1)=[];
        title(t)
        mkdir([savedir '\MeanSub\' nameSub{i}])
        print('-dtiff',imageResolution,[savedir '\MeanSub\' nameSub{i} '\' t '.tiff'])
        close
        
    end
end


end