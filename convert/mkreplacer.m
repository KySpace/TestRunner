function r = mkreplacer(replaced, replacing)
    function val_o = repl(val_in)
        if isequal(val_in, replaced)
            val_o = replacing;
        else
            val_o = val_in;
        end
    end
    r = @repl;
end