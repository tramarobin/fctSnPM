function clPlot=chooseCL(colorLine,lineStyle,effectN)

%% Color
if isempty(colorLine)
    clPlot.color=[];
elseif iscell(colorLine)
    if numel(colorLine)>=effectN
        clPlot.color=colorLine{effectN};
    else
        clPlot.color=[];
    end
else
    clPlot.color=colorLine;
end

%% Linestyle
if iscell(lineStyle)
    if numel(lineStyle)>=effectN
        clPlot.line=lineStyle{effectN};
    else
        clPlot.line=lineStyle;
        if iscell(lineStyle{1})
           clPlot.line=[];
        end
    end
else
    clPlot.line=lineStyle;
end


end