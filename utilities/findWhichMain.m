function [indiceMain]=findWhichMain(modalities,n1,n2)


nModalities=numel(modalities);

loop=0;
for i=1:nModalities-1
    for j=2:nModalities
        if j>i
            loop=loop+1;
            comp(loop,1)=i;
            comp(loop,2)=j;
        end
    end
end

indiceMain=find(n1==comp(:,1) & n2==comp(:,2));







end

