function r = mtimes(obj1, obj2)
% POSYNOMIAL/MTIMES  Implements '*' for posynomial objects.
%
% Multiply through posynomials, later might implement algorithm that 
% uses generalized posynomials when multiplying out large posynomials
% (in which case we introduce new GP variables).
%

sz1 = size(obj1); sz2 = size(obj2);
if( sz1(2) ~= sz2(1) )
  error(['Cannot multiply vectors or matrices with incompatible dimensions.'])
end

% multiplying two posynomials together (to get another posynomial)
if( length(obj1) == 1 & length(obj2) == 1 )
  r = posynomial;
  obj1 = posynomial(obj1);
  obj2 = posynomial(obj2);

  % all monomial simplifications are handled by posy addition
  for i = 1:obj1.mono_terms
    for j = 1:obj2.mono_terms
      r = r + obj1.monomials{i}*obj2.monomials{j};
    end
  end
  return;
end

% inner product of two posynomial vectors (will get a posynomial)
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
