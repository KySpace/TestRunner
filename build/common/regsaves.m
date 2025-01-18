% Save data or files
function regsaves(entry_save, ~, q)    
    for i_s = 1 : numel(entry_save)
        si = entry_save{i_s}; 
        op = @(name, dflt) lensgetop(name, dflt, entry_save{i_s});
        need = @(name) lensget(name, [], entry_save{i_s});
        val_is_enabled = op("Enabled", true);
        val_addto = need("AddTo");
        if ~val_is_enabled; continue; end
        if isfield(si, "SaveSource")
            val_src = need("SaveSource");
            val_name = need("Name");
            saver = savesetter(val_src, @(i) sprintf("%i.%s", i, val_name));
            q.register(val_addto, "→", saver, "Save file from: " + val_src);
        elseif isfield(si, "CopyFile")
            val_src = need("CopyFile");
            copier = copysetter(val_src);
            q.register(val_addto, "→", copier, "Copy file: " + val_src);
        elseif isfield(si, "Serialized")
            val_src = need("Serialized");
            val_prefix = need("Name");
            saver = savesrlsetter(val_src, val_prefix);
            q.register(val_addto, "→", saver, "Save serialization files: " + val_src);
        elseif isfield(si, "Figure")
            val_src = need("Figure");
            val_name = need("Name");
            val_to_idx = op("Index", 1);
            namer = tern(val_to_idx, @(i) sprintf("%i.%s.bmp", i, val_name), ...
                                 const(sprintf("%s.bmp", val_name)));
            saver = savefigsetter(val_src, namer);
            q.register(val_addto, "→", saver, "Save figure from: " + val_src);
        end
    end
end

function saver = savesetter(src, namemaker)
arguments
    src         string
    namemaker   {mustBeFunctionHandle}
end
    function saveit(io, idx, ~)
        saveddata = evalinio(io, src);
        name = namemaker(idx);
        save(io.devices.savepath + "/" + name + ".mat", "saveddata");
    end
    saver = @saveit;
end

function saver = savefigsetter(src, namemaker)
arguments
    src         string
    namemaker   {mustBeFunctionHandle}
end
    function saveit(io, idx, ~)
        if isfield(io.visuals, src)
            fig = io.visuals.(src);
            name = namemaker(idx);
            saveas(fig, io.devices.savepath + "/" + name, "bmp");
        else
            warning("when trying to save figure, " + src + " does not exist");
        end
    end
    saver = @saveit;
end

function saver = savesrlsetter(src, prefix)
    function savealldata(io, idx, ~)
        srl = evalinio(io, src);
        fns_srl = fieldnames(srl);
        for i_s = 1 : length(fns_srl)
            name_srl_i = fns_srl{i_s};
            path = sprintf("%s/%s.%i.[%s].json", io.devices.savepath, ...
                prefix, idx, name_srl_i);
            fid = fopen(path, "wt");
            fprintf(fid, srl.(name_srl_i));
            fclose(fid);
        end
    end
    saver = @savealldata;
end

function copier = copysetter(src)
    arguments 
        src         string
    end
    function copyit(io, varargin)
        if isfile(src)
            copyfile(src, io.devices.savepath);
        else
            file_list = evalinio(io, src);
            arrayfun(@(f_i) copyfile(which(f_i), io.devices.savepath), ...
                    file_list);
        end
    end
    copier = @copyit;
end