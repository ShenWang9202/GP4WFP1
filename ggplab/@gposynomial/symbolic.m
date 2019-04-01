function str = symbolic(obj)
% GPOSYNOMIAL/SYMBOLIC creates symbolic string representation of
% the generalized posynomial.
%

if( isnumeric(obj.op) )
  str = ['(' symbolic(obj.args{1}) ')^(' num2str(obj.op) ')'];
elseif( strcmp(obj.op,'obj') )
  str = symbolic(obj.args{:});
elseif( strcmp(obj.op,'max') )
  str = ['max( '];
  for k = 1:length(obj.args)-1
    str = [str private_symbolic(obj.args{k}) ' , '];
  end
  str = [str private_symbolic(obj.args{end}) ' )'];
elseif( strcmp(obj.op,'*') )
  str = ['(' private_symbolic(obj.args{1}) ') * (' private_symbolic(obj.args{2}) ')'];
elseif( strcmp(obj.op,'+') )
  str = ['(' private_symbolic(obj.args{1}) ') + (' private_symbolic(obj.args{2}) ')'];
end

function str = private_symbolic(obj)
% define symbolic function for numeric values (doubles, etc.)
%
if isnumeric( obj )
  str = num2str(obj);
else
  str = symbolic(obj);
end
