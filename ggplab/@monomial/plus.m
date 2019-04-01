function r = plus(obj1, obj2)
% MONOMIAL/PLUS  Implement '+' for monomial objects.
%

sz1 = size(obj1); sz2 = size(obj2);

% adding two monomials together (to get a posynomial)
if( length(obj1) == 1 & length(obj2) == 1 )
  r = posynomial(obj1) + posynomial(obj2);
  return;
end

% adding two compatible vectors or matrices of monomials
if( sz1(1) == sz2(1) & sz1(2) == sz2(2) )
  for i = 1:sz1(1)
    for j = 1:sz1(2)
      r(i,j) = obj1(i,j) + obj2(i,j);
    end
  end
else
  error(['Cannot add vectors or matrices with incompatible dimensions.'])
end
