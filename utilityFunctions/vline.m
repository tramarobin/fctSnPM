function vline(x,varargin)

p = inputParser;
addParameter(p,'displayLegend',1,@isnumeric); % if 0, not displayed in legend
addParameter(p,'linetype','--k',@ischar);
addParameter(p,'label','',@ischar);
addParameter(p,'vLimits',[],@isnumeric);
parse(p,varargin{:});
displayLegend=p.Results.displayLegend;
linetype=p.Results.linetype;
label=p.Results.label;
vLimits=p.Results.vLimits;

hold on
if isempty(vLimits)
    y=get(gca,'ylim');
else
    y=vLimits;
end
y=repmat(y,numel(x),1);
for i=1:numel(x)
    h=plot([x(i) x(i)],[y(i,1) y(i,2)],linetype);
    if displayLegend==0
        set(h,'tag','vline','handlevisibility','off')
    end
end
end
