%% INPUTS

%% OUTPUT

function []=displayDiffMaps(map,Fs,xlab,ylab,ylimits,nx,ny,limitMeanMaps,xlimits,imageFontSize,imageSize,colorbarLabel,colorMap,diffRatio,equalAxis,deleteAxis)

if isempty(imageSize)
    figure('Units', 'Pixels', 'OuterPosition', [0, 0, 720, 480],'visible','off');
elseif max(size(imageSize))==1
    figure('Units', 'Centimeter', 'OuterPosition', [0, 0, imageSize, imageSize],'visible','off');
else
    figure('Units', 'Centimeter', 'OuterPosition', [0, 0, imageSize(1), imageSize(2)],'visible','off');
end

if isempty(ylimits)
    ylimits=[0 size(map,1)];
end

map(abs(map)==inf)=0;
map(isnan(map))=0;
imagesc(flipud(map)); hold on
ylabel(ylab)
xlabel(xlab)
colormap(colorMap)
Co=colorbar('EastOutside');
Co.Label.String=(['Differences of ' lower(colorbarLabel)]);
Co.FontSize=imageFontSize;

if ~isempty(limitMeanMaps)
    if numel(limitMeanMaps)==1
        caxis([-diffRatio*limitMeanMaps diffRatio*limitMeanMaps]);
    else
        caxis([-diffRatio*limitMeanMaps(2) diffRatio*limitMeanMaps(2)]);
    end

else
    caxis([-max(max(abs(map))) max(max(abs(map)))]);
end

if ~isempty(ylimits)
    ylabels=linspace(ylimits(end),ylimits(1),ny);
else
    ylabels=linspace((size(map,1))/Fs,0,nx);
end
yticks(linspace(1,size(map,1),ny))
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
    xlabels=linspace(0,(size(map,2))/Fs,nx);
end
xticks(linspace(1,size(map,2),nx))
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

set(gca,'FontSize',imageFontSize)

if equalAxis==1
    axis equal
end
if deleteAxis==1
    set(findall(gca, 'type', 'axes'), 'visible', 'off')
end

end

