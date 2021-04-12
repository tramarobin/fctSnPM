%% INPUTS
% Obligatory
% Map of F-values
% Threshold of significativity

%% OUTPUT
% Figure of the anova results

function []=displayMeanMaps_sub(map,Fs,limitMeanMaps,colorMap)

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

end

