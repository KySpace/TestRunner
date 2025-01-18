function val_setat = findsetatauto(entry, op)
arguments
    entry           struct
    op.key_setat    = "SetAt"
    op.val_addto     = []
end
    % if `val_addto` is not assigned, use `entry.AddTo`
    val_addto = ifthel(   isempty(op.val_addto), ...
                        lensgetop("AddTo", [], entry), ...
                        op.val_addto );
    % prioritize the given `SetAt`
    if isfield(entry, op.key_setat)
        val_setat = entry.SetAt;
    elseif ismember(val_addto, QueueManager.unitnames)
        val_setat = "init";
    else
        val_setat = "prep";
    end
end