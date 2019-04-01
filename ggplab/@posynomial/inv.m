function r = inv(x)
% POSYNOMIAL/INV Inverse function is only allowed for posynomials
%                that are actually monomials.
%

if ismonomial(x)
  x = eval( x, {'' []} );
  r = inv(x);
else
  error(['Inverse function is not allowed for posynomials that are not monomials.'])
end
