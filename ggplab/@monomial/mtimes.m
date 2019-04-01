function r = mtimes(obj1, obj2)
% MONOMIAL/MTIMES  Implement '*' for monomial objects.
%

sz1 = size(obj1); sz2 = size(obj2);
if( sz1(2) ~= sz2(1) )
  error(['Cannot multiply vectors or matrices with incompatible dimensions.'])
end

% multiplying two monomials together (to get another monomial)
if( length(obj1) == 1 & length(obj2) == 1 )
  % initialize the return object as a monomial
  r = monomial; 

  % cast both inputs as monomials
  obj1 = monomial(obj1); 
  obj2 = monomial(obj2);

  % check if we have multiplication by an empty monomial
  % in that case just return an empty monomial
  if( isempty(obj1.c) || isempty(obj2.c) )
    return;
  end

  % multiply two (nonempty) monomials
  r.c = obj1.c*obj2.c;
  r.a = [obj1.a];
  r.gpvars = obj1.gpvars;

  % merge gpvars while combining the same ones
  for k = 1:length(obj2.gpvars)
    [tf, loc] = ismember( obj2.gpvars{k}, r.gpvars );
    if tf
    % if GP variable is in the list then combine it
      r.a(loc) = r.a(loc) + obj2.a(k);
    else
    % new GP variable, add it to the monomial
      r.gpvars = { r.gpvars{:}, obj2.gpvars{k} };
      r.a = [r.a obj2.a(k)];
    end
  end

  % eliminate GP variables from the monomial that have 0 exponent
  a_var = r.a;
  gpvars_var = r.gpvars;
  nonzero_ind = find(a_var ~= 0);
  r.a = a_var(nonzero_ind); 
  if isempty(r.a)
    r.gpvars = {};
  else
    r.gpvars = {gpvars_var{nonzero_ind}};
  end
  return;
end

% inner product of two monomial vectors (will get a posynomial)
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
