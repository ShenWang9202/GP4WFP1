function str = symbolic(obj)
% GPCONSTRAINT/SYMBOLIC Creates symbolic string representation of the GP constraint.
%

if isnumeric(obj.rhs)
  str_rhs = num2str(obj.rhs);
else
  str_rhs = symbolic(obj.rhs);
end

if isnumeric(obj.lhs)
  str_lhs = num2str(obj.lhs);
else
  str_lhs = symbolic(obj.lhs);
end

str = [str_lhs ' ' obj.type ' ' str_rhs];
