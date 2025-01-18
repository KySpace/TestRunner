% This function generates report by putting images in the cells of tables
% decide which varying dictionary are put into the rows and columns of each
% table, the rest of the variation will be represented by different tables
function nodes = genmultitableimg(schminfo, tmpl, vary_row, vary_col, imgpathgen, idxlist)
    nodes = xmlread(tmpl);
    n_page = nodes.getChildNodes.item(1);
    n_body = n_page.getChildNodes.item(5);
    %format long

    function ss = labeler(v, i)
        fn_vary = schminfo.fn_vary{v};
        val = schminfo.cand_vary{v}{i};
        s_val = "";
        if isstring(val); s_val = val;
        elseif isnumeric(val); s_val = sprintf("%1.5G", val);
        end
        ss = sprintf("%s = %s", fn_vary, s_val);
    end
    
    pos_variables = 1 : schminfo.n_variable;
    num_tab = schminfo.n_variation / prod([schminfo.sz_vary(vary_row) schminfo.sz_vary(vary_col)]);
    vary_tab = pos_variables(pos_variables ~= vary_col & pos_variables ~= vary_row);
    sz_tab = schminfo.sz_vary(vary_tab);
    n_variable_tab = numel(sz_tab);

    permpos = [vary_tab vary_row vary_col];
    invpermpos(permpos) = 1 : schminfo.n_variable;

    for i_tab = 1 : num_tab
        sub_tab = cell([1 n_variable_tab]);
        [sub_tab{:}] = ind2sub(sz_tab, i_tab);
        
        tabledesc = fold_c( ...
            @(v, s) s + " | " + labeler(v, sub_tab{invpermpos(v)}) ...
            , "", num2cell(permpos(1:n_variable_tab)));
        n_tabledesc = n_body.appendChild(nodes.createElement("p"));
        n_tabledesc.appendChild(nodes.createTextNode(tabledesc));
        n_table = n_body.appendChild(nodes.createElement("table"));
        % col labels
        n_collabel = n_table.appendChild(nodes.createElement("tr"));
        n_collabel.appendChild(nodes.createElement("th"))...
               .appendChild(nodes.createTextNode("")); 
        for i_col = 1 : schminfo.sz_vary(vary_col)
            n_collabel.appendChild(nodes.createElement("th"))...
               .appendChild(nodes.createTextNode(labeler(vary_col, i_col))); 
        end
        for i_row = 1 : schminfo.sz_vary(vary_row)        
            n_row = n_table.appendChild(nodes.createElement("tr"));
            % row labels
            n_row.appendChild(nodes.createElement("th"))...
                .appendChild(nodes.createTextNode(labeler(vary_row, i_row)));
            for i_col = 1 : schminfo.sz_vary(vary_col)
                subs = [sub_tab {i_row,i_col}];
                subs = subs(invpermpos);
                node_td = n_row.appendChild(nodes.createElement("td"));
                for idx = 1 : length(idxlist)
                    rawidx = idxlist(idx);
                    [~, sub_i] = accessvary(schminfo, rawidx);
                    if isequal(cell2mat(subs), sub_i)
                        picname = imgpathgen(idx);
                        n_data = node_td.appendChild(nodes.createElement("img"));
                        n_data.setAttribute("src", picname);
                        n_data.setAttribute("width", "600");
                    end
                end
            end
        end
    end
end