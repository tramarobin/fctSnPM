%% INPUTS

%% OUTPUT

function []=displayDiffMaps_sub(map,Fs,limitMeanMaps,diffRatio)

imagesc(flipud(map)); hold on
colormap(jet)

if ~isempty(limitMeanMaps)
    if numel(limitMeanMaps)==1
        caxis([-diffRatio*limitMeanMaps diffRatio*limitMeanMaps]);
    else
        caxis([-diffRatio*limitMeanMaps(2) diffRatio*limitMeanMaps(2)]);
    end
end

xticklabels('')
yticklabels('')
xlabel('')
ylabel('')
box off

end

