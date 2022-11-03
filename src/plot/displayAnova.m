%% INPUTS
% Obligatory
% Map of F-values
% Threshold of significativity

%% OUTPUT
% Figure of the anova results

function []=displayAnova(mapF,Fthreshold,anovaEffects,Fs,xlab,ylab,ylimits,dimensions,nx,ny,xlimits,colorMap,imageSize,imageFontSize,equalAxis,deleteAxis,statLimit)

anovaEffects=anovaEffects(:)';

if isempty(imageSize)
    figure('Units', 'Pixels', 'OuterPosition', [0, 0, 720, 480],'visible','off');
elseif max(size(imageSize))==1
    figure('Units', 'Centimeter', 'OuterPosition', [0, 0, imageSize, imageSize],'visible','off');
else
    figure('Units', 'Centimeter', 'OuterPosition', [0, 0, imageSize(1), imageSize(2)],'visible','off');
end

if dimensions(1)==1 | dimensions(2)==1 %1D

    time=0:1/Fs:(max(size(mapF))-1)/Fs;
    plot(time,mapF,'k','linewidth',1); hold on
    ylim([0 1.05*max([max(mapF) Fthreshold])])

    clusters=find(abs(diff(anovaEffects))==1);
    clusters=[0,clusters,max(size(mapF))];
    legendDone=0;
    for t=1:size(clusters,2)-1
        timeCluster=time(clusters(t)+1:clusters(t+1));
        mapCluster=mapF(clusters(t)+1:clusters(t+1));
        goPlot=mean(anovaEffects(clusters(t)+1:clusters(t+1)));
        if goPlot==1
            if legendDone==0
                plot(timeCluster, mapCluster,'b','linewidth',2)
                legendDone=1;
            else
                plot(timeCluster, mapCluster,'b','linewidth',2,'handlevisibility','off')
            end
            vline([timeCluster(1),timeCluster(end)],'linetype','-.k','displayLegend',0)
        end
    end

    xlabel(xlab)
    ylabel('SnPM (F)')
    if ~isempty(xlimits)
        xlabels=linspace(xlimits(1),xlimits(end),nx);
    else
        xlabels=linspace(0,(max(size(mapF)))/Fs,nx);
    end
    xticks(linspace(0,(max(size(mapF))-1)/Fs,nx))
    for i=1:nx
        if xlabels(i)<0 && xlabels(i)>-1e-16
            xlabs{i}='0';
        elseif abs(xlabels(i))==0 | abs(xlabels(i))>=1 & abs(xlabels(i))<100
            xlabs{i}=sprintf('%0.2g',xlabels(i));
        elseif abs(xlabels(i))>=100
            xlabs{i}=sprintf('%d',round(xlabels(i)));
        else
            xlabs{i}=sprintf('%0.2f',xlabels(i));
        end
    end
    xticklabels(xlabs)
    box off

    hline(Fthreshold,'displayLegend',1)
    if max(anovaEffects)==0
        legend({'F-value',['Threshold = ' sprintf('%0.3g',Fthreshold)]},'Location','eastoutside','Box','off');
    else
        legend({'F-value','Significant cluster',['Threshold = ' sprintf('%0.3g',Fthreshold)]},'Location','eastoutside','Box','off');
    end


else %2D

    if isempty(ny)
        ny=4;
    end

    if isempty(ylimits)
        ylimits=[0 size(mapF,1)];
    end

    imagesc(flipud(mapF))
    ylabel(ylab)
    xlabel(xlab);
    colormap(colorMap)
    Co=colorbar('EastOutside');
    Co.Label.String=('SnPM (F)');

    if ~isempty(ylimits)
        ylabels=linspace(ylimits(end),ylimits(1),ny);
    else
        ylabels=linspace((size(mapF,1))/Fs,0,nx);
    end
    yticks(linspace(1,size(mapF,1),ny))
    for i=1:ny
        if abs(ylabels(i))==0 | abs(ylabels(i))>=1 & abs(ylabels(i))<100
            ylabs{i}=sprintf('%0.2g',ylabels(i));
        elseif abs(ylabels(i))>=100
            ylabs{i}=sprintf('%d',round(ylabels(i)));
        else
            ylabs{i}=sprintf('%0.2f',ylabels(i));
        end
    end
    yticklabels(ylabs)

    if ~isempty(xlimits)
        xlabels=linspace(xlimits(1),xlimits(end),nx);
    else
        xlabels=linspace(0,(size(mapF,2))/Fs,nx);
    end
    xticks(linspace(1,size(mapF,2),nx))
    for i=1:nx
        if abs(xlabels(i))==0 | abs(xlabels(i))>=1 & abs(xlabels(i))<100
            xlabs{i}=sprintf('%0.2g',xlabels(i));
        elseif abs(xlabels(i))>=100
            xlabs{i}=sprintf('%d',round(xlabels(i)));
        else
            xlabs{i}=sprintf('%0.2f',xlabels(i));
        end
    end
    xticklabels(xlabs)
    box off

    if statLimit==0
        if ~isnan(Fthreshold)
            caxis([0 max([max(mapF) Fthreshold])])
        end
    else
        caxis([0 max(max(mapF))])
    end

    if equalAxis==1
        axis equal
    end
    if deleteAxis==1
        set(findall(gca, 'type', 'axes'), 'visible', 'off')
    end

end

set(gca,'FontSize',imageFontSize)


end

