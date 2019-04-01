function r = eq(lhs,rhs)
% GPVAR/EQ  Implements '==' for GP variables.
%

sz1 = size(lhs); sz2 = size(rhs);
if( sz1(1) > 1 & sz1(2) > 1)
  error(['Cannot impose pointwise equality with matrices of GP variables.' ...
         char(10) 'The pointwise equality is only allowed between vectors.'])
end
if( sz2(1) > 1 & sz2(2) > 1)
  error(['Cannot impose pointwise equality with matrices of GP variables.' ...
         char(10) 'The pointwise equality is only allowed between vectors.'])
end
if( sz1(1) ~= sz2(1) || sz1(2) ~= sz2(2))
  error(['Cannot make pointwise equality between vectors ' ...
         'with incompatible dimensions.'])
end

% constructing a single equality
if( length(lhs) == 1 & length(rhs) == 1 )
  r = monomial(lhs) == monomial(rhs);
  return;
end

% pointwise equality between vectors
if( sz1(1) == 1 & sz2(1) == 1 )
  for k = 1:sz1(2)
    r(1,k) = lhs(1,k) == rhs(1,k);
  end
  return;
end

if( sz1(2) == 1 & sz2(2) == 1 )
  for k = 1:sz1(1)
    r(k,1) = lhs(k,1) == rhs(k,1);
  end
  return;
end
