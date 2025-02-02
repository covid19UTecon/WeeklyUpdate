% This is for the weekly analysis on 14th February 2022

clear variables
% close all
iPC = 1; % 0 for Mac, 1 for Windows

if iPC == 1
    home = '\Users\mogura\Downloads\20220215\';
    dropbox_path='\Users\mogura\Downloads\20220215\';
    fn = 'Yu Gothic'; % Font style for xaxis, yaxis, title
else
    %         home = '/Users/sohtakawawaki/Dropbox/fujii_nakata (1)/Website/Codes/';
    %     home = '/Users/okamotowataru/Dropbox/fujii_nakata/Website/Codes/';
    home = '/Users/ymaeda/Dropbox/fujii_nakata/Website/Codes/';
    dropbox_path = '/Users/ymaeda/Dropbox/fujii_nakata/Website/Codes/';
    fn = 'YuGothic';
end

%====================== Program parameter values ======================%
pref = 'Tokyo';
prefGDP = 106; %Cho-yen; Trillion yen
figure_save = 0; % 0 = figures won't be saved, 1 = they will be saved
data_save = 1; % save back data
no_omicron = 0;     %
data_switch = 0; % Use I_data and gamma = mean(gamma_data(end-17+1:end))

fs = 12; % common font size for many figures
ldfs = 12; % legend font size for vaccine path
ldfs_main = 12;
axfs = 10;
ft = '%.1f';
yft = '%.0f';
language = {'EN', 'JP'};

%===================== Figure Names =================%
figname_main = string(['MainResults']);
figname_beta_tilde = 'Beta Tilde Path';
figname_beta = 'Beta Path';
figname_var = 'Variant_Share';
figname_delta = 'Death Rate transition';
figname_ICU_nation = 'Severity Rate transition National Standard';
figname_ICU_local = 'Severity Rate transition Local Standard';
figname_new_ICU_local = 'Severity Rate transition New Local Standard';
figname_ERN = 'ERN transition';
figname_Hospital = 'Hospital Rate transition';
figname_dD = 'dD transition';
figname_BRN = 'BRN';
figname_omicron_share = 'Omicron share';


%================== Model Fixed Parameter Values ============================%
parameter
SimPeriod = 52;
if no_omicron == 1
    iniI_omicron = 0;
end

%=============== Import data ============%
import_prefecture
sample_period = find(date == datetime(2021, 6, 17)):find(date == datetime(2021, 11, 4)); %The periods of the 5th wave
ICU_nation(103) = round((ICU_nation(104) + ICU_nation(102))/2, 0);
ICU_nation(109) = 618;
BED(102) = BED(101);

YearMonth = [YearMonthEN, YearMonthJP];
YearMonthWeek = [YearMonthWeekEN, YearMonthWeekJP];
%Date and Figure parameter

x_left_omicron = find(date == datetime(2021, 12, 9));
x_right_omicron = find(date == datetime(2022, 3, 3));

NewSevere = readmatrix([dropbox_path 'tokyo_new_severe_cases.csv']);
newICU_pref = zeros(Tdata+1, 1);
initialICUdata = datetime(2020,12,17);
indNewICU = find(date == initialICUdata,1,'first');
newICU_pref(indNewICU+1:end,1) = NewSevere(:,6);

% ICU_nation(end) = 12; %Update Saturday values from Tokyo website : https://www.fukushihoken.metro.tokyo.lg.jp/iryo/kansen/corona_portal/info/kunishihyou.html
if data_switch == 1
    I = I_data;
    gamma_data = zeros(Tdata, 1);
    %     delta_data = zeros(Tdata,1);
    for i = 1:Tdata
        if I(i) > 0
            gamma_data(i) = dR_data(i) / I_data(i);
            %             delta_data(i) = dD_data(i)/I_data(i);
        end
    end
    gamma = mean(gamma_data(end - RetroPeriod + 1:end));
end


%============ Import vaccine data ============%
Vmat = readmatrix([dropbox_path 'vaccination_Tokyo_newly.xlsx']);
vac1stweek = Vmat(1, 1); %column 1 = week, raw 1 = first week

V1_elderly = zeros(Tdata, 1);
V2_elderly = V1_elderly;
V1_others  = V1_elderly;
V2_others  = V1_elderly;
V1_elderly(vac1stweek:Tdata)    = Vmat(:, 4);
V2_elderly(vac1stweek:Tdata)    = Vmat(:, 5);
V1_others(vac1stweek:Tdata)     = Vmat(:, 7);
V2_others(vac1stweek:Tdata)     = Vmat(:, 8);

% Medical personels
vaccine_medical = readmatrix([dropbox_path 'vaccine_daily_medical.xls']);
[V1_medical_past, V2_medical_past] = vaccine_daily_to_weekly_table(vaccine_medical, ps, dateEN);
V3_d = vaccine_medical(:,5);
Vdata = size(vaccine_medical,1);
V3_w = zeros(length(dateEN),1);
dateV = datetime(vaccine_medical(:,1),'ConvertFrom','excel');
for i = find(dateEN == datetime(2021,12,02)):find(dateEN == datetime(2021,12,23))
    V3_w(i) = V3_d(dateV == dateEN(i)+4);
end
for i = find(dateEN == datetime(2021,12,30)):find(dateEN == datetime(2021,12,30))
    V3_w(i) = V3_d(dateV == dateEN(i)+5);
end
for i = find(dateEN == datetime(2022,1,6)):find(dateEN == datetime(2022,1,6))
    V3_w(i) = V3_d(dateV == dateEN(i)+5);
end
for i = find(dateEN == datetime(2022,1,13)):Tdata
    V3_w(i) = V3_d(dateV == dateEN(i)+4);
end
V3_ps = 1368391/V3_w(end); %Use cumulative data in Tokyo... https://www.fukushihoken.metro.tokyo.lg.jp/iryo/kansen/coronavaccine/third.html
V3_w = round(V3_w * V3_ps);
V3_total = round(cum_to_new(V3_w));

M_first = cum_to_new(Data(:, 12));  M_second = cum_to_new(Data(:, 13));
M_ps_first = Data(:, 15);   M_ps_second = Data(:, 16);
M_first(find(date == datetime(2021, 8, 5)):end) = zeros(length(find(date == datetime(2021, 8, 5)):length(M_first)),1);
M_second(find(date == datetime(2021, 8, 5)):end) = zeros(length(find(date == datetime(2021, 8, 5)):length(M_second)),1);
indM1 = find(M_ps_first > 0, 1, 'first');   indM21 = find(M_ps_second > 0, 1, 'first');

V1_medical = (V1_medical_past / ps) * M_ps_first(indM1);
V1_medical(indM1 + 1:end) = M_first(indM1 + 1:end);
V2_medical = (V2_medical_past / ps) * M_ps_second(indM1);
V2_medical(indM21 + 1:end) = M_second(indM21 + 1:end);
cumsumPastV1 = cumsum(V1_elderly + V1_others + V1_medical);
cumsumPastV2 = cumsum(V2_elderly + V2_others + V2_medical);

medStuff2_cv = cumsum(V2_medical)/600000;
elderly2_cv = cumsum(V2_elderly)/elderly_tokyo;
others2_cv = cumsum(V2_others)/(working_tokyo+children_tokyo+600000);
% figure()
% plot(dateEN, medStuff2_cv,'k')
% hold on
% plot(dateEN, elderly2_cv,'r')
% plot(dateEN, others2_cv, 'b')
% plot(dateEN, cumsumPastV2/POP0, '--k')
% ylim([0 1])

%============ Simulated Vaccine Path ============%
% VT = zeros(SimPeriod,6);
% VT(1,2) = V1_elderly(end-2);
% VT(2,2) = V1_elderly(end-1);
% VT(3,2) = V1_elderly(end);
% VT(1,4) = V1_others(end-2);
% VT(2,4) = V1_others(end-1);
% VT(3,4) = V1_others(end);
% cumsumVT1           = cumsum(VT(:,1) + VT(:,3) + VT(:,5))+ cumsumPastV1(end);
% lagged_cumsumVT1    = [cumsumPastV1(end-2);cumsumPastV1(end-1);cumsumVT1(1:end-2)];
% cumsumVT2           = cumsum(VT(:,2) + VT(:,4) + VT(:,6))+ cumsumPastV2(end);
% lagged_cumsumVT2    = [cumsumPastV2(end-2);cumsumPastV2(end-1);cumsumVT2(1:end-2)];

VT = zeros(SimPeriod,9);
VT(1,2) = V1_elderly(end-2);
VT(2,2) = V1_elderly(end-1);
VT(3,2) = V1_elderly(end);
VT(1,5) = V1_others(end-2);
VT(2,5) = V1_others(end-1);
VT(3,5) = V1_others(end);


e_share = 0.6563;
V3_elderly  = V3_total*e_share;
V3_medical  = V3_total*(1-e_share);
V3_others  = zeros(Tdata,1);
% aa          = V2_elderly(find(V2_elderly>0,1,'first'):end);
% V3_elderly(indJan2022:length(aa)+indJan2022-1) = aa;
% V3_elderly(length(aa)+indJan2022:length(aa)+indJan2022+2) = VT(1:3,2);
% ind_Jan2022 = find(SimDateEN == datetime(2022,1,27)):find(SimDateEN == datetime(2022,1,27));
ind_Feb2022 = 1:find(SimDateEN == datetime(2022,2,24));
ind_Mar2022 = find(SimDateEN == datetime(2022,3,3)):find(SimDateEN == datetime(2022,3,31));
ind_Apr2022 = find(SimDateEN == datetime(2022,4,7)):find(SimDateEN == datetime(2022,4,28));
ind_May2022 = find(SimDateEN == datetime(2022,5,5)):find(SimDateEN == datetime(2022,5,26));
ind_Jun2022 = find(SimDateEN == datetime(2022,6,2)):find(SimDateEN == datetime(2022,6,30));

totalVT = zeros(SimPeriod,1);
% totalVT(ind_Jan2022) = 150000;
totalVT(ind_Feb2022) = 500000;
totalVT(ind_Mar2022) = 700000;
totalVT(ind_Apr2022) = 500000;
totalVT(ind_May2022) = 350000;
totalVT(ind_Jun2022) =  80000;

VT(:,9) = totalVT * 0.5; % Medical
VT9_ind = find(sum(V2_medical)*0.9 < cumsum(VT(:,9)+sum(V3_medical)),1,'first');
VT(VT9_ind:end,9) = zeros(SimPeriod-(VT9_ind-1),1);
VT(VT9_ind,9) = sum(V2_medical)*0.9 - sum(VT(1:VT9_ind-1,9)) - sum(V3_medical);

VT(:,3) = totalVT - VT(:,9); %Elderly
VT3_ind = find(sum(V2_elderly)*0.9<cumsum(VT(:,3)),1,'first');
VT(VT3_ind:end,3) = zeros(SimPeriod-(VT3_ind-1),1);
VT(VT3_ind,3) = sum(V2_elderly)*0.9 - sum(VT(1:VT3_ind-1,3));

VT(:,6) = totalVT -VT(:,9) - VT(:,3); %others
VT6_ind = find(sum(V2_others)*0.7<cumsum(VT(:,6)),1,'first');
VT(VT6_ind:end,6) = zeros(SimPeriod-(VT6_ind-1),1);
VT(VT6_ind,6) = sum(V2_others)*0.7 - sum(VT(1:VT6_ind-1,6));

cumVT3 = cumsum(VT(:,3))/(sum(V2_elderly));
cumVT6 = cumsum(VT(:,6))/(sum(V2_others));
cumVT9 = (cumsum(VT(:,9))+sum(V3_medical))/(sum(V2_medical));

figure
plot(SimDateEN, cumVT3,'r')
hold on
plot(SimDateEN, cumVT6,'b')
plot(SimDateEN, cumVT9, 'k')
ylim([0 1])

cumsumVT1           = cumsum(VT(:,1) + VT(:,4) + VT(:,7))+ cumsumPastV1(end);
lagged_cumsumVT1    = [cumsumPastV1(end-1);cumsumPastV1(end);cumsumVT1(1:end-2)];
cumsumVT2           = cumsum(VT(:,2) + VT(:,5) + VT(:,8))+ cumsumPastV2(end);
lagged_cumsumVT2    = [cumsumPastV2(end-1);cumsumPastV2(end);cumsumVT2(1:end-2)];

cumsumPastV3        = cumsum(V3_elderly + V3_others + V3_medical);
cumsumVT3           = cumsum(VT(:,3) + VT(:,6) + VT(:,9))+ cumsumPastV3(end);
lagged_cumsumVT3    = [cumsumPastV3(end-1);cumsumPastV3(end);cumsumVT3(1:end-2)];

%============ Constructing the reference level of output ===========%
[potentialGDP, referenceGDP, alpha] = construct_GDP(GDP, TdataGDP);

[Malt, h_all, h_all_se, h, h_se] = estimate_h(M, alpha, TdataGDP, RetroH, hconstant);
figname = string(['Mobility_GDP_' char(pref)]);
f = figure('Name', figname);
plot_mobility(Malt, alpha, Tdata, TdataGDP, YearMonthWeekJP, xtick1, fs, 16)
if figure_save == 1
    saveas(f, [dropbox_path 'Figures/' char(pref) '/MobilityGDPLine_v.png']);
end

%====== Common exogenous settings ====%


% Seasonality
seasonality = seasonal_adjustment(retro_lb, retro_ub, dateD, SimPeriod+DRi+1, seasonal_effect);

%===== Compute the history of S, I, R, D in the data period ====%
if data_switch == 0
    [S, I, R, D,cum_in_R] ...
        = SIRD(Tdata, POP0, N, E1, E2, E3,...
        V1_elderly, V1_medical, V1_others, V2_elderly, V2_medical, V2_others, ...
        V3_elderly,V3_medical,V3_others,...
        gamma, dD, TdataGDP, referenceGDP, alpha);
else
    pastV = zeros(Tdata, 1);
    pastV(3:end) = E1 * (V1_elderly(1:end - 2) + V1_medical(1:end - 2) + V1_others(1:end - 2)) ...
        + (E2 - E1) * (V2_elderly(1:end - 2) + V2_medical(1:end - 2) + V2_others(1:end - 2)) ...
        + (E3 - E2) * (V3_elderly(1:end - 2) + V3_medical(1:end - 2) + V3_others(1:end - 2)) ;
    S = S_data;
    S(2:end) = S(2:end) - cumsum(pastV);
    R = R_data;
    R(2:end) = R(2:end) + cumsum(pastV);
    D = D_data;
end

%========== Compute time series average ==========%
[delta,beta_tilde,ERN,beta, ...
    ICU_nation_rate, ICU_pref_rate, Hospital_rate,...
    gammaT,delta_average,ICU_nation_rate_average,ICU_pref_rate_average,Hospital_rate_average,...
    simple_beta_avg,beta_se, delta_se] ...
    = Time_Series_Average(S, I, D, ICU_nation, ICU_pref, hospital, dD, N, ...
    Tdata, SimPeriod, RetroPeriod, POP0, ...
    hconstant, h_all, alpha, k, ...
    gamma, gamma_ICU_nation, gamma_ICU_pref, gamma_Hospital, ...
    ICU_nation_adjustment, ICU_pref_adjustment, Hospital_adjustment, ...
    sample_period);

newICU_pref_rate           =   (newICU_pref(2:Tdata+1) - newICU_pref(1:Tdata) + gamma_newICU_pref.*newICU_pref(1:Tdata) + dD(1:Tdata))./I(1:Tdata);
weight = I(sample_period)/sum(I(sample_period));
weight_newICU_pref_sample  =   newICU_pref_rate(sample_period).*weight;
newICU_pref_rate_average   =   sum(weight_newICU_pref_sample(isnan(weight_newICU_pref_sample)==0))*newICU_pref_adjustment; 

gamma_ICU_nation_path   = gamma_ICU_nation * ones(SimPeriod,1);
gamma_ICU_pref_path     = gamma_ICU_pref * ones(SimPeriod,1);
gamma_newICU_pref_path     = gamma_newICU_pref * ones(SimPeriod,1);
gamma_Hospital_path     = gamma_Hospital * ones(SimPeriod,1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%% Simulaiton starts here %%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%=========== simulation setting =============%
nVariant = 2;
alpha_Aug = mean(alpha((dateEN >= datetime(2021, 8, 05)) & (datetime(2021, 8, 26) >= dateEN)));
alpha_Oct2021 = mean(alpha((dateEN >= datetime(2021, 10, 07)) & (datetime(2021, 10, 28) >= dateEN)));
% exogenous parameters
state               = 0;    %=1 if currently under SOE
th_on_percent       = 0.35;
th_on               = max(newICU_limit_pref_vec)*th_on_percent; %8000*7; %ICU_limit_pref_vec(end)*0.5; %
th_off              = th_on*0.5; %1000 * 7;  %ICU_limit_pref_vec(end)*0.25; %
th_on_N             = 25000*7;
th_off_N            = th_on_N * 0.1;
%ori_beta_goal       = 2.1975; %3.75*(gamma+delta_average) BRN = 3.75
relative_beta_SOE   = 0.3;

alpha_on            = alpha_Aug;
alpha_off           = 0.00;
alpha_jump          = 0.9 * alpha_Aug;
beta_jump           = 1.0; %0.6

InitialValues = [S(end), I(end), R(end), D(end), ICU_nation(end), ICU_pref(end), hospital(end), newICU_pref(end)];

% xmin = find(date == datetime(2021, 11, 04));
% xmax = find(date == datetime(2022, 12, 01));
xmax = find(date == datetime(2022, 4, 28));
xmin = find(date == datetime(2021, 7, 1));
ymax_D = 50;

% Simulation parameters
ori_beta_goal_vec = [1.46,1.17,0.88];
omicron_relative_infectivity = 1.0;%1.2 
SoE_date_vec  = [SimPeriod+1,SimPeriod+1,SimPeriod+1];  %End of Feb., First wekk of Mar., Second week of Mar
betaT_temp_ini_vec = [0, 0, 0];   
betaT_rho_vec      = [0.99, 0.99, 0.99];
delta_temp_ini_vec = [-0.4,-0.4,-0.4];
delta_rho_vec = [0.95,0.95,0.84];
delta_ICU_nation_temp_ini_vec = [-0.25,-0.25,-0.25]; %[0.9,0.9,3.0];
delta_ICU_pref_temp_ini_vec = [-0.4,-0.4,-0.4]; %[0,0,2.0];
delta_newICU_pref_temp_ini_vec = [-0.5,-0.5,-0.5]; %[0,0,2.0];
delta_Hospital_temp_ini_vec = [0,0,0]; %[2.5,2.5,8.0];
omicron_E2_vector = 0.5;%[1, 0.6, 0.2]; %Relative
omicron_realtive_severity        = 0.2;%[0.4,0.2,0.05];%[1, 0.5, 0.25];
omicron_realtive_severity_nation = omicron_realtive_severity; %[0.6,0.35,0.10];%[1, 0.5, 0.25];
omicron_realtive_hospitalized_rate = omicron_realtive_severity; 
severity_nation_standard_vector = [1, 0.6, 0.3];
severity_new_pref_standard_vector = [1.25, 1.0, 0.75];
hospitalization_standard_vector = ones(3,1);% [1, 0.4, 0.2];
gamma_ICU_nation_shock_vec = (1-(1-gamma_ICU_nation)* severity_nation_standard_vector);
gamma_newICU_pref_shock_vec = (1-(1-gamma_ICU_nation)* severity_nation_standard_vector);
gamma_Hospital_shock_vec = (1-(1-gamma_Hospital)* hospitalization_standard_vector) ;

% xvec = 1;
% yvec = 1;
% zvec = 1;

% Directory for saved figures
xvec = betaT_temp_ini_vec;
yvec = severity_new_pref_standard_vector;
zvec = omicron_E2_vector;
nX = length(xvec);
nY = length(yvec);
nZ = length(zvec);


figfolder = string(['Baseline']);
% Scenario Name and Line
titlevec = {'Scenario', 'シナリオ'};
figname_xvar = '_relative_severity_';
Scenario = ["基本再生産数2.5"; "基本再生産数2.0"; "基本再生産数1.5"];
ScenarioEN = [ "Basic Reproduction Number = 2.5"; ...
               "Basic Reproduction Number = 2.0"; ...
               "Basic Reproduction Number = 1.5"];
Scenario_vec = [ScenarioEN,Scenario];
fig_Scenario_vec = ["Scenario_A", "Scenario_B", "Scenario_C"];
linecolor = {"r", "k", "b"};
LineStyles = {"-", "-", "-"};
lineWidth = [1.5, 1.5, 1.5];
markertype = {'o','o','o'};
lineNameJP = {"第5波の重症化率の25%", "第5波の重症化率の20%", "第5波の重症化率の15%"};
lineNameEN = {"Severity Rate 25% (Relatieve to the 5th Wave)", ...
              "Severity Rate 20% (Relatieve to the 5th Wave)", ...
              "Severity Rate 15% (Relatieve to the 5th Wave)"};

column_num_main = nZ;

originalE1 = E1;
originalE2 = E2;
originalE3 = E3;

% initialize_matirix
DMat        = nan(nX, nY, nZ);
AlphaMat    = DMat;

SimData                 = nan(SimPeriod + 1, length(InitialValues), nX, nY, nZ);
SimData_endogenous      = zeros(SimPeriod + 1, length(InitialValues), nX, nY, nZ, nVariant);
beta_path_mat           = zeros(SimPeriod, nX, nY, nZ, nVariant);
beta_tilde_path_mat     = beta_path_mat;
BRN_path_mat            = beta_path_mat;
ERN_path_mat            = beta_path_mat;
AlphaPath               = nan(SimPeriod, nX, nY, nZ);
NPath                   = AlphaPath;
Sim_dD                    = AlphaPath;
SimERN                  = AlphaPath;
SimBRN                 = AlphaPath;
betaPath                = AlphaPath;
betaTildePath           = AlphaPath;
deltaPath               = AlphaPath;
delta_ICU_nationPath    = AlphaPath;
delta_ICU_prefPath      = AlphaPath;
delta_newICU_prefPath   = AlphaPath;
delta_HospitalPath      = AlphaPath;
omicron_share_mat       = AlphaPath;
omicron_I_share_mat     = AlphaPath;
omicron_N_share_mat     = AlphaPath;
SimICU_nation           = nan(SimPeriod+1, nX, nY, nZ);
SimICU_pref             = SimICU_nation;
SimNewICU_pref          = SimICU_nation;
SimHospital             = SimICU_nation;

for iX = 1:nX %different figures
    SoE_date = SoE_date_vec(iX);
    ori_beta_goal = ori_beta_goal_vec(iX);
    delta_temp_ini = delta_temp_ini_vec(iX);
    delta_rho = delta_rho_vec(iX);
    for iY = 1:nY %different curves within a figure
        for iZ = 1:nZ %different curves within a figure
%             gamma_ICU_nation_path(1) = gamma_ICU_nation*gamma_shock_vec(iY);
%             gamma_ICU_pref_path(1) = gamma_ICU_pref*gamma_shock_vec(iY);
%             gamma_Hospital_path(2)  = gamma_Hospital_shock_vec(iY);
%             gamma_ICU_nation_path(2)= gamma_ICU_nation_shock_vec(iY);
%             gamma_newICU_pref_path(2)= gamma_newICU_pref_shock_vec(iY);
            severity_nation_standard = severity_nation_standard_vector(iY);
            severity_new_pref_standard = severity_new_pref_standard_vector(iY);
            hospitalization_standard = hospitalization_standard_vector(iY);
            delta_ICU_nation_temp_ini = delta_ICU_nation_temp_ini_vec(iY);
            delta_ICU_pref_temp_ini   = delta_ICU_pref_temp_ini_vec(iY);
            delta_newICU_pref_temp_ini = delta_newICU_pref_temp_ini_vec(iY);
            delta_Hospital_temp_ini   = delta_Hospital_temp_ini_vec(iY);
            
            omicronE3 = originalE3;
            omicronE2 = originalE2 * omicron_E2_vector(iZ);
            omicronE1 = originalE1 * omicron_E2_vector(iZ);
            if no_omicron == 1
                ori_beta_goal  = beta_goal_vec(iZ);
            end
            
            betaT_temp_ini = betaT_temp_ini_vec(iX);
            beta_rho = betaT_rho_vec(iX);
            relative_infectivity_path       = ones(SimPeriod,1); %vector
            relative_severity_path    = ones(SimPeriod,1); %vector
            past_omicron_share  = zeros(Tdata,1);
            past_omicron_share(find(dateEN == datetime(2021, 12, 23)))= 0.079;
            past_omicron_share(find(dateEN == datetime(2021, 12, 30)))= 0.446;
            past_omicron_share(find(dateEN == datetime(2022, 1, 6))) = 0.81;
            past_omicron_share(find(dateEN == datetime(2022, 1, 13)))= 0.894; %https://www3.nhk.or.jp/news/html/20220118/k10013437211000.html
            past_omicron_share(find(dateEN == datetime(2022, 1, 20)))= 0.95;
            past_omicron_share(find(dateEN == datetime(2022, 1, 27)))= 0.99;
            past_omicron_share(find(dateEN == datetime(2022, 2, 3)))=  0.995;
            past_omicron_share(find(dateEN == datetime(2022, 2, 10)))=  0.995;
            %calculate_omicron_share
            logit_initial       = log(omicron_initial/(omicron_ss-omicron_initial)); % Logit of the variant share, most recently
            sim_omicron_share   = zeros(SimPeriod,1);
            sim_omicron_share(1)  =   omicron_initial;
            sim_omicron_share(2:end,1)  ...
                = exp((1:length(sim_omicron_share(2:end,1)))'* omicron_growth + logit_initial).*omicron_ss ...
                ./(1+exp((1:length(sim_omicron_share(2:end,1)))'*omicron_growth+logit_initial));
            sim_omicron_share(isnan(sim_omicron_share)) = 1;
            omicron_share       = [past_omicron_share; sim_omicron_share];
            %plot omicron share
            if iX == 1 && iY == 1 && iZ == 1
                figure('Name', char(figname_omicron_share));
                set(gcf, 'Position', [100, 100, 1200, 800])
                jTitle = 'オミクロン株割合の推移';
                plot(omicron_share)
                xlim([x_left_omicron x_right_omicron])
                ylim([0 1])
                xticks(x_left_omicron:x_right_omicron)
                xticklabels(YearMonthWeekJP(xticks))
                title(char(jTitle),'FontSize',fs,'FontWeight','normal','FontName',fn)
                ax = gca;
                ax.YAxis.FontSize = axfs;   ax.XAxis.FontSize = axfs;   ax.YAxis.Exponent = 0;
                xtickangle(45)
                if figure_save == 1
                    saveas(gcf, [home 'Figures/' char(pref) '/' char(figfolder) '/' char(figname_omicron_share) '.png']);
                end
            end
            
            % calculate vaccine effectiveness
            E1 = originalE1*(1-sim_omicron_share) + omicronE1 * sim_omicron_share; %vector
            E2 = originalE2*(1-sim_omicron_share) + omicronE2 * sim_omicron_share; %vector
            E3 = originalE3*(1-sim_omicron_share) + omicronE3 * sim_omicron_share; %vector
            
            D1 = (D1 - E1)./(1-E1);      % Find reduction of death conditoinal on infection after first does
            D2 = (D2 - E2)./(1-E2);      % Find reduction of death conditoinal on infection after second does
            D3 = (D3 - E3)./(1-E3);      % Find reduction of death conditoinal on infection after second does
            
            relative_infectivity_path       = 1 * (1-sim_omicron_share) ...
                + omicron_relative_infectivity * sim_omicron_share; %vector
            
            relative_severity_path    = 1 * (1-sim_omicron_share) ...
                + omicron_realtive_severity * sim_omicron_share; %vector
            relative_severity_path_nation    = 1 * (1-sim_omicron_share) ...
                + omicron_realtive_severity_nation * sim_omicron_share; %vector
            relative_hospitalized_path = 1 * (1-sim_omicron_share) ...
                + omicron_realtive_hospitalized_rate * sim_omicron_share;
            VE = E1.*(VT(:,1)+VT(:,4)+VT(:,7))...
                +(E2-E1).*(VT(:,2)+VT(:,5)+VT(:,8)) ...
                +(E3-E2).*(VT(:,3)+VT(:,6)+VT(:,9));
            VE_prev = originalE1.*(V1_elderly+V1_medical+V1_others)...
                +(originalE2-originalE1).*(V2_elderly+V2_medical+V2_others)...
                +(originalE3-originalE2).*(V3_elderly+V3_medical+V3_others);
            V = [VE_prev(end-1);VE_prev(end);VE(1:end-2)];
            
            VE_omicron      = omicronE1 * (VT(:,1)+VT(:,4)+VT(:,7))...
                + (omicronE2-omicronE1) * (VT(:,2)+VT(:,5)+VT(:,8)) ...
                + (omicronE3-omicronE2) * (VT(:,3)+VT(:,6)+VT(:,9));
            VE_prev_omicron = omicronE1 * (V1_elderly+V1_medical+V1_others) ...
                + (omicronE2-omicronE1) * (V2_elderly+V2_medical+V2_others) ...
                + (omicronE3-omicronE2) * (V3_elderly+V3_medical+V3_others);
            V_omicron       = [VE_prev_omicron(end-1); VE_prev_omicron(end); VE_omicron(1:end-2)];
            
            
            %Construct betapath
            beta_goal   = ori_beta_goal;
            beta_goal   = beta_goal * relative_infectivity_path;
            betaT       = beta_goal .* transpose(seasonality(1:SimPeriod));
            
            betaT               = beta_AR1(betaT_temp_ini, beta_rho, betaT, start_beta);  %2021/12/23 kawawaki
            betaBox     = [beta; betaT];
            
            %Construct alphapath
            alphaAfterSOE   = [alpha(Tdata):(alpha_off - alpha(Tdata)) / (DRi):alpha_off];
            %alphaT          = [alphaAfterSOE'; alpha_off * ones(SimPeriod, 1)];
            alphaT          = [ones(3,1)*alpha(Tdata); alphaAfterSOE';alpha_off * ones(SimPeriod-3,1)];
            alphaBox        = [alpha; alphaT];
            
            % death rate, severity rate, hospoital rate paths
            deltaT              = delta_average             * relative_severity_path;
            SimICU_nation_rate    = ICU_nation_rate_average  * relative_severity_path_nation;
            SimICU_pref_rate      = ICU_pref_rate_average    * relative_severity_path;
            SimNewICU_pref_rate   = newICU_pref_rate_average * relative_severity_path;
            SimHospital_rate      = Hospital_rate_average    * relative_hospitalized_path;
            
            %AR1 adjustment
            deltaT_woAR             = deltaT;
            deltaT                  = beta_AR1(delta_temp_ini, delta_rho, deltaT, start_delta);
            
            SimICU_nation_rate_woAR   = SimICU_nation_rate;
            SimICU_nation_rate      = beta_AR1(delta_ICU_nation_temp_ini, delta_ICU_nation_rho, SimICU_nation_rate, start_delta_ICU_nation);
            
            SimICU_pref_rate_woAR     = SimICU_pref_rate;
            SimICU_pref_rate          = beta_AR1(delta_ICU_pref_temp_ini, delta_ICU_pref_rho, SimICU_pref_rate, start_delta_ICU_pref);
            
            SimNewICU_pref_rate_woAR  = SimNewICU_pref_rate;
            SimNewICU_pref_rate       = beta_AR1(delta_newICU_pref_temp_ini, delta_newICU_pref_rho, SimNewICU_pref_rate, start_delta_newICU_pref);
            
            SimHospital_rate_woAR     = SimHospital_rate;
            SimHospital_rate          = beta_AR1(delta_Hospital_temp_ini, delta_Hospital_rho, SimHospital_rate, start_delta_Hospital);
            
            
            
            
            
            
            
            
            SimICU_nation_rate(1:end)   = SimICU_nation_rate(1:end) *  severity_nation_standard;
            SimNewICU_pref_rate(1:end)  = SimNewICU_pref_rate(1:end) *  severity_new_pref_standard;
            SimHospital_rate(1:end)     = SimHospital_rate(1:end) *  hospitalization_standard;
            
            
            
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%% Simulation SIRD %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            [DMat(iX,iY,iZ), AlphaMat(iX,iY,iZ), AlphaPath(:, iX,iY,iZ), ...
                SimData(:, :, iX,iY,iZ), NPath(:, iX,iY,iZ), SimERN(:, iX,iY,iZ),...
                SimICU_nation(:, iX,iY,iZ), SimICU_pref(:, iX,iY,iZ), SimHospital(:, iX,iY,iZ), SimNewICU_pref(:, iX,iY,iZ),...
                betaPath(:,iX,iY,iZ),betaTildePath(:,iX,iY,iZ),SimBRN(:,iX,iY,iZ)] = ...
                Covid_projection_omicron_date(InitialValues,alpha_on,alpha_off,SoE_date,th_off_N,...
                betaT,gammaT,deltaT,SimICU_nation_rate, SimICU_pref_rate, SimHospital_rate,SimNewICU_pref_rate,h,k,POP0,...
                lagged_cumsumVT1, lagged_cumsumVT2,lagged_cumsumVT3, E1, E2, E3, cum_in_R, ...
                hconstant,DRi, ...
                gamma_ICU_nation_path, gamma_ICU_pref_path, gamma_Hospital_path,gamma_newICU_pref_path,...
                relative_beta_SOE, beta_jump, beta_goal, seasonality, alphaBox(Tdata + 1:end), state, simple_beta_avg);
            Sim_dD(:, iX, iY, iZ) = squeeze(SimData(2:end,4,iX,iY,iZ)-SimData(1:end-1,4,iX,iY,iZ)+SimData(2:end,4,iX,iY,iZ)-SimData(1:end-1,4,iX,iY,iZ));
            
            deltaPath(:, iX,iY,iZ)  = deltaT;
            SimICU_nation_rate_Path(:, iX,iY,iZ) = SimICU_nation_rate;
            SimICU_pref_rate_Path(:, iX,iY,iZ) = SimICU_pref_rate;
            SimNewICU_pref_rate_Path(:, iX,iY,iZ) = SimNewICU_pref_rate;
            SimHospital_rate_Path(:, iX,iY,iZ) = SimHospital_rate;
            
            
        end
        
    end
    
end

% Save variable names and values for backdata files
minAlpha = alpha_off; % 経済損失0の基準
AlphaM = AlphaMat;
% AlphaM = AlphaMat(~isnan(AlphaMat));
AlphaM = (AlphaM - minAlpha) * prefGDP * 10000 * SimPeriod / 52;
DM = DMat;
% DM = DMat(~isnan(DMat));
% BackDataDA(1:nX*nY*nZ) = [round(AlphaM') / 10000, round(DM'), Scenario'];
%--- Record how many times on and off are triggered ---%
waves = zeros(nX,nY,nZ);
for ixx = 1:nX
    for iyy = 1:nY
        for izz = 1:nZ
            svec = zeros(SimPeriod - 1, 1);
            
            for t = 1:SimPeriod - 1
                svec(t) = AlphaPath(t + 1, ixx,iyy,izz) - AlphaPath(t, ixx,iyy,izz);
            end
            
            waves(ixx,iyy,izz) = sum(svec > 0);
        end
    end
end

disp('Pessimistic')
disp(round(squeeze(NPath(3,1,1,1)/7)'))
disp('Baseline')
disp(round(squeeze(NPath(3,2,1,1)/7)'))
disp('Optimistic')
disp(round(squeeze(NPath(3,3,1,1)/7)'))

% %==================== Plot and Backdata ====================%

lgdLocation = 'northwest';
yft = '%.0f';
lgdfs = 6;
axfs = 8;
column_num = 3;

for l = 1:2 %1:2 when english version needed
    
    for iX = 1:nX
        if l == 1
            lineName = lineNameEN;
        elseif l == 2
            lineName = lineNameJP;
        end
        
        % Generate graphs for the website
        lng = language{l};
        figname = [char(figname_main) '_' char(fig_Scenario_vec(iX)) '_' char(lng)];
        f = figure('Name', figname);
        t = tiledlayout(3,3, 'TileSpacing', 'compact');
        title(t,Scenario_vec(iX,l),'FontSize',20)
        f.WindowState = 'maximized';
        
        
        %--- Number of people who are in ICU (local standard)---%
        %         subplot(3, 3, 1)
        nexttile
        title_vec = ["ICU (Old Tokyo Standard)", "重症患者数（旧都基準）"];
        plot_3Dfunction(ICU_pref(2:end), SimICU_pref(2:end,:,:), iX, ...
            WeekNumber, YearMonth, xmin, xmax, ...
            fn, fs, lgdfs, axfs,yft,...
            lgdLocation, column_num, l, title_vec, ...
            lineWidth,linecolor, LineStyles, lineName)
        hold on
        plot([ICU_limit_pref_vec; ones(SimPeriod, 1) * max(ICU_limit_pref_vec)], '--k', 'HandleVisibility', 'off', 'LineWidth', 1.5)
        text(xmin, ICU_limit_pref_vec(xmin) * 0.85, '100%', 'FontSize', fs)
        hold on
        plot([ICU_limit_pref_vec * 0.5; ones(SimPeriod, 1) * max(ICU_limit_pref_vec)*0.5], '--k', 'HandleVisibility', 'off', 'LineWidth', 1.5)
        hold on
        text(xmin, ICU_limit_pref_vec(xmin) * 0.5 * 0.8, '50%', 'FontSize', fs)
        ylim([0 max(ICU_limit_pref_vec)*1.5])
       
        %         subplot(3, 3, 2)
        nexttile
        
        title_vec = ["ICU (New Tokyo Standard)", "重症患者数（新都基準）"];

        plot_3Dfunction(newICU_pref(2:end), SimNewICU_pref(2:end,:,:), iX, ...
            WeekNumber, YearMonth, xmin, xmax, ...
            fn, fs, lgdfs, axfs,yft,...
            lgdLocation, column_num, l, title_vec, ...
            lineWidth,linecolor, LineStyles, lineName)
        Handle = legend;
        set(Handle, 'Visible', 'off');
        hold on
        plot([newICU_limit_pref_vec; ones(SimPeriod, 1) * max(newICU_limit_pref_vec)], '--k', 'HandleVisibility', 'off', 'LineWidth', 1.5)
        text(xmin, newICU_limit_pref_vec(xmin) * 0.85, '100%', 'FontSize', fs)
        hold on
        plot([newICU_limit_pref_vec * th_on_percent; ones(SimPeriod, 1) * th_on], '--k', 'HandleVisibility', 'off', 'LineWidth', 1.5)
        hold on
        %         plot([nan(Tdata,1); ones(SimPeriod, 1) * th_on], '-r', 'HandleVisibility', 'off', 'LineWidth', 1.0)
        %         hold on
        %         plot([nan(Tdata,1); ones(SimPeriod, 1) * th_off], '-b', 'HandleVisibility', 'off', 'LineWidth', 1.0)
        text(xmin, newICU_limit_pref_vec(xmin) * th_on_percent * 0.8, [num2str(th_on_percent*100) '%'], 'FontSize', fs)
        ylim([0 max(newICU_limit_pref_vec)*1.5])
        
        %--- Number of people who are in ICU (Naitonal standard) ---%
        %         subplot(3, 3, 3)
%         nexttile
%         title_vec = ["ICU (National Standard)", "重症患者数（国基準）"];
%         plot_3Dfunction(ICU_nation(2:end), SimICU_nation(2:end,:,:), iX, ...
%             WeekNumber, YearMonth, xmin, xmax, ...
%             fn, fs, lgdfs, axfs,yft,...
%             lgdLocation, column_num, l, title_vec, ...
%             lineWidth,linecolor, LineStyles, lineName)
%         Handle = legend;
%         set(Handle, 'Visible', 'off');
%         hold on
%         plot([BED; ones(SimPeriod, 1) * BED(end)], '--k', 'HandleVisibility', 'off', 'LineWidth', 1.5)
%         text(xmin, BED(xmin) * 0.85, '100%', 'FontSize', fs)
%         hold on
%         plot([BED * 0.5; ones(SimPeriod, 1) * BED(end) * 0.5], '--k', 'HandleVisibility', 'off', 'LineWidth', 1.5)
%         text(xmin, BED(xmin) * 0.4, '50%', 'FontSize', fs)
%         ylim([0 max(BED)*1.5])
%         
        %--- Number of newly hospitalized ---%
        %         subplot(3, 3, 3)
        nexttile
        title_vec = ["Hospitalized Patients", "入院患者数"];
        plot_3Dfunction(hospital(2:end), SimHospital(2:end,:,:), iX, ...
            WeekNumber, YearMonth, xmin, xmax, ...
            fn, fs, lgdfs, axfs,yft,...
            lgdLocation, column_num, l, title_vec, ...
            lineWidth,linecolor, LineStyles, lineName)
        Handle = legend;
        set(Handle, 'Visible', 'off');
        hold on
        plot([Hospital_limit_vec; ones(SimPeriod, 1) * max(Hospital_limit_vec)], '--k', 'HandleVisibility', 'off', 'LineWidth', 1.5)
        text(xmin, Hospital_limit_vec(xmin) * 0.85, '100%', 'FontSize', fs)
        hold on
        plot([Hospital_limit_vec * 0.5; ones(SimPeriod, 1) * max(Hospital_limit_vec) * 0.5], '--k', 'HandleVisibility', 'off', 'LineWidth', 1.5)
        text(xmin, Hospital_limit_vec(xmin) * 0.4, '50%', 'FontSize', fs)
        ylim([0 max(Hospital_limit_vec)*1.5])
%         
        %         subplot(3, 3, 4)
        nexttile
        title_vec = ["New Deaths (Daily Average)", "新規死亡者数（1日平均）"];
        plot_3Dfunction(dD / 7, Sim_dD/ 7, iX, ...
            WeekNumber, YearMonth, xmin, xmax, ...
            fn, fs, lgdfs, axfs,yft,...
            lgdLocation, column_num, l, title_vec, ...
            lineWidth,linecolor, LineStyles, lineName)
        Handle = legend;
        set(Handle, 'Visible', 'off');
        %         ylim([0 ymax_D])
        %
        %--- Number of new cases ---%
        %         subplot(3, 3, 5)
        nexttile
        title_vec = ["New Cases (Daily Average)", "新規感染者数（1日平均）"];
        plot_3Dfunction(N/7, NPath/7, iX, ...
            WeekNumber, YearMonth, xmin, xmax, ...
            fn, fs, lgdfs, axfs,yft,...
            lgdLocation, column_num, l, title_vec, ...
            lineWidth,linecolor, LineStyles, lineName)
        Handle = legend;
        set(Handle, 'Visible', 'off');
        %         ylim([0,10000])
        %--- GDP Path ---%
        %         yft = '%.2f';
        %         subplot(3, 3, 6)
        nexttile
        title_vec = ["GDP", "GDP"];
        plot_3Dfunction(100*(1-alpha), 100*(1-AlphaPath), iX, ...
            WeekNumber, YearMonth, xmin, xmax, ...
            fn, fs, lgdfs, axfs,yft,...
            lgdLocation, column_num, l, title_vec, ...
            lineWidth,linecolor, LineStyles, lineName)
        ylim([90 100])
        Handle = legend;
        set(Handle, 'Visible', 'off');
        
        %         subplot(3, 3, 7)
        nexttile
        title_vec = ["Transitions of ERN", "実効再生産数"];
        plot_3Dfunction(ERN, SimERN, iX, ...
            WeekNumber, YearMonth, xmin, xmax, ...
            fn, fs, lgdfs, axfs,yft,...
            lgdLocation, column_num, l, title_vec, ...
            lineWidth,linecolor, LineStyles, lineName)
        Handle = legend;
        set(Handle, 'Visible', 'off');
        
        
        %         subplot(3, 3, 8) %Cumulative vaccinated
        nexttile
        
        VT_23 = VT;
        VT_23(:,[1,4,7]) = [];
        plot_vaccinepath_separate_percentage(2, VT_23, V2_medical, V3_medical, V2_elderly, V3_elderly, V2_others, V3_others, ps, YearMonthWeek(:, l), WeekNumber, Tdata, fs, 8, fn, xmin, xmax, l, POP0);
        yticks(0:10:100)
        ylim([0 100])
        grid on
        xlim([xmin, xmax])
        %     xticks(find(WeekNumber == 1 & abs(1 - mod(MonthNumber, 4)) < 0.01))
        xticks(find(WeekNumber == 1))
        %     xticklabels(YearMonthWeekJP(xticks))
        xticklabels(YearMonthJP(xticks))
        lgd = legend;
        lgd.FontSize = 12;
        lgd.Location = 'Northwest';
        ax = gca;
        ax.YAxis.FontSize = axfs;
        ax.XAxis.FontSize = axfs;
        %     xline(xline_ind, 'LineWidth', 1.5, 'HandleVisibility', 'off');
        
        %--- Trade-off Curve ---%
        %         subplot(3, 3, 9)
        
        nexttile
        title_vec = ["Transition of the Share of Omicron Variant, ", "オミクロン株割合の推移, "];
        
        plot(omicron_share)
        hold on
        xline(Tdata,'LineWidth',1.5,'HandleVisibility','off');
        xlim([xmin xmax])
        ylim([0 1])
        xticks(find(WeekNumber == 1))
        xticklabels(YearMonth(xticks,l))
        title(title_vec(l),'FontSize',fs,'FontWeight','normal','FontName',fn)
        ax = gca;
        ax.YAxis.FontSize = axfs;   ax.XAxis.FontSize = axfs;   ax.YAxis.Exponent = 0;
        xtickangle(45)
        
        Handle = legend;
        set(Handle, 'Visible', 'off');
        ylim([0 1])
        grid on
        ax = gca;
        box on
        xtickangle(45)
        
        
        %         for iyy = 1:nY
        %             for izz = 1:nZ
        %                 scatter(AlphaM(iX,iyy,izz),DM(iX,iyy,izz),250,...
        %                     markertype{iyy,izz}, linecolor{iyy,izz},'filled');
        %                 hold on
        %             end
        %         end
        %         if l == 1
        %             xlabel('Output Loss (hundred million yen)','FontSize',fs)
        %             ylabel('Cumulative Deaths','FontSize',fs)
        %             title('Relationship between Covid-19 and Output(within 10 years)','FontSize',fs,'FontWeight','normal')
        %         elseif l == 2
        %             xlabel('経済損失 (兆円)','FontSize',fs,'FontName',fn)
        %             ylabel('累計死亡者数','FontSize',fs,'FontName',fn)
        %             title('コロナ感染と経済の関係(今後10年)','FontSize',fs,'FontWeight','normal','FontName',fn)
        %         end
        %         xlim([0,inf])
        %         xtickangle(45)
        %         grid on
        %         ax = gca;
        %         ax.YAxis.FontSize = 12;
        %         ax.XAxis.FontSize = 12;
        %         ax.YAxis.Exponent = 0;
        %         ax.XAxis.Exponent = 0;
        %         ytickformat('%,6.0f')
        %         box on
        %         grid on
        %
        lgd = legend(nexttile(1));
        lgd.Layout.Tile  = 'south';
        lgd.NumColumns = 3;
        lgd.FontSize = ldfs_main;
        %     xticks(0:2.5:30)
        %     ylim([max(0, mean(DM(iX,:,:),[2,3]) - 7500) mean(DM(iX,:,:),[2,3]) + 7500])
        
        if figure_save == 1
            %         saveas(f, [home 'Figures/' char(pref) '/' char(figname_main) char(lng) '.png']);
            saveas(f, [dropbox_path 'Figures/' char(pref) '/' char(figfolder) '/' char(figname) '.png']);
        end
        
        
    end
end %End of language loop = figure loop

%% Other Plot
lgdfs = 12;
axfs = 12;
lineWidth = 2.0*ones(nY);
omicron_plot_parameter

% figure('Name','SR_transition')
% title_vec = ["Transition of S and R", "SとRの推移"];
% for iX = 1:nX
%     for iY = 1:nY
%         plot([S(2:end); squeeze(SimData(2:end,1,iX,iY))])
%         hold on
%         plot([R(2:end); squeeze(SimData(2:end,3,iX,iY))])
%         hold on
%     end
% end

%% Backdata
BRNpast = beta_tilde ./ (gamma + delta);
BackDataN           = zeros(8 + SimPeriod, nX, nY, nZ);
BackDataAlpha       = BackDataN;
BackDataERN         = BackDataN;
BackDataBRN         = BackDataN;
BackDatadD          = BackDataN;
BackDataICU_pref    = BackDataN;
BackDataNewICU_pref = BackDataN;
BackDataICU_nation  = BackDataN;
BackDataHospital    = BackDataN;
for iX = 1:nX
    for iY = 1:nY
        for iZ = 1:nZ
            BackDataN(:, iX, iY, iZ)            = [N(end - 7:end);          NPath(:, iX, iY, iZ)];
            BackDataAlpha(:, iX, iY, iZ)        = [alpha(end - 7:end);      AlphaPath(:, iX, iY, iZ)];
            BackDataERN(:, iX, iY, iZ)          = [ERN(end - 7:end);        SimERN(:, iX, iY, iZ)];
            BackDataBRN(:, iX, iY, iZ)          = [BRNpast(end - 7:end);    SimBRN(:, iX, iY, iZ)];
            BackDatadD(:, iX, iY, iZ)           = [dD(end - 7:end);         Sim_dD(:, iX, iY, iZ)];
            BackDataICU_pref(:, iX, iY, iZ)     = [ICU_pref(end - 7:end);   SimICU_pref(2:end, iX, iY, iZ)];
            BackDataNewICU_pref(:, iX, iY, iZ)     = [newICU_pref(end - 7:end);   SimNewICU_pref(2:end, iX, iY, iZ)];
            BackDataICU_nation(:, iX, iY, iZ)   = [ICU_nation(end - 7:end); SimICU_nation(2:end, iX, iY, iZ)];
            BackDataHospital(:, iX, iY, iZ)     = [hospital(end - 7:end);   SimHospital(2:end, iX, iY, iZ)];
        end
    end
end
%%
% if data_save == 1
%     for iX = 1:nX
%         titleN = strings(1, 1 + nZ * 9);
%         titleN(1) = "週";
%         for ti = 1:nZ
%             titleN(1, 1 + ti) = append("新規感染者数（", Scenario(ti), "）");
%             titleN(1, 1 + nZ + ti) = append("経済活動（", Scenario(ti), "）");
%             titleN(1, 1 + nZ * 2 + ti) = append("実効再生産数（", Scenario(ti), "）");
%             titleN(1, 1 + nZ * 3 + ti) = append("基本再生産数（", Scenario(ti), "）");
%             titleN(1, 1 + nZ * 4 + ti) = append("入院患者数（", Scenario(ti), "）");
%             titleN(1, 1 + nZ * 5 + ti) = append("重症者数_国基準（", Scenario(ti), "）");
%             titleN(1, 1 + nZ * 6 + ti) = append("重症者数_旧都基準（", Scenario(ti), "）");
%             titleN(1, 1 + nZ * 7 + ti) = append("重症者数_新都基準（", Scenario(ti), "）");
%             titleN(1, 1 + nZ * 8 + ti) = append("新規死亡者数（", Scenario(ti), "）");
%         end
%         TN = table([
%             titleN;
%             YearMonthWeekJP(Tdata - 7:end - 1), ...
%             squeeze(round(BackDataN(:, iX, iY, :) / 7)), ...
%             squeeze(round(100 * (1 - BackDataAlpha(:, iX, iY, :)), 1)), ...
%             squeeze(round(BackDataERN(:, iX, iY, :), 2)), ...
%             squeeze(round(BackDataBRN(:, iX, iY, :), 2)), ...
%             squeeze(round(BackDataHospital(:, iX, iY, :))), ...
%             squeeze(round(BackDataICU_nation(:, iX, iY, :))), ...
%             squeeze(round(BackDataICU_pref(:, iX, iY, :))), ...
%             squeeze(round(BackDataNewICU_pref(:, iX, iY, :))), ...
%             squeeze(round(BackDatadD(:, iX, iY, :) / 7))
%             ]);
%         writetable(TN, [dropbox_path 'Figures/' char(pref) '/' char(figfolder) '/BackData_' char(figname_main) '_' char(ScenarioEN(iX)) '.xls'], 'Sheet', '新規感染者数（1日平均）', 'WriteVariableNames', false);
%     end
if data_save == 1
    for iX = 1:nX
        titleN = strings(1, 11);
        titleN(1) = "週";
        titleN(1, 2) = "新規感染者数";
        titleN(1, 3) = "経済活動";
        titleN(1, 4) = "実効再生産数";
        titleN(1, 5) = "基本再生産数";
        titleN(1, 6) = "入院患者数";
        titleN(1, 7) = "重症者数_旧都基準";
        titleN(1, 8) = append("重症者数_新都基準（", lineNameJP{1}, "）");
        titleN(1, 9) = append("重症者数_新都基準（", lineNameJP{2}, "）");
        titleN(1, 10)= append("重症者数_新都基準（", lineNameJP{3}, "）");
        titleN(1, 11)= "新規死亡者数";
        
        TN = table([
            titleN;
            YearMonthWeekJP(Tdata - 7:end - 1), ...
            squeeze(round(BackDataN(:, iX, 2, 1) / 7)), ...
            squeeze(round(100 * (1 - BackDataAlpha(:, iX, 2, 1)), 1)), ...
            squeeze(round(BackDataERN(:, iX, 2, 1), 2)), ...
            squeeze(round(BackDataBRN(:, iX, 2, 1), 2)), ...
            squeeze(round(BackDataHospital(:, iX, 2, 1))), ...
            squeeze(round(BackDataICU_pref(:, iX, 2, 1))), ...
            squeeze(round(BackDataNewICU_pref(:, iX, :, 1))), ...
            squeeze(round(BackDatadD(:, iX, 2, 1) / 7))
            ]);
        writetable(TN, [home 'Figures\' char(pref) '\' char(figfolder) '\BackData_' char(figname_main) '_' char(ScenarioEN(iX)) '.xls'], 'Sheet', '新規感染者数（1日平均）', 'WriteVariableNames', false);
    end
end

% %%
% if data_save == 1
%     titleN = strings(1, 1 + length(TH_index) * 8);
%     titleN(1) = "週";
%
%     TN = table([titleN; YearMonthWeekJP(Tdata - 7:end - 1), ...
%                 round(BackDataN(:, 1:length(TH_index)) / 7), ...
%                 round(100 * (1 - BackDataAlpha(:, 1:length(TH_index))), 1), ...
%                 round(BackDataERN(:, 1:length(TH_index)), 2), ...
%                 round(BackDataICU_nation(:, 1:length(TH_index))), ...
%                 round(BackDataICU_pref(:, 1:length(TH_index))), ...
%                 round(BackDatadD(:, 1:length(TH_index)) / 7), ...
%                 round(BackDataHospital(:, 1:length(TH_index))),...
%                 round(BackDataBRN(:, 1:length(TH_index)), 2)]);
%
%     titleAD = ["経済損失（兆円）", "死亡者数", "ケース"];
%     TAD = table([titleAD; BackDataDA(1:length(TH), :)]);
%
%     %     TVAC = table([titleVAC; ...
%     %         MonthWeekJP(x_left-3:x_right),...
%     %         round(BackData_Area_nv_all(x_left-3:x_right,:))*10000]);
%     TVAC_new = table([titleVAC; ...
%                 YearMonthWeekJP(x_left - 3:x_right), ...
%                     round(BackData_Area_nv_all(x_left - 3:x_right, :) * 10000)]);
%
%     TVAC_cum = table([titleVAC; ...
%                     YearMonthWeekJP(x_left - 3:x_right), ...
%                     round(BackData_Area_cv_all(x_left - 3:x_right, :) * 100000000)]);
%
%     writetable(TN, [home 'Figures/' char(pref) '/' char(figfolder) '/BackData_' char(figname_main) char(pref) '.xls'], 'Sheet', '新規感染者数（1日平均）', 'WriteVariableNames', false);
%     writetable(TVAC_new, [home 'Figures/' char(pref) '/' char(figfolder) '/BackData_' char(figname_main) char(pref) '.xls'], 'Sheet', 'ワクチン新規接種パス', 'WriteVariableNames', false);
%     writetable(TVAC_cum, [home 'Figures/' char(pref) '/' char(figfolder) '/BackData_' char(figname_main) char(pref) '.xls'], 'Sheet', 'ワクチン累計接種パス', 'WriteVariableNames', false);
%     writetable(TAD, [home 'Figures/' char(pref) '/' char(figfolder) '/BackData_' char(figname_main) char(pref) '.xls'], 'Sheet', '経済損失と死亡者数', 'WriteVariableNames', false);
% end
%