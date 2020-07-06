function vertShadeSPM(xLimits,varargin)
% xLimits=[start,end]

p = inputParser;
addParameter(p,'label',[],@ischar);
addParameter(p,'linetype','none',@ischar);
addParameter(p,'color',[0.5 0.5 0.5]);
addParameter(p,'vLimits',[],@isnumeric); % end or [start,end]
addParameter(p,'transparency',0.1,@isnumeric);
parse(p,varargin{:});
label=p.Results.label;
linetype=p.Results.linetype;
color=p.Results.color;
vLimits=p.Results.vLimits;
transparency=p.Results.transparency;


hold on
x_points = [xLimits(1), xLimits(1), xLimits(2), xLimits(2)];
if isempty(vLimits)
    y=get(gca,'ylim');
else
    y=vLimits;
    if numel(y)==1
        y=[0 y];
    end
end
y_points = [y(1), y(2), y(2), y(1)];


a = fill(x_points,y_points,color,'lineStyle',linetype);
a.FaceAlpha = transparency;
if isempty(label)
    set(a,'handlevisibility','off')
else
    hLegend = findobj(gcf, 'Type', 'Legend');
    legend([hLegend.String(1:end-1), label])
end

end