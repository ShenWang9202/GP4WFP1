m2feet = 3.28084;
LPS2GMP = 15.850372483753;
feet2inch = 12;
GPM2CFS = 448.8325660485;
mm2m = 1000;
mm2inch = 0.0393701;
L2cube_m = 1000;
base = 1.00000001;
L_pipe = d.getLinkLength *m2feet; % ft
D_pipe = d.getLinkDiameter *mm2inch; % inches ; be careful, pump's diameter is 0
C_pipe = d.getLinkRoughnessCoeff; % roughness of pipe
% be careful, pump's diameter is 0, we need to exempt pump from pipe
FlowUnits = {'GPM'};
%FlowUnits = d.getFlowUnits;
if(strcmp('LPS',FlowUnits{1}))
    diameter_conversion = mm2m;
    Volum_conversion = L2cube_m;
end

if(strcmp('GPM',FlowUnits{1}))
    diameter_conversion = feet2inch;
    Volum_conversion = GPM2CFS;
end
FlowUnits = d.getFlowUnits;
if(strcmp('LPS',FlowUnits{1}))
    diameter_conversion = mm2m;
    Volum_conversion = L2cube_m;
end

if(strcmp('GPM',FlowUnits{1}))
    diameter_conversion = feet2inch;
    Volum_conversion = GPM2CFS;
end

PipeIndex = d.getLinkPipeIndex;
L_pipe = L_pipe(PipeIndex);
D_pipe = D_pipe(PipeIndex)/diameter_conversion;
C_pipe = C_pipe(PipeIndex);
if(strcmp('GPM',FlowUnits{1}))
    Headloss_pipe_R = 4.727 * L_pipe./((C_pipe*Volum_conversion).^(1.852))./(D_pipe.^(4.871));
end
% get the R cofficient for pipe 1 to 8
if(strcmp('LPS',FlowUnits{1}))
    Headloss_pipe_R = 10.66 * L_pipe./((C_pipe*Volum_conversion).^(1.852))./(D_pipe.^(4.871));
end

C_estimate = [];
q_pipe = -100:1:100;
[~,n] = size(q_pipe);
[~,m] = size(Headloss_pipe_R);
for i = 1:m
    c_estimate = [];
    for j = 1:n
        c_estimate = [c_estimate base^((Headloss_pipe_R(i)*abs(q_pipe(j))^(0.852)-1)*q_pipe(j))];
        %c_estimate = [c_estimate;base^((Headloss_pipe_R(i)*abs(q_pipe(i))^(0.852)))];
    end
    C_estimate = [C_estimate;c_estimate];
end
h = figure;
for i = 1:m
    plot(q_pipe,C_estimate(i,:),'LineWidth',2);
    hold on
end
title(strcat('base=',num2str(base,10)))
xlabel('Flow','FontSize',12)
ylabel('C^{estimate}','FontSize',12)
saveas(h,sprintf('C_estimate_base_%s.png',num2str(base,10)))
close(h)
