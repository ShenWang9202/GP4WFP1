function display(obj)
% MONOMIAL display method
%
disp(' ');

sz = size(obj);
if( sz(1) == 1 & sz(2) == 1 )   % single monomial object
  if( ~isempty(obj.c) )
    disp([inputname(1) ' is a monomial object, ' ...
    inputname(1) ' = ' symbolic(obj)])
  else
    disp([inputname(1) ' is an empty monomial object.'])
  end
elseif( sz(1) > 1 & sz(2) > 1 )
  disp([inputname(1),' is a matrix of monomials ' ...
        '(with size ' num2str(sz(1)) ' by ' num2str(sz(2)) ').' ...
       char(10) 'Index to access individual monomials.'])
else
  disp([inputname(1),' is a vector of monomials ' ...
       '(with size ' num2str(sz(1)) ' by ' num2str(sz(2)) ').' ...
       char(10) 'Index to access individual monomials.'])
end
disp(' ');
