function [colorPlot]=chooseColor(colorLine,effectN)


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


end