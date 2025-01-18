function regpath(entry_path, io, ~)
arguments
    entry_path      struct
    io              IOManager
    ~
end
    if ~exist("config_local.json", "file")
        open(fileparts(which('settestdir')) + "/config_local.sample.json");
        error('Please setup a "config_lib.json" file at root. See the sample');
    end
    if exist(entry_path.TestRoot, "dir")
        test_root_dir = entry_path.TestRoot;
    else
        % legacy reasons, no longer a function call
        val_test_root = erase(entry_path.TestRoot, "()");
        % separated <name>/<key> into an <name> and a <key>
        entry_path_arr = split(val_test_root, '/');
        % by default, the <key> is "normal"
        if numel(entry_path_arr) == 1; entry_path_arr = [entry_path_arr "normal"]; end
        % json file into struct
        info_root = readconfiglocal();
        % info_root.<name>.<key>
        test_root_dir = lensgetdeep(entry_path_arr, info_root);
    end
    io.devices.savepath = settestdir(test_root_dir, entry_path.TestFolder, entry_path.TestName);
end