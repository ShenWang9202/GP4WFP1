% create file nlcon.m for nonlinear constraints
function [c,ceq] = nlcon_WDN(Tao,mu,d)
    % input :
    %         Tao 8 * 73  = [x(k);z(k)] = [h8;h1;h2;...;h7]
    %         mu 9 * 73   = [u(k);w(k)] = [q8;q9; q1;q2;...;q7]
    % output:
    %         inequality constraint: c
    %          equality constraint: ceq
    
    % inequality constraint is null
    c = [];
    % Headloss_pipe
    C_pipe = d.getLinkRoughnessCoeff;
    %     q = Flows(t,1:8); % GPM
    %     q(1)      q(2)     q(3)      q(4)    q(5)    q(6)     q(7)      q(8) 
    q = [mu(3,:)' mu(4,:)' mu(5,:)' mu(6,:)' mu(7,:)' mu(8,:)' mu(9,:)' mu(1,:)']; % 73 * 8
    q_abs = abs(q); % make sure q is postive number.
    q0verc = q.*(q_abs.^(0.852)./C_pipe.^(1.852));
    Headloss_pipe = 10.47 * L_pipe.*q0verc./(D_pipe.^(4.8704)); % 73 * 8
    % Headloss_pump
    speed = 1;
    Headloss_pump = -speed^2*(200 - 0.0001389*((mu(2,:)/speed).^2)); %73 * 1
    headloss_all = [Headloss_pipe Headloss_pump];
    % equality constraint 
    
    P_x = -1 * [-1;
            0;
            0;
            0;
            0;
            0;
            0;
            0;
            0];
    P_z = -1 * [0 0 0 0 0 0 1;
            1 -1 0 0 0 0 0;
            0 1 -1 0 0 0 0;
            0 0 1 -1 0 0 0;
            0 0 0 1 -1 0 0;
            0 0 1 0 0 0 -1;
            0 0 0 1 0 -1 0;
            0 0 0 0 0 -1 1;
            0 0 0 0 1 -1 0];
    Pi = [P_x P_z]; % 9 * 8
    
%     x_k = Head(:,8)';  1 * 73
%     z_k = [Head(:,7) Head(:,1:6)]'; 7 * 73
%     Tao_k = [x_k' z_k']'; 8 * 73
    
    ceq = Pi * Tao +  [headloss_all(:,8:9) headloss_all(:,1:7)]' ;
    
    
    
    