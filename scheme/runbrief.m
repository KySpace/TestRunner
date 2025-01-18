function str = runbrief(fn_vary, dict, idx, maxrun)
    function ss = labelfolder(fn_vary, s)
        val = dict.(fn_vary);
        s_val = "";
        if isstring(val); s_val = val;
        elseif isnumeric(val); s_val = sprintf("%1.5G", val);
        end
        ss = sprintf("%s | %s = %s", s, fn_vary, s_val);
    end
    init = sprintf("TEST No. %4i / %d", idx, maxrun);
    str = fold_c(@labelfolder, init, fn_vary);
end