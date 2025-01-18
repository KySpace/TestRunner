function val = evalifstring(expr, wksp)
    assignwksp(wksp);
    if isstring(expr)
        val = eval(expr);
    else
        val = expr;
    end
end