function r = plus(obj1, obj2)
% GPOSYNOMIAL/PLUS  Implements '+' for generalized posynomial objects.
%

sz1 = size(obj1); sz2 = size(obj2);
if( sz1(1) ~= sz2(1) || sz1(2) ~= sz2(2))
  error(['Cannot add vectors or matrices with incompatible dimensions.'])
end

% adding two scalar generalized posynomials
if( length(obj1) == 1 & length(obj2) == 1 )
  % check if objects can be reduced to simpler forms via eval
  if ~isnumeric(obj1)
    obj1 = eval( obj1, {'' []} );
  end
  if ~isnumeric(obj2)
    obj2 = eval( obj2, {'' []} );
  end

  if( ~isa(obj1,'gposynomial') & ~isa(obj2,'gposynomial') )
    % if both objects where reduced (they are not generalized posynomials)
    % then invoke a simpler computation
    r = obj1 + obj2;
    return;
  end

  % else create a resulting generalized posynomial
  r = gposynomial('+', {obj1, obj2});

else % this handles arrays and matrices using scalar case
  for i = 1:sz1(1)
    for j = 1:sz1(2)
      r(i,j) = obj1(i,j) + obj2(i,j);
    end
  end
end
