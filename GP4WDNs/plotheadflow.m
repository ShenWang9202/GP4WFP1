headindex = IndexInVar.JunctionHeadIndex;

headiterations = X(headindex,:);
[m,n] = size(headiterations);
h = figure;
for i = 1:m
    plot(1:n,headiterations(i,:));
    hold on
end

flowindex = IndexInVar.PipeFlowIndex;

flowiterations = X(flowindex,:);
[m,n] = size(flowiterations);
for i = 1:m
    plot(1:n,flowiterations(i,:));
end

delta_h = headiterations(6,:) - X(8,:);
L_pipe = 7000;
C_pipe  = 100;
GPM2CFS = 448.8325660485;
mm2m = 1000;
Volum_conversion = GPM2CFS;
D_pipe = 10;
feet2inch = 12;
diameter_conversion = feet2inch;
D_pipe = D_pipe/diameter_conversion;
Headloss_pipe_R = 4.727 * L_pipe./((C_pipe*Volum_conversion).^(1.852))./(D_pipe.^(4.871));

qd = (delta_h./Headloss_pipe_R).^(1/1.852)
realqd = real(qd);

h = figure;
plot(1:n,X(17,:));
hold on
plot(1:n,realqd);

