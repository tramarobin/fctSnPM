function savedir=chooseSavedir(savedir)

% target a save directory
if isempty(savedir)
    savedir=uigetdir('','Choose or create the directory to save the outputs');
    
    files=dir(savedir);
    a="No";
    
    while a=="No" && numel(files)>2
        
        if numel(files)>2
            a=questdlg('Choosen directory is not empty, do you want to overwrite existing files ?','erase files?','Yes','No','No');
            
            if a=="No"
                savedir=uigetdir(savedir,'Choosen directory is not empty, please erase files or choose/create an empty directory');
            end
            
            files=dir(savedir);
            
        end
    end
    
end