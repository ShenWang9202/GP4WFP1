function B = subsref(A,S)
% GPOSYNOMIAL/SUBSREF method
%

switch length(S)     % number of subscripting levels

  case 1             % one subscript reference
    switch S.type
      case '.'
        switch S.subs
          case 'op',     B = A.op;
          case 'args',   B = A.args;
          case 'gpvars', B = A.gpvars;
          otherwise
            error('Generalized posynomial indexing error.');
        end
      case '()'
        B = A(S.subs{:});
      otherwise
        error(['Generalized posynomial indexing with ' S.type ' is not supported.']) ;
    end

  case 2             % two subscript references
    if ( strcmp(S(1).type,'.') & strcmp(S(1).subs,'args') & strcmp(S(2).type,'{}') )
      B = A.args(S(2).subs{:});
      B = B{:};
    else
      error('This type of generalized posynomial indexing is not supported.');
    end
  otherwise
    error(['Unknown generalized posynomial subscript index.']);
end
