%% INPUTS
% Obligatory
% Map of F-values
% Threshold of significativity

%% OUTPUT
% Figure of the anova results

function []=displayTtest_sub(mapT,Tthreshold,Fs,colorMapDiff,ax,equalAxis,deleteAxis,statLimit)

mapT(abs(mapT)==inf)=0;
mapT(isnan(mapT))=0;

imagesc(flipud(mapT))
colormap(ax,colorMapDiff)
if statLimit==0
    caxis([-Tthreshold Tthreshold]);
else
    caxis([-max(max(mapT)) max(max(mapT))])
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


