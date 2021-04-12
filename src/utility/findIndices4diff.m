function indices4diff=findIndices4diff(n)


loop=0;
for i=1:n
    for j=1:n
        if j>i
            loop=loop+1;
            indices4diff{loop}=[i j];
        end
    end
end


end
