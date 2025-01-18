function [headdict, schminfo, accessor_raw] = testmkschmhead(dictschm_name, dictschm_convrules_name)
    arguments
        dictschm_name           = "Tests/dictschm.yaml"
        dictschm_convrules_name = "Tests/dictschm.convrule.yaml"
    end
    conv = mkconvrules(loadyaml(dictschm_convrules_name));
    schm = loaddictschm(dictschm_name);
    [schminfo, accessor_raw] = fromschm(conv, schm);
    headdict = accessor_raw(1);
end