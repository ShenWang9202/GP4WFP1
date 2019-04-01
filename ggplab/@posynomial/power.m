function r = power(obj1,obj2)
% POSYNOMIAL/POWER  Implements '.^' for posynomials.
%

if( ~isnumeric(obj2) )
  error('The exponent in the power must be a numerical value.');
end

sz1 = size(obj1); sz2 = size(obj2);
if( length(obj2) ~= 1 ) % the exponent is not a scalar
  if( sz1(1) ~= sz2(1) || sz1(2) ~= sz2(2))
    error(['Cannot apply pointwise power to vectors or matrices ' ...
           'with incompatible dimensions' char(10) ...
           '(if the power is not scalar).'])
  end
end

% take the pointwise power with a posynomial and a scalar (to get a gposy)
if( length(obj1) == 1 & length(obj2) == 1 )
  r = obj1^obj2;
  return;
end

% pointwise power of a posynomial vector (or matrix) and scalar power
if( length(obj2) == 1 )
  for i = 1:sz1(1)
    for j = 1:sz1(2)
      r(i,j) = obj1(i,j)^obj2;
    end
  end
  return;
end

% pointwise power of a posynomial vector and a scalar vector
if( sz1(1) == 1 & sz2(1) == 1 )
  for k = 1:sz1(2)
    r(1,k) = obj1(1,k)^obj2(1,k);
  end
  return;
end

if( sz1(2) == 1 & sz2(2) == 1 )
  for k = 1:sz1(1)
    r(k,1) = obj1(k,1)^obj2(k,1);
  end
  return;
end

% pointwise power of matrices (one has posynomials and the other scalars)
for i = 1:sz1(1)
  for j = 1:sz1(2)
    r(i,j) = obj1(i,j)^obj2(i,j);
  end
end
