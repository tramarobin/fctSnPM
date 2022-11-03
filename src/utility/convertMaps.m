function [mapsALL, effectsRM]= convertMaps(mapsAll, effectsRm)

%% Effect RM
for i=1:numel(effectsRm{1})
    for j=1:numel(effectsRm{2})
        effectsRM{1}{numel(effectsRm{2})*(i-1)+j}=effectsRm{1}{i};
    end
end
effectsRM{2}=[repmat(effectsRm{2},1,numel(effectsRm{1}))];


%% Maps
for s=1:size(mapsAll,1)
    for i=1:size(mapsAll,2)
        for j=1:size(mapsAll,3)
            mapsALL{s,size(mapsAll,3)*(i-1)+j}=mapsAll{s,i,j};
        end
    end
end


end