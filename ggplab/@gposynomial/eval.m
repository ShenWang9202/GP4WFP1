function r = eval(obj, vars)
% GPOSYNOMIAL/EVAL  Implements EVAL command for general posynomials.
%
% Returns reduced generalized posynomial where all the GP variables with given
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

% evaluate immediately if gposy has a single term
if( strcmp(obj.op,'obj') )
  r = eval(obj.args{:},vars);
  return
end

% now evaluate classic gposynomials
% make sure all arguments can be evaluated (convert constants to constant monos)
for k = 1:length(obj.args)
  if( isnumeric(obj.args{k}) )
    obj.args{k} = monomial(obj.args{k});
  end
end
 
% evaluate different flavors of gposynomial
% power gposynomial
if( isnumeric(obj.op) )
  r = (eval(obj.args{1},vars))^(obj.op);

% times gposynomial
elseif( strcmp(obj.op,'*') )
  r = (eval(obj.args{1},vars))*(eval(obj.args{2},vars));

% plus gposynomial
elseif( strcmp(obj.op,'+') )
  r = (eval(obj.args{1},vars))+(eval(obj.args{2},vars));

% max gposynomial
elseif( strcmp(obj.op,'max') )
  num_args = [];
  obj_args = {};

  for k = 1:length(obj.args)
    value = eval(obj.args{k},vars);
    if( isnumeric(value) )
      num_args(end+1) = value;
    else
      obj_args = { obj_args{:} value };
    end
  end

  num_max = max(num_args);

  if( ~isempty(obj_args) )
    if( ~isempty(num_max) )
      obj_args = {obj_args{:} num_max};
    end
    r = max(obj_args{:});

  else
    r = num_max;
  end

end
