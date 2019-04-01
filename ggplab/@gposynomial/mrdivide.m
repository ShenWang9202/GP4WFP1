function r = mrdivide(obj1,obj2)
% GPOSYNOMIAL/MRDIVIDE  Implements '/' for general posynomials.
%

if ( length(obj1) > 1 || length(obj2) > 1 )
  error(['Cannot divide vectors or matrices of general posynomials.' char(10) ...
         'Try pointwise division which is defined for vectors and matrices.'])
end

% convert numeric values to monomials
if isnumeric(obj2)
  obj2 = monomial(obj2);
end

if ismonomial(obj2)

  % convert the GP object obj2 to a monomial (using empty eval statement)
  obj2 = eval( obj2, {'' []} );

  % now compute the division
  r = gposynomial(obj1); 
  r_terms = r.args;

  % divide general posy's terms with the dividing monomial
  for k = 1:length(r_terms)
    r_terms{k} = r_terms{k}/obj2;
  end
  r.args = r_terms;

else
  error('General posynomial division is only permitted with monomial divisors.')
end
