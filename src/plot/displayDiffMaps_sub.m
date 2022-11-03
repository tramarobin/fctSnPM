%% INPUTS

%% OUTPUT

function []=displayDiffMaps_sub(map,Fs,limitMeanMaps,diffRatio,colorMapDiff,ax,equalAxis,deleteAxis)

map(abs(map)==inf)=0;
map(isnan(map))=0;

imagesc(flipud(map)); hold on
colormap(ax,colorMapDiff)

if ~isempty(limitMeanMaps)
    if numel(limitMeanMaps)==1
        caxis([-diffRatio*limitMeanMaps diffRatio*limitMeanMaps]);
    else
        caxis([-diffRatio*limitMeanMaps(2) diffRatio*limitMeanMaps(2)]);
    end
else
    caxis([-max(max(abs(map))) max(max(abs(map)))]);
end

xticklabels('')
yticklabels('')
xlabel('')
ylabel('')
box off

if equalAxis==1
    axis equal
end
if deleteAxis==1
    set(findall(gca, 'type', 'axes'), 'visible', 'off')
end


end

