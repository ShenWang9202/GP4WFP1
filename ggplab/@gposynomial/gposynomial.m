function obj = gposynomial(varargin)
% GPOSYNOMIAL is a generalized posynomial class constructor.
%
%	X = GPOSYNOMIAL creates an empty generalized posynomial object X.
%
%	Generalized posynomials can be formed from positive constants,
%	GP variables, monomials, posynomials, and other generalized 
%	posynomials using addition, multiplication, positive powers, 
%	and maximum (using MAX function).
%	You can also divide a generalized posynomial by a monomial.
%
%	Generalized posynomial is treated as a tree with the operation
%	at the root node and arguments as the tree leaves.
%
superiorto('gpvar', 'monomial', 'posynomial');

% create an empty generalized posynomial
if nargin == 0  
  obj.op     = [];
  obj.args   = {};
  obj.gpvars = {};
  obj = class(obj,'gposynomial');
  return
end

if nargin == 1 % one argument 
  % copy to a new object if genposynomial
  if( isa(varargin{1},'gposynomial') )
    obj = varargin{1};

  % cast posynomial to a genposynomial
  elseif( isa(varargin{1},'posynomial') ) 
    obj.op     = 'obj';              % gposy's operation (obj, +, *, ^, max)
    obj.args   = {varargin{1}};      % gposy's arguments
    obj.gpvars = varargin{1}.gpvars; % gposy's gpvars
    obj = class(obj,'gposynomial');

  % cast monomial to a genposynomial
  elseif( isa(varargin{1},'monomial') ) 
    obj.op     = 'obj';              % gposy's operation (obj, +, *, ^, max)
    obj.args   = {varargin{1}};      % gposy's arguments
    obj.gpvars = varargin{1}.gpvars; % gposy's gpvars
    obj = class(obj,'gposynomial');

  % under obj flag can only have a monomial, posymonial, or generalized posynomial
  elseif( isa(varargin{1},'gpvar') ) 
    % first cast to monomial
    obj = gposynomial(monomial(varargin{1}));

  elseif( isnumeric(varargin{1}) )
    % first cast to monomial
    obj = gposynomial(monomial(varargin{1}));

  else
    error('Uncompatible object passed to the generalized posynomial constructor.');
  end
  return
end

if nargin > 1
  % create gposynomial out of input arguments
  obj.op   = varargin{1};     % gposy's operation (obj, +, *, ^, max)
  obj.args = varargin{2:end}; % gposy's arguments
  obj.gpvars = {};            % gposy's gpvars
  
  for k = 1:length(obj.args)

    % the input list (now obj.args) has to be a list of scalar gp objects
    if( length(obj.args{k}) > 1 )
      error(['All GP objects have to be scalars when creating a generalized posynomial' ...
            char(10) 'using an input list of several GP objects.']);
    end

    if isa(obj.args{k}, 'gpvar')
      obj.gpvars = union({obj.args{k}.label}, obj.gpvars);
    elseif isa(obj.args{k}, 'monomial')
      obj.gpvars = union(obj.args{k}.gpvars, obj.gpvars);
    elseif isa(obj.args{k}, 'posynomial')
      obj.gpvars = union(obj.args{k}.gpvars, obj.gpvars);
    elseif isa(obj.args{k}, 'gposynomial')
      obj.gpvars = union(obj.args{k}.gpvars, obj.gpvars);
    end
  end
  obj = class(obj,'gposynomial');
end
