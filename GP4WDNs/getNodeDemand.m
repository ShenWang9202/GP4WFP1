%function Node_Demand = getNodeDemand(k,Demand,CurrentHead,ReferenceHead)
function Actual_Node_Demand_array = getNodeDemand(k,d,Hp)
    % we need to get the node demand ahead of time.
    % The demand of tank should be got each iteration according to the
    % reference you set. For example, currentHead = 834, the reference head
    % = 839. Thus, the Volume changed during a period of time for tank is (839 - 834) * Sec = 5 * pi * d^2
    % /4 (feet^3), (head = Volume/Sec + E_i).  Now we need to convert volume/time into GPM,
    % Assume that, we would like to achieve the goal in a hour, so the
    %
    % volume per hour = 5 * pi * d^2 /4 / 1 (feet^3/hour)
    % Gallons per minute = volume per hour * 0.124675325
    
    %input k-th, return the demand from k+1 to k+Hp; for example when k =
    %1, prediction horizon = 2, this function will return deamnd at k=2,3;
    % k is the step, which start from 1 to 145, time = 0:0.5:72;
    Actual_Node_Demand_array = [];
    for step = k+1:(k+Hp)
        time = (step-1)/2;
        index = floor(mod(time,24)/6)+1;
        Demand_Multiplier = d.getPattern;
        Node_Demand = d.getNodeBaseDemands{1};
        Actual_Node_Demand = Demand_Multiplier(index) * Node_Demand;%GPM
        Actual_Node_Demand_array = [Actual_Node_Demand_array;Actual_Node_Demand];
    end

    Actual_Node_Demand_array = Actual_Node_Demand_array(1:Hp,1:6);
%     hour = 3;
%     TankDemand4NextHour = (ReferenceHead - CurrentHead) * pi * 60^2 * 0.25 / hour * 0.124675325;
%     Node_Demand = [Demand(k,1:6) TankDemand4NextHour]; % only node 2 - 7 and node 8 (tank), node 1 is the reservior, no need demand.
 end
