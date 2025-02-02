function [CumD,GDPLoss,SimData,SimN,SimICU] = Covid_projection2(InitialValues,alpha,beta,gamma,delta,V,h,k,POP0,hconstant,ICU_inflow_avg,gamma_ICU,delta_ICU)
% Simulation for cumulative deaths and output loss given parameters

% - InitialValues = 1-by-4 vector of initial values: S, I, R, D
% - alpha, beta, gamma, delta and V are T-by-1 vectors of time-varying
% parameters
% - h, k are scalar parameters
% - T is a simulation period

T = length(alpha);
SimData = zeros(T+1,length(InitialValues)-1);
SimData(1,:) = InitialValues(1:4);
SimN = zeros(T,1);
SimICU = zeros(T+1,1);
SimICU(1) = InitialValues(5);
for i = 1:T
    if hconstant == 0
        SimN(i) = ((1 + h*alpha(i))^k)*beta(i)*SimData(i,1)*SimData(i,2)*(1/POP0);
    elseif hconstant == 1
%         SimN(i) = ((h(1)+h(2)*alpha(i))^k)*beta(i)*SimData(i,1)*SimData(i,2)*(1/POP0);
        SimN(i) = ((1+(h(2)/h(1))*alpha(i))^k)*beta(i)*SimData(i,1)*SimData(i,2)*(1/POP0);
    end
    SimData(i+1,1) = SimData(i,1) - SimN(i) - V(i);
    SimData(i+1,2) = SimData(i,2) + SimN(i) - gamma(i)*SimData(i,2) - delta(i)*SimData(i,2);
    SimData(i+1,3) = SimData(i,3) + gamma(i)*SimData(i,2) + V(i);
    SimData(i+1,4) = SimData(i,4) + delta(i)*SimData(i,2);
    SimICU(i+1) = max(0, SimICU(i) + ICU_inflow_avg*delta_ICU(i)*SimData(i,2) - gamma_ICU*SimICU(i) - delta(i)*SimData(i,2));
end
CumD = SimData(:,4);  % Cumulative deaths during the simulation period
GDPLoss = mean(alpha);              % Average output loss during the simulation period





