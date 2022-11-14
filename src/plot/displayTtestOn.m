%% INPUTS
% Obligatory
% Map of F-values
% Threshold of significativity

%% OUTPUT
% Figure of the anova results

function []=displayTtestOn(mapT,Tthreshold,anovaEffects,Fs,xlab,ylab,ylimits,dimensions,nx,ny,xlimits,imageFontSize,imageSize,colorMap,equalAxis,deleteAxis,statLimit)

if isempty(imageSize)
    figure('Units', 'Pixels', 'OuterPosition', [0, 0, 720, 480],'visible','on');
elseif max(size(imageSize))==1
    figure('Units', 'Centimeter', 'OuterPosition', [0, 0, imageSize, imageSize],'visible','on');
else
    figure('Units', 'Centimeter', 'OuterPosition', [0, 0, imageSize(1), imageSize(2)],'visible','on');
end

if dimensions(1)==1 | dimensions(2)==1 %1D
    time=0:1/Fs:(max(size(mapT))-1)/Fs;
    plot(time,mapT,'k','linewidth',1); hold on

    hline([-Tthreshold Tthreshold],'displayLegend',0,'linetype',':w')
    hline(0,'linetype','--r')

    clusters=find(abs(diff(anovaEffects'))==1)';
    clusters=transposeColmunIfNot(clusters);
    clusters=[0;clusters;max(size(mapT))];
    legendDone=0;
    for t=1:size(clusters,1)-1
        timeCluster=time(clusters(t)+1:clusters(t+1));
        mapCluster=mapT(clusters(t)+1:clusters(t+1));
        goPlot=mean(anovaEffects(clusters(t)+1:clusters(t+1)));
        if goPlot==1
            if legendDone==0
                plot(timeCluster,mapCluster,'b','linewidth',2)
                legendDone=1;
            else
                plot(timeCluster,mapCluster,'b','linewidth',2,'handlevisibility','off')
            end
            vline([timeCluster(1),timeCluster(end)],'linetype','-.k','displayLegend',0)
        end
    end

    xlabel(xlab)
    ylabel('SnPM (t)')
    if ~isempty(xlimits)
        xlabels=linspace(xlimits(1),xlimits(end),nx);
    else
        xlabels=linspace(0,(max(size(mapT)))/Fs,nx);
    end
    xticks(linspace(0,(max(size(mapT))-1)/Fs,nx))
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

    hline([-Tthreshold Tthreshold],'displayLegend',1)
    if max(anovaEffects)==0
        legend({'t-value',['Threshold = \pm' sprintf('%0.3g',Tthreshold)]},'Location','eastoutside','Box','off');
    else
        legend({'t-value','Significant cluster',['Threshold = \pm' sprintf('%0.3g',Tthreshold)]},'Location','eastoutside','Box','off');
    end


else % 2D

    mapT(abs(mapT)==inf)=0;
    mapT(isnan(mapT))=0;

    if isempty(ylimits)
        ylimits=[0 size(mapT,1)];
    end

    imagesc(flipud(mapT))
    ylabel(ylab)
    xlabel(xlab);
    colormap(colorMap)
    Co=colorbar('EastOutside');
    Co.Label.String=('SnPM (t)');
    Co.FontSize=imageFontSize;


    if ~isempty(ylimits)
        ylabels=linspace(ylimits(end),ylimits(1),ny);
    else
        ylabels=linspace((size(mapT,1))/Fs,0,nx);
    end
    yticks(linspace(1,size(mapT,1),ny))
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
        xlabels=linspace(0,(size(mapT,2))/Fs,nx);
    end
    xticks(linspace(1,size(mapT,2),nx))
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

    if statLimit==0
        caxis([-Tthreshold Tthreshold]);
    else
        caxis([-max(max(mapT)) max(max(mapT))])
    end

    set(gca,'FontSize',imageFontSize)

    if equalAxis==1
        axis equal
    end
    if deleteAxis==1
        set(findall(gca, 'type', 'axes'), 'visible', 'off')
    end

end

set(gca,'FontSize',imageFontSize)

end

