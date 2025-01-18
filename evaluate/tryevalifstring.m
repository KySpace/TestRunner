function val = tryevalifstring(expr, wksp)
    arguments
        expr        
        wksp        = struct()
    end
    try
        val = evalifstring(expr, wksp);
    catch ME
        if isequal(ME.identifier, 'MATLAB:UndefinedFunction')
            val = expr;
        end
    end
end