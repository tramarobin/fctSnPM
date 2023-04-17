function dataGroup=groupBysub(data,sub)


if numel(sub)>max(sub)
loop=1;
for s=1:max(sub)
    if max(s==sub)
        dataGroup(loop,:)=nanmean(data(s==sub,:));
        loop=loop+1;
    end
end

else
    dataGroup=data;
end

end