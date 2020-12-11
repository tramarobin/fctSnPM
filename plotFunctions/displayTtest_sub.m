%% INPUTS
% Obligatory
% Map of F-values
% Threshold of significativity

%% OUTPUT
% Figure of the anova results

function []=displayTtest_sub(mapT,Tthreshold,Fs,colorMapDiff,ax)


imagesc(flipud(mapT))
colormap(ax,colorMapDiff)
caxis([-Tthreshold Tthreshold]);
xticklabels('')
yticklabels('')
xlabel('')
ylabel('')
box off

end


