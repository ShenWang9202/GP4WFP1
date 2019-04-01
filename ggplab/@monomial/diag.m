function r = diag(obj)
% MONOMIAL/DIAG  Creates a diagonal matrix of monomial objects.
%

r = monomial;

% XXX make robust

for k = 1:size(obj)
  r(k,k) = obj(k);
end
