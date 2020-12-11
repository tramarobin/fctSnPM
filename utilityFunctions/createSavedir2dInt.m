function createSavedir2dInt(savedir)

warning('off', 'MATLAB:MKDIR:DirectoryExists');

mkdir([savedir '\DIFF'])
mkdir([savedir '\ES'])
mkdir([savedir '\SPM'])
end