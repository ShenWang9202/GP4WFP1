function r = eval(obj, vars)
% GPCONSTRAINT/EVAL  Implements EVAL command for GP constraints.
%
% Returns either a true (logical 1) or a false (logical 0) if all
% GP variables are specified or a reduced GP constraint.
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

% evaluate different flavors of gpconstraint
if( strcmp(obj.type,'<=') )
  r = (eval(obj.lhs,vars)) <= (eval(obj.rhs,vars));
elseif( strcmp(obj.type,'==') )
  r = (eval(obj.lhs,vars)) == (eval(obj.rhs,vars));
end
