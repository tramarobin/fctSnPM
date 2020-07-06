function [eFixed,eTested,modalFixed,modalTested]=findWhichTitle(combi)
eFixed=find(combi(1,:)==combi(2,:));
eTested=find(combi(1,:)~=combi(2,:));
modalFixed=combi(1,eFixed);
modalTested=combi(:,eTested);
end
