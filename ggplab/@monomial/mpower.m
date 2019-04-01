function r = mpower(x,y)
% MONOMIAL/MPOWER  Implement '^' for a monomial.
%

if( ~isnumeric(y) )
  error('The exponent in the power must be a numerical value.');
end

if( length(x) > 1 )
  error(['Cannot raise vectors or matrices of monomials to a power.' char(10) ...
         'Try pointwise power which is defined for vectors and matrices.'])
end

if( length(y) > 1 )
  error(['Cannot use exponents that are vectors or matrices with a regular power.'...
         char(10) 'Try pointwise power which is defined for vectors and matrices.'])
end

if( y == 0 ) 
  % return scalar 1 if the exponent is zero
  r = 1;
else
  r = monomial;
  r.c = (x.c)^y;
  r.a = (x.a)*y;
  r.gpvars = x.gpvars;
end
