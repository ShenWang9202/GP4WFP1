clc;
clear;
close all;
%% Hydraulic Analysis
% Create EPANET object using the INP file

TestCase  = 6;
%TestCase  = 1;
if(TestCase == 1)
    inpname='AnytownModify.inp';
end
if(TestCase == 2)
    inpname='BWSN_Network_1.inp';
end

if(TestCase == 3)
   inpname='ctown_only_fcv3.inp';
end
if(TestCase == 4)
   inpname='tutorial4price14_copy2tankswei.inp';
   %inpname='tutorial4price19_copy.inp';
end
if(TestCase == 5)
   inpname='Threenodes-gp.inp';
   %inpname='tutorial4price19_copy.inp';
end
if(TestCase == 6)
   inpname='tutorial_lps_prv1.inp';
   %inpname='tutorial4price19_copy.inp';
end

if(TestCase == 17)
    inpname='ctownfcv.inp';
end
if(TestCase == 18)
    inpname='tutorial4price14_valve.inp';
end
if(TestCase == 19)
    inpname='tutorial_lps_prv1.inp';
end

[d,InitialParameter,SettingsNStatus,IndexInVar,...
    MassEnergyMatrix4GP,Variable_Symbol_Table,Solution]=Prepare(inpname,TestCase);

%% Initialize empty matrice for final results.
Demand_known=InitialParameter.Demand_known;
[m,n] = size(Demand_known);
Error_All = cell(n,1);
Relative_Error_All = [];
Final_Error_All = [];
XSolution = [];

M2FT = InitialParameter.M2FT;
LPS2GMP = InitialParameter.LPS2GMP;
NumberofX = IndexInVar.NumberofX;
for i = 1:1
    % initial conditions
    X0 = zeros(IndexInVar.NumberofX,1);
    %     X0(JunctionHeadIndexInVar) = Solution(JunctionHeadIndexInVar,i);
    X0(IndexInVar.ReservoirHeadIndex) = Solution(IndexInVar.ReservoirHeadIndex,i)*M2FT;
    X0(IndexInVar.TankHeadIndex) = Solution(IndexInVar.TankHeadIndex,i)*M2FT;
    X0(IndexInVar.PumpSpeedIndex) = Solution(IndexInVar.PumpSpeedIndex,i);
    %     X0(IndexInVar.PumpFlowIndex) = Solution(IndexInVar.PumpFlowIndex,i)*LPS2GMP;
    %     X0(IndexInVar.PumpFlowIndex) = Solution(IndexInVar.PumpFlowIndex,i)*LPS2GMP;
    %     X0(IndexInVar.ValveFlowIndex) = Solution(IndexInVar.ValveFlowIndex,i)*LPS2GMP;
    X0(IndexInVar.PumpFlowIndex) = InitialParameter.PipeFLowAverage(IndexInVar.PumpFlowIndex)*LPS2GMP;
    X0(IndexInVar.PipeFlowIndex) = InitialParameter.PipeFLowAverage(IndexInVar.PipeFlowIndex)*LPS2GMP;
    X0(IndexInVar.ValveFlowIndex) = InitialParameter.PipeFLowAverage(IndexInVar.ValveFlowIndex)*LPS2GMP;
    % make sure the flow of pump is greater than 0; can not be negative
    %X0(IndexInVar.PumpFlowIndex) = 1;% make sure the flow of pump is greater than 0; can not be negative
    X0
    

    gpvar W(NumberofX)
    gpvar z%
    
    verify = 0;
    X = sym('X',[NumberofX 1]);
    X = [];
    Aux = [];
    base = 1.001;
    X = [X;X0];
    Error = [];
    Iteration_Error = 1000;
    C_estimate = [];
    iter = 0;
    c_estimate_new = [];
    STEP = 1;
    K = [];
    demand = Demand_known(:,i)';
    
    %%
    ValveFlag = SettingsNStatus.ValveStatus(:,i);
    while(Iteration_Error >= 0.01 && iter<=300)
        tic
        DEMAND = base.^demand;
        % SOURCE HEAD
        SOURCE_HEAD =  base.^(X0(IndexInVar.ReservoirHeadIndex));
        % Tank min and max Head
        TANK_HEAD = base.^(X0(IndexInVar.TankHeadIndex));
        %% Flow balance Constraints
        if (verify)
            constraints_flow = FlowConst(X,MassEnergyMatrix4GP.MassMatrixIndexCell,DEMAND,verify,IndexInVar);
        else
            constraints_flow = FlowConst(W,MassEnergyMatrix4GP.MassMatrixIndexCell,DEMAND,verify,IndexInVar);
        end
        %     [m,~] = size(constraints_flow)
        %
        %
        %     if (verify)
        %         f_value = double(subs(constraints_flow,X,base.^(X0)))
        %     else
        %         for j = 1:m
        %             constraints_flow(j)
        %         end
        %     end
        
        
        
        %% Additional Index
        UnchangedConstraints = [];
        % Head in are non-negatvie (pressure are non-negative)
        % Actually they should be greater than the elevations
        
        ind = 1;
        for j = IndexInVar.ReservoirHeadIndex
            UnchangedConstraints = [UnchangedConstraints;
                W(j) == SOURCE_HEAD(ind);];
            ind = ind + 1;
        end
        % fix the head of tank
        ind = 1;
        for j = IndexInVar.TankHeadIndex
            UnchangedConstraints = [UnchangedConstraints;
                W(j) == TANK_HEAD(ind);];
            ind = ind +1;
        end
        
        % TO DO
        % TANK_Min_HEAD = base.^(TankMinimumWaterLevel + TankElevation);
        % TANK_Max_HEAD = base.^(TankMaximumWaterLevel + TankElevation);
        
        % Flow through Pumps are non-negatvie
        ind = 1;
        obj = 0;
        for j = IndexInVar.PumpFlowIndex
            %         UnchangedConstraints = [UnchangedConstraints;
            %              W(j)^(-1) <= 1;];
            if(SettingsNStatus.PumpStatus(ind)==1) % if the pump is open
                UnchangedConstraints = [UnchangedConstraints;
                    W(j)^(-1) <= 1;];
                ind = ind + 1;
                %     else % if the pump is closed.  have to garantee x <= 1 and x == 1 won't show simitanouesly, otherwise no solution
                %         UnchangedConstraints = [UnchangedConstraints;
                %             W(j) == 1;]
            end
            if(SettingsNStatus.PumpStatus(ind)==0)
                % if the pump is closed.  have to garantee x <= 1 and x == 1 won't show simitanouesly, otherwise no solution
                UnchangedConstraints = [UnchangedConstraints;
                    W(j) == 1;];
            end
        end
        
        % fix speed of pump when performing Hydraulic Analysis
        % since we add the pump speed as object (we cannot add constraints like
        % speed ==0), the final speed that is free variable will be 0
        
        % remove speed, not a optimization variable any more.
        ind = 1;
        for j = IndexInVar.PumpSpeedIndex
            if(SettingsNStatus.PumpStatus(ind)==1)
                UnchangedConstraints = [UnchangedConstraints;
                    W(j) == base^(1);
                    ];
                ind = ind +1;
            end
            if(SettingsNStatus.PumpStatus(ind)==0)
                UnchangedConstraints = [UnchangedConstraints;
                    W(j) == base^(0);
                    ];
                ind = ind +1;
            end
        end
        
        UnchangedConstraints = [
            constraints_flow;
            %         constraints_Valve_pressure;
            UnchangedConstraints;
            z <=1;
            ];
        c_estimate_value = [];
        iter = iter + 1;
        % this acceleration will lead to no solution sometimes.
%         if (iter >=5 && STEP >=3)
%             STEP = 0;
%             k = (X(:,iter) - X(:,iter - 2))/2  * 1 ;
%             X0 = k * 3 + X(:,iter);
%             K = [K k];
%         end

        %% Pipe Constraints
        
        if (verify)
            [constraints_Pipe_pressure,c_estimate_pipe] = PressurePipeConst(X,MassEnergyMatrix4GP.EnergyPipeMatrixIndex,X0,base,d,verify,IndexInVar);
        else
            [constraints_Pipe_pressure,c_estimate_pipe] = PressurePipeConst(W,MassEnergyMatrix4GP.EnergyPipeMatrixIndex,X0,base,d,verify,IndexInVar);
        end
        
        %         [m,n] = size(constraints_Pipe_pressure);
        %         if (verify)
        %             f_value = double(subs(constraints_Pipe_pressure,X,base.^(X0)))
        %         else
        %             for j = 1:m
        %                 constraints_Pipe_pressure(j)
        %             end
        %         end
        %
        
        %% Valve Constraints
        ValveIndex = d.getLinkValveIndex;
        constraints_Valve_pressure = [];
        c_estimate_valve = [];
        if ~isempty(ValveIndex)
            ValveTypesString = d.getLinkType(ValveIndex);
            ValveSetting = d.getLinkSettings(ValveIndex);
            NodeElevations = d.getNodeElevations;
            if (verify)
                [constraints_Valve_pressure,c_estimate_valve,ValveFlag] = PressureValveConst(X,MassEnergyMatrix4GP.EnergyValveMatrixIndex,X0,base,NodeElevations,ValveSetting,ValveTypesString,verify,SettingsNStatus.ValveStatus(:,i),ValveFlag,DelataValvePressure,SettingsNStatus.FlowUnits,iter,IndexInVar);
            else
                [constraints_Valve_pressure,c_estimate_valve,ValveFlag] = PressureValveConst(W,MassEnergyMatrix4GP.EnergyValveMatrixIndex,X0,base,NodeElevations,ValveSetting,ValveTypesString,verify,SettingsNStatus.ValveStatus(:,i),ValveFlag,X,SettingsNStatus.FlowUnits,iter,IndexInVar);
            end
        end
        %% Pump constraints
        if (verify)
            constraints_Pump_pressure = PressurePumpConst(X,MassEnergyMatrix4GP.EnergyPumpMatrixIndex,X0,base,verify,SettingsNStatus.PumpStatus,IndexInVar);
        else
            constraints_Pump_pressure = PressurePumpConst(W,MassEnergyMatrix4GP.EnergyPumpMatrixIndex,X0,base,verify,SettingsNStatus.PumpStatus,IndexInVar);
        end
        
        %     [m,n] = size(constraints_Pump_pressure);
        %     if (verify)
        %         X0_change = base.^(X0);
        %         X0_change(IndexInVar.PumpSpeedIndex) = X0(IndexInVar.PumpSpeedIndex);
        %         f_value = double(subs(constraints_Pump_pressure,X,X0_change))
        %     else
        %         for j = 1:m
        %             constraints_Pump_pressure(j)
        %         end
        %     end
        %% solve gp
        obj = 0;
        obj = obj+z;
        % remove speed, not a optimization variable any more.
        % obj = z + sum(W(IndexInVar.PumpSpeedIndex));
        
        constrs = [UnchangedConstraints;
            constraints_Pipe_pressure;
            constraints_Valve_pressure;
            constraints_Pump_pressure;
            ];
        [m,n] = size(constrs);
        m
        disp('constraints');
        for j = 1:m
            constrs(j)
        end
        % solve generalized GP and assign solution to GP variables
        toc
        tic
        [obj_value, solution, status] = gpsolve(obj,constrs);
        obj_value
        toc
        % pick solution out
        Aux_array = cell2mat(solution(1,2));
        W_array = cell2mat(solution(2,2));
        Aux_solution = full(Aux_array);
        W_array = full(W_array);
        %[wm,wn] = size(W_array)
        % remove speed, not a optimization variable any more.
        [m,n] = size(IndexInVar.PumpSpeedIndex);
        Xsolution = mylog(base,W_array(1:end));
        %         Xsolution = mylog(base,W_array(1:end-n));
        %         s = W_array(end-n+1:end,1);
        %         Xsolution = [Xsolution ; s]
        
        c_estimate_value = [c_estimate_value;c_estimate_pipe;c_estimate_valve;];
        C_estimate = [C_estimate c_estimate_value];
        X = [X Xsolution];
        Aux = [Aux Aux_solution];
        X0 = Xsolution;
        Iteration_Error = norm(abs(X(:,end)-X(:,end-1)));
        Error = [Error Iteration_Error];
        STEP = STEP +1;
    end
    
    Error_All{i} = Error;
    
    h = figure;
    
    plot(log10(Error),'LineWidth',2);
    title(strcat('Error for demand ',string(i)),'FontSize', 24)
    xlabel('Iteration','FontSize',16)
    ylabel('log10(Error)','FontSize',16)
    saveas(h,sprintf('D_Error_%d.png',(i)))
    close(h)
    
    h = figure;
    
    plot(C_estimate','LineWidth',2)
    title(strcat('C^{estimate} for demand ',string(i)),'FontSize', 24)
    xlabel('Iteration','FontSize',12)
    ylabel('C^{estimate}','FontSize',12)
    saveas(h,sprintf('D_C_estimate_%d.png',(i)))
    close(h)
    XSolution = [XSolution X(:,end)];
    Final_Error = norm(X(:,end)-Solution(i));
    Final_Error_All = [Final_Error_All Final_Error];
    relative_error = Iteration_Error/norm(Solution(i));
    Relative_Error_All = [Relative_Error_All relative_error];
end
Final_Error_All
Relative_Error_All
%% find the index of error pipes or heads.

i =1;
Solution1 = zeros(size(Solution));
Solution1(IndexInVar.JunctionHeadIndex,i) = Solution(IndexInVar.JunctionHeadIndex,i)*M2FT;
Solution1(IndexInVar.ReservoirHeadIndex,i) = Solution(IndexInVar.ReservoirHeadIndex,i)*M2FT;
Solution1(IndexInVar.TankHeadIndex,i) = Solution(IndexInVar.TankHeadIndex,i)*M2FT;
Solution1(IndexInVar.PumpFlowIndex,i) = Solution(IndexInVar.PumpFlowIndex,i)*LPS2GMP;
Solution1(IndexInVar.PipeFlowIndex,i) = Solution(IndexInVar.PipeFlowIndex,i)*LPS2GMP;
Solution1(IndexInVar.ValveFlowIndex,i) = Solution(IndexInVar.ValveFlowIndex,i)*LPS2GMP;
Solution1(IndexInVar.PumpSpeedIndex,i) = Solution(IndexInVar.PumpSpeedIndex,i);
error =  XSolution - Solution1(:,i);

ErrorSolution = Xsolution(:,1) - Solution1(:,1);
ErrorSolution = abs(ErrorSolution);
Errorindex = find(ErrorSolution >= 20);
VariableErrorIndex = Variable_Symbol_Table(Errorindex);
GP_VS_EPANET  = [XSolution(Errorindex,1),Solution(Errorindex,1)];




