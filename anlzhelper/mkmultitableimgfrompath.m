function xmlpath = mkmultitableimgfrompath(testpath, pic_name, vary_row, vary_col)
    datainfo = load(testpath + "/NaN.SchemeInfo.mat", "saveddata");
    idxlist = load(testpath + "/NaN.IdxList.mat", "saveddata");
    schminfo = datainfo.saveddata;
    idxlist = idxlist.saveddata;
    namegen = @(idx) sprintf("%i.%s.bmp", idx, pic_name);
    node = genmultitableimg(schminfo, "Commands/tmpl.html", vary_row, vary_col, namegen, idxlist);
    xmlpath = sprintf("%s/Collection.%s.%i.%i.html", testpath, pic_name, vary_row, vary_col);
    xmlwrite(xmlpath, node);
end