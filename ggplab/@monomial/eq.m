function r = eq(lhs,rhs)
% MONOMIAL/EQ  Implements '==' for monomials.
%

sz1 = size(lhs); sz2 = size(rhs);
if( sz1(1) > 1 & sz1(2) > 1)
  error(['Cannot impose pointwise equality with matrices of monomials.' ...
         char(10) 'The pointwise equality is only allowed between vectors.'])
end
if( sz2(1) > 1 & sz2(2) > 1)
  error(['Cannot impose pointwise equality with matrices of monomials.' ...
         char(10) 'The pointwise equality is only allowed between vectors.'])
end
if( sz1(1) ~= sz2(1) || sz1(2) ~= sz2(2))
  error(['Cannot make pointwise equality between vectors ' ...
         'with incompatible dimensions.'])
end

% constructing a single equality
if( length(lhs) == 1 & length(rhs) == 1 )
  % lhs is a monomial, now check what is the rhs
  if (isa(rhs,'posynomial'))
    error('Not a valid GP equality: right hand side cannot be a posynomial.')
  elseif (isa(rhs,'genposynomial'))
    error(['Not a valid GP equality: ' ...
           'right hand side cannot be a generalized posynomial.'])
  else
    % create a GP equality constraint
    r = gpconstraint(lhs,'==',rhs);
    return;
  end
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
