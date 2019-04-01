function r = eval(obj, vars)
% GPVAR/EVAL  Implements EVAL command for GP variables.
%
% Returns GP variable value given the list of GP variable values.
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

% reduction algorithm
[tf, loc] = ismember( obj.label, {vars_expand{:,1}} );
if tf
  r = vars_expand{loc,2}; % if GP variable is in the list return its value
else
  r = obj; % otherwise return it back as a gpvar object
end
