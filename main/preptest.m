function io = preptest(io, queue, idx)   
arguments
    io          IOManager
    queue       QueueManager
    idx         {mustBeInteger}
end
    queue.execinitialize(io);
    md = io.multidicts;
    dict = md.get(idx);
    queue.prep.invoke(io, idx, dict); 
end