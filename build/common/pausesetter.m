function setter = pausesetter(pausetime, s_addto)
    function setpause(io, ~, ~)
        addto = evalinio(io, s_addto);
        function drawatpause(varargin)
            drawnow();
        end
        function pauser(varargin)
            pause(pausetime);
        end
        p = tern(pausetime > 0, @pauser, @drawatpause);
        addto.reg("→", p, "intentional pause / drawnow.");
    end
    setter = @setpause;
end