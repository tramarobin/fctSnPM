function []=plotmean(Data,IC,xlab,ylab,Fs,xlimits,nx,ny,colorLine,imageFontSize,imageSize,transparancy1D,ylimits)

if isempty(imageSize)
    figure('Units', 'Normalized', 'OuterPosition', [0, 0, 1, 1],'visible','off');
elseif max(size(imageSize))==1
    figure('Units', 'Centimeter', 'OuterPosition', [0, 0, imageSize, imageSize],'visible','off');
else
    figure('Units', 'Centimeter', 'OuterPosition', [0, 0, imageSize(1), imageSize(2)],'visible','off');
end

if ~isempty(IC)
    indices=[0.7 0.75 0.8 0.85 0.90 0.92 0.95 0.96 0.98 0.99 0.995 0.999];
    coeff=[1.04 1.15 1.28 1.44 1.645 1.75 1.96 2.05 2.33 2.58 2.81 3.29];
    coeff=interp1(indices,coeff,0.7:0.001:0.999);
    indices=0.7:0.001:0.999;
    if IC>=0.7
        z=coeff(find(IC==indices));
    elseif IC==0
        z=1;
    else
        error('Chose CI between 0.7 and 0.999, or 0 to display SEM')
    end
end

if ~isempty(colorLine)
    colors=colorLine;
else
    colors=lines(size(Data,2));
end

for i=1:size(Data,2)
    MData{i}=mean(Data{i});
    SDsup{i}=MData{i}+std(Data{i});
    SDinf{i}=MData{i}-std(Data{i});
end
for i=1:size(Data,2)
    time = 0:1/Fs:(size(Data{i},2)-1)/Fs;
    f=1:size(Data{i},2);
    if size(Data{i},1)>1
        noNan=~isnan(SDsup{i});
        if isempty(IC)
            fill([time(noNan),fliplr(time(noNan))], [SDsup{i}(noNan),fliplr(SDinf{i}(noNan))],colors(i,:),'EdgeColor','none','facealpha',transparancy1D,'handlevisibility','off'); hold on
        else
            fill([time(noNan),fliplr(time(noNan))], [MData{i}(noNan)+std(Data{i}(:,noNan))*z/sqrt(size(Data{i},1)),fliplr(MData{i}(noNan)-std(Data{i}(:,noNan))*z/sqrt(size(Data{i},1)))],colors(i,:),'EdgeColor','none','facealpha',transparancy1D,'handlevisibility','off'); hold on
        end
    end
end
for i=1:size(Data,2)
    if min(size(Data{i}))>1
        plot(time(noNan),MData{i}(noNan),'color',colors(i,:),'LineWidth',1.5); hold on
        if isempty(IC)
            plot(time(noNan),SDsup{i}(noNan),'--','color',colors(i,:),'handlevisibility','off')
            plot(time(noNan),SDinf{i}(noNan),'--','color',colors(i,:),'handlevisibility','off')
            title('Means \pm standard deviation')
        else
            plot(time(noNan),MData{i}(noNan)+std(Data{i}(:,noNan))*z/sqrt(size(Data{i},1)),'--','color',colors(i,:),'handlevisibility','off')
            plot(time(noNan),MData{i}(noNan)-std(Data{i}(:,noNan))*z/sqrt(size(Data{i},1)),'--','color',colors(i,:),'handlevisibility','off')
            if IC==0
                title('Means \pm SEM')
            else
                title(['Means \pm IC' num2str(100*IC) '%'])
            end
        end
    elseif ~isempty(Data{i})
        noNan=~isnan(Data{i});
        plot(time(noNan),Data{i}(noNan),'color',colors(i,:),'LineWidth',1.5); hold on
    end
end

box off
xlabel(xlab)
ylabel(ylab)
if ~isempty(xlimits)
    xlabels=linspace(xlimits(1),xlimits(end),nx);
else
    xlabels=linspace(0,(max(size(Data{i})))/Fs,nx);
end

xticks(linspace(0,(size(Data{i},2)-1)/Fs,nx))
for i=1:nx
    if xlabels(i)<0 && xlabels(i)>-1e-16
        xlabs{i}='0';
    elseif abs(xlabels(i))==0 | abs(xlabels(i))>=1 & abs(xlabels(i))<100
        xlabs{i}=sprintf('%0.2g',xlabels(i));
    elseif abs(xlabels(i))>=100
        xlabs{i}=sprintf('%d',round(xlabels(i)));
    else
        xlabs{i}=sprintf('%0.2f',xlabels(i));
    end
end
xticklabels(xlabs)

set(gca,'FontSize',imageFontSize)

if ~isempty(ylimits)
    ylim(ylimits)
end

y=get(gca,'ylim');
if ~isempty(ny) 
yticks(linspace(y(1),y(2),ny))
end


end
