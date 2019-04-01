function B = subsref(A,S)
% GPCONSTRAINT/SUBSREF method
%

% one subscripting level
if length(S) == 1 
  switch S.type
  case '.'
    switch S.subs
      case 'lhs'
        B = A.lhs;
      case 'rhs'
        B = A.rhs;
      case 'type'
        B = A.type;
      case 'gpvars'
        B = A.gpvars;
      otherwise
        error('GP constraint indexing error');
    end
  case '()'
    B = A(S.subs{:});
  otherwise
    error(['GP constraint indexing with ' S.type ' is not supported']) ;
  end
% two level subscripting
elseif length(S) == 2
  if ( strcmp(S(1).type,'()') && strcmp(S(2).type,'.') )
    switch S(2).subs
      case 'lhs'
        B = A(S(1).subs{:}).lhs;
      case 'rhs'
        B = A(S(1).subs{:}).rhs;
      case 'type'
        B = A(S(1).subs{:}).type;
      case 'gpvars'
        B = A(S(1).subs{:}).gpvars;
      otherwise
        error('GP constraint indexing error');
    end
  end
else
  error('Such GP constraint indexing is not supported');
end  
