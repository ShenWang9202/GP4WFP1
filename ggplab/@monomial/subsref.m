function B = subsref(A,S)
% MONOMIAL/SUBSREF method
%

switch length(S)     % number of subscripting levels
  case 1             % one subscript reference
    switch S.type
      case '.'
        switch S.subs
        case 'gpvars'
          B = A.gpvars;
        case 'c'
          B = A.c;
        case 'a'
          B = A.a;
        otherwise
          error('Monomial indexation error');
        end
      case '()'
        B = A(S.subs{:});
      otherwise
        error(['Monomial indexation with ' S.type ' not supported']);
    end
  case 2             % two subscript references
    if ( strcmp(S(1).type,'.') & strcmp(S(1).subs,'a') & strcmp(S(2).type,'()') )
      B = A.a(S(2).subs{:});
    elseif ( strcmp(S(1).type,'.') & strcmp(S(1).subs,'gpvars') & ... 
             strcmp(S(2).type,'{}') )
      B = A.gpvars{S(2).subs{:}};
    else
      error('Monomial indexation not supported.');
    end
  otherwise
    error(['Unknown monomial subscript index.']);
end

