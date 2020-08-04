function nAnova=whichAnova(mainEffect)


if mainEffect(1)==1 & mainEffect(2)==2
    nAnova=4;
elseif mainEffect(1)==1 & mainEffect(2)==3
    nAnova=5;
elseif mainEffect(1)==2 & mainEffect(2)==3
    nAnova=6;
end



end