function [schminfo, idxlist] = loadschminfo(testpath, schminfoname, idxlistname, schminfovarname, idxlistvarname, verification)
arguments
    testpath
    schminfoname                = "NaN.SchemeInfo.mat"
    idxlistname                 = "NaN.IdxList.mat"
    schminfovarname             = "saveddata"
    idxlistvarname              = "saveddata"
    verification.fn_vary        = []
end
    load(testpath + "\" + schminfoname, schminfovarname);
    schminfo = eval(schminfovarname);
    if ~isin(verification.fn_vary, stringcelltoarray(schminfo.fn_vary)')
        error("Wrong data directory. Data loaded but variable names not expected")
    end
    load(testpath + "\" + idxlistname, idxlistvarname);
    idxlist = eval(idxlistvarname);
end