function [anovaEffects]=findInterractionEffects(ANOVA_inf)


if size(ANOVA_inf.SnPMs ,2)==3 % anova2
    
    anovaEffects{3}=ANOVA_inf.SnPMs{3}.z>=ANOVA_inf.SnPMs{3}.zstar;
    for mainEffects=1:2
        effect=ANOVA_inf.SnPMs{mainEffects}.z>=ANOVA_inf.SnPMs{mainEffects}.zstar;
        anovaEffects{mainEffects}=mean([effect;~anovaEffects{3}])==1;
    end
    
    
else %anova3
    
    anovaEffects{7}=ANOVA_inf.SnPMs{7}.z>=ANOVA_inf.SnPMs{7}.zstar;
    for interactionEffects=4:6
        effect=ANOVA_inf.SnPMs{interactionEffects}.z>=ANOVA_inf.SnPMs{interactionEffects}.zstar;
        anovaEffects{interactionEffects}=mean([effect;~anovaEffects{7}])==1;
    end
%     figure('visible','on')
% plot(anovaEffects{1, 4}); hold on
% plot(effect)

    interactionMains=[4 5;4 6;5 6];
    for mainEffects=1:3
        effect=ANOVA_inf.SnPMs{mainEffects}.z>=ANOVA_inf.SnPMs{mainEffects}.zstar;
        noInteraction=mean([anovaEffects{interactionMains(mainEffects,1)};anovaEffects{interactionMains(mainEffects,2)};anovaEffects{7}])==0;
        anovaEffects{mainEffects}=mean([effect;noInteraction])==1;
    end
    
end

end