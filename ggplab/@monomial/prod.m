function p = prod(varargin)
% MONOMIAL/PROD Implements product function for monomial objects.
% 
% P = PROD(X) is the product of the elements of the vector X.
% If X is a matrix, P is a row vector with the product over each column.
%

sz = size(varargin{1});

if( length(varargin) == 1 )
  % have a single input or an array input or a matrix input
  if( max(sz) == 1 ) 
    % single input, return it back
    p = varargin{1};
  elseif( sz(1) == 1 || sz(2) == 1 )
    % have a row or a column array
    p = monomial(1);
    array = varargin{1};
    for k = 1:length(array)
      p = p*array(k);
    end
  else
    % have a matrix (default is to take product over columns)
    mtx = varargin{1};
    for k = 1:sz(2)
      col = mtx(:,k); 
      p(1,k) = prod(col);
    end
  end
else
  % have an input list of scalar monomial objects
  p = monomial(1);
  for k = 1:length(varargin)
    p = p*varargin{k};
  end
end
