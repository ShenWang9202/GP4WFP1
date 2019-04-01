function r = max(varargin)
% GPVAR/MAX implements max function for GP variables.
% 
% For matrices, MAX() returns a row vector formed by 
% the maximum operation over each column.
%

sz = size(varargin{1});

if( length(varargin) == 1 )
  % have a single input or an array input or a matrix input
  if( max(sz) == 1 ) 
    % single input, return it back
    r = varargin{1};
  elseif( sz(1) == 1 || sz(2) == 1 )
    % have an array (a row or a column vector), convert it to a cell
    r = gposynomial('max',num2cell(varargin{1}));
  else
    % have a matrix (default is to max over columns)
    mtx = varargin{1};
    for k = 1:sz(2)
      col = mtx(:,k); 
      r(1,k) = gposynomial('max',num2cell(col));
    end
  end
else
  % have an input list
  r = gposynomial('max',varargin);
end
