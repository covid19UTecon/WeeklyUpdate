function [CumD,GDPLoss,alphapath,SimData,SimN,SimERN] = Covid_projection_control_gradual_alt_2(InitialValues,alpha_now,alpha_on,alpha_off,th_on,th_off,th_off2,beta,gamma,delta,V,h,k,POP0,hconstant,alpha_duration)
% Simulation for cumulative deaths and output loss given parameters

% - InitialValues = 1-by-4 vector of initial values: S, I, R, D
% - alpha_on is the target alpha with status of emergency
% - beta, gamma, delta and V are T-by-1 vectors of time-varying
% parameters
% - h, k are scalar parameters
% - T is a simulation period

T = length(beta);
SimData = zeros(T+1,length(InitialValues));
SimData(1,:) = InitialValues;
SimN = zeros(T,1);
alphapath = zeros(T,1);
% alpha = alpha_now; %Initial alpha
alpha = alpha_on;
state = 1;   % 1 = state of emergency is on, 0 = it's lifted
% alpha_off_path = alpha_now:(alpha_off-alpha_now)/(alpha_duration+1):alpha_off;
alpha_off_path = alpha_on:(alpha_off-alpha_on)/(alpha_duration+1):alpha_off;
counter = 1;
wave = 0;
wave_off = 0;
for i = 1:T
    alphapath(i) = alpha;
    if hconstant == 0
        SimN(i) = ((1 + h*alpha)^k)*beta(i)*SimData(i,1)*SimData(i,2)*(1/POP0);
    elseif hconstant == 1
        SimN(i) = ((1+(h(2)/h(1))*alpha)^k)*beta(i)*SimData(i,1)*SimData(i,2)*(1/POP0);
    end
    SimData(i+1,1) = SimData(i,1) - SimN(i) - V(i);
    SimData(i+1,2) = SimData(i,2) + SimN(i) - gamma(i)*SimData(i,2) - delta(i)*SimData(i,2);
    SimData(i+1,3) = SimData(i,3) + gamma(i)*SimData(i,2) + V(i);
    SimData(i+1,4) = SimData(i,4) + delta(i)*SimData(i,2);
    if wave_off == 0
        if th_off2 <= SimN(i)
            if counter <= alpha_duration + 1
                alpha = alpha_off_path(counter+1);
                counter = counter + 1;
            else
                alpha = alpha_off;
            end
            wave_off = wave_off + 1;
            state = 0;
        else
            % alpha = alpha_now;
            alpha = alpha_on;
        end
    elseif wave_off >= 1
        if th_on <= SimN(i)
            alpha = alpha_on;
            counter = 1;
            state = 1;
            wave = wave + 1;
        elseif th_off >= SimN(i)
            state = 0;
            if counter <= alpha_duration + 1
                alpha = alpha_off_path(counter+1);
                counter = counter + 1;
            else
                alpha = alpha_off;
            end
        elseif th_on > SimN(i) && th_off < SimN(i)
            if state == 1
                if wave == 0
                    % alpha = alpha_now;
                    alpha = alpha_on;
                elseif wave >= 1
                    alpha = alpha_on;
                end 
            elseif state == 0
                if counter <= alpha_duration + 1
                    alpha = alpha_off_path(counter+1);
                    counter = counter + 1;
                else
                    alpha = alpha_off;
                end
            end
        end
    end
end
SimERN = (SimData(1:end-1,1)./POP0).*(((1+(h(2)/h(1))*alphapath).^k).*beta)./(gamma+delta);
CumD = SimData(end,4);              % Cumulative deaths during the simulation period
GDPLoss = mean(alphapath);              % Average output loss during the simulation period
