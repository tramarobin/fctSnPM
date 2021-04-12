function saveNameVerifed=verifSaveName(saveName)

nTC={'/' '\' ':' '.' '<' '>' '?' '*' '|' '"' }; % non tolerated characters

for i=1:numel(nTC)
    saveName=strrep(saveName,nTC{i},'');
end

saveNameVerifed=saveName;


end