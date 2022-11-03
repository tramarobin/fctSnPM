%% INPUTS
% Obligatory
% Map of F-values
% Threshold of significativity

%% OUTPUT
% Figure of the anova results

function []=plotTtest(mapT,Tthreshold,anovaEffects,Fs,xlab,ylab,ylimits,dimensions,nx,ny,xlimits,imageFontSize,imageSize)

if isempty(imageSize)
    figure('Units', 'Pixels', 'OuterPosition', [0, 0, 720, 480],'visible','off');
elseif max(size(imageSize))==1
    figure('Units', 'Centimeter', 'OuterPosition', [0, 0, imageSize, imageSize],'visible','off');
else
    figure('Units', 'Centimeter', 'OuterPosition', [0, 0, imageSize(1), imageSize(2)],'visible','off');
end

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
    
set(gca,'FontSize',imageFontSize)

end

