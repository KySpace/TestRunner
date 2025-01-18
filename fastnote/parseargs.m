function args = parseargs(args)
    if ~iscell(args); args = {args}; end
    args = map_c(@parsepipeline, args);
end