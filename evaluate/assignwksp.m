function assignwksp(wksp)
    fns = fieldnames(wksp);
    for i_f = 1 : numel(fns)
        fn = fns{i_f};
        assignin("caller", fn, wksp.(fn))
    end
end