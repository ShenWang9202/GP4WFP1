function r = eval(obj, vars)
% POSYNOMIAL/EVAL  Implements EVAL command for posynomials.
%
% Returns reduced posynomial where all the GP variables with given
% numerical values are evaluated.
%

sz = size(vars);
if( ~isa(vars,'cell') || sz(2) ~= 2 )
  error('Second argument should be a cell array with 2 rows');
end

% check that all the gp variables are positive (implicit GP constraint)
for k = 1:size(vars,1)
  var_values = vars{k,2};
  if any(var_values <= 0)
    error('GP variables must have positive value.');
  end
end

% posynomial evaluation
r = posynomial;
for k = 1:obj.mono_terms
  r = r + eval(obj.monomials{k},vars);
end

if isempty(r.gpvars) % have a numeric result
  r = r.monomials{1};
  r = r.c;
  if isempty(r), r = 0; end
end
