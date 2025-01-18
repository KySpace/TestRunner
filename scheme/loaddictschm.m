% this only load the field as is, does not do any conversion
function [schm, fn_vary] = loaddictschm(filename)
    schm_yaml = validifyyamlschm(loadyaml(filename));
    vary = schm_yaml.Varying;  fn_vary = fieldnames(vary);
    prty = schm_yaml.Priority; fn_prty = fieldnames(prty);
    % Remove the higher-priority names from lower ones
    schm.Varying  = vary;
    schm.Priority = rmfieldifexists(fn_vary, prty);
    schm.Passive  = rmfieldifexists([fn_vary fn_prty], schm_yaml.Passive);
end

% Why "Priority"? What do we want with it?
% Sometimes, we want to make some value be varied (target), but it's not convenient
% to be varied through Varying (maybe because it's not a numeric value,
% or because we don't want the variations to be evenly separated). We put a
% simpler variable (or multiple) in Varying, and make the target variable depend on the
% simple ones. 
% But if we hide the varying expression in the Passive, it is not apparent
% that this is the variable that's been intentionally varied. It also
% messes up the original static value if we only want to vary the target 
% temporarily for a test.
% Putting the target and the expression in "Priority" highlights the
% intention, while also enables leaving a backup expression of the target
% in the Passive.
% But the tricky part of "Priority" is where to insert it and when to
% evaluate it, in fact, neither putting it ahead of everything nor behind
% everything is ideal.
% Why it didn't work all this time is exactly because I wasn't sure what I
% wanted. I thought I wanted a single functionality, but in fact I'm
% thinking about two.
% Currently, let's focus on making Priority evaluated before passive ones,
% but this prevents Priority from depending on other passive variables.

% The original recursive way of differentiating "Following" and "Fixed" was
% a mistake that actually made it work
% It ends up putting everything that follows into fixed, which would be
% evaluated in the right order anyway. This is due to the fact that the
% filter body took fieldnames rather than values and never checks properly
% However, in this branch, I tried to fix this bug, but I cannot make it
% work easily. This is because when I attempt to extract the Following
% first, I could break the order of the dependency (which I assume is valid in the yaml file)
% in the case that some variable depend on two other variables at the same
% time. This method will extract this doubly-dependent variable when
% checking its first dependency, resulting in this variable placed before
% its second dependency.
% It would be very hard to really fix this bug. So I decide to give up on
% distinguishing "Follow" and true "Fixed".