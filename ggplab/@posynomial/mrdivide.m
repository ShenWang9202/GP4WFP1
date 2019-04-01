function r = mrdivide(obj1,obj2)
% POSYNOMIAL/MRDIVIDE  Implements '/' for posynomials.
%

if ( length(obj1) > 1 || length(obj2) > 1 )
  error(['Cannot divide vectors or matrices of posynomials.' char(10) ...
         'Try pointwise division which is defined for vectors and matrices.'])
end

if( isa(obj2,'posynomial') & obj2.mono_terms ~= 1 )
  error('Posynomial division with another multi-term posynomial is not permitted.')
elseif( isa(obj2,'posynomial') & obj2.mono_terms == 1 )
  % convert single term posynomial to a monomial
  obj2 = obj2.monomials{1};
end

r = posynomial(obj1); 
obj2 = monomial(obj2);

% divide posy's monomials with the dividing monomial
for k = 1:r.mono_terms
  r.monomials{k} = r.monomials{k}/obj2;
end
