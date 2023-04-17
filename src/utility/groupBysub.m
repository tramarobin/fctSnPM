function dataGroup=groupBysub(data,sub)


if numel(sub)>max(sub)

    for s=1:max(sub)
        dataGroup(s,:)=nanmean(data(s==sub,:));
    end

else
    dataGroup=data;
end

end