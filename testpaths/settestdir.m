function testpath = settestdir(rootdir, testfolder, testname)
arguments
    rootdir         string
    testfolder      string
    testname        string
end
    dirpath = rootdir + "\" + testfolder;
    % Will not allow creating a new path if the root folder does not exist
    if ~exist(rootdir, "dir")
        disp(rootdir);
        error("root directory does not exist");
    % Create a new path if the parent testfolder does not exist
    elseif ~exist(dirpath, 'dir')
        mkdir(dirpath);
        disp("Created a new folder: ");
        disp(dirpath);
    end
    testpath = dirpath + "\" + testname;
    if exist(testpath, "dir")
        warning("Directory already exists. Continue?"); 
        pause;
    end
    warning('off', 'MATLAB:MKDIR:DirectoryExists');    
    mkdir(testpath);
end