function display(obj)
% POSYNOMIAL display method
%
disp(' ');

sz = size(obj);
if( sz(1) == 1 & sz(2) == 1 )   % scalar posynomial object
  if( obj.mono_terms == 0 )
    disp([inputname(1) ' is an empty posynomial object, ' inputname(1) ' = 0'])
  else
    disp([inputname(1),' is a posynomial with ', num2str(obj.mono_terms), ...
          ' monomial terms' ])
    disp(' ');
    disp([inputname(1) ' = ' symbolic(obj)])
  end
elseif( sz(1) > 1 & sz(2) > 1 )
  disp([inputname(1),' is a matrix of posynomials ' ...
        '(with size ' num2str(sz(1)) ' by ' num2str(sz(2)) ').' ...
       char(10) 'Index to access individual posynomials.'])
else
  disp([inputname(1),' is a vector of posynomials ' ...
       '(with size ' num2str(sz(1)) ' by ' num2str(sz(2)) ').' ...
       char(10) 'Index to access individual posynomials.'])
end
disp(' ');
