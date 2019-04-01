function str = symbolic(obj)
% POSYNOMIAL/SYMBOLIC creates symbolic string representation of the posynomial
%
str = [symbolic(obj.monomials{1})];
for k = 2:obj.mono_terms
  str = [str ' + ' symbolic(obj.monomials{k})];
end
