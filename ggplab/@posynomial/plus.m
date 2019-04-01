function r = plus(obj1, obj2)
% POSYNOMIAL/PLUS  Implements '+' for posynomial objects.
%
MERGE_FLAG = 1; % flag to control if we want to combine the same monomials
                % in the posynomial sum (if 1) or not (if 0)
                % merging is a very costly operation (slows the whole system)
                % but by default it should be on (i.e., MERGE_FLAG = 1) 
                
sz1 = size(obj1); sz2 = size(obj2);

% adding two posynomials together (to get another posynomial)
if( length(obj1) == 1 & length(obj2) == 1 )
  obj1 = posynomial(obj1);
  obj2 = posynomial(obj2);

  if( MERGE_FLAG == 0 )
    % do not merge posynomials
    r = posynomial;
    r.mono_terms = obj1.mono_terms + obj2.mono_terms;
    r.monomials = { obj1.monomials{:} obj2.monomials{:} };
    % r.gpvars = union(obj1.gpvars, obj2.gpvars);
    r.gpvars = { obj1.gpvars{:} obj2.gpvars{:} };

    % check for empty monomials and eliminate them (e.g. 0*x + 0*y)
    s = r;
    s_monos = s.monomials;
    r = posynomial;
    for k = 1:s.mono_terms
      if( ~isempty(s_monos{k}.c) )
        r.mono_terms = r.mono_terms + 1;
        % r.gpvars = union(r.gpvars, s_monos{k}.gpvars);
        r.gpvars( end+1 : end+length(s_monos{k}.gpvars) ) = s_monos{k}.gpvars;
        r.monomials{r.mono_terms} = s_monos{k};
      end
    end

  else
    % add posynomials but merge the same monomials
    r = posynomial;
    r.mono_terms = obj1.mono_terms;
    r.monomials = obj1.monomials;
    r.gpvars = union(obj1.gpvars, obj2.gpvars);

    % check for duplicate monomials and eliminate them
    for i = 1:obj2.mono_terms
      merge_flag = 0;
      for j = 1:r.mono_terms
        if( merge_flag == 0 & isequal(obj2.monomials{i}, r.monomials{j}) )
          % merge monomials together in the posynomial sum
          merge_mono = r.monomials{j};
          obj2_mono = obj2.monomials{i};
          % be careful with empty monomials (zeros) since [] + double = []
          if( isempty(obj2_mono.c) )
            c = merge_mono.c;
          else
            c = merge_mono.c + obj2_mono.c;
          end
          r.monomials{j} = monomial(merge_mono.gpvars, c, merge_mono.a);
          merge_flag = 1;
        end
      end 
      if( merge_flag == 0 )
        r.mono_terms = r.mono_terms + 1;  
        r.monomials{end+1} = obj2.monomials{i};
      end
    end

    % check for empty monomials and eliminate them (e.g. 0*x + 0*y)
    s = r;
    s_monos = s.monomials;
    r = posynomial;
    for k = 1:s.mono_terms
      if( ~isempty(s_monos{k}.c) )
        r.mono_terms = r.mono_terms + 1;
        r.gpvars = union(r.gpvars, s_monos{k}.gpvars);
        r.monomials{r.mono_terms} = s_monos{k};
      end
    end

  end % if MERGE_FLAG

  return;

end

% adding two compatible vectors or matrices of posynomials
if( sz1(1) == sz2(1) & sz1(2) == sz2(2) )
  for i = 1:sz1(1)
    for j = 1:sz1(2)
      r(i,j) = obj1(i,j) + obj2(i,j);
    end
  end
else
  error(['Cannot add vectors or matrices with incompatible dimensions.'])
end
