function r = le(lhs,rhs)
% POSYNOMIAL/LE  Implements '<=' for posynomials.
%

sz1 = size(lhs); sz2 = size(rhs);
if( sz1(1) > 1 & sz1(2) > 1)
  error(['Cannot impose pointwise inequality with matrices of posynomials.' ...
         char(10) 'The pointwise inequality is only allowed between vectors.'])
end
if( sz2(1) > 1 & sz2(2) > 1)
  error(['Cannot impose pointwise inequality with matrices of posynomials.' ...
         char(10) 'The pointwise inequality is only allowed between vectors.'])
end
if( sz1(1) ~= sz2(1) || sz1(2) ~= sz2(2))
  error(['Cannot make pointwise inequality between vectors ' ...
         'with incompatible dimensions.'])
end

% constructing a single inequality
if( length(lhs) == 1 & length(rhs) == 1 )

  % lhs is a posynomial, now check what is the rhs
  if( isa(rhs,'posynomial') )
    % check if rhs is a posynomial with single term (i.e. monomial)
    % then it is fine
    if( rhs.mono_terms > 1 )
      error(['Not a valid GP constraint: ' char(10) ...
             'right hand side cannot be a posynomial with two or more monomials.'])
    elseif( rhs.mono_terms == 1 )
      rhs = rhs.monomials{1};
    else
      error(['Not a valid GP constraint: ' char(10) ...
             'right hand side cannot be an empty variable.'])
  end
  elseif( isa(rhs,'genposynomial') )
    error(['Not a valid GP constraint: ' ...
           'right hand side cannot be a generalized posynomial.'])
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
