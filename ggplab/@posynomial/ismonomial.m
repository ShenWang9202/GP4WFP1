function r = ismonomial(obj)
% POSYNOMIAL/ISMONOMIAL  Checks whether the input posynomial is a monomial.
%

if( obj.mono_terms == 1 )
  r = 1;
else
  r = 0;
end
