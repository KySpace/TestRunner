function alldict = testmkallschm(dictschm_name, dictschm_convrules_name)
    arguments
        dictschm_name           = "Tests/dictschm.yaml"
        dictschm_convrules_name = "Tests/dictschm.convrule.yaml"
    end
    conv = mkconvrules(loadyaml(dictschm_convrules_name));
    schm = loaddictschm(dictschm_name);
    [schminfo, accessor_raw] = fromschm(conv, schm);
    alldict = cell(size(schminfo.sz_vary));
    for idx = 1 : schminfo.n_variation
        alldict{idx} = accessor_raw(idx);
    end
end