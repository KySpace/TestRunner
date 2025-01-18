classdef IOManager < handle
    properties
        runner      struct         = struct()
        data        struct         = struct()
        visuals     struct         = struct()
        updaters    struct         = struct()
        devices     struct         = struct()
        schemeinfo  struct         = struct();
        multidicts  struct         = struct();
    end
    methods 
        function ss = allstructs(o)
            ss = {o.runner, o.data, o.visuals, o.updaters, o.devices, o.schemeinfo, o.multidicts};
        end
        function add(o, ty, name, val)
            o.(ty).(name) = val;
        end
        function val = access(o, ty, access_path)
            arguments
                o
                ty      {mustBeMember(ty, ["runner", "data", "visuals", "updaters", "devices"])}
                access_path       string
            end
            target_path = split(access_path, ".");
            val = lensgetdeep(target_path, o.(ty));
        end
    end
end