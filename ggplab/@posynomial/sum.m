function s = sum(varargin)
% POSYNOMIAL/SUM implements sum function for posynomials.
% 
% If input is a matrix, SUM gives a row vector with the sum over each column.
%

sz = size(varargin{1});

if( length(varargin) == 1 )
  % have a single input or an array input or a matrix input
  if( max(sz) == 1 ) 
    % single input, return it back
    s = varargin{1};
  elseif( sz(1) == 1 )
    % have a row array
    s = varargin{1}*ones(sz(2),1);
  elseif( sz(2) == 1 )
    % have a column array
    s = ones(1,sz(1))*varargin{1};
  else
    % have a matrix (default is to sum over columns)
    mtx = varargin{1};
    for k = 1:sz(2)
      col = mtx(:,k); 
      s(1,k) = ones(1,sz(1))*col;
    end
  end
else
  % have an input list of scalar GP objects
  s = posynomial;
  for k = 1:length(varargin)
    s = s + varargin{k};
  end
end
