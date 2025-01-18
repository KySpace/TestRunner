% schminfo should be saved, but multidicts should be used, not saved
% because it contains such convoluted function handles
% use maxrun = -1 to indicate run each case once
function [schminfo, multidicts] = mkmultidicts(conv, schm, maxrun_in, ordering)
arguments
    conv            
    schm            {mustHaveField(schm, ["Varying" "Passive" "Priority"])}
    maxrun_in       
    ordering        {mustBeMember(ordering, ["ordered", "random"])}
end
    % index plan, deciding on each run which parameter to choose
    % randomize this will help removing experiment biases.    
    [schminfo, accessor_raw] = fromschm(conv, schm);
    n_vary = schminfo.n_variation;
    if isnumeric(maxrun_in) 
        maxrun = maxrun_in; 
    else 
        tokens = regexp(maxrun_in, "^x(?<repeats>\d+)$", "names");
        maxrun = str2double(tokens.repeats) * n_vary;
    end
    switch ordering
    case "random"
        idxlist = ifthel(n_vary >= maxrun, ...
                        @() randperm(n_vary, maxrun)', ...
                        @() mod(randperm(maxrun, maxrun), n_vary)' + 1);
    case "ordered"
        idxlist = mod((1 : maxrun)', maxrun);
    end
    multidicts.maxrun = maxrun;
    multidicts.accessor_raw = accessor_raw;
    multidicts.idxlist = idxlist;
    multidicts.get = @(i) accessor_raw(multidicts.idxlist(i));
end