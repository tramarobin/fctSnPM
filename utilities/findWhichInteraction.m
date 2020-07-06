function [indiceInteraction]=findWhichInteraction(modalities,combi,interaction,testedEffect)


fixed=find(combi{1}==combi{2});
fixed=fixed(interaction);
for i=1:2
    comp(i,:)=combi{i}([sort([fixed,testedEffect])]);
end

for i=1:size(modalities,2)
    isIndice(i)=mean(mean(comp==modalities{i}));
end

indiceInteraction=find(isIndice==1);

end

