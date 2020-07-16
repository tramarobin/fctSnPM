function [colorPlot,colorShadeSPM]=chooseColor(colorLine,colorSPM,effectN)


if isempty(colorLine)
    colorPlot=[];
elseif iscell(colorLine)
    if numel(colorLine)>=effectN
        colorPlot=colorLine{effectN};
    else
        colorPlot=[];
    end
else
    colorPlot=colorLine;
end


if isempty(colorSPM)
    colorShadeSPM=[];
elseif iscell(colorSPM)
    if numel(colorSPM)>=effectN
        colorShadeSPM=colorSPM{effectN};
    else
        colorShadeSPM=[];
    end
else
    colorShadeSPM=colorSPM;
end

end