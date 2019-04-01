function r = mtimes(obj1, obj2)
% GPVAR/MTIMES  Implements '*' for GP variables.
%

sz1 = size(obj1); sz2 = size(obj2);
if( sz1(2) ~= sz2(1) )
  error(['Cannot multiply vectors or matrices with incompatible dimensions.'])
end

% multiplying two scalar GP vars together (to get a monomial)
if( length(obj1) == 1 & length(obj2) == 1 )
  r = monomial(obj1)*monomial(obj2);
  return;
end

% inner product of two GP var vectors (to get a posy)
if( sz1(1) == 1 & sz2(2) == 1 )
  r = obj1(1,1)*obj2(1,1); 
  for k = 2:sz1(2)
    r = r + obj1(1,k)*obj2(k,1);
  end
  return;
end

% multiplying out vectors and matrices
for i = 1:sz1(1)
  for j = 1:sz2(2)
    r(i,j) = obj1(i,:)*obj2(:,j);
  end
end
