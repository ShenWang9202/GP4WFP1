function r = mpower(posy, power)
% POSYNOMIAL/MPOWER  Implements '^' for posynomial objects.
%
% Note: all the powers (even the integer ones are treated using gposy's).
%

if( ~isnumeric(power) )
  error('The exponent in the power must be a numerical value.');
end

if( length(posy) > 1 )
  error(['Cannot raise vectors or matrices of posynomials to a power.' char(10) ...
         'Try pointwise power which is defined for vectors and matrices.'])
end

if( length(power) > 1 )
  error(['Cannot use exponents that are vectors or matrices with a regular power.'...
         char(10) 'Try pointwise power which is defined for vectors and matrices.'])
end

if( power == 1 )
  r = posy;
elseif( power > 0 )
  r = gposynomial(power, {posy});
elseif( power == 0 )
  r = 1;
else
  error(['The exponent must be a positive number in order to obtain'...
        char(10) 'a generalized posynomial.']);
end
