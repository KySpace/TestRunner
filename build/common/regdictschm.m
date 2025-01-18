function regdictschm(p, io, ~)
arguments 
    p       struct
    io      IOManager
    ~
end
    conv = mkconvrules(loadyaml(p.ConvRules));
    schm = loaddictschm(p.Scheme);
    [schminfo, multidicts] = mkmultidicts(conv, schm, p.MaxRun, p.Ordering);  
    io.devices.dict_src_filename  = p.Scheme;
    io.devices.dict_conv_filename = p.ConvRules;
    io.multidicts = multidicts;
    io.schemeinfo = schminfo;
end