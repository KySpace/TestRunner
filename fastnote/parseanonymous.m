% Now supports only one argument
function f = parseanonymous(s)
    argname = "anonymous_arg";
    if regexp(s, "λ"); convstr = "@(" + argname + ") " + regexprep(s, "λ", argname);
    else; convstr = "@" + s; end
    f = eval(convstr);
end