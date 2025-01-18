function info = readconfiglocal()
    info = jsondecode(fileread("config_local.json"));
end