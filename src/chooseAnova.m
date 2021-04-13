function [ANOVA,anova]=chooseAnova(maps1d,sujets,nEffects,nRm,indicesEffects,eNames)


if nEffects==1
    if max(indicesEffects>2)
        indicesAnovaEffects{1}=1;
        if nRm==0
            ANOVA=spm1d.stats.nonparam.anova1(maps1d,indicesEffects(:,1));
            anova.type='ANOVA1';
            disp('ANOVA1')
        elseif nRm==1
            ANOVA=spm1d.stats.nonparam.anova1rm(maps1d,indicesEffects(:,1),sujets);
            disp('ANOVA1rm')
            anova.type='ANOVA1rm';
        end
    else
        ANOVA=[];
        disp('no ANOVA required')
        anova.type='no ANOVA';
        indicesAnovaEffects{1}=1;
    end
end

if nEffects==2
    indicesAnovaEffects{1}=1;
    indicesAnovaEffects{2}=2;
    indicesAnovaEffects{3}=[1 2];
    
    if nRm==0
        ANOVA=spm1d.stats.nonparam.anova2(maps1d,indicesEffects(:,1),indicesEffects(:,2));
        disp('ANOVA2')
        anova.type='ANOVA2';
    elseif nRm==1
        ANOVA=spm1d.stats.nonparam.anova2onerm(maps1d,indicesEffects(:,1),indicesEffects(:,2),sujets);
        disp('ANOVA2 1rm')
        anova.type='ANOVA2 1rm';
    elseif nRm==2
        ANOVA=spm1d.stats.nonparam.anova2rm(maps1d,indicesEffects(:,1),indicesEffects(:,2),sujets);
        disp('ANOVA2rm')
        anova.type='ANOVA2rm';
    end
    
    
elseif nEffects==3
    indicesAnovaEffects{1}=1;
    indicesAnovaEffects{2}=2;
    indicesAnovaEffects{3}=3;
    indicesAnovaEffects{4}=[1 2];
    indicesAnovaEffects{5}=[1 3];
    indicesAnovaEffects{6}=[2 3];
    indicesAnovaEffects{7}=[1 2 3];
    
    if nRm==0
        ANOVA=spm1d.stats.nonparam.anova3(maps1d,indicesEffects(:,1),indicesEffects(:,2),indicesEffects(:,3));
        disp('ANOVA3')
        anova.type='ANOVA3';
    elseif nRm==1
        ANOVA=spm1d.stats.nonparam.anova3onerm(maps1d,indicesEffects(:,1),indicesEffects(:,2),indicesEffects(:,3),sujets);
        disp('ANOVA3 1rm')
        anova.type='ANOVA3 1rm';
    elseif nRm==2
        ANOVA=spm1d.stats.nonparam.anova3tworm(maps1d,indicesEffects(:,1),indicesEffects(:,2),indicesEffects(:,3),sujets);
        disp('ANOVA3 2rm')
        anova.type='ANOVA3 2rm';
    elseif nRm==3
        ANOVA=spm1d.stats.nonparam.anova3rm(maps1d,indicesEffects(:,1),indicesEffects(:,2),indicesEffects(:,3),sujets);
        disp('ANOVA3rm')
        anova.type='ANOVA3rm';
    end
end

if nEffects==1
    anova.effectNames=eNames{indicesAnovaEffects{1}};
else
    for k=1:size(indicesAnovaEffects,2)
        if size(indicesAnovaEffects{k},2)==1
            anova.effectNames{k}=[eNames{indicesAnovaEffects{k}(1)}];
        elseif size(indicesAnovaEffects{k},2)==2
            anova.effectNames{k}=[eNames{indicesAnovaEffects{k}(1)} ' x ' eNames{indicesAnovaEffects{k}(2)}];
        elseif size(indicesAnovaEffects{k},2)==3
            anova.effectNames{k}=[eNames{indicesAnovaEffects{k}(1)} ' x ' eNames{indicesAnovaEffects{k}(2)} ' x ' eNames{indicesAnovaEffects{k}(3)}];
        end
    end
end

end