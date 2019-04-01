function obj = gpvar(varargin)
% GPVAR is a GP variable class constructor.
%
%	You can define multiple scalar GPVARs using:
%	  gpvar x y z 
%
%	You can define GPVAR arrays using:
%	  gpvar x(10)
%	which creates array of 10 gpvars with (print) labels x_1,...,x_10.
%
%	You can also make assignments such as:
%	  gpvar x(10) y(100) z
%
%	Another calling sequence for GP variable (or array) definition is:
%	  x = gpvar(1,'x')
%	  x = gpvar(100,'x')
%	where you need to specify variable label as a string.
%

if nargin == 0
  % no argument: do not create anything 
  help gpvar 
  return
end

% check if have multiple scalar declarations or array
if ischar(varargin{1})
  for k = 1:length(varargin)

    varstr = varargin{k};

    % parse for array declarations
    match = find( varstr == '(' );
    if isempty( match )
      varname = varstr;
      varsize = 1;
    elseif( varstr( end ) ~= ')' )
      error(['Invalid variable specification: ' varstr]);
    else
      varname = varstr( 1 : match(1)-1 );
      varsize = varstr( match(1)+1 : end-1 );
      varsize = evalin('caller', varsize);
      
      if ~isnumeric( varsize )
        error('gpvar array dimension should be a numeric value.');
      end
    end

    if ~isvarname( varname )
      error(['Not a valid variable name: ' varname]);
    end
    assignin('caller', varname, gpvar(varsize,varname));

  end
  return
end

% GP variable construction
switch nargin

  case 1
    % copy constructor
    if isa(varargin{1},'gpvar')
      obj = varargin{1};
      return
    end

    % if a numeric value is passed to gpvar, then give an error 
    if isnumeric(varargin{1})
      error(['Cannot cast a numeric value into a GP variable.' ...
             char(10) char(10) ...
             'You can do that with monomials, posynomials, and generalized ' ...
             'posynomials.' char(10) ...
             'If you are building an array of GP functions, then cast your '...
             'single GP variables' char(10) ...
             'as monomials (e.g., if x is a gpvar, use x^1 or monomial(x)).']);
    end

  case 2
    N = varargin{1};
    if( N == 1 ) % create a scalar GP variable
      obj.label = varargin{2};
      obj = class(obj,'gpvar');
    else % create a GP array
      if( N >= 1000000 )
        error(['You are not allowed to create an array with a million ' ...
                'or more GP variables.']);
      end
      obj = [];
      for n = 1:N
        if(     n < 10  ),     numstr = ['00000' num2str(n)];
        elseif( n < 100 ),     numstr = ['0000'  num2str(n)];
        elseif( n < 1000 ),    numstr = ['000'   num2str(n)];
        elseif( n < 10000 ),   numstr = ['00'    num2str(n)];
        elseif( n < 100000 ),  numstr = ['0'     num2str(n)];
        else                   numstr = num2str(n);
        end
        obj(n).label = [varargin{2} '__array__' numstr];
      end  
      obj = obj'; % make it a vector array
      obj = class(obj,'gpvar');
    end 

  otherwise
    error('Wrong number of input arguments')
end
