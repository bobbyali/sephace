% --- Get the complete path to the input item     
function strFullPath = get_full_path(DataID,blnReturnDir)
    
    sql_IsDir = ['select data.Name, data.IsDir, data.ParentDirID, ' ...
                 'experiments.Directory from experiments inner join ' ...
                 'data on experiments.ExptID = data.ExptID ' ...
                 'where DataID = ' num2str(DataID)];             
    rsIsDir   = mksqlite(sql_IsDir);
    blnIsDir  = rsIsDir(1).IsDir;    
    parentDirID = rsIsDir(1).ParentDirID;
    strPathRoot = findreplace(rsIsDir(1).Directory,'\\','\');
    blnFullDir = 0;
    
    if blnIsDir == 1
        strFullPath = ['\' rsIsDir(1).Name '\'];
    elseif blnReturnDir == 0
        strFullPath = ['\' rsIsDir(1).Name];
    else
        strFullPath = '\';
    end
    
    while parentDirID > 0
        sql_GetParentDir = ['select Name, ParentDirID from data where ' ...
                            'DataID = ' num2str(parentDirID) ' and IsDir = 1'];
        rsGetParentDir   = mksqlite(sql_GetParentDir);
        strFullPath      = ['\' rsGetParentDir(1).Name strFullPath];
        parentDirID      = rsGetParentDir(1).ParentDirID;
        clear rsGetParentDir        
    end
    
    strFullPath = [strPathRoot strFullPath];
    clear rsIsDir