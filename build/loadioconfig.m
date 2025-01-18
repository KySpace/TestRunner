% This function load the ioconfig file and convert string fields that are expected
% to represent functions into actual function handlers
% Other strings remain untouched.
function config_o = loadioconfig(filename, rulesname)
    config_yaml = loadyaml(filename);
    conv = mkconvrules(loadyaml(rulesname));
    config_o = evalconv(conv, 0, struct(), config_yaml);
end