function B = subsref(A,S)
% GPPROBLEM/SUBSREF method
%

switch length(S) % number of subscripting levels

  case 1 % one subscript reference
    switch S.type
    case '.'
      switch S.subs

      case 'status',    B = A.status;
      case 'flag',      B = A.flag;
      case 'type',      B = A.type;

      case 'gpvars',           B = A.gpvars;
      case 'new_gpvars',       B = A.new_gpvars;
      case 'new_gpvars_count', B = A.new_gpvars_count;

      case 'solution',  B = A.solution;

      case 'obj',       B = A.obj;
      case 'std_obj',   B = A.std_obj;
      case 'obj_value', B = A.obj_value;

      case 'constr',       B = A.constr;
      case 'constr_value', B = A.constr_value;
      case 'constr_dual',  B = A.constr_dual;

      case 'new_constr',   B = A.new_constr;

      case 'std_ineq',  B = A.std_ineq;
      case 'std_eq',    B = A.std_eq;

      case 'A',         B = A.A;
      case 'b',         B = A.b;
      case 'szs',       B = A.szs;
      case 'G',         B = A.G;
      case 'h',         B = A.h;

      case 'nu',        B = A.nu;
      case 'mu',        B = A.mu;
      case 'lambda',    B = A.lambda;

      otherwise
        error('GP problem indexing error.');
      end
    otherwise
      error(['GP problem indexing with ' S.type ' not supported.']) ;
    end

  case 2 % two subscript references
    if( strcmp(S(1).type,'.') & strcmp(S(1).subs,'constr') & ...
        strcmp(S(2).type,'()') )
      B = A.constr(S(2).subs{:});

    elseif( strcmp(S(1).type,'.') & strcmp(S(1).subs,'std_ineq') & ...
            strcmp(S(2).type,'{}') )
      B = A.std_ineq(S(2).subs{:});
      B = B{:};

    elseif( strcmp(S(1).type,'.') & strcmp(S(1).subs,'std_eq') & ...
            strcmp(S(2).type,'{}') )
      B = A.std_eq(S(2).subs{:});
      B = B{:};

    elseif( strcmp(S(1).type,'.') & strcmp(S(1).subs,'new_constr') & ...
            strcmp(S(2).type,'{}') )
      B = A.new_constr(S(2).subs{:});
      B = B{:};

    elseif( strcmp(S(1).type,'.') & strcmp(S(1).subs,'new_constr') & ...
            strcmp(S(2).type,'{}') )
      B = A.new_constr(S(2).subs{:});
      B = B{:};

    else
      error('This type of GP problem indexing is not supported.');
    end

  case 3 % three subscript references
    if( strcmp(S(1).type,'.') & strcmp(S(1).subs,'constr') & ...
        strcmp(S(2).type,'()') & ...
        strcmp(S(3).type,'.') & strcmp(S(3).subs,'dual') )
      B = 77;
      % B = A.dual(S(2).subs{:});

    elseif( strcmp(S(1).type,'.') & strcmp(S(1).subs,'constr') & ...
        strcmp(S(2).type,'()') & ...
        strcmp(S(3).type,'.') & strcmp(S(3).subs,'value') )
      B = logical(1);
      % B = A.dual(S(2).subs{:});

    else
      error('This type of GP problem indexing is not supported.');
    end

  otherwise
    error(['Unknown GP problem subscript index.']);
end
