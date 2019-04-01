function r = mtimes(obj1, obj2)
% GPOSYNOMIAL/MTIMES  Implements '*' for generalized posynomial objects.
%

sz1 = size(obj1); sz2 = size(obj2);
if( sz1(2) ~= sz2(1) )
  error(['Cannot multiply vectors or matrices with incompatible dimensions.'])
end

% multiplying two gen posynomials together (to get another gen posynomial)
if( length(obj1) == 1 & length(obj2) == 1 )

  % make sure that numerics are converted to monomials
  if isnumeric(obj1)
    obj1 = monomial(obj1);
  else % check if the object can be reduced
    obj1 = eval( obj1, {'' []} );
  end
  if isnumeric(obj2)
    obj2 = monomial(obj2);
  else % check if the object can be reduced
    obj2 = eval( obj2, {'' []} );
  end

  if( ~isa(obj1,'gposynomial') && ~isa(obj2,'gposynomial') )
  % if both objects where reduced (they are not generalized posynomials)
  % then invoke a simpler computation
    r = obj1*obj2;
    return;
  end

  if ismonomial(obj1) % here obj2 can be a generalized posynomial
    r = gposynomial(obj2);
    r_terms = r.args;

    % multiply general posy's terms with the monomial
    for k = 1:length(r_terms)
      r_terms{k} = r_terms{k}*obj1;
    end
    r.args = r_terms;
    return;
  end

  if ismonomial(obj2) % here obj1 can be a generalized posynomial
    r = gposynomial(obj1);
    r_terms = r.args;

    % multiply general posy's terms with the monomial
    for k = 1:length(r_terms)
      r_terms{k} = r_terms{k}*obj2;
    end
    r.args = r_terms;
    return;
  end

  % combine the two posy or gposy objects as a generalized posynomial 
  r = gposynomial('*', {obj1, obj2});
  return;

end

% inner product of two gen posynomial vectors (will get a gen posynomial)
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
