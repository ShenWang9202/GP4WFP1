function r = times(obj1, obj2)
% GPVAR/TIMES  Implement '.*' for GP variables.
%

sz1 = size(obj1); sz2 = size(obj2);
if( sz1(1) ~= sz2(1) || sz1(2) ~= sz2(2))
  error(['Cannot pointwise multiply vectors or matrices ' ...
         'with incompatible dimensions.'])
end

% multiplying two GP vars together (to get a monomial)
if( length(obj1) == 1 || length(obj2) == 1 )
  r = monomial(obj1)*monomial(obj2);
  return;
end

% pointwise product of two GP var vectors (to get another monomial vector)
if( sz1(1) == 1 & sz2(1) == 1 )
  for k = 1:sz1(2)
    r(1,k) = obj1(1,k)*obj2(1,k);
  end
  return;
end

if( sz1(2) == 1 & sz2(2) == 1 )
  for k = 1:sz1(1)
    r(k,1) = obj1(k,1)*obj2(k,1);
  end
  return;
end

% multiplying out matrices of gpvars
for i = 1:sz1(1)
  for j = 1:sz1(2)
    r(i,j) = obj1(i,j)*obj2(i,j);
  end
end
