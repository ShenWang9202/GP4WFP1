function B = subsref(A,S)
% POSYNOMIAL/SUBSREF method
%

% one subscripting level
if length(S) == 1
  switch S.type
    case '.'
      switch S.subs
        case 'gpvars'
          B = A.gpvars;
        case 'mono_terms'
          B = A.mono_terms;
        case 'monomials'
          B = A.monomials;
        otherwise
          error('posynomial indexing error');
      end
    case '()'
      B = A(S.subs{:});
    otherwise
      error(['(posy indexation with ' S.type ' not supported)']) ;
  end
% two subscripting levels
elseif length(S) == 2
  if ( strcmp(S(1).subs,'monomials') && strcmp(S(2).type,'{}') )
     B = A.monomials{S(2).subs{:}};
  end
else
  error('Such posynomial indexing is not supported');
end
