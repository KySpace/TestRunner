function runfiles(file_config, file_configconv, op)
arguments
    file_config         string
    file_configconv     string
    op.mode             {mustBeMember(op.mode, ["debug" "normal" "testat"])}    = "normal"
    op.fromidx          {mustBeInteger}                                    = 1        
    op.toidx            {mustBeInteger}                                    = -1      
    op.filenames_reg    string              = fileparts(which("/buildmanagers.m")) + "/reg_common.csv"
end
    warning on backtrace
    [io, queue] = buildmanagers(loadioconfig(file_config, file_configconv), op.filenames_reg);
    io.devices.config_src_filename  = file_config;
    io.devices.config_conv_filename = file_configconv;
    assignin("base", "io", io);
    assignin("base", "queue", queue);

    switch op.mode
        case "debug";   rundebug (io, queue, op.fromidx, op.toidx);
        case "normal";  runnormal(io, queue, op.fromidx, op.toidx);
        case "testat";  preptest (io, queue, op.fromidx);
    end

    assignin("base", "io", io);
    assignin("base", "queue", queue);
end