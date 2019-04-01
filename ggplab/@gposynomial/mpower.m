function r = mpower(gposy, power)
% POSYNOMIAL/MPOWER  Implements '^' for general posynomial objects.
%

if( ~isnumeric(power) )
  error('The exponent in the power must be a numerical value.');
end

if( length(gposy) > 1 )
  error(['Cannot raise vectors or matrices of general posynomials to a power.'...
          char(10) ...
         'Try pointwise power which is defined for vectors and matrices.'])
end

if( length(power) > 1 )
  error(['Cannot use exponents that are vectors or matrices with a regular power.'...
         char(10) 'Try pointwise power which is defined for vectors and matrices.'])
end

if( power == 1 )
  r = gposy;
elseif( power > 0 )
  r = gposynomial(power, {gposy});
elseif( power == 0 )
  r = 1;
else
  error(['The exponent must be a positive number in order to obtain'...
        char(10) 'a generalized posynomial.']);
end
