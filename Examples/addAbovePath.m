% addp previous path to lauch examples (fctSPM)
function addAbovePath

mydir  = pwd;
idcs   = strfind(mydir,'\');
if isempty(idcs)
    idcs   = strfind(mydir,'/');
end
newdir = mydir(1:idcs(end)-1);

addpath(genpath(newdir));

end