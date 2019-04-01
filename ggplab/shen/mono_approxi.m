function f_mono = mono_approxi(d,X0,W)
    %W = sym('X',[20 1]);
    solution = [  700.0000;
        851.904;
        849.510;
        844.524;
        841.667
        844.307;
        846.024;
        838.8;
        618.161;
        160.015;
        55.584;
        383.145;
        29.432;
        89.985;
        44.416;
        293.161;
        613.775;
        1.011;
        100000;];
    [f_cofficient, a_matirx] =  generate_mono_approxi_coffi2(d,X0);
    [m,n] = size(a_matirx);
    f_mono = [];
    for i = 1:m
        monomial_shen = 1.0;
        for j = 1:n
            monomial_shen = monomial_shen * ((W(j)/X0(j))^a_matirx(i,j));
        end
        f_mono = [f_mono;f_cofficient(i) * monomial_shen] ;
    end
    %double(subs(f_mono,W,solution))
end
