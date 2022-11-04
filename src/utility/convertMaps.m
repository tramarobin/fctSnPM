function [mapsALL, effectsRM]= convertMaps(mapsAll, effectsRm)

if numel(size(mapsAll))==3% 2 repeated measure effects

    %% Effect RM
    for i=1:numel(effectsRm{1})
        for j=1:numel(effectsRm{2})
            effectsRM{1}{numel(effectsRm{2})*(i-1)+j}=effectsRm{1}{i};
        end
    end
    effectsRM{2}=[repmat(effectsRm{2},1,numel(effectsRm{1}))];


    %% Maps
    loop=1;
    for i=1:size(mapsAll,2)
        for j=1:size(mapsAll,3)
            for s=1:size(mapsAll,1)
                mapsALL{s,loop}=mapsAll{s,i,j};
            end
            loop=loop+1;
        end
    end

elseif numel(size(mapsAll))==4 % 3 repeated measure effects


    %% Effect RM
    n4e1=numel(effectsRm{2})*numel(effectsRm{3});
    for i=1:numel(effectsRm{1})
        for j=1:n4e1
            effectsRM{1}{j+(i-1)*n4e1}=effectsRm{1}{i};
        end
    end

    for i=1:numel(effectsRm{2})
        for j=1:numel(effectsRm{3})
            effectsRM{2}{numel(effectsRm{3})*(i-1)+j}=effectsRm{2}{i};
        end
    end

    effectsRM{2}=[repmat(effectsRM{2},1,numel(effectsRm{1}))];
    effectsRM{3}=[repmat(effectsRm{3},1,numel(effectsRm{1})*numel(effectsRm{2}))];


    %% Maps
    loop=1;
    for i=1:size(mapsAll,2)
        for j=1:size(mapsAll,3)
            for k=1:size(mapsAll,4)
                for s=1:size(mapsAll,1)
                    mapsALL{s,loop}=mapsAll{s,i,j,k};
                end
                loop=loop+1;
            end
        end
    end
end



end