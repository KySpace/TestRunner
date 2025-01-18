% Build a map that directs entry names to corresponding register functions
function map_reg = mkregmap(filenames_reg, is_trial)
arguments
    filenames_reg            
    is_trial
end
    table_reg_names = table();
    for i_tab = 1 : length(filenames_reg)
        table_reg_names_i = readtable(filenames_reg(i_tab));
        table_reg_names = [table_reg_names; table_reg_names_i];
    end
    keys_entry = stringcelltoarray(table_reg_names.key_entry);
    reg_norm = map_c(@(s) eval("@" + s), table_reg_names.register_norm);
    reg_trial = map_c(@(s) eval("@" + s), table_reg_names.register_trial);
    reg_fun = tern(is_trial, reg_trial, reg_norm);
    map_reg = containers.Map(keys_entry, reg_fun);
end