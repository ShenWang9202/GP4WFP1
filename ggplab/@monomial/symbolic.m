function str = symbolic(obj)
% MONOMIAL/SYMBOLIC creates symbolic string representation of the monomial
%
str = [num2str(obj.c)];
for k = 1:length(obj.gpvars)
  if( ~isempty(obj.gpvars{k}) )
    gpvar_str = remove_array_notation(obj.gpvars{k});
    str = [str '*' gpvar_str '^(' num2str(obj.a(k)) ')'];
  end
end

function str = remove_array_notation(str)
% helper function for pretty printing
%
ind = strfind(str,'__array__'); % will require Matlab 6.1

if ~isempty(ind)
  ind = ind(end) + 1;
  str( ind : ind+7 ) = [];
  while( str( ind ) == '0' )
    str( ind ) = [];
  end
end
