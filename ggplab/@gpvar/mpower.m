function r = mpower(x,y)
% GPVAR/MPOWER  Implement '^' for GP variable.
%

if( ~isnumeric(y) )
  error('The exponent in the power must be a numerical value.');
end

if( length(x) > 1 )
  error(['Cannot raise vectors or matrices of GP variables to a power.' char(10) ...
         'Try pointwise power which is defined for vectors and matrices.'])
end

if( length(y) > 1 )
  error(['Cannot use exponents that are vectors or matrices with a regular power.'...
         char(10) 'Try pointwise power which is defined for vectors and matrices.'])
end

r = monomial(x)^y;
