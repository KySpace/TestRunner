function io = runnormal(io, queue, fromidx, toidx)
arguments
    io          IOManager
    queue       QueueManager
    fromidx     {mustBeInteger}         = 1
    toidx       {mustBeInteger}         = -1
end
    queue.execinitialize(io);
    md = io.multidicts;
    toidx = tern(toidx > 0, toidx, md.maxrun);
    try        
        for idx = fromidx : toidx
            dict = md.get(idx);
            io = queue.execpertest(io, idx, dict);
        end        
    catch ME
         assignin("base", "lastME", ME);
         queue.execpanic(io, idx); 
         assignin("base", "io", io);
         rethrow(ME);
    end    
    queue.execfinal(io, nan, struct());
end