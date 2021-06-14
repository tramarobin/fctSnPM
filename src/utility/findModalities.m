function [maps_1D,dimensions,sujets,nRm,nEffects,typeEffectsAll,modalitiesAll,indicesEffects]=findModalities(mapsAll,effectsRm,effectsInd)

maps_1D=[];
sujets=[];
E_rm=cell(1,size(effectsRm,2));
E_ind=cell(1,size(effectsInd,2));
dimensions=size(mapsAll{1,1});

for s=1:size(mapsAll,1)
    for cond=1:size(mapsAll,2)
        
        % Vectorisation of maps
        maps_1D(end+1,:)= mapsAll{s,cond}(:);
        sujets(end+1,1)=s;
        
        % Modalities of each effect
        
        if ~isempty(effectsRm)
            for nRm=1:size(effectsRm,2)
                modalitiesRm{nRm}=unique(effectsRm{nRm},'stable');
                E_rm{nRm}{end+1,1}=effectsRm{nRm}{cond};
            end
        else
            nRm=0;
            modalitiesRm={};
        end
        
        if ~isempty(effectsInd)
            for nInd=1:size(effectsInd,2)
                modalitiesInd{nInd}=unique(effectsInd{nInd},'stable');
                E_ind{nInd}{end+1,1}=effectsInd{nInd}{s};
            end
        else
            nInd=0;
            modalitiesInd={};
        end
    end
end

% numerisation of effects for SnPM
effectsModalities=[E_ind,E_rm];
typeEffectsAll=[zeros(1,nInd),ones(1,nRm)];
modalitiesAll=[modalitiesInd,modalitiesRm];
indicesEffects=zeros(size(sujets,1),size(effectsModalities,2));
nEffects=nInd+nRm;


for nEffects=1:size(modalitiesAll,2)
    for modal=1:numel(modalitiesAll{nEffects})
        indice=strcmp(effectsModalities{nEffects},modalitiesAll{nEffects}{modal});
        indicesEffects(indice,nEffects)=modal;
    end
end


end