function display(obj)
% GPVAR display method
%
disp(' ');

sz = size(obj);
if( sz(1) == 1 & sz(2) == 1 )   % scalar GP var
  disp([inputname(1),' is a scalar GP variable.'])
elseif( sz(1) > 1 & sz(2) > 1 ) % matrix of GP vars
  disp([inputname(1),' is a matrix of GP variables ' ...
        '(with size ' num2str(sz(1)) ' by ' num2str(sz(2)) ').'])
else
  disp([inputname(1),' is a vector of GP variables ' ...
       '(with size ' num2str(sz(1)) ' by ' num2str(sz(2)) ').'])
end
disp(' ');
