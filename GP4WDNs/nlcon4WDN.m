% create file nlcon.m for nonlinear constraints
function [c,ceq] = nlcon4WDN(XX,d,Num_XX0)
    % input :
    %         Tao 8 * 1  = [z(k);x(k)] = [h1;h2;...;h8]
    %         mu 9 * 1   = [w(k);u(k)] = [ q1;q2;...;q9]
    %         XX = [Tao;mu]
    % output:
    %         inequality constraint: c
    %         equality constraint: ceq
    % inequality constraint is null
    c = [];
    ceq = [];
    Hp = Constants4WDN.Hp;
    L_pipe = d.getLinkLength; % ft
    D_pipe = d.getLinkDiameter; % inches ; be careful, pump's diameter is 0
    C_pipe = d.getLinkRoughnessCoeff; % roughness of pipe
    % be careful, pump's diameter is 0, we need to exempt pump from pipe
    L_pipe = L_pipe(1:8);
    D_pipe = D_pipe(1:8)/12;
    C_pipe = C_pipe(1:8);
    
    %XX = [ Head(1,7) Head(1,1:6) Head(1,8) Flows(1,1:9) Head(2,7) Head(2,1:6) Head(2,8) Flows(2,1:9)]';
    % Headloss_pipe
    %     q = Flows(t,1:8); % GPM
    %     q(1)      q(2)     q(3)      q(4)    q(5)    q(6)     q(7)      q(8) 
    %q = [mu(3,:)' mu(4,:)' mu(5,:)' mu(6,:)' mu(7,:)' mu(8,:)' mu(9,:)' mu(1,:)']; % 73 * 8
    %
    P_x = -1 * [
    0;
    0;
    0;
    0;
    0;
    0;
    0;
    -1;
    0;];
    P_z = -1 * [
        0 1 -1 0 0 0 0;
        0 0 1 -1 0 0 0;
        0 0 0 1 -1 0 0;
        0 0 1 0 0 0 -1;
        0 0 0 1 0 -1 0;
        0 0 0 0 0 -1 1;
        0 0 0 0 -1 1 0;
        0 0 0 0 0 0 1;% h7 - h8
        1 -1 0 0 0 0 0];% h1 - h2
    Pi = [P_z P_x]; % 9 * 8

    assert(Hp>=1, ['Hp = ' num2str(Hp) '<1 is impossible!']);
    baseIndex = 2;
    for i = 0:(Hp-1)
        q =  [XX(K_th_XX_index(baseIndex+i,'w_k',Num_XX0));XX(K_th_XX_index(baseIndex+i,'u_k',Num_XX0))]';
        q_pipe = q(1:8)/448.8325660485;
        q_pipe_abs = abs(q_pipe); % make sure q_pipe is postive number.
        q0verc = q_pipe.*(q_pipe_abs.^(0.852)./C_pipe.^(1.852));
        Headloss_pipe = 4.727 * L_pipe.*q0verc./(D_pipe.^(4.871));
        % Headloss_pump
        speed = XX(K_th_XX_index(baseIndex+i,'speed_k',Num_XX0));
        q_pump = q(9);
        Headloss_pump = -speed^2*(200 - 0.0001389*(q_pump/speed).^2); %73 * 1
        headloss_all = [Headloss_pipe Headloss_pump];
        Tao = [XX(K_th_XX_index(baseIndex+i,'z_k',Num_XX0));XX(K_th_XX_index(baseIndex+i,'x_k',Num_XX0))];
        %head_loss_i_th = Pi * Tao;
        ceq_i_th = Pi * Tao + headloss_all';% [headloss_all(:,8:9) headloss_all(:,1:7)]' ;
        ceq = [ceq;ceq_i_th];
    end
    %VERIFY
end

    



