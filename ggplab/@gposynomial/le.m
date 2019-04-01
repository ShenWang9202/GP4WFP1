function r = le(lhs, rhs)
% GPOSYNOMIAL/LE  Implements '<=' for generalized posynomial objects.
%

sz1 = size(lhs); sz2 = size(rhs);
if( sz1(1) > 1 & sz1(2) > 1)
  error(['Cannot impose pointwise inequality with matrices of general posynomials.' ...
         char(10) 'The pointwise inequality is only allowed between vectors.'])
end
if( sz2(1) > 1 & sz2(2) > 1)
  error(['Cannot impose pointwise inequality with matrices of general posynomials.' ...
         char(10) 'The pointwise inequality is only allowed between vectors.'])
end
if( sz1(1) ~= sz2(1) || sz1(2) ~= sz2(2))
  error(['Cannot make pointwise inequality between vectors ' ...
         'with incompatible dimensions.'])
end

% constructing a single inequality
if( length(lhs) == 1 & length(rhs) == 1 )

  % lhs is a gen posynomial, now check that rhs is a scalar or a monomial
  if isnumeric(rhs)
    rhs = rhs;
  elseif ismonomial(rhs)
    rhs = eval(rhs, {'' []});
  else
    error('Not a valid GP constraint: right hand side has to be a monomial.')
  end

  % create a GP constraint
  r = gpconstraint(lhs,'<=',rhs);
  return;
end

% pointwise inequality between vectors
if( sz1(1) == 1 & sz2(1) == 1 )
  for k = 1:sz1(2)
    r(1,k) = lhs(1,k) <= rhs(1,k);
  end
  return;
end

if( sz1(2) == 1 & sz2(2) == 1 )
  for k = 1:sz1(1)
    r(k,1) = lhs(k,1) <= rhs(k,1);
  end
  return;
end
