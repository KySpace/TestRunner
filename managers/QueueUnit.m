classdef QueueUnit < handle
    properties
        queue                    {mustBeFunctionHandleCell(queue)} = {}
        log           string                                       = []
    end
    methods
        function reg(o, pos, fun, msg)
            arguments
                o
                pos             string      {mustBeMember(pos, ["←", "→"])}
                fun                         {mustBeFunctionHandle}
                msg             string
            end
            if ~iscell(fun); fun = {fun}; end
            function ba = append(a, b)
                ba = [b; a];
            end
            function ab = preppend(a, b)
                ab = [a; b];
            end
            addit = tern(pos=="←", @preppend, @append);
            o.queue = addit(fun, o.queue);
            o.log   = addit(msg, o.log);
        end 
        function invoke(o, varargin)
            executeall(o.queue, varargin{:});
        end
        function clear(o)
            o.queue = {};
            o.log = [];
        end
        function o = QueueUnit()
            o.clear();
        end
    end
end

