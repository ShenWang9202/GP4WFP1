function r = mrdivide(obj1, obj2)
% GPVAR/MRDIVIDE  Implements '/' for GP variable.
%

if ( length(obj1) > 1 || length(obj2) > 1 )
  error(['Cannot divide vectors or matrices of GP variables.' char(10) ...
         'Try pointwise division which is defined for vectors and matrices.'])
end

r = monomial(obj1)/monomial(obj2);
