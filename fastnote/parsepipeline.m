function piped = parsepipeline(s)
arguments
    s       string
end
    pipeline = arrayfun(@(x) {x}, split(s, "→"));
    pipeline = map_c(@parseanonymous, pipeline);
    piped = pipe(pipeline);
end

