function hline(y,varargin)

p = inputParser;
addParameter(p,'displayLegend',0,@isnumeric); % if 0, not displayed in legend
addParameter(p,'linetype',':k',@ischar);
addParameter(p,'label','',@ischar);
addParameter(p,'xLimits',[],@isnumeric);
parse(p,varargin{:});
displayLegend=p.Results.displayLegend;
linetype=p.Results.linetype;
label=p.Results.label;
xLimits=p.Results.xLimits;

hold on
if isempty(xLimits)
    x=get(gca,'xlim');
else
    x=xLimits;
end
x=repmat(x,numel(y),1);
for i=1:numel(y)
    h=plot([x(i,1) x(i,2)],[y(i) y(i)],linetype);
    if displayLegend==0
        set(h,'tag','hline','handlevisibility','off')
    end
end
end
