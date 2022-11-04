%% INPUTS
% Obligatory
% Map of F-values
% Threshold of significativity

%% OUTPUT
% Figure of the anova results

function []=displayMeanMaps_sub(map,Fs,limitMeanMaps,colorMap,equalAxis,deleteAxis)

imagesc(flipud(map))
colormap(colorMap)
if ~isempty(limitMeanMaps)
    if numel(limitMeanMaps)==1
        caxis([0 limitMeanMaps]);
    else
        caxis([limitMeanMaps]);
    end
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

% to force the axes to actualize
hold on
drawnow;
contour(flipud(map),[2*max(max(map)) 10*max(max(map))])

end

