function r = inv(x)
% GPOSYNOMIAL/INV Inverse function is only allowed for generalized posynomials
%                 that are actually monomials.
%

if ismonomial(x)
  x = eval( x, {'' []} );
  r = inv(x);
else
  error(['Inverse function is not allowed for generalized posynomials' char(10) ...
         'that are actually not monomials.'])
end
