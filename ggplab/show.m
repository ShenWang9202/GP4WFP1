function show(obj)
% SHOW 	Pretty display for GP objects.
%
%	SHOW(X) symbolically displays a scalar GP object X, or 
%	a whole array X of GP objects, or a matrix X of GP objects.
%

sz = size(obj);

if( sz(1) == 1 && sz(2) == 1 )    % obj is a scalar object
  disp(['Display for a scalar object:'])
  display(obj);

elseif( sz(1) > 1 && sz(2) == 1 ) % obj is a column array 
  disp(['Display for a column vector with ' num2str(sz(1)) ' elements: ' char(10)])
  for k = 1:sz(1)
    disp(['row ' num2str(k) ': ' symbolic( obj(k) ) char(10)]);
  end

elseif( sz(1) == 1 && sz(2) > 1 ) % obj is a row array 
  disp(['Display for a row vector with ' num2str(sz(2)) ' elements: ' char(10)])
  for k = 1:sz(2)
    disp(['column ' num2str(k) ': ' symbolic( obj(k) ) char(10)]);
  end

else                              % obj is a matrix
  disp(['Display for a matrix with ' num2str(sz(1)) ' by ' num2str(sz(2)) ...
       ' size: ' char(10)])
  for i = 1:sz(1)
    disp(['row ' num2str(i) ': '])
    disp('+++++++++')
    for j = 1:sz(2)
      disp(['column ' num2str(j) ': ' symbolic( obj(i,j) ) char(10)]);
    end
  end
end
