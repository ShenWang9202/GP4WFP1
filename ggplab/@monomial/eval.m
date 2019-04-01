function r = eval(obj, vars)
% MONOMIAL/EVAL  Implements EVAL command for monomials.
%
% Returns reduced monomial where all the GP variables with given
% numerical values are evaluated.
%

sz = size(vars);
if( ~isa(vars,'cell') || sz(2) ~= 2 )
  error('Second argument should be a cell array with 2 columns.');
end

% check that all the gp variables are positive (implicit GP constraint)
for k = 1:size(vars,1)
  var_values = vars{k,2};
  if any(var_values <= 0)
    error('GP variables must have positive value.');
  end
end

% expand arrays in vars
vars_expand = {};
for k = 1:sz(1)
  array = vars{k,2};
  array_length = length(array);
  if( array_length > 1 ) % have an array
    for m = 1:array_length
      if(     m < 10  ),     numstr = ['00000' num2str(m)];
      elseif( m < 100 ),     numstr = ['0000'  num2str(m)];
      elseif( m < 1000 ),    numstr = ['000'   num2str(m)];
      elseif( m < 10000 ),   numstr = ['00'    num2str(m)];
      elseif( m < 100000 ),  numstr = ['0'     num2str(m)];
      else                   numstr = num2str(m);
      end
      sz = size(vars_expand);
      vars_expand{sz(1)+1,1} = [vars{k,1} '__array__' numstr];
      vars_expand{sz(1)+1,2} = array(m);
    end
  else                   % have a scalar
    sz = size(vars_expand);
    vars_expand{sz(1)+1,1} = vars{k,1};
    vars_expand{sz(1)+1,2} = vars{k,2};
  end                    
end

% reducation algorithm
r = monomial;
for k = 1:length(obj.gpvars)
  [tf, loc] = ismember( obj.gpvars{k}, {vars_expand{:,1}} );
  if tf
    % if GP variable is in the list evaluate its value in the monomial
    obj.c = obj.c*vars_expand{loc,2}^(obj.a(k)); 
  else
    r.gpvars = { r.gpvars{:}, obj.gpvars{k} };
    r.a = [r.a obj.a(k)]; 
  end
end

if isempty(r.gpvars) % have a numeric results
  r = obj.c;
else                 % otherwise return a reduced monomial
  r.c = obj.c;
end
