function [schminfo, accessor_raw] = fromschm(conv, schm)
    % they should be cell of simple values without need for further parsing
    vary = schm.Varying;
    prty = schm.Priority;
    passive = schm.Passive;

    fn_vary = fieldnames(schm.Varying);
    cand_vary = map_c(@(vn) vary.(vn), fn_vary);
    sz_vary   = cell2mat(map_c(@(vn) numel(vary.(vn)), fn_vary))';
    n_variable    = length(sz_vary);
    n_variation   = truncatecond(prod(sz_vary), 1, Inf);

    schminfo.schm         = schm     ;
    schminfo.fn_vary      = fn_vary  ;
    schminfo.cand_vary    = cand_vary;
    schminfo.sz_vary      = sz_vary  ;
    schminfo.n_variable       = n_variable   ;
    schminfo.n_variation      = n_variation  ;

    function dict = accessor(idx)
        dict_vary = accessvary(schminfo, idx);
        % environment has both fixed and Varying
        % start with the current variation
        dict = dict_vary;      
        % evaluate priority first
        dict_prty = evalconv(conv, 1, dict_vary, prty);
        dict = extractfields(fieldnames(dict_prty), dict_prty, dict);
        % evaluate the passive ones
        dict_pssv = evalconv(conv, 1, dict, passive);
        dict = extractfields(fieldnames(dict_pssv), dict_pssv, dict);   % vary, prty names should already be excluded in follow
    end        
    accessor_raw   = @accessor;
end

