function r = mrdivide(obj1,obj2)
% MONOMIAL/MRDIVIDE  Implement '/' for monomials.
%

if ( length(obj1) > 1 || length(obj2) > 1 )
  error(['Cannot divide vectors or matrices of monomials.' char(10) ...
         'Try pointwise division which is defined for vectors and matrices.'])
end

% cast inputs as monomials
obj1 = monomial(obj1); 
obj2 = monomial(obj2);

% divide two monomials
r = obj1*monomial(obj2.gpvars, 1/obj2.c, -obj2.a);
