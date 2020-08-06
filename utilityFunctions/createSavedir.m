function createSavedir(savedir)

warning('off', 'MATLAB:MKDIR:DirectoryExists');

mkdir([savedir '\DIFF'])
mkdir([savedir '\ES'])
mkdir([savedir '\SPM'])
mkdir([savedir '\FIG'])

end