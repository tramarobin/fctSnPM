function vline(x,varargin)

p = inputParser;
addParameter(p,'displayLegend',0,@isnumeric); % if 0, not displayed in legend
addParameter(p,'linetype','--k',@ischar);
addParameter(p,'label','',@ischar);
addParameter(p,'vLimits',[],@isnumeric);
addParameter(p,'lineWidth',1,@isnumeric);
addParameter(p,'color',[]);
parse(p,varargin{:});
displayLegend=p.Results.displayLegend;
linetype=p.Results.linetype;
label=p.Results.label;
color=p.Results.color;
vLimits=p.Results.vLimits;
lineWidth=p.Results.lineWidth;

hold on
if isempty(vLimits)
    y=get(gca,'ylim');
else
    y=vLimits;
end
y=repmat(y,numel(x),1);
for i=1:numel(x)

    h=plot([x(i) x(i)],[y(i,1) y(i,2)],linetype,'LineWidth',lineWidth);

    if ~isempty(color)
        h.Color=color;
    end

    if displayLegend==0
        set(h,'tag','vline','handlevisibility','off')
    end

end
end
