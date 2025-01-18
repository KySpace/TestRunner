function val = tryevalinioifstring(expr, io)
    arguments
        expr
        io      IOManager
    end
    if ~isstring(expr); val = expr; return; end
    try
        val = eval(expr);
    catch ME
        if isequal(ME.identifier, 'MATLAB:UndefinedFunction')
            try 
                val = evalinio(io, expr);
            catch ME
                if isequal(ME.identifier, 'MATLAB:UndefinedFunction')
                    val = expr;
                else
                    rethrow(ME);
                end
            end
        else
            rethrow(ME); 
        end
    end
end