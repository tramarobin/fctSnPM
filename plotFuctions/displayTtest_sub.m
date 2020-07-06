%% INPUTS
% Obligatory
% Map of F-values
% Threshold of significativity

%% OUTPUT
% Figure of the anova results

function []=displayTtest_sub(mapT,Tthreshold,Fs)
    
    colors = [rgb('blue');rgb('lightblue');rgb('white');rgb('white');rgb('darkorange');rgb('red')];
    
    imagesc(flipud(mapT))
    colormap(colors)
    caxis([-3*Tthreshold 3*Tthreshold]);
    xticklabels('')
    yticklabels('')
    xlabel('')
    ylabel('')
    box off
    
end


