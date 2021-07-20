SimPeriod = 52;        % simulation period in weeks
gamma = 7/12;          % recovery rate from Covid % Should change this to 7/12 (4/25 Kohei Machi)
k = 2;                 % exponent of (1-h*alpha)
hconstant = 1;         % 0 = without intercept, 1 = with intercept for h regression
medical_start_date = datetime(2021,3,18);
elderly_start_date = datetime(2021,5,13);
RetroPeriod = 17;      % retroactive periods used to estimate gamma 
RetroPeriodDelta = 15; %17;      % retroactive periods used to estimate delta
tt = 12; % Showing previous t periods for the plot
% 経済回復速度
DRi=17;%26 %10;
% Parameters for beta
retro_ub = 17; % Control the moving average of beta (beta_avg = sum_{t = lb}^{ub} (1/(ub-lb + 1) sum_{x=1}^t (1/t) beta_t)
retro_lb = 17;
% Parameters for mobility estimation
retroH_switch = 1; %If retroH_switch == 1, retroH = TdataGDP - 4, else = retroH
RetroH = 15;
% Parameters for variants
var_infection = 0.3; %Relative increase of infectiousness (alpha varaint)
var_infection_delta = 0.4; %Relative increase of death rate (alpha varaint)
var_growth = 0.47;
% Population
POP_jp = 125710000;
medical_jp = 4700000;
elderly_jp = 36000000;
ordinary_jp = (POP_jp-elderly_jp-medical_jp);
accept_share = 0.9;
accept_share_ordinary = 0.6879; %so that an accept share of age 13-64 = 80%
% vaccine pace 
PF = 1; % 0 for AZ, 1 for PF
if PF == 0  % AZ
    E1 = 0.365; %0.615;
    E2 = 0.625; %0.64;
    D1 = 0.675; %0.8;85
    D2 = 0.905; %0.85;
else   % PF
    E1 = 0.38; %0.625;
    E2 = 0.795; %0.895;
    D1 = 0.68; %0.8;
    D2 = 0.925; %0.94;
end

% parameters for ICU
gamma_ICU = 7/28; % Recovery rate from ICU
ICU_adjustment = 0.85; %1; %0.8

% parameters for Hospitalizaiton
gamma_Hospital = 7/15; %7/10;
Hospital_adjustment = 0.85; 
Hospital_limit = 5882;

% Indian Variant Parameters
% var_initial2 = 0.50;
var_growth2 = 0.75;     % weekly growth parameter for logit model
var_infection2 = 0.3;%0.2; % relative infection rate for delta variant compared to alpha variant
var_infection_delta2 = 0.1; % relative increase of death rate for delta variant compared to alpha variant
var_start = 1;         % time when the Indian variant starts spreading