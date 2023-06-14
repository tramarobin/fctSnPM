function dataGroup=groupBysub(data,sub)

uniqueSub=unique(sub);

if numel(uniqueSub)<numel(sub)
loop=1;
for s=1:numel(uniqueSub)
    if any(uniqueSub(s)==sub)
        dataGroup(loop,:)=nanmean(data(uniqueSub(s)==sub,:));
        loop=loop+1;
    end
end

else
    dataGroup=data;
end

end