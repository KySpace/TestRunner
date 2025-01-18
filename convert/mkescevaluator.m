% generate evaluator for a string if it does not fit the escaped options
function e = mkescevaluator(escaped)
    arguments
        escaped         string     % string array
    end
    e = @(expr, wksp) evalexpr(escaped, expr, wksp);
end

function val = evalexpr(escaped, expr, wksp)
    assignwksp(wksp);
    if ~isstring(expr) || ismember(expr, escaped)
        val = expr;
    else            
        val = eval(expr);
    end
end