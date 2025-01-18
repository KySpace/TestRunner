function s = validifyyamlschm(schm_yaml)
arguments
    schm_yaml       {mustHaveField(schm_yaml, ["Varying" "Passive"])}
end
    if ~isfield(schm_yaml, ["Varying" "Passive"]); error("Invalid yaml scheme, must have Varying and Passive"); end
    rmnull = @(x) tern(isequal(x,yaml.Null), struct(), x);
    varying = rmnull(schm_yaml.Varying);    
    % fields of Varing must be able to be converted to cell array
    % the most upper layer of cell array represents the varying candidates
    fns = fieldnames(varying);
    for idx = 1 : numel(fns)        
        fn = fns{idx}; val = varying.(fn);
        cand = ifthel(isstring(val), @() eval(val), const(val));
        if ~iscell(cand); error("fields in Varying must be cells or can be evaluated to cells"); end
        varying.(fn) = map_c(@(s) tryevalifstring(s, struct()), cand);
    end    
    s.Varying = varying;
    s.Passive = rmnull(schm_yaml.Passive);
    s.Priority = rmnull(lensgetop("Priority", struct(), schm_yaml));
end