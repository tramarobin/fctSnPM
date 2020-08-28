function createSavedir(savedir)

warning('off', 'MATLAB:MKDIR:DirectoryExists');

mkdir([savedir '\DIFF'])
mkdir([savedir '\ES'])
mkdir([savedir '\SPM'])
mkdir([savedir '\FIG'])
mkdir([savedir '\FIG\DIFF'])
mkdir([savedir '\FIG\ES'])
mkdir([savedir '\FIG\SPM'])

end