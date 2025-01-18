function io = rundebug(io, queue, fromidx, toidx)
arguments
    io          IOManager
    queue       QueueManager
    fromidx     {mustBeInteger}         = 1
    toidx       {mustBeInteger}         = -1
end
    queue.execinitialize(io);
    md = io.multidicts;   
    toidx = tern(toidx > 0, toidx, md.maxrun);  
    for idx = fromidx : toidx
        dict = md.get(idx);
        io = queue.execpertest(io, idx, dict);
    end       
    queue.execfinal(io, nan, struct());
end