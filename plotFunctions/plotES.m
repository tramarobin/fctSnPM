%% INPUTS
% Obligatory
% Map of F-values
% Threshold of significativity

%% OUTPUT
% Figure of the anova results

function []=plotES(mapT,sdT,mapsT,Fs,xlab,nx,xlimits,imageFontSize,imageSize,transparancy1D,yLimitES)

if isempty(imageSize)
    figure('Units', 'Normalized', 'OuterPosition', [0, 0, 1, 1],'visible','off');
elseif max(size(imageSize))==1
    figure('Units', 'Centimeter', 'OuterPosition', [0, 0, imageSize, imageSize],'visible','off');
else
    figure('Units', 'Centimeter', 'OuterPosition', [0, 0, imageSize(1), imageSize(2)],'visible','off');
end

ESup=mapT+1.96*sdT;
ESinf=mapT-1.96*sdT;
time=0:1/Fs:(max(size(mapT))-1)/Fs;
noNan=~isnan(mapT);
plot(time(noNan),mapT(noNan),'k','linewidth',1); hold on
fill([time(noNan),fliplr(time(noNan))], [ESup(noNan),fliplr(ESinf(noNan))],'b','EdgeColor','none','facealpha',transparancy1D);
plot(time(noNan),ESup(noNan),'--b')
plot(time(noNan),ESinf(noNan),'--b')

hline(0,'linetype','--r')
hline([0.2 0.5 0.8],'linetype',':k')
xlabel(xlab)
ylabel('Effect Size \pm 95% CI')
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


y=get(gca,'ylim');
if ~isempty(yLimitES)
    if numel(yLimitES)==1
        ylim([y(1), yLimitES])
    else
        ylim(yLimitES)
    end
end

clusters=find(abs(diff(mapsT'))==1)';
clusters=transposeColmunIfNot(clusters);
clusters=[0;clusters;max(size(mapT))];
for t=1:size(clusters,1)-1
    timeCluster=time(clusters(t)+1:clusters(t+1));
    mapCluster=mapT(clusters(t)+1:clusters(t+1));
    goPlot=mean(mapsT(clusters(t)+1:clusters(t+1)));
    if goPlot==1
        plot(timeCluster,mapCluster,'b','linewidth',2)
        vline([timeCluster(1),timeCluster(end)],'linetype','-.k','displayLegend',0)
    end
end

set(gca, 'YTick', unique([[0 0.2 0.5 0.8], get(gca, 'YTick')]));
set(gca,'FontSize',imageFontSize)

end

