function display(obj)
% GPOSYNOMIAL display method
%
disp(' ');

sz = size(obj);
if( sz(1) == 1 & sz(2) == 1 )   % scalar gposynomial object
  if strcmp( obj.op, 'obj' )
    str = [inputname(1),' is a generalized posynomial with a single term.'];
  else
    str = [inputname(1),' is a generalized posynomial with <'];
    if isnumeric(obj.op)
      str = [str '^' num2str(obj.op)];
    else
      str = [str obj.op];
    end
    str = [str '> operation and ' num2str(length(obj.args)) ' argument(s).'];
  end
  disp(str);
  disp(' ');
  disp([inputname(1) ' = ' symbolic(obj)])
elseif( sz(1) > 1 & sz(2) > 1 )
  disp([inputname(1),' is a matrix of generalized posynomials ' ...
        '(with size ' num2str(sz(1)) ' by ' num2str(sz(2)) ').' ...
       char(10) 'Index to access individual generalized posynomials.'])
else
  disp([inputname(1),' is a vector of generalized posynomials ' ...
       '(with size ' num2str(sz(1)) ' by ' num2str(sz(2)) ').' ...
       char(10) 'Index to access individual generalized posynomials.'])
end
disp(' ');
