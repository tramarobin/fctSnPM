function createSavedir2d(savedir)

warning('off', 'MATLAB:MKDIR:DirectoryExists');

mkdir([savedir '/DIFF'])
mkdir([savedir '/ES'])
mkdir([savedir '/SnPM'])
mkdir([savedir '/SD'])
mkdir([savedir '/FIG/DIFF'])
mkdir([savedir '/FIG/ES'])
mkdir([savedir '/FIG/SnPM'])
mkdir([savedir '/FIG/SD'])
end