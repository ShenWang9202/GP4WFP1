function str = symbolic(obj)
% GPVAR/SYMBOLIC Creates symbolic string representation of the GP variable.
%

str = obj.label;
ind = strfind(str,'__array__'); % strfind function requires Matlab 6.1

if ~isempty(ind)
  ind = ind(end) + 1;
  str( ind : ind+7 ) = [];
  while( str( ind ) == '0' )
    str( ind ) = [];
  end
end
