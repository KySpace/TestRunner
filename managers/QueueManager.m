classdef QueueManager < handle
    properties (Constant)
        unitnames = ["init" "link" "prep" "main" "post" "panic" "final"]
    end
    properties
        % to initialize windows, classes, iterators, etc.
        init        QueueUnit  = QueueUnit()
        % to initialize callbacks that are called during the run
        link        QueueUnit  = QueueUnit()
        % to prepare pertest
        prep        QueueUnit  = QueueUnit()
        % the main execution pertest
        main        QueueUnit  = QueueUnit()
        % the on-the-fly data collection or analyzation pertest
        post        QueueUnit  = QueueUnit()
        % special handling for failure
        panic       QueueUnit  = QueueUnit()
        % conclusion
        final       QueueUnit  = QueueUnit()
    end
    methods
        function io = execinitialize(o, io)
            o.init.invoke(io, nan);
            o.link.invoke(io, nan, struct());
        end
        function io = execpertest(o, io, idx, dict)
            o.prep.invoke(io, idx, dict);
            o.main.invoke(io, idx, dict);
            o.post.invoke(io, idx, dict);
        end
        function io = execpanic(o, io, idx)
            fprintf("Panicing at test %i, collecting info \n", idx);
            o.panic.invoke(io, idx);
        end
        function io = execfinal(o, io, ~, ~)
            fprintf("Task finished \n");
            o.final.invoke(io, nan, struct());
        end
    end
    methods
        function register(o, target, pos, fun, msg)
            arguments
                o                
                target          string      {mustBeMember(target, ["init" "link" "prep" "main" "post" "panic" "final"])}
                pos             string      {mustBeMember(pos, ["←", "→"])}
                fun                         {mustBeFunctionHandle}
                msg             string
            end
            o.(target).reg(pos, fun, msg)
        end
        function clear(o)
            o.init .clear();
            o.link .clear();
            o.prep .clear();
            o.main .clear();
            o.post .clear();
            o.panic.clear();
            o.final.clear();
        end
        function o = QueueManager()
            o.clear;
        end
    end
end