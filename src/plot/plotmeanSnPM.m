function []=plotmeanSnPM(Data,tTest1,tTest2,legendPlot,diffNames,IC,xlab,ylab,Fs,xlimits,nx,ny,clPlot,imageFontSize,imageSize,transparancy1D,ylimits,anovaEffects,eNames,ratioSnPM,SnPMPos,aovColor,xLine,yLine,xGrid,yGrid)

if isempty(imageSize)
    figure('Units', 'Pixels', 'OuterPosition', [0, 0, 720, 480],'visible','off');
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
    elseif IC<0
        z=0;
    else
        error('Chose CI between 0.7 and 0.999, 0 to display SEM, or negative to not display the SD')
    end
end

if ~isempty(clPlot)
    colorLine=clPlot.color;
    lineStyle=clPlot.line;

    if ~isempty(colorLine)
        colors=colorLine;
    else
        colors=lines(size(Data,2));
    end

    if size(Data,2)~=size(lineStyle,2)
        clear lineStyle
        for i=1:size(Data,2)
            lineStyle{1,i}='-';
            lineStyle{2,i}='--';
        end
    end

else

    colors=lines(size(Data,2));
    for i=1:size(Data,2)
        lineStyle{1,i}='-';
        lineStyle{2,i}='--';
    end
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
        elseif IC>=0
            fill([time(noNan),fliplr(time(noNan))], [MData{i}(noNan)+std(Data{i}(:,noNan))*z/sqrt(size(Data{i},1)),fliplr(MData{i}(noNan)-std(Data{i}(:,noNan))*z/sqrt(size(Data{i},1)))],colors(i,:),'EdgeColor','none','facealpha',transparancy1D,'handlevisibility','off'); hold on
        end
    end
end
for i=1:size(Data,2)
    if min(size(Data{i}))>1
        plot(time(noNan),MData{i}(noNan),'color',colors(i,:),'linestyle',lineStyle{1,i},'LineWidth',1.5); hold on
        if isempty(IC)
            plot(time(noNan),SDsup{i}(noNan),'linestyle',lineStyle{2,i},'color',colors(i,:),'handlevisibility','off')
            plot(time(noNan),SDinf{i}(noNan),'linestyle',lineStyle{2,i},'color',colors(i,:),'handlevisibility','off')
        elseif IC>=0
            plot(time(noNan),MData{i}(noNan)+std(Data{i}(:,noNan))*z/sqrt(size(Data{i},1)),'linestyle',lineStyle{2,i},'color',colors(i,:),'handlevisibility','off')
            plot(time(noNan),MData{i}(noNan)-std(Data{i}(:,noNan))*z/sqrt(size(Data{i},1)),'linestyle',lineStyle{2,i},'color',colors(i,:),'handlevisibility','off')
        end
    elseif ~isempty(Data{i})
        noNan=~isnan(Data{i});
        plot(time(noNan),Data{i}(noNan),'color',colors(i,:),'linestyle',lineStyle{1,i},'LineWidth',1.5); hold on
    end
end

box off
ylabel(ylab);
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
xl = xlim;
xlabel(xlab)
if isempty(IC)
    title('Means \pm standard deviation')
else
    if IC==0
        title('Means \pm SEM')
    elseif IC>0
        title(['Means \pm IC' num2str(100*IC) '%'])
    end
end

if xGrid~=0
    set(gca,'XGrid','on')
end
if yGrid~=0
    set(gca,'YGrid','on')
end

if ~isempty(xLine)
    for i=1:numel(xLine)
        hline(xLine{i}{1},'linetype',xLine{i}{2},'lineWidth',xLine{i}{3})
    end
end

if ~isempty(yLine)
    for i=1:numel(yLine)
        vline(yLine{i}{1},'linetype',yLine{i}{2},'lineWidth',yLine{i}{3})
    end
end

if ~isempty(ylimits)
    ylim(ylimits)
end
y=get(gca,'ylim');

if ~isempty(ny)
    yticks(linspace(y(1),y(2),ny))
end

set(gca,'FontSize',imageFontSize)
legend(legendPlot,'Location','eastoutside','box','off')

%% add SnPM
valTtest=tTest1;
tTest=tTest2;

% anova
for c=1:numel(anovaEffects)
    isSignificantAnova(c)=sum(anovaEffects{c})>=2;
end
for c=1:numel(tTest)
    isSignificant(c)=sum(tTest{c})>=2;
end

if ~isempty(anovaEffects)
    totalSignificantAnova=sum(isSignificantAnova);
    whichSignificantAnova=find(isSignificantAnova);
else
    totalSignificantAnova=0;
    whichSignificantAnova=[];
end

totalSignificant=sum(isSignificant);
whichSignificant=find(isSignificant);
allSignificant=totalSignificant+totalSignificantAnova;

loop=allSignificant;
rangeFig=diff(y);
for c=1:allSignificant
    if ~isempty(SnPMPos)
        startShade=y(2)+0.95*loop*0.05*rangeFig;
        endShade=y(2)+0.95*loop*0.05*rangeFig+0.04*rangeFig;
    else
        startShade=y(1)-0.95*loop*0.05*rangeFig;
        endShade=y(1)-0.95*loop*0.05*rangeFig-0.04*rangeFig;
    end
    ylimitsSnPM(c,:)=[startShade endShade];
    loop=loop-1;
end
if ~isempty(SnPMPos) & allSignificant>0
    ylimitsSnPM=flipud(ylimitsSnPM);
end
if allSignificant>0
    yMean=mean(ylimitsSnPM,2);
end

if allSignificant>0

    loop=allSignificant+1;
    for c=whichSignificantAnova
        loop=loop-1;
        yTlab{loop}=eNames{c};
        clusters=find(abs(diff(anovaEffects{c}))==1)';
        clusters=transposeColmunIfNot(clusters);
        clusters=[0;clusters;max(size(anovaEffects{c}))];
        for t=1:size(clusters,1)-1
            timeCluster=time(clusters(t)+1:clusters(t+1));
            mapCluster=anovaEffects{c}(clusters(t)+1:clusters(t+1));
            goPlot=mean(anovaEffects{c}(clusters(t)+1:clusters(t+1)));
            if goPlot==1
                vertShadeSnPM([timeCluster(1),timeCluster(end)],...
                    'color',aovColor,'vLimits',[ylimitsSnPM(loop,1) ylimitsSnPM(loop,2)],'transparency',1);
            end
        end
    end

    indices4diff=findIndices4diff(size(Data,2));
    for c=whichSignificant
        loop=loop-1;
        if min(size(diffNames))>1
            yTlab{loop}=[diffNames{1,c} ' \neq ' diffNames{2,c}];
        else
            firstParPos=strfind(diffNames{c},'(');
            if ~isempty(firstParPos)
                minusPos=strfind(diffNames{c},'-');
                secondParPos=strfind(diffNames{c},')');
                firstLetters=diffNames{c}(1:firstParPos-2);
                firstGp=diffNames{c}(firstParPos+1:minusPos-2);
                secondGp=diffNames{c}(minusPos+2:secondParPos-1);
                diffName=[firstGp ' \neq ' secondGp];
            else
                diffName=[diffNames{1} ' \neq ' diffNames{2}];
            end
            yTlab{loop}=diffName;
        end

        clusters=find(abs(diff(tTest{c}'))==1)';
        clusters=transposeColmunIfNot(clusters);
        clusters=[0;clusters;max(size(tTest{c}))];
        for t=1:size(clusters,1)-1
            timeCluster=time(clusters(t)+1:clusters(t+1));
            mapCluster=tTest{c}(clusters(t)+1:clusters(t+1));
            goPlot=mean(tTest{c}(clusters(t)+1:clusters(t+1)));
            if goPlot==1
                if mean(valTtest{c}(clusters(t)+1:clusters(t+1)))>0
                    vertShadeSnPM([timeCluster(1),timeCluster(end)],...
                        'color',colors(indices4diff{c}(1),:),'vLimits',[yMean(loop) yMean(loop)+0.02*rangeFig],'transparency',1);
                    vertShadeSnPM([timeCluster(1),timeCluster(end)],...
                        'color',colors(indices4diff{c}(2),:),'vLimits',[yMean(loop) yMean(loop)-0.02*rangeFig],'transparency',1);
                else
                    vertShadeSnPM([timeCluster(1),timeCluster(end)],...
                        'color',colors(indices4diff{c}(2),:),'vLimits',[yMean(loop) yMean(loop)+0.02*rangeFig],'transparency',1);
                    vertShadeSnPM([timeCluster(1),timeCluster(end)],...
                        'color',colors(indices4diff{c}(1),:),'vLimits',[yMean(loop) yMean(loop)-0.02*rangeFig],'transparency',1);

                end
            end
        end
    end


    xticks(linspace(0,(size(Data{1},2)-1)/Fs,nx))
    xticklabels(xlabs)
    set(gca,'FontSize',imageFontSize)

    if allSignificant>0
        yText=sort(mean(ylimitsSnPM,2));
        for i=1:numel(yTlab)
            text(time(end),yText(i),[' ' yTlab{i}],'FontSize',imageFontSize);
        end
    end

    y=get(gca,'ylim');
    if ~isempty(allSignificant)
        if ~isempty(SnPMPos)
            ylim([y(1) max(max(ylimitsSnPM))+0.05*rangeFig]);
        else
            ylim([min(min(ylimitsSnPM))-0.05*rangeFig y(2)]);
        end
    end

    set(gca,'FontSize',imageFontSize)
end
end
