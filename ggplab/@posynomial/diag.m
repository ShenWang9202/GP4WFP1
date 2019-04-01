function r = diag(obj)
% POSYNOMIAL/DIAG  Creates a diagonal matrix of posynomial objects.
%

r = posynomial;

% XXX make robust

for k = 1:size(obj)
  r(k,k) = obj(k);
end
