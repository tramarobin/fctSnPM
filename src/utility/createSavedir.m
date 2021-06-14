function createSavedir(savedir)

warning('off', 'MATLAB:MKDIR:DirectoryExists');

mkdir([savedir '/DIFF'])
mkdir([savedir '/ES'])
mkdir([savedir '/SnPM'])
mkdir([savedir '/FIG/DIFF'])
mkdir([savedir '/FIG/ES'])
mkdir([savedir '/FIG/SnPM'])

end