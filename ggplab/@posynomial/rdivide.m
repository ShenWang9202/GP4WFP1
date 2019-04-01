function r = rdivide(obj1,obj2)
% POSYNOMIAL/RDIVIDE  Implements './' for posynomials.
%

sz1 = size(obj1); sz2 = size(obj2);
if( sz1(1) ~= sz2(1) || sz1(2) ~= sz2(2))
  error(['Cannot pointwise divide vectors or matrices ' ...
         'with incompatible dimensions.'])
end

% pointwise division of posynomials (divisor has to be a monomial)
if( length(obj1) == 1 & length(obj2) == 1 )
  r = obj1/obj2;
  return;
end

% pointwise division of two vectors
if( sz1(1) == 1 & sz2(1) == 1 )
  for k = 1:sz1(2)
    r(1,k) = obj1(1,k)/obj2(1,k);
  end
  return;
end

if( sz1(2) == 1 & sz2(2) == 1 )
  for k = 1:sz1(1)
    r(k,1) = obj1(k,1)/obj2(k,1);
  end
  return;
end

% pointwise division of matrices
for i = 1:sz1(1)
  for j = 1:sz1(2)
    r(i,j) = obj1(i,j)/obj2(i,j);
  end
end
