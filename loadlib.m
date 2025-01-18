fprintf("loading: TestRunner.\n")

if ~contains(path, "MatlabFunctional"); run("[MatlabFunctional]/loadlib"); end

tr_rootpath = fileparts(mfilename("fullpath"));
tr_srcfolders = ["classes", "yaml", "scheme", "main", "managers", "fastnote", "build", ...
              "evaluate", "testpaths", "convert", "anlzhelper", "Trials"];
for i = 1 : numel(tr_srcfolders)
    addpath(genpath(tr_rootpath+"/"+tr_srcfolders(i)));
end

clear tr_rootpath tr_srcfolders