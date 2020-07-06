function [nPlot,whichPlot,whichFixed,whichModal]=findNPlot(combi)

for n=1:size(combi,2)
    for m=1:size(combi{1},2)
        variable(n,m)=combi{n}(m);
    end
end
for m=1:size(combi{1},2)
    mod(m)=max(variable(:,m));
end


loop=1;

if size(combi{1},2)==2
    for i=1:max(mod)
        
        a=find(i==variable(:,1));
        b=find(i==variable(:,2));
        
        if ~isempty(a)
            whichPlot{loop}=find(i==variable(:,1));
            whichFixed(1,loop)=1;
            whichFixed(2,loop)=2;
            whichModal(loop)=i;
            loop=loop+1;
        end
        
        if ~isempty(b)
            whichPlot{loop}=find(i==variable(:,2));
            whichFixed(1,loop)=2;
            whichFixed(2,loop)=1;
            whichModal(loop)=i;
            loop=loop+1;
        end
        
    end
    
else
    
    corrFixed=[2 3; 1 3; 1 2];
    for mainEffect=1:3
        for fixedOne=1:mod(corrFixed(mainEffect,1))
            for fixedTwo=1:mod(corrFixed(mainEffect,2))
                
                whichPlot{loop}=find(fixedOne==variable(:,corrFixed(mainEffect,1)) &  fixedTwo==variable(:,corrFixed(mainEffect,2)));
                whichFixed(1,loop)=mainEffect;
                whichFixed(2,loop)=corrFixed(mainEffect,1);
                whichFixed(3,loop)=corrFixed(mainEffect,2);
                whichModal(1,loop)=fixedOne;
                whichModal(2,loop)=fixedTwo;
                loop=loop+1;
                
            end
        end
    end
    
    
end
    nPlot=size(whichPlot,2);
end
