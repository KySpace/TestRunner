function [dict, sub_v, sub_v_struct] = accessvary(schminfo, idx)
    idx = mod(idx - 1, schminfo.n_variation) + 1;
    sub_v = cell([1 schminfo.n_variable]);
    [sub_v{:}] = ind2sub(schminfo.sz_vary, idx);
    % select value from vary
    dict = struct();
    for i_v = 1 : schminfo.n_variable
        dict.(schminfo.fn_vary{i_v}) = schminfo.cand_vary{i_v}{sub_v{i_v}};
        sub_v_struct.(schminfo.fn_vary{i_v}) = sub_v{i_v};
    end
    sub_v = cell2mat(sub_v);
end