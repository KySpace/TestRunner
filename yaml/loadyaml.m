function f = loadyaml(filename)
    try
        f = yaml.loadFile(filename);
    catch ME
        if isequal(ME.identifier, 'yaml:load:Failed')
        msg = ME.cause{1}.message;
        msg = erase(msg, "Java exception occurred:");
        msg = eraseBetween(msg, ...
            "at org.yaml.snakeyaml", ...
            "java:" + wildcardPattern + ")", ...
            Boundaries="inclusive");
        me = MException(ME.identifier, [ME.message strtrim(msg)]);        
        throw(me);
        else 
            rethrow(ME)
        end
    end
end