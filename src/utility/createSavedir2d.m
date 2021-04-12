function createSavedir2d(savedir)

warning('off', 'MATLAB:MKDIR:DirectoryExists');

mkdir([savedir '/DIFF'])
mkdir([savedir '/ES'])
mkdir([savedir '/SPM'])
mkdir([savedir '/SD'])
mkdir([savedir '/FIG/DIFF'])
mkdir([savedir '/FIG/ES'])
mkdir([savedir '/FIG/SPM'])
mkdir([savedir '/FIG/SD'])
end