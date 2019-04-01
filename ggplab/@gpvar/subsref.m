function B = subsref(A,S)
% GPVAR/SUBSREF method for GP variable objects.
%

switch length(S) % number of subscripting levels
  % one subscripting level
  case 1
    switch S.type
      case '.'
        switch S.subs
          case 'label'
            B = A.label;
          otherwise
            error('GP variable (gpvar) indexation error.');
        end
      case '()'
        B = A(S.subs{:});
      otherwise
        error(['GP variable indexation with ' S.type ' is not supported.']);
    end
  % two subscripting levels
  case 2 
    if ( strcmp(S(1).type,'()') && strcmp(S(2).type,'.') )
      B = A(S(1).subs{:}).label;
    end
  otherwise
    error('GP variable indexation with this many levels is not allowed.');
end 
