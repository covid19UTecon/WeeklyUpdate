% This m-file executes simulation and generates figures for the
% analysis of the state of emergency placed in Tokyo in the paper
% "Covid-19 and Output in Japan" by Daisuke Fujii and Taisuke
% Nakata
% For Optimistic Scenario, set Scenario_switch = 1.

clear variables
close all
iPC = 0; % 0 for Mac, 1 for Windows

if iPC == 1
    home = '\Users\masam\Dropbox\fujii_nakata\Website\Codes\';
    %     home = '/Users/MEIP-users/Dropbox/fujii_nakata/Website/Codes/';
else
    %         home = '/Users/sohtakawawaki/Dropbox/fujii_nakata (1)/Website/Codes/';
    % home = '/Users/ymaeda/Dropbox/fujii_nakata/Policy_request/2021年8月/CabinetOffice_2021AUG13/';
    home = '/Users/okamotowataru/Dropbox/fujii_nakata/Website/Codes/';
%     home = '/Users/koheimachi/Dropbox/fujii_nakata/Website/Codes/';
%     home = '/Users/shotaro/Dropbox/fujii_nakata/Website/Codes/';
end

cd(home);
%====================== Program parameter values ======================%
pindex = 1;
figure_save = 0; % 0 = figures won't be saved, 1 = they will be saved
data_save = 0; % save back data
vaccine_figure_loop = 0; % =0 appear only once; =1 appear every loop;
beta_figure_loop = 0; % =0 appear only once; =1 appear every loop;
vaccine_disp_switch = 0; % =0 not display the summary of # of the vaccinated ; =1 display
delta_se0swtich = 1;
data_switch = 0; % Use I_data and gamma = mean(gamma_data(end-17+1:end))
% ICU_nation = 1; % = 1 use national definition (NHK data), = 0 use data from Tokyo Keizai
% in the "Figure" folder
fs = 12; % common font size for many figures
ldfs = 12; % legend font size for vaccine path
ft = '%.1f';

if iPC == 1
    fn = 'Yu Gothic'; % Font style for xaxis, yaxis, title
else
    fn = 'YuGothic';
end

language = {'EN', 'JP'};

% Scenario_switch = 1; % To simulate alternative case, choose Scenario_switch = 0
% linecolor = {'red', 'red', 'red', 'blue', 'blue', 'blue'};
Scenario_switch = 0;

if Scenario_switch == 0 %基本再生産数3,4,5
    %     linecolor = {'green', 'blue', 'magenta', 'red',  'black'};
    linecolor = {'blue', 'black', 'red',  'magenta'};
    
elseif Scenario_switch == 1 %基本再生産数4 + 1.5 2 2.5倍
    %     linecolor = {'green', 'blue', 'magenta', 'red',  'black'};
    linecolor = {'red', 'black', 'blue'};
elseif Scenario_switch == 2 %基本再生産数3
    %     linecolor = {'red', 'red', 'red','red', 'red'};
    %     linecolor = {'green', 'blue', 'magenta', 'red',  'black'};
    linecolor = {'blue', 'black', 'red'};
    
elseif Scenario_switch == 3 %Alternative vaccine scenario
    %     linecolor = {'red', 'red', 'red','red', 'red'};
    %     linecolor = {'green', 'blue', 'magenta', 'red',  'black'};
    linecolor = {'blue', 'red'};
    
    
end

%================== Model Fixed Parameter Values ============================%
parameter

%================ Parameter Values (Prefecture Specific) ====================%
prefecture_parameter

%--- Import data ---%
import_prefecture

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

ICU_nation(end) = 539; %2021/9/13 1031  %2021/08/30 1195; % 2021/08/09 %826; % 2021/08/02 % 678; % 2021/07/26 %2021/08/23 1096

% hospital(end) = 3749;

% Covid data are recorded at weekly frequencies (Mon-Sun)
% The first week start on January 20 (Mon), 2020

%--- Construct weekly vaccine data ---%
[V1_medical_ori, V1_medical_old, V2_medical_ori, V2_medical_old, ...
    V1_elderly_ori, V1_elderly_old, V2_elderly_ori, V2_elderly_old, ...
    V1_others_ori, V1_others_old, V2_others_ori, V2_others_old, ...
    vs_MT, vs_ET, vs_M1, vs_E1, vs_M2, vs_E2] ...
    = ImportVaccineData(home, iPC, Data, pref, dateEN, ps, vaccine_disp_switch);

[V1_medical, V2_medical, V1_elderly, V2_elderly, V1_others, V2_others] ...
    = ImportVaccineTokyo(home, dateEN, Data, Tdata, ps, iPC);
% V1_elderly = (V1_elderly_old + V1_others_old) * (sum(V1_elderly)/sum(V1_elderly + V1_others));
% V1_others = (V1_elderly_old + V1_others_old) * (sum(V1_others)/sum(V1_elderly + V1_others));
% V2_elderly = (V2_elderly_old + V2_others_old) * (sum(V2_elderly)/sum(V2_elderly + V2_others));
% V2_others = (V2_elderly_old + V2_others_old) * (sum(V2_others)/sum(V2_elderly + V2_others));

%if not full data for the last week is availale
% V1_medical(end) = V1_medical(end)*7/4;
% V2_medical(end) = V2_medical(end)*7/4;
V1_elderly(end) = V1_elderly(end) * 7/4;
V2_elderly(end) = V2_elderly(end) * 7/4;
V1_others(end) = V1_others(end) * 7/4;
V2_others(end) = V2_others(end) * 7/4;

%--- Constructing the reference level of output ---%
[potentialGDP, referenceGDP, alpha] = construct_GDP(GDP, TdataGDP);

%--- Regress mobility on alpha to estimate the elasticity h ---%
[Malt, h_all_ori, h_all_se, h_ori, h_se] = estimate_h(M, alpha, TdataGDP, RetroH, hconstant);

%--- Plot mobility data ---%
figname = string(['Mobility_GDP_' char(pref)]);
f = figure('Name', figname);
plot_mobility(Malt, alpha, Tdata, TdataGDP, YearMonthWeekJP, xtick1, fs, 16)

if figure_save == 1
    saveas(f, [home 'Figures/' char(pref) '/MobilityGDPLine_v.png']);
end

%--- Plot ICU data ---%
figname = string(['ICU_nation_transition_' char(pref)]);
f = figure('Name', figname);
plot(ICU_nation, 'LineWidth', 1.5)
title('Transition of  ICU (National Definition)')
ytickformat('%,6.0f')
xticks(find(WeekNumber == 1))
xticklabels(YearMonthWeekJP(WeekNumber == 1))
lgd.NumColumns = 2;
xtickangle(45)

figname = string(['ICU_prefecture_transition_' char(pref)]);
f = figure('Name', figname);
plot(ICU_pref, 'LineWidth', 1.5)
title('Transition of  ICU (Prefecture-Specific Definition)')
ytickformat('%,6.0f')
xticks(find(WeekNumber == 1))
xticklabels(YearMonthWeekJP(WeekNumber == 1))
lgd.NumColumns = 2;
xtickangle(45)

alpha_Jan = mean(alpha((dateEN >= datetime(2021, 1, 07)) & (datetime(2021, 1, 28) >= dateEN)));
alpha_Feb = mean(alpha((dateEN >= datetime(2020, 2, 7)) & (datetime(2020, 2, 28) >= dateEN))); % output loss without the state of emergency
alpha_Nov = mean(alpha((dateEN >= datetime(2020, 11, 5)) & (datetime(2020, 11, 26) >= dateEN))); % output loss without the state of emergency
alpha_June = mean(alpha((dateEN >= datetime(2020, 6, 4)) & (datetime(2020, 6, 25) >= dateEN))); % output loss without the state of emergency
alpha_Apr_May_2020 = mean(alpha((dateEN >= datetime(2020, 4, 2)) & (datetime(2020, 5, 28) >= dateEN)));

alpha_Jan_2020 = mean(alpha((dateEN >= datetime(2020, 1, 1)) & (datetime(2020, 1, 31) >= dateEN)));

alpha_Jan_Feb = mean(alpha((dateEN >= datetime(2021, 1, 07)) & (datetime(2021, 2, 25) >= dateEN)));

alpha_Aug = mean(alpha((dateEN >= datetime(2021, 8, 05)) & (datetime(2021, 8, 19) >= dateEN)));

ind_date = ind_date - 1;

alpha_off = alpha_Jan_2020; %0.5*alpha_Feb + 0.5*alpha_Nov;

alpha_lockdown = 0.5 * alpha_Apr_May_2020 + 0.5 * alpha_Jan_Feb; %alpha_Apr_May_2020;
alpha_jump = alpha_June;
state = 1;
alpha_scale = 1.0;
alpha_on = alpha(end); %alpha(end); %alpha_Jan; %(0.5 * alpha_May + 0.5 * alpha_Jan); %alpha_Jan; %alpha_scale * (0.5 * alpha_May + 0.5 * alpha_Jan);

% ======================================================= %
% ==================== CHANGE HERE ====================== %
% ======================================================= %
% TH = [-3, 0, 3, 3, 3];
% TH = [-3, 0, 3, 3];

alpha_red = 1.2;
alpha_black = 1.5;

% TH = [0, 3, -1.5];


Nymax_vec = [35000, 35000, 35000, 35000];

if Scenario_switch == 0 %基本再生産数 4
    Scenario = ["基本再生産数 3", "基本再生産数 4","基本再生産数 5" ,"基本再生産数 6"];
    ScenarioEN = ["BRN 3", "BRN 4", "BRN 5", "BRN 6"];
    
    accept_share = 0.92;
    accept_share_ordinary = 0.7094; %so that an accept share of age 13-64 = 80 %
    
    betaT_temp_ini = -0.7; %[-0.15,0,0,0,0,0,0,0]; %[0.1,0,0,0,0,0,0,0]; %-0.1
    start_beta = 1;
    beta_rho = 0.5; %[0.95,0,0,0,0];
    
    %     beta_goal = 1.2304;
    beta_goal = 1.3;
    
    lockdown_th_on = 0.9;
    lockdown_th_off = 0.5;
    
    %     TH = [7000 * 7, 10000 * 7, 7000 * 7];
    %     TH1 = [1.3, 0.6, 1.9];
    TH = [10000 * 7, 10000 * 7, 10000 * 7, 10000 * 7];
    TH1 = [0.6, 1.3, 1.9, 2.4];
    LineStyles = {"-", "-", "-", "-"};
    
    %     th_on = 7000 * 7;
    %         th_on = 12000 * 7;
    %     th_on = 19000 * 7;
    th_off = 500 * 7;
    
    xline_ind2 = find(date == datetime(2021, 9, 30)); % consider the case where state of emergency is extended
    xline_ind = find(date == datetime(2021, 9, 30)); % when the state of emergency end
    
    SOE_end = find(date == datetime(2021, 9, 30)) - Tdata;
    
    %     alpha_lockdown_main =  0.5 * alpha_Apr_May_2020 + 0.5 * alpha_Jan_Feb;%alpha_Apr_May_2020;
    alpha_lockdown_main = alpha_Jan;
    %     alpha_lockdown_vec = [alpha_lockdown_main, alpha_lockdown_main, alpha_lockdown_main, alpha_red * alpha_lockdown_main, alpha_black * alpha_lockdown_main];
    alpha_lockdown_vec = [alpha_lockdown_main, alpha_lockdown_main ,alpha_lockdown_main ,alpha_lockdown_main];
    alpha_jump = 0.7 * alpha_Jan;%alpha_on;
    
    beta_scale_vec = ones(1, 4) * 0.8;
    
    E1 = 0.45;
    E2 = 0.75;
    D1 = 0.865;
    D2 = 0.96;
    
    ICU_ylim = 1200;
    BED_ylim = 4000;
    Hospital_yiim = 18000;
    death_ylim = 80;
    N_ylim = 25000;
    GDP_ylim = 80;
    
    figname_main = string(['Baseline_MainResults_']);
    figname_beta_tilde = 'Baseline Scenario 1 Beta Tilde Path';
    figname_beta = 'Baseline Scenario 1 Beta Path';
    figname_var = 'Baseline Scenario 1 Variant_Share';
    figname_delta = 'Baseline Scenario 1 Death Rate transition';
    figname_ICU_nation = 'Baseline Scenario 1 ICU Rate transition National Standard';
    figname_ICU_local = 'Baseline Scenario 1 ICU Rate transition Local Standard';
    figname_ERN = 'Baseline Scenario 1 ERN transition';
    figname_Hospital = 'Baseline Scenario 1 Hospital Rate transition';
    figname_dD = 'Baseline Scenario 1 dD transition';
    
    
    th_off_date_vec = ones(1, 4) * (xline_ind2 - Tdata + 1);
    
elseif Scenario_switch == 1 %基本再生産数 4
    Scenario = ["医療体制1.5倍 (基本再生産数 4)", "医療体制2倍 (基本再生産数 4)","医療体制2.5倍 (基本再生産数 4)"];
    ScenarioEN = ["1.5 times Medical System Senario (BRN 4)", "2 times  Medical System Senario (BRN 4)","2.5 times Medical System Senario (BRN 4)"];
    
    %     accept_share = 0.95;
    %     accept_share_ordinary = 0.7739; %so that an accept share of age 13-64 = 90 %
    accept_share = 0.92;
    accept_share_ordinary = 0.7094; %so that an accept share of age 13-64 = 80 %
    
    betaT_temp_ini = -0.7; %[-0.15,0,0,0,0,0,0,0]; %[0.1,0,0,0,0,0,0,0]; %-0.1
    start_beta = 1;
    beta_rho = 0.5; %[0.95,0,0,0,0];
    
    beta_goal = 1.3;
    
    
    lockdown_th_on = 0.9;
    lockdown_th_off = 0.5;
    
%     TH = [8000 * 7, 5000 * 7, 12000 * 7];
    TH = [6000 * 7, 10000 * 7, 18000 * 7];
    
    LineStyles = {"-", "-", "-"};
    
    %         th_on = 6000 * 7;
    %     %     th_on = 12000 * 7;
    % %     th_on = 18000 * 7;
    th_off = 500 * 7;
    
    E1 = 0.45;
    E2 = 0.75;
    D1 = 0.865;
    D2 = 0.96;
    
    %     xline_ind2 = find(date == datetime(2021, 10, 14)); % consider the case where state of emergency is extended
    %     xline_ind = find(date == datetime(2021, 10, 14)); % when the state of emergency end
    %
    %     SOE_end = find(date == datetime(2021, 10, 14)) - Tdata;
    
    xline_ind2 = find(date == datetime(2021, 9, 30)); % consider the case where state of emergency is extended
    xline_ind = find(date == datetime(2021, 9, 30)); % when the state of emergency end
    
    SOE_end = find(date == datetime(2021, 9, 30)) - Tdata;
    
    %     alpha_lockdown_main =  0.5 * alpha_Apr_May_2020 + 0.5 * alpha_Jan_Feb;%alpha_Apr_May_2020;
    alpha_lockdown_main = alpha_Jan;
    %     alpha_lockdown_vec = [alpha_lockdown_main, alpha_lockdown_main, alpha_lockdown_main, alpha_red * alpha_lockdown_main, alpha_black * alpha_lockdown_main];
    alpha_lockdown_vec = [alpha_lockdown_main, alpha_lockdown_main ,alpha_lockdown_main ,alpha_lockdown_main];
    alpha_jump = 0.7 * alpha_Jan;%alpha_on;
    
    %     beta_scale_vec = ones(1, 5) * 0.8;
    beta_scale_vec = ones(1, 3) * 0.8;
    
    ICU_ylim = 1200;
    BED_ylim = 4100;
    Hospital_yiim = 18000;
    death_ylim = 55;
    N_ylim = 25000;
    GDP_ylim = 80;
    
    %     figname_main = 'Lockdown_MainResults_180';
    figname_main = string(['Different_Medical_Results_' 'BRN_4' '_']);
    figname_beta_tilde = 'Different Medical Scenario Beta Tilde Path';
    figname_beta = 'Different Medical Scenario Beta Path';
    figname_var = 'Different Medical Scenario Variant_Share';
    figname_delta = 'Different Medical Scenario Death Rate transition';
    figname_ICU_nation = 'Different Medical Scenario ICU Rate transition National Standard';
    figname_ICU_local = 'Different Medical Scenario ICU Rate transition Local Standard';
    figname_ERN = 'Different Medical Scenario ERN transition';
    figname_Hospital = 'Different Medical Scenario Hospital Rate transition';
    figname_dD = 'Different Medical Scenario dD transition';
    
    
    th_off_date_vec = ones(1, 3) * (xline_ind2 - Tdata + 1);
    
elseif Scenario_switch == 2 %基本再生産数 5
    Scenario = ["医療体制1.5倍 (基本再生産数 5)", "医療体制2倍 (基本再生産数 5)","医療体制2.5倍 (基本再生産数 5)"];
    ScenarioEN = ["Current Medical System Senario (BRN 5)", "1.5 times  Medical System Senario (BRN 5)","Twice Medical System Senario (BRN 5)"];
    
    
    accept_share = 0.9;
    accept_share_ordinary = 0.6449; %so that an accept share of age 13-64 = 75 %
    
    %     betaT_temp_ini = -0.3;%-0.35;%[-0.15,0,0,0,0,0,0,0];%[0.1,0,0,0,0,0,0,0];%-0.1
    %     start_beta = 3; %5;
    %     beta_rho = 0.7; %0.95 %[0.95,0,0,0,0];
    
    betaT_temp_ini = -0.5; %[-0.15,0,0,0,0,0,0,0]; %[0.1,0,0,0,0,0,0,0]; %-0.1
    start_beta = 1;
    beta_rho = 0.5; %[0.95,0,0,0,0];
    
    beta_goal = 1.9;
    
    
    lockdown_th_on = 0.9;
    lockdown_th_off = 0.5;
    
    TH = [4000 * 7, 8000 * 7, 12000 * 7];
    LineStyles = {"-", "-", "-"};
    
    %         th_on = 7000 * 7;
    %     %     th_on = 13000 * 7;
    %     %     th_on = 23000 * 7;
    th_off = 500 * 7;
    
    E1 = 0.45;
    E2 = 0.815;
    D1 = 0.865;
    D2 = 0.96;
    
    %     xline_ind2 = find(date == datetime(2021, 11, 25)); % consider the case where state of emergency is extended
    %     xline_ind = find(date == datetime(2021, 11, 25)); % when the state of emergency end
    %
    %     SOE_end = find(date == datetime(2021, 11, 25)) - Tdata;
    
    xline_ind2 = find(date == datetime(2021, 9, 30)); % consider the case where state of emergency is extended
    xline_ind = find(date == datetime(2021, 9, 30)); % when the state of emergency end
    
    SOE_end = find(date == datetime(2021, 9, 30)) - Tdata;
    
    %     alpha_lockdown_main =  0.5 * alpha_Apr_May_2020 + 0.5 * alpha_Jan_Feb;%alpha_Apr_May_2020;
    alpha_lockdown_main = alpha_Jan;
    %     alpha_lockdown_vec = [alpha_lockdown_main, alpha_lockdown_main, alpha_lockdown_main, alpha_red * alpha_lockdown_main, alpha_black * alpha_lockdown_main];
    alpha_lockdown_vec = [alpha_lockdown_main, alpha_lockdown_main ,alpha_lockdown_main];
    alpha_jump = 0.8 * alpha_Jan;%alpha_on;
    
    %     beta_scale_vec = ones(1, 5) * 0.9;
    beta_scale_vec = ones(1, 3) * 0.9;
    
    ICU_ylim = 1300;
    BED_ylim = 4500;
    Hospital_yiim = 22000;
    death_ylim = 70;
    N_ylim = 30000;
    GDP_ylim = 75;
    
    %     figname_main = 'Lockdown_MainResults_270';
    figname_main = string(['Pessimistic_MainResults_''BRN_5' '_']);
    figname_beta_tilde = 'Pessimistic Scenario Beta Tilde Path';
    figname_beta = 'Pessimistic Scenario Beta Path';
    figname_var = 'Pessimistic Scenario Variant_Share';
    figname_delta = 'Pessimistic Scenario Death Rate transition';
    figname_ICU_nation = 'Pessimistic Scenario ICU Rate transition National Standard';
    figname_ICU_local = 'Pessimistic Scenario ICU Rate transition Local Standard';
    figname_ERN = 'Pessimistic Scenario ERN transition';
    figname_Hospital = 'Pessimistic Scenario Hospital Rate transition';
    figname_dD = 'Pessimistic Scenario dD transition';
    
    th_off_date_vec = ones(1, 3) * (xline_ind2 - Tdata + 1);
    
    
elseif Scenario_switch == 3 %基本再生産数 4 + alternative ワクチン接種
    Scenario = ["基本再生産数 4 (ワクチン接種現状)", "基本再生産数 4 (ワクチン接種6月末)"];
    ScenarioEN = ["BRN 4 (Current Vaccine)", "BRN 4 (Alternative Vaccine)"];
    
    accept_share = 0.92;
    accept_share_ordinary = 0.7094; %so that an accept share of age 13-64 = 80 %
    
    betaT_temp_ini = -0.7; %[-0.15,0,0,0,0,0,0,0]; %[0.1,0,0,0,0,0,0,0]; %-0.1
    start_beta = 1;
    beta_rho = 0.5; %[0.95,0,0,0,0];
    

    
    %     beta_goal = 1.2304;
    beta_goal = 1.3;
    
    lockdown_th_on = 0.9;
    lockdown_th_off = 0.5;
    
    TH = [10000 * 7, 5000 * 7];
    
    LineStyles = {"-", "-"};
    
    %     th_on = 7000 * 7;
    %         th_on = 12000 * 7;
    %     th_on = 19000 * 7;
    th_off = 500 * 7;
    
    xline_ind2 = find(date == datetime(2021, 9, 30)); % consider the case where state of emergency is extended
    xline_ind = find(date == datetime(2021, 9, 30)); % when the state of emergency end
    
    SOE_end = find(date == datetime(2021, 9, 30)) - Tdata;
    
    %     alpha_lockdown_main =  0.5 * alpha_Apr_May_2020 + 0.5 * alpha_Jan_Feb;%alpha_Apr_May_2020;
    alpha_lockdown_main = alpha_Jan;
    %     alpha_lockdown_vec = [alpha_lockdown_main, alpha_lockdown_main, alpha_lockdown_main, alpha_red * alpha_lockdown_main, alpha_black * alpha_lockdown_main];
    alpha_lockdown_vec = [alpha_lockdown_main, 1.1 * alpha_lockdown_main];
    alpha_jump = 0.7 * alpha_Jan;%alpha_on;
    
    beta_scale_vec = ones(1, 2) * 0.8;
    
    E1 = 0.45;
    E2 = 0.75;
    D1 = 0.865;
    D2 = 0.96;
    
    ICU_ylim = 1200;
    BED_ylim = 4000;
    Hospital_yiim = 18000;
    death_ylim = 80;
    N_ylim = 25000;
    GDP_ylim = 80;
    
    figname_main = string(['Alternative_Vaccine_Results_' 'BRN_4' '_']);
    figname_beta_tilde = 'Alternative_Vaccine Scenario 1 Beta Tilde Path';
    figname_beta = 'Alternative_Vaccine Scenario 1 Beta Path';
    figname_var = 'Alternative_Vaccine Scenario 1 Variant_Share';
    figname_delta = 'Alternative_Vaccine Scenario 1 Death Rate transition';
    figname_ICU_nation = 'Alternative_Vaccine Scenario 1 ICU Rate transition National Standard';
    figname_ICU_local = 'Alternative_Vaccine Scenario 1 ICU Rate transition Local Standard';
    figname_ERN = 'Alternative_Vaccine Scenario 1 ERN transition';
    figname_Hospital = 'Alternative_Vaccine Scenario 1 Hospital Rate transition';
    figname_dD = 'Alternative_Vaccine Scenario 1 dD transition';
    
    th_off_date_vec = ones(1, 2) * (xline_ind2 - Tdata + 1);
    
    
end

%--- Compute the history of S, I, R, D in the data period ---%
if data_switch == 0
    [S, I, R, D] ...
        = SIRD(Tdata, POP0, N, E1, E2, ...
        V1_elderly, V1_medical, V1_others, V2_elderly, V2_medical, V2_others, ...
        gamma, dD, TdataGDP, referenceGDP, alpha);
else
    pastV = zeros(Tdata, 1);
    pastV(3:end) = E1 * (V1_elderly(1:end - 2) + V1_medical(1:end - 2) + V1_others(1:end - 2)) + (E2 - E1) * (V2_elderly(1:end - 2) + V2_medical(1:end - 2) + V2_others(1:end - 2));
    S = S_data;
    S(2:end) = S(2:end) - cumsum(pastV);
    R = R_data;
    R(2:end) = R(2:end) + cumsum(pastV);
    D = D_data;
end

InitialValues = [S(end), I(end), R(end), D(end), ICU_nation(end), ICU_pref(end), hospital(end)];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%% Main analysis starts here %%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

TH_index = TH;

% beta_scale_vec = [0.9, 0.9, 0.9, 0.85, 0.85, 0.85];
% beta_scale_vec = [0.9, 0.9, 0.9];
% th_off_date_vec = ones(1,6)*5; %[5, 5, 5]; % [6,6,6,8,8,8];

% xline_ind = find(date == datetime(2021, 10, 14)); % when the state of emergency end
xmax = find(date == datetime(2022, 3, 31));
% xmax = find(date == datetime(2026, 12, 31));
xmin = find(date == datetime(2021, 7, 1));
% xline_ind2 = find(date == datetime(2021, 10, 28)); % consider the case where state of emergency is extended

% th_off_date_vec = ones(1, 2) * (xline_ind2 - Tdata + 1);

beta_shock_after_emergency = 0.0; %0.375; %0.075;
rho_after_emergency = 0.8; %0.995; %0.95;
beta_shock_at_emergency = -0.5;
% alpha_jump = (alpha(end) - alpha_on) / (alpha_off - alpha_on);

h_scale = 1;
h = h_ori; % Estimated h using 17 weeks data
h_all = h_all_ori; % Estimated h using all periods data
h(2) = h_scale * h_ori(2); % Adjust coefficient of alpha = Higher elasticity to alpha

x_left = 59;
x_right = Tdata + 22;

% ======================================================= %
% ======================================================= %
% for iAlpha = 1:length(alpha_on_vector_sim)
%     alpha_on = alpha_on_vector_sim(iAlpha)
nTH = length(TH);
DMat = nan(1, length(TH));
AlphaMat = nan(1, length(TH));
SimData = nan(SimPeriod + 1, length(InitialValues), length(TH));
AlphaPath = nan(SimPeriod, length(TH));
NPath = nan(SimPeriod, length(TH));
SimERN = nan(SimPeriod, length(TH));
THonPath = nan(SimPeriod, length(TH));
BackDataN = zeros(SimPeriod + 8, length(TH_index));
BackDataAlpha = zeros(SimPeriod + 8, length(TH_index));
BackDataERN = zeros(SimPeriod + 8, length(TH_index));
betaPath = zeros(SimPeriod, nTH);
betaAvgVec = zeros(nTH, 1);
deltaAvgVec = zeros(nTH, 1);
betaAlphaPath = zeros(SimPeriod, nTH);
betaTildePath = zeros(SimPeriod, nTH);
deltaPath = zeros(SimPeriod, nTH);
delta_ICU_nationPath = zeros(SimPeriod, nTH);
delta_ICU_prefPath = zeros(SimPeriod, nTH);
delta_HospitalPath = zeros(SimPeriod, nTH);
varSharePath = zeros(SimPeriod, nTH);
varDeltaSharePath = zeros(SimPeriod, nTH);
Sim_dDPath = zeros(SimPeriod, nTH);
nbSimICU_nation = zeros(SimPeriod + 1, nTH);
SimICU_pref = zeros(SimPeriod + 1, nTH);
SimHospital = zeros(SimPeriod + 1, nTH);

for iTH = [2, 1, 3, 4]%[1, 2, 3]%%[1, 2]%[2, 1, 3]%1:length(TH) %[1, 2] %[2, 1, 3] %length(TH)
    h_se = 0; h_all_se = 0;
    %%%%%%%%%%% Change here %%%%%%%%%%%%%%%%%%%
    h = h_ori .* [1; h_scale] + h_se * TH(iTH);
    h_all = h_all_ori + h_all_se * TH(iTH);
    th_off_date = th_off_date_vec(iTH);
    beta_scale = beta_scale_vec(iTH);
    %     beta_goal = beta_goal_vec(iTH);
    alpha_lockdown = alpha_lockdown_vec(iTH);
    
    th_on = TH(iTH);
    
    if Scenario_switch ~= 3 && Scenario_switch ~= 1
        beta_goal = TH1(iTH);
    end
    
    if Scenario_switch == 3 && iTH == 2
        delta_temp_ini = 0.7;
        delta_ICU_nation_temp_ini = 0.3;
        delta_ICU_pref_temp_ini = 0.3;
        delta_Hospital_temp_ini = 0.3;
        scale_beta = 0.7;
    end
    
    
%     if Scenario_switch == 3 && iTH == 1
%         V1_elderly_Tokyo = V1_elderly;
%         V1_medical_Tokyo = V1_medical;
%         V1_others_Tokyo = V1_others;
%         V2_elderly_Tokyo  = V2_elderly;
%         V2_medical_Tokyo  = V2_medical;
%         V2_others_Tokyo = V2_others;
%         
%     elseif Scenario_switch == 3 && iTH == 2
%         
%         V1_elderly = zeros(Tdata,1);
%         V1_medical = zeros(Tdata,1);
%         V1_others = zeros(Tdata,1);
%         V2_elderly = zeros(Tdata,1);
%         V2_medical = zeros(Tdata,1);
%         V2_others = zeros(Tdata,1);
%         
%         Vac_shift_ind = find(date == datetime(2021, 6, 24));
%         
%         V1_elderly(Tdata - Vac_shift_ind + 1:end) = V1_elderly_Tokyo(1:Vac_shift_ind);
%         V1_medical(Tdata - Vac_shift_ind + 1:end) = V1_medical_Tokyo(1:Vac_shift_ind);
%         V1_others(Tdata - Vac_shift_ind + 1:end) = V1_others_Tokyo(1:Vac_shift_ind);
%         V2_elderly(Tdata - Vac_shift_ind + 1:end) = V2_elderly_Tokyo(1:Vac_shift_ind);
%         V2_medical(Tdata - Vac_shift_ind + 1:end) = V2_medical_Tokyo(1:Vac_shift_ind);
%         V2_others(Tdata - Vac_shift_ind + 1:end) = V2_others_Tokyo(1:Vac_shift_ind);
%         
%         
%         if data_switch == 0
%             [S, I, R, D] ...
%                 = SIRD(Tdata, POP0, N, E1, E2, ...
%                 V1_elderly, V1_medical, V1_others, V2_elderly, V2_medical, V2_others, ...
%                 gamma, dD, TdataGDP, referenceGDP, alpha);
%             InitialValues = [S(end), I(end), R(end), D(end), ICU_nation(end), ICU_pref(end), hospital(end)];
%             
%             
%         else
%             pastV = zeros(Tdata, 1);
%             pastV(3:end) = E1 * (V1_elderly(1:end - 2) + V1_medical(1:end - 2) + V1_others(1:end - 2)) + (E2 - E1) * (V2_elderly(1:end - 2) + V2_medical(1:end - 2) + V2_others(1:end - 2));
%             S = S_data;
%             S(2:end) = S(2:end) - cumsum(pastV);
%             R = R_data;
%             R(2:end) = R(2:end) + cumsum(pastV);
%             D = D_data;
%         end
%         
%         
%         
%         
%     end
%     
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    [delta, beta_tilde, ERN, beta, ICU_nation_inflow, ICU_pref_inflow, Hospital_inflow, ...
        gammaT, delta_average, delta_ICU_nation_average, delta_ICU_pref_average, delta_Hospital_average, ...
        ICU_nation_inflow_avg, ICU_pref_inflow_avg, Hospital_inflow_avg, simple_beta_avg, beta_se, ...
        delta_se, delta_ICU_nation_se, delta_ICU_pref_se, delta_Hospital_se] ...
        = Time_Series_Average(S, I, D, ICU_nation, ICU_pref, hospital, dD, N, Tdata, SimPeriod, ...
        RetroPeriod, POP0, hconstant, h_all, alpha, k, ...
        gamma, gamma_ICU_nation, gamma_ICU_pref, gamma_Hospital, ...
        ICU_nation_adjustment, ICU_pref_adjustment, Hospital_adjustment, ...
        RetroPeriodDelta, RetroPeriodICU_nation, RetroPeriodICU_pref, RetroPeriodHospital);
    
    %     delta_se = 0;
    %     beta_se = beta_se / 1.5;
    %      beta_se = 0;
    if delta_se0swtich == 1
        delta_se = 0;
        delta_ICU_nation_se = 0;
        delta_ICU_pref_se = 0;
        delta_Hospital_se = 0;
    end
    
    %%%%%%%%%%% Change here %%%%%%%%%%%%%%%%%%%
    delta_past_avg = delta_average; %Past RetroPeriodDelta weeks average
    delta_ICU_nation_past_avg = delta_ICU_nation_average;
    delta_ICU_pref_past_avg = delta_ICU_pref_average;
    delta_Hospital_past_avg = delta_Hospital_average;
    %beta_bar = beta_avg; %Past RetroPeriod weeks average
    %beta_avg = beta_bar + beta_se * TH(iTH);
    delta_average = delta_past_avg + delta_se * TH(iTH);
    delta_ICU_nation_average = delta_ICU_nation_past_avg + delta_ICU_nation_se * TH(iTH);
    delta_ICU_pref_average = delta_ICU_pref_past_avg + delta_ICU_pref_se * TH(iTH);
    delta_Hospital_average = delta_Hospital_past_avg + delta_Hospital_se * TH(iTH);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %     elderly_total = ps * elderly_jp;
    %     medical_total = ps * medical_jp;
    %     ordinary_total = ps * ordinary_jp;
    
    elderly_total = elderly_tokyo;
    medical_total = sum(V1_medical);
    ordinary_total = POP0 - elderly_total; % = working_tokyo + children_tokyo;
    working_total = working_tokyo - medical_total;
    
    medical = medical_total;
    elderly = elderly_total * accept_share;
    ordinary = ordinary_total * accept_share_ordinary; %working_total * accept_share_working_tokyo; % ordinary_total * accept_share_ordinary;
    %         elderly = elderly - (sum(V1_elderly));
    
    % %--- Eliminate the effects of delta variant from delta and beta---%
    
    delta_wo_alpha_series = delta ./ (1 + var_infection_delta); %Eliminate the effects of alpha variant in the past average value
    delta_ICU_nation_wo_alpha_series = delta ./ (1 + var_infection_delta);
    delta_ICU_pref_wo_alpha_series = delta ./ (1 + var_infection_delta);
    delta_Hospital_wo_alpha_series = delta ./ (1 + var_infection_delta);
    
    delta_wo_alpha = mean(delta_wo_alpha_series(end - RetroPeriodDelta + 1:end));
    delta_ICU_nation_wo_alpha = mean(delta_ICU_nation_wo_alpha_series(end - RetroPeriodICU_nation + 1:end));
    delta_ICU_pref_wo_alpha = mean(delta_ICU_pref_wo_alpha_series(end - RetroPeriodICU_pref + 1:end));
    delta_Hospital_wo_alpha = mean(delta_Hospital_wo_alpha_series(end - RetroPeriodHospital + 1:end));
    
    beta_wo_alpha_series = beta / (1 + var_infection);
    beta_wo_alpha = mean(beta_wo_alpha_series(end - RetroPeriod + 1:end));
    
    %--- Eliminate the effects of delta variant from delta and beta---%
    
    %--- Eliminate the effects of delta variant from beta---%
    [var_share2, var_prev2, var_initial2] = var_share_prev(Data(:, 24), SimPeriod, var_ss, var_growth2);
    [beta_wo_delta_series, beta_avg, beta_se] = variant_adjustment(beta_wo_alpha_series, var_prev2, RetroPeriod, var_infection2);
    [delta_wo_delta_series, delta_average, delta_se] = variant_adjustment(delta_wo_alpha, var_prev2, RetroPeriod, var_infection2);
    [delta_ICU_nation_wo_delta_series, delta_ICU_nation_average, delta_ICU_nation_se] = variant_adjustment(delta_ICU_nation_wo_alpha, var_prev2, RetroPeriod, var_infection2);
    [delta_ICU_pref_wo_delta_series, delta_ICU_pref_average, delta_ICU_pref_se] = variant_adjustment(delta_ICU_pref_wo_alpha, var_prev2, RetroPeriod, var_infection2);
    [delta_Hospital_wo_delta_series, delta_Hospital_average, delta_Hospital_se] = variant_adjustment(delta_Hospital_wo_alpha, var_prev2, RetroPeriod, var_infection2);
    
    beta_se = 0;
    
    beta_bar = beta_avg; %Past RetroPeriod weeks average
    beta_avg = beta_bar + beta_se * TH(iTH);
    deltaAvgVec(iTH) = delta_average;
    betaAvgVec(iTH) = beta_avg;
    
    %--- Construct vaccine distribution and delta path---%
    
    if Scenario_switch == 3 && iTH == 2
    else
        [V, VT] = ...
            vaccine_distribution(V1_medical, V2_medical, ...
            V1_elderly, V2_elderly, V1_others, V2_others, ...
            ind_date2, date_slowdown, date_slowdown2, date_slowdown3, lagged_VT2share, VT3share, ...
            elderly, medical, ordinary, lag, ...
            medical_duration, paces_ori, paces2, paces3, paces4, paces5, sw_vacpath, gradual_paces, gradual_paces2, ...
            E1, E2, D1, D2, ps, SimPeriod, Tdata);
    end
    
%     if Scenario_switch == 3 && iTH == 1
%         V_ori = V;
%         VT_ori = VT;
%     elseif Scenario_switch == 3 && iTH == 2
%         VT = zeros(SimPeriod, 6);
%         VT(1:Tdata - Vac_shift_ind,1) = V1_elderly_Tokyo(Vac_shift_ind + 1:Tdata);
%         VT(1:Tdata - Vac_shift_ind,2) = V2_elderly_Tokyo(Vac_shift_ind + 1:Tdata);
%         VT(1:Tdata - Vac_shift_ind,3) = V1_others_Tokyo(Vac_shift_ind + 1:Tdata);
%         VT(1:Tdata - Vac_shift_ind,4) = V2_others_Tokyo(Vac_shift_ind + 1:Tdata);
%         VT(1:Tdata - Vac_shift_ind,5) = V1_medical_Tokyo(Vac_shift_ind + 1:Tdata);
%         VT(1:Tdata - Vac_shift_ind,6) = V2_medical_Tokyo(Vac_shift_ind + 1:Tdata);
%         
%         VT(Tdata - Vac_shift_ind + 1:SimPeriod,:) = VT_ori(1:SimPeriod- (Tdata - Vac_shift_ind),:);
%         
%         V1 = E1*(VT(:,1)+VT(:,3)+VT(:,5))+(E2-E1)*(VT(:,2)+VT(:,4)+VT(:,6));
%         V2 = D1*VT(:,1)+(D2-D1)*VT(:,2);
%         V_ord = D1*(VT(:,3)+VT(:,5))+(D2-D1)*(VT(:,4)+VT(:,6));
%         V2 = [0;0;V2(1:end-2)];
%         V = [0;0;V1(1:end-2)];
%         V_ord = [0;0;V_ord(1:end-2)];
%         
%         V2(1) = sum(D1*V1_elderly(1:end-1)+(D2-D1)*V2_elderly(1:end-1));
%         V_ord(1) = sum(D1*V1_medical(1:end-1)+(D2-D1)*V2_medical(1:end-1) + D1*V1_others(1:end-1)+(D2-D1)*V2_others(1:end-1));
%         V2(2) = D1*V1_elderly(end)+(D2-D1)*V2_elderly(end);
%         V_ord(2) = (D1*V1_medical(end)+(D2-D1)*V2_medical(end)) + (D1*V1_others(end)+(D2-D1)*V2_others(end));
%         
%         V1_prev = E1*(V1_elderly+V1_medical+V1_others)+(E2-E1)*(V2_elderly+V2_medical+V2_others);
%         V(1) = V1_prev(end-1);
%         %     V(1) = V(1) + sum(V1_prev(1:end-1));
%         V(2) = V1_prev(end);
%     end
    
    
    
    delta_path
    
    %Assuming that alpha variant = 100% without delta variant
    deltaT = deltaT * (1 + var_infection_delta); %Alpha variant adjsutment for death rate
    delta_ICU_nation = delta_ICU_nation * (1 + var_infection_delta); %Alpha variant adjsutment for ICU rate
    delta_ICU_pref = delta_ICU_pref * (1 + var_infection_delta); %Alpha variant adjsutment for ICU rate
    delta_Hospital = delta_Hospital * (1 + var_infection_delta); %Alpha variant adjsutment for ICU rate
    
    %Delta variant adjustment
    deltaT = deltaT .* (1 + var_infection_delta2 * var_share2 / var_prev2(end));
    delta_ICU_nation = delta_ICU_nation .* (1 + var_infection_delta2 * var_share2 / var_prev2(end));
    delta_ICU_pref = delta_ICU_pref .* (1 + var_infection_delta2 * var_share2 / var_prev2(end));
    delta_Hospital = delta_Hospital .* (1 + var_infection_delta2 * var_share2 / var_prev2(end));
    
    
    % figure for vaccine path
    if vaccine_figure_loop == 0
        
        if iTH == 1
            [Vplot, BackData_Area_nv, BackData_Area_cv] = plot_vaccinepath_ym(200, VT, V1_medical, V2_medical, V1_elderly, V2_elderly, V1_others, V2_others, date, ps, YearMonthWeekJP, WeekNumber, Tdata, fs, ldfs, fn);
            
            titleVAC = strings(1, 1 + 6);
            titleVAC(1) = "週";
            
            startvalue = 1;
            titleVAC(1, 1 + startvalue) = "新規ワクチン接種本数(医療従事者1本目)";
            titleVAC(1, 1 + startvalue + 1) = "新規ワクチン接種本数(医療従事者2本目)";
            titleVAC(1, 1 + startvalue + 2) = "新規ワクチン接種本数(高齢者1本目)";
            titleVAC(1, 1 + startvalue + 3) = "新規ワクチン接種本数(高齢者2本目)";
            titleVAC(1, 1 + startvalue + 4) = "新規ワクチン接種本数(若者1本目)";
            titleVAC(1, 1 + startvalue + 5) = "新規ワクチン接種本数(若者2本目)";
            
            BackData_Area_nv_all = BackData_Area_nv;
            BackData_Area_cv_all = BackData_Area_cv;
        end
        
        
    elseif vaccine_figure_loop == 1
        [Vplot, BackData_Area_nv, BackData_Area_cv] = plot_vaccinepath_ym(200 + iTH, VT, V1_medical, V2_medical, V1_elderly, V2_elderly, V1_others, V2_others, date, ps, YearMonthWeekJP, WeekNumber, Tdata, fs, ldfs, fn);
        subplot(1, 2, 1)
        title(string(['新規ワクチン接種本数（週ごと）（', sprintf(ft, TH(iTH)), '）']), 'FontSize', fs, 'FontName', fn);
        subplot(1, 2, 2)
        title(string(['累計ワクチン接種本数（週ごと）（', sprintf(ft, TH(iTH)), '）']), 'FontSize', fs, 'FontName', fn);
        
        titleVAC = strings(1, 1 + length(TH_index) * 6);
        titleVAC(1) = "週";
        
        for ti = 1:length(TH_index)
            startvalue = (ti - 1) + 6;
            
            if ti == 1
                startvalue = 1;
            end
            
            titleVAC(1, 1 + startvalue) = append("新規ワクチン接種本数(医療従事者1本目)（", Scenario(ti), "）");
            titleVAC(1, 1 + startvalue + 1) = append("新規ワクチン接種本数(医療従事者2本目)（", Scenario(ti), "）");
            titleVAC(1, 1 + startvalue + 2) = append("新規ワクチン接種本数(高齢者1本目)（", Scenario(ti), "）");
            titleVAC(1, 1 + startvalue + 3) = append("新規ワクチン接種本数(高齢者2本目)（", Scenario(ti), "）");
            titleVAC(1, 1 + startvalue + 4) = append("新規ワクチン接種本数(若者1本目)（", Scenario(ti), "）");
            titleVAC(1, 1 + startvalue + 5) = append("新規ワクチン接種本数(若者2本目)（", Scenario(ti), "）");
        end
        
        if iTH == 1
            BackData_Area_nv_all = BackData_Area_nv;
            BackData_Area_cv_all = BackData_Area_cv;
        else
            BackData_Area_nv_all = cat(2, BackData_Area_nv_all, BackData_Area_nv);
            BackData_Area_cv_all = cat(2, BackData_Area_cv_all, BackData_Area_cv);
        end
        
    end
    
    %Assuming that alpha variant = 100% without delta variant
    beta_Eng = beta_avg * (1 + var_infection); %Alpha variant adjsutment for beta
    
    %Delta variant adjustment
    betaT = beta_Eng .* (1 + var_infection2 .* var_share2);
    
    % Seasonality
    seasonality = seasonal_adjustment(retro_lb, retro_ub, dateD, SimPeriod, seasonal_effect);
    
    %AR1 adjustment for betaT
    if Scenario_switch ~= 3 &&  iTH == 2
        betaT_woAR = betaT;
    elseif Scenario_switch == 3 &&  iTH == 1
        betaT_woAR = betaT;
        elseif Scenario_switch == 1 &&  iTH == 1
        betaT_woAR = betaT;
    end
    
    betaT = beta_AR1(betaT_temp_ini, beta_rho, betaT, start_beta);
    
    % ========== Change here ==================== %
    if Scenario_switch == 0 %ロックダウン90 %
        %                 beta_jump = 0.6;
        beta_jump = 0.5;
        %
        %         betaT(1) = betaT(1) * 0.925;
        %         betaT(2) = betaT(2) * 0.925; %1.7582;
        %         betaT(3:SOE_end) = betaT(3:SOE_end) * 1.15;
        %         betaT(4) = betaT(4) * 1.15;
        %
        %         alpha_jump = alpha(end);
    elseif Scenario_switch == 1 %ロックダウン180 %
        %                 beta_jump = 0.6;
        beta_jump = 0.5;
        %
        %         betaT(1) = betaT(1) * 0.925;
        %         betaT(2) = betaT(2) * 0.925; %1.7582;
        %         betaT(4) = betaT(4) * 1.15;
        
    elseif Scenario_switch == 2 %ロックダウン270 %
        %                 beta_jump = 0.6;
        beta_jump = 0.5;
        %
        %         betaT(1) = betaT(1) * 0.925;
        %         betaT(2) = betaT(2) * 0.925; %1.7582;
        %         betaT(4) = betaT(4) * 1.15;
        
        %         alpha_jump = alpha(end);
    elseif Scenario_switch == 3 %ロックダウン270 %
        %                 beta_jump = 0.6;
        beta_jump = 0.5;
        %
        %         betaT(1) = betaT(1) * 0.925;
        %         betaT(2) = betaT(2) * 0.925; %1.7582;
        %         betaT(4) = betaT(4) * 1.15;
        
        %         alpha_jump = alpha(end);
        
        
    end
    
    % ========== Change here ==================== %
    
    %AR1 adjustment for deltaT
    deltaT_woAR = deltaT;
    deltaT = beta_AR1(delta_temp_ini, delta_rho, deltaT, start_delta);
    
    %AR1 adjustment for delta_ICU_nation
    delta_ICU_nation_woAR = delta_ICU_nation;
    delta_ICU_nation = beta_AR1(delta_ICU_nation_temp_ini, delta_ICU_nation_rho, delta_ICU_nation, start_delta_ICU_nation);
    
    %
    %AR1 adjustment for delta_ICU_pref
    delta_ICU_pref_woAR = delta_ICU_pref;
    delta_ICU_pref = beta_AR1(delta_ICU_pref_temp_ini, delta_ICU_pref_rho, delta_ICU_pref, start_delta_ICU_pref);
    
    %
    %AR1 adjustment for delta_Hospital
    delta_Hospital_woAR = delta_Hospital;
    delta_Hospital = beta_AR1(delta_Hospital_temp_ini, delta_Hospital_rho, delta_Hospital, start_delta_Hospital);
    
    if Scenario_switch ~= 3 &&  iTH == 2
        betaT_ori = betaT;
        deltaT_ori = deltaT;
        delta_ICU_nation_ori = delta_ICU_nation;
        delta_ICU_pref_ori = delta_ICU_pref;
        delta_Hospital_ori = delta_Hospital;
    elseif Scenario_switch == 3 &&  iTH == 1
        betaT_ori = betaT;
        deltaT_ori = deltaT;
        delta_ICU_nation_ori = delta_ICU_nation;
        delta_ICU_pref_ori = delta_ICU_pref;
        delta_Hospital_ori = delta_Hospital;
    elseif Scenario_switch == 1 &&  iTH == 1
        betaT_ori = betaT;
        deltaT_ori = deltaT;
        delta_ICU_nation_ori = delta_ICU_nation;
        delta_ICU_pref_ori = delta_ICU_pref;
        delta_Hospital_ori = delta_Hospital;
    end
    
    betaT(1:SOE_end) = betaT_ori(1:SOE_end);
    deltaT(1:SOE_end) = deltaT_ori(1:SOE_end);
    delta_ICU_nation(1:SOE_end) = delta_ICU_nation_ori(1:SOE_end);
    delta_ICU_pref(1:SOE_end) = delta_ICU_pref_ori(1:SOE_end);
    delta_Hospital(1:SOE_end) = delta_Hospital_ori(1:SOE_end);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Simulation %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    BED_vec_Simdate = ones(SimPeriod, 1) * BED(end);
    ICU_limit_pref_vec_Simdate = ones(SimPeriod, 1) * ICU_limit_pref_vec(end);
    lockdown_state = 0;
    
    if Scenario_switch == 3 && iTH == 1
        V1_elderly_Tokyo = V1_elderly;
        V1_medical_Tokyo = V1_medical;
        V1_others_Tokyo = V1_others;
        V2_elderly_Tokyo  = V2_elderly;
        V2_medical_Tokyo  = V2_medical;
        V2_others_Tokyo = V2_others;
        
    elseif Scenario_switch == 3 && iTH == 2
        
        V1_elderly = zeros(Tdata,1);
        V1_medical = zeros(Tdata,1);
        V1_others = zeros(Tdata,1);
        V2_elderly = zeros(Tdata,1);
        V2_medical = zeros(Tdata,1);
        V2_others = zeros(Tdata,1);
        
        Vac_shift_ind = find(date == datetime(2021, 6, 24));
        
        V1_elderly(Tdata - Vac_shift_ind + 1:end) = V1_elderly_Tokyo(1:Vac_shift_ind);
        V1_medical(Tdata - Vac_shift_ind + 1:end) = V1_medical_Tokyo(1:Vac_shift_ind);
        V1_others(Tdata - Vac_shift_ind + 1:end) = V1_others_Tokyo(1:Vac_shift_ind);
        V2_elderly(Tdata - Vac_shift_ind + 1:end) = V2_elderly_Tokyo(1:Vac_shift_ind);
        V2_medical(Tdata - Vac_shift_ind + 1:end) = V2_medical_Tokyo(1:Vac_shift_ind);
        V2_others(Tdata - Vac_shift_ind + 1:end) = V2_others_Tokyo(1:Vac_shift_ind);
        
        
        if data_switch == 0
            [S, I, R, D] ...
                = SIRD(Tdata, POP0, N, E1, E2, ...
                V1_elderly, V1_medical, V1_others, V2_elderly, V2_medical, V2_others, ...
                gamma, dD, TdataGDP, referenceGDP, alpha);
            InitialValues = [S(end), I(end), R(end), D(end), ICU_nation(end), ICU_pref(end), hospital(end)];
            
            
        else
            pastV = zeros(Tdata, 1);
            pastV(3:end) = E1 * (V1_elderly(1:end - 2) + V1_medical(1:end - 2) + V1_others(1:end - 2)) + (E2 - E1) * (V2_elderly(1:end - 2) + V2_medical(1:end - 2) + V2_others(1:end - 2));
            S = S_data;
            S(2:end) = S(2:end) - cumsum(pastV);
            R = R_data;
            R(2:end) = R(2:end) + cumsum(pastV);
            D = D_data;
        end
        
         
    end
    
    if Scenario_switch == 3 && iTH == 1
        V_ori = V;
        VT_ori = VT;
    elseif Scenario_switch == 3 && iTH == 2
        VT = zeros(SimPeriod, 6);
        VT(1:Tdata - Vac_shift_ind,1) = V1_elderly_Tokyo(Vac_shift_ind + 1:Tdata);
        VT(1:Tdata - Vac_shift_ind,2) = V2_elderly_Tokyo(Vac_shift_ind + 1:Tdata);
        VT(1:Tdata - Vac_shift_ind,3) = V1_others_Tokyo(Vac_shift_ind + 1:Tdata);
        VT(1:Tdata - Vac_shift_ind,4) = V2_others_Tokyo(Vac_shift_ind + 1:Tdata);
        VT(1:Tdata - Vac_shift_ind,5) = V1_medical_Tokyo(Vac_shift_ind + 1:Tdata);
        VT(1:Tdata - Vac_shift_ind,6) = V2_medical_Tokyo(Vac_shift_ind + 1:Tdata);
        
        VT(Tdata - Vac_shift_ind + 1:SimPeriod,:) = VT_ori(1:SimPeriod- (Tdata - Vac_shift_ind),:);
        
        V1 = E1*(VT(:,1)+VT(:,3)+VT(:,5))+(E2-E1)*(VT(:,2)+VT(:,4)+VT(:,6));
        V2 = D1*VT(:,1)+(D2-D1)*VT(:,2);
        V_ord = D1*(VT(:,3)+VT(:,5))+(D2-D1)*(VT(:,4)+VT(:,6));
        V2 = [0;0;V2(1:end-2)];
        V = [0;0;V1(1:end-2)];
        V_ord = [0;0;V_ord(1:end-2)];
        
        V2(1) = sum(D1*V1_elderly(1:end-1)+(D2-D1)*V2_elderly(1:end-1));
        V_ord(1) = sum(D1*V1_medical(1:end-1)+(D2-D1)*V2_medical(1:end-1) + D1*V1_others(1:end-1)+(D2-D1)*V2_others(1:end-1));
        V2(2) = D1*V1_elderly(end)+(D2-D1)*V2_elderly(end);
        V_ord(2) = (D1*V1_medical(end)+(D2-D1)*V2_medical(end)) + (D1*V1_others(end)+(D2-D1)*V2_others(end));
        
        V1_prev = E1*(V1_elderly+V1_medical+V1_others)+(E2-E1)*(V2_elderly+V2_medical+V2_others);
        V(1) = V1_prev(end-1);
        %     V(1) = V(1) + sum(V1_prev(1:end-1));
        V(2) = V1_prev(end);
    end
 
    
    
    [DMat(iTH), AlphaMat(iTH), AlphaPath(:, iTH), SimData(:, :, iTH), NPath(:, iTH), SimERN(:, iTH), THonPath(:, iTH), SimICU_nation(:, iTH), SimICU_pref(:, iTH), SimHospital(:, iTH), betaShock] ...
        = Covid_projection_pref_date_NewCases(InitialValues, alpha_on, alpha_off, ...
        th_on, th_on2, th_off, th_off2, th_off3, ...
        betaT, gammaT, deltaT, delta_ICU_nation, delta_ICU_pref, delta_Hospital, V, h, k, POP0, hconstant, ...
        DRi, state, ICU_nation_inflow_avg, ICU_pref_inflow_avg, Hospital_inflow_avg, ...
        gamma_ICU_nation, gamma_ICU_pref, gamma_Hospital, alpha_jump, th_off_date, ...
        alpha_lockdown, lockdown_state, ...
        beta_jump, beta_goal, ...
        SOE_end, ...
        betaT_woAR, simple_beta_avg,...
        seasonality,...
        scale_beta);
    
    
    betaPath(:, iTH) = betaShock;
    betaShock_tilde = ((1 + (h(2) / h(1)) .* AlphaPath(:, iTH)).^k) .* betaShock;
    betaTildePath(:, iTH) = betaShock_tilde;
    
    deltaPath(:, iTH) = deltaT;
    delta_ICU_nationPath(:, iTH) = delta_ICU_nation;
    delta_ICU_prefPath(:, iTH) = delta_ICU_pref;
    delta_HospitalPath(:, iTH) = delta_Hospital;
    varSharePath(:, iTH) = var_share2;
    Sim_dDPath(:, iTH) = SimData(2:end, 4, iTH) - SimData(1:end - 1, 4, iTH);
    
end

%%%%%%%%
% Save variable names and values for backdata files
minAlpha = alpha_off; % 経済損失0の基準
AlphaM = AlphaMat(~isnan(AlphaMat));
AlphaM = (AlphaM - minAlpha) * prefGDP * 10000 * SimPeriod / 52;
DM = DMat(~isnan(DMat));
% BackDataDA(1:length(TH),:) = [round(AlphaM'),round(DM'),round(TH',1)];
BackDataDA(1:length(TH), :) = [round(AlphaM') / 10000, round(DM'), Scenario'];

%--- Record how many times on and off are triggered ---%
waves = zeros(1, length(TH));

for i = 1:length(TH)
    svec = zeros(SimPeriod - 1, 1);
    
    for t = 1:SimPeriod - 1
        svec(t) = AlphaPath(t + 1, i) - AlphaPath(t, i);
    end
    
    waves(i) = sum(svec > 0);
end

%%

for l = 1:2 %1:2 when english version needed
    
    if l == 1
        lineName = ScenarioEN;
    elseif l == 2
        lineName = Scenario;
    end
    
    % Generate graphs for the website
    lng = language{l};
    f = figure('Name', [char(figname_main) char(lng)]);
    %     if iPC == 1
    %         f.WindowState = 'maximized';
    %     else
    %         set(gcf,'Position',[100,100,1000,1000])
    %     end
    f.WindowState = 'maximized';
    
    %--- Number of people who are in ICU ---%
    subplot(3, 3, 1)
    BackDataICU_pref = ...
        plot_ICU(TH, TH_index, ICU_pref, SimICU_pref, ICU_limit, YearMonthWeekEN, YearMonthWeekJP, WeekNumber, Tdata, xline_ind, linecolor, fs, fn, ft, l, lineName, LineStyles);
    
    xline(xline_ind2, 'LineWidth', 1.5, 'HandleVisibility', 'off');
    %     if Scenario_switch == 0 % %|| Scenario_switch == 1
    %         xline(90, 'LineWidth', 1.5, 'HandleVisibility', 'off');
    %     elseif Scenario_switch == 1
    %         xline(90, 'LineWidth', 1.5, 'HandleVisibility', 'off');
    %     elseif Scenario_switch == 2
    %         xline(93, 'LineWidth', 1.5, 'HandleVisibility', 'off');
    %     end
    
    hold on
    %     plot(ICU_limit_pref_vec/2,'LineColor','black','LineStyle','--','DisplayName',"50%",'LineWidth',1.0,'HandleVisibility','off','LabelHorizontalAlignment','left','LabelVerticalAlignment','bottom')
    % plot([ICU_limit_pref_vec / 2; ones(SimPeriod, 1) * ICU_limit_pref_vec(end) / 2], '--k', 'HandleVisibility', 'off', 'LineWidth', 1.5)
    % text(xmin, ICU_limit_pref_vec(xmin) / 2 * 0.8, '50%', 'FontSize', fs)
    % hold on
    %     plot(ICU_limit_pref_vec,'LineColor','black','LineStyle','--','DisplayName',"100%",'LineWidth',1.0,'HandleVisibility','off','LabelHorizontalAlignment','left','LabelVerticalAlignment','bottom')
    plot([ICU_limit_pref_vec; ones(SimPeriod, 1) * ICU_limit_pref_vec(end)], '--k', 'HandleVisibility', 'off', 'LineWidth', 1.5)
    text(xmin, ICU_limit_pref_vec(xmin) * 1.1, '100%', 'FontSize', fs)
    hold on
            plot([ICU_limit_pref_vec * 1.5; ones(SimPeriod, 1) * ICU_limit_pref_vec(end) * 1.5], '--k', 'HandleVisibility', 'off', 'LineWidth', 1.5)
        text(xmin, ICU_limit_pref_vec(xmin) * 1.4, '150%', 'FontSize', fs)
%         plot([ICU_limit_pref_vec * 2; ones(SimPeriod, 1) * ICU_limit_pref_vec(end) * 2], '--k', 'HandleVisibility', 'off', 'LineWidth', 1.5)
%         text(xmin, ICU_limit_pref_vec(xmin) * 1.8, '200%', 'FontSize', fs)
%         plot([ICU_limit_pref_vec * 3; ones(SimPeriod, 1) * ICU_limit_pref_vec(end) * 3], '--k', 'HandleVisibility', 'off', 'LineWidth', 1.5)
%         text(xmin, ICU_limit_pref_vec(xmin) * 2.8, '300%', 'FontSize', fs)
    %
    %     plot([ICU_limit_pref_vec * 0.9; ones(SimPeriod, 1) * ICU_limit_pref_vec(end) * 0.9], '--k', 'HandleVisibility', 'off', 'LineWidth', 1.5)
    %     text(xmin, ICU_limit_pref_vec(xmin) * 0.9, '90%', 'FontSize', fs)
    plot([ICU_limit_pref_vec * 0.5; ones(SimPeriod, 1) * ICU_limit_pref_vec(end) * 0.5], '--k', 'HandleVisibility', 'off', 'LineWidth', 1.5)
    text(xmin, ICU_limit_pref_vec(xmin) * 0.5, '50%', 'FontSize', fs)
    
    
    if l == 1
        title('ICU (Tokyo Standard)', 'FontSize', fs, 'FontWeight', 'normal')
        xticklabels(YearMonthWeekEN(WeekNumber == 1))
        %xticklabels(datestr(MonthWeekEN(xtick1), 'mmm-yy'))
    elseif l == 2
        title('重症患者数（都基準）', 'FontSize', fs, 'FontWeight', 'normal', 'FontName', fn)
        xticklabels(YearMonthWeekJP(WeekNumber == 1))
    end
    
    xlim([xmin, xmax])
    %     xticks(find(WeekNumber == 1 & abs(1 - mod(MonthNumber, 4)) < 0.01))
    xticks(find(WeekNumber == 1))
    %     xticklabels(YearMonthWeekJP(xticks))
    xticklabels(YearMonthJP(xticks))
    
    %     ylim([0 ICU_limit_pref_vec(end) * 3 * 1.3]) %ylim([0 ICU_limit * 1.1])
    Simmax = max(SimICU_pref(1:(xmax - Tdata),:), [], 'all');
    Datamax = max(ICU_pref(xmin:end));
    ylim([0  max(Simmax, Datamax) * 1.1]) %ylim([0 ICU_limit * 1.1])
    
    subplot(3, 3, 2)
    
    BackDataICU_nation = ...
        plot_ICU(TH, TH_index, ICU_nation, SimICU_nation, BED(Tdata), YearMonthWeekEN, YearMonthWeekJP, WeekNumber, Tdata, xline_ind, linecolor, fs, fn, ft, l, lineName, LineStyles);
    
    
    
    xline(xline_ind2, 'LineWidth', 1.5, 'HandleVisibility', 'off');
    hold on
    
    hold on
    %     plot(ICU_limit_pref_vec,'LineColor','black','LineStyle','--','DisplayName',"100%",'LineWidth',1.0,'HandleVisibility','off','LabelHorizontalAlignment','left','LabelVerticalAlignment','bottom')
    plot([BED; ones(SimPeriod, 1) * BED(end)], '--k', 'HandleVisibility', 'off', 'LineWidth', 1.5)
    text(xmin, BED(xmin) * 1.2, '100%', 'FontSize', fs)
    plot([BED * 1.5; ones(SimPeriod, 1) * BED(end) * 1.5], '--k', 'HandleVisibility', 'off', 'LineWidth', 1.5)
    text(xmin, BED(xmin) * 1.6, '150%', 'FontSize', fs)
        plot([BED * 2; ones(SimPeriod, 1) * BED(end) * 2], '--k', 'HandleVisibility', 'off', 'LineWidth', 1.5)
        text(xmin, BED(xmin) * 1.2 * 1.5, '200%', 'FontSize', fs)
%         plot([BED * 2.5; ones(SimPeriod, 1) * BED(end) * 2.5], '--k', 'HandleVisibility', 'off', 'LineWidth', 1.5)
%         text(xmin, BED(xmin) * 0.9 * 2.7, '250%', 'FontSize', fs)
%         plot([BED * 3; ones(SimPeriod, 1) * BED(end) * 3], '--k', 'HandleVisibility', 'off', 'LineWidth', 1.5)
%         text(xmin, BED(xmin) * 0.9 * 3, '300%', 'FontSize', fs)
    
    plot([BED * 0.5; ones(SimPeriod, 1) * BED(end) * 0.5], '--k', 'HandleVisibility', 'off', 'LineWidth', 1.5)
    text(xmin, BED(xmin) * 0.5, '50%', 'FontSize', fs)
    %     plot([BED * 0.9; ones(SimPeriod, 1) * BED(end) * 0.9], '--k', 'HandleVisibility', 'off', 'LineWidth', 1.5)
    %     text(xmin, BED(xmin) * 0.9, '90%', 'FontSize', fs)
    
    
    if l == 1
        title('ICU (National Standard)', 'FontSize', fs, 'FontWeight', 'normal')
        xticklabels(YearMonthWeekEN(WeekNumber == 1))
        %xticklabels(datestr(MonthWeekEN(xtick1), 'mmm-yy'))
    elseif l == 2
        title('重症患者数（国基準）', 'FontSize', fs, 'FontWeight', 'normal', 'FontName', fn)
        xticklabels(YearMonthWeekJP(WeekNumber == 1))
    end
    
    xlim([xmin, xmax])
    xticks(find(WeekNumber == 1))
    %     xticklabels(YearMonthWeekJP(xticks))
    xticklabels(YearMonthJP(xticks))
    
    %     ylim([0 BED(end) * 3 * 1.3]) %ylim([0 2500])
    %     ylim([0 BED_ylim]) %ylim([0 2500])
    %     ylim([0  max(SimICU_nation(1:(xmax - Tdata),:), [], 'all') * 1.1]) %ylim([0 ICU_limit * 1.1])
    
    Simmax = max(SimICU_nation(1:(xmax - Tdata),:), [], 'all');
    Datamax = max(ICU_nation(xmin:end));
    ylim([0  max(Simmax, Datamax) * 1.1]) %ylim([0 ICU_limit * 1.1])
    
    Handle = legend;
    set(Handle, 'Visible', 'off');
    
    %     lineStyle = {'-', '-', '-', '-', '-', '-'};
    lineStyle = {'-', '-', '-'};
    %     lineWidth = [0.5,1.5,0.5,0.5,1.5,0.5];
    %     lineWidth = [0.5, 1.5, 0.5, 1.5, 0.5];
    lineWidth = [1.5, 1.5, 1.5, 0.75];
    %     lineWidth = [1.5, 1.5];
    lgfs = 12;
    show_other = 0; % Do not show lines other than TH index
    yft = '%.0f';
    column = 2;
    
    %--- Number of newly hospitalized ---%
    subplot(3, 3, 3)
    eTitle = 'Hospitalized Patients';
    jTitle = '入院患者数';
    plot_function(TH, TH_index, hospital(2:end), SimHospital(2:end, :), ...
        YearMonthWeekEN, YearMonthWeekJP, WeekNumber, Tdata, Tdata, linecolor, lineWidth, lineName, ...
        eTitle, jTitle, fs, lgfs, fn, ft, yft, column, l, show_other, 'Northwest')
    
    
    xline(xline_ind2, 'LineWidth', 1.5, 'HandleVisibility', 'off');
    
    xlim([xmin, xmax])
    %     xticks(find(WeekNumber == 1 & abs(1 - mod(MonthNumber, 4)) < 0.01))
    xticks(find(WeekNumber == 1))
    %     xticklabels(YearMonthWeekJP(xticks))
    xticklabels(YearMonthJP(xticks))
    
    Handle = legend;
    set(Handle, 'Visible', 'off');
    %     plot([Hospital_limit_vec/2;ones(SimPeriod,1) * Hospital_limit_vec(end)/2],'--k','HandleVisibility', 'off', 'LineWidth', 1.5)
    %     text(72,Hospital_limit_vec(72)/2*0.8,'50%', 'FontSize', fs)
    hold on
    %     plot(ICU_limit_pref_vec,'LineColor','black','LineStyle','--','DisplayName',"100%",'LineWidth',1.0,'HandleVisibility','off','LabelHorizontalAlignment','left','LabelVerticalAlignment','bottom')
    plot([Hospital_limit_vec; ones(SimPeriod, 1) * Hospital_limit_vec(end)], '--k', 'HandleVisibility', 'off', 'LineWidth', 1.5)
    text(xmin, Hospital_limit_vec(xmin) * 0.9, '100%', 'FontSize', fs)
    plot([Hospital_limit_vec * 2; ones(SimPeriod, 1) * Hospital_limit_vec(end) * 2], '--k', 'HandleVisibility', 'off', 'LineWidth', 1.5)
    text(xmin, Hospital_limit_vec(xmin) * 0.9 * 2, '200%', 'FontSize', fs)
        text(72,Hospital_limit_vec(72)*0.9 * 2,'200%', 'FontSize', fs)
    plot([Hospital_limit_vec * 3; ones(SimPeriod, 1) * Hospital_limit_vec(end) * 3], '--k', 'HandleVisibility', 'off', 'LineWidth', 1.5)
    text(xmin, Hospital_limit_vec(72) * 0.9 * 3, '300%', 'FontSize', fs)
    %     plot([Hospital_limit_vec * 4; ones(SimPeriod, 1) * Hospital_limit_vec(end) * 4], '--k', 'HandleVisibility', 'off', 'LineWidth', 1.5)
    %     text(xmin, Hospital_limit_vec(72) * 0.95 * 4, '400%', 'FontSize', fs)
    %     ylim([0 Hospital_limit_vec(end) * 5])
    %     ylim([0 Hospital_yiim])
    
    %     ylim([0  max(SimHospital(1:(xmax - Tdata),:), [], 'all') * 1.1]) %ylim([0 ICU_limit * 1.1])
    Simmax = max(SimHospital(1:(xmax - Tdata),:), [], 'all');
    Datamax = max(hospital(xmin:end));
    ylim([0  max(Simmax, Datamax) * 1.1]) %ylim([0 ICU_limit * 1.1])
    
    % ylim([0 Hospital_limit_vec(end) * 3 * 1.1])
    %     ylim([0 10000])
    
    subplot(3, 3, 4)
    eTitle = 'New Deaths (Daily Average)';
    jTitle = '新規死亡者数（1日平均）';
    plot_function(TH, TH_index, dD / 7, Sim_dDPath / 7, ...
        YearMonthWeekEN, YearMonthWeekJP, WeekNumber, Tdata, Tdata, linecolor, lineWidth, lineName, ...
        eTitle, jTitle, fs, lgfs, fn, ft, yft, column, l, show_other, 'Northwest')
    
    xline(xline_ind2, 'LineWidth', 1.5, 'HandleVisibility', 'off');
    
    xlim([xmin, xmax])
    %     xticks(find(WeekNumber == 1 & abs(1 - mod(MonthNumber, 4)) < 0.01))
    xticks(find(WeekNumber == 1))
    %     xticklabels(YearMonthWeekJP(xticks))
    xticklabels(YearMonthJP(xticks))
    
    %     ylim([0 50])
    %     ylim([0 death_ylim])
    %     ylim([0  max(Sim_dDPath(1:(xmax - Tdata),:), [], 'all')/7 * 1.1]) %ylim([0 ICU_limit * 1.1])
    
    Simmax = max(Sim_dDPath(1:(xmax - Tdata),:), [], 'all')/7;
    Datamax = max(dD(xmin:end))/7;
    ylim([0  max(Simmax, Datamax) * 1.1]) %ylim([0 ICU_limit * 1.1])
    
    Handle = legend;
    set(Handle, 'Visible', 'off');
    
    %--- Number of new cases ---%
    eTitle = 'New Cases (Daily Average)';
    jTitle = '新規感染者数（1日平均）';
    subplot(3, 3, 5)
    plot_function(TH, TH_index, N / 7, NPath / 7, ...
        YearMonthWeekEN, YearMonthWeekJP, WeekNumber, Tdata, Tdata, linecolor, lineWidth, lineName, ...
        eTitle, jTitle, fs, lgfs, fn, ft, yft, column, l, show_other, 'Southwest')
    
    
    xline(xline_ind2, 'LineWidth', 1.5, 'HandleVisibility', 'off');
    %
    Handle = legend;
    set(Handle, 'Visible', 'off');
    xticks(find(WeekNumber == 1))
    xtickangle(45)
    xlim([xmin, xmax])
    %     xticks(find(WeekNumber == 1 & abs(1 - mod(MonthNumber, 4)) < 0.01))
    xticks(find(WeekNumber == 1))
    %     xticklabels(YearMonthWeekJP(xticks))
    xticklabels(YearMonthJP(xticks))
    
    % ylim([0, 12000])
    %     ylim([0, Nymax_vec(Scenario_switch + 1)])
    
    Simmax = max(NPath(1:(xmax - Tdata),:), [], 'all')/7;
    Datamax = max(N(xmin:end))/7;
    ylim([0  max(Simmax, Datamax)*1.1]) %ylim([0 ICU_limit * 1.1])
    
    %     ylim([0  max(NPath(1:(xmax - Tdata),:), [], 'all')/7 * 1.1]) %ylim([0 ICU_limit * 1.1])
    
    %--- GDP Path ---%
    subplot(3, 3, 6)
    YearMonthWeek = [YearMonthWeekEN, YearMonthWeekJP];
    plot_Alpha(alpha, AlphaPath, TH, TH_index, YearMonthWeek(:, l), WeekNumber, MonthNumber, Tdata, linecolor, ft, fs, fn, l)
    title('GDP', 'FontSize', fs, 'FontWeight', 'normal')
    
    
    xline(xline_ind2, 'LineWidth', 1.5, 'HandleVisibility', 'off');
    xlim([1, xmax])
    xticks(find(WeekNumber == 1 & abs(1 - mod(MonthNumber, 4)) < 0.01))
    xticks(find(WeekNumber == 1))
    %     xticklabels(YearMonthWeekJP(xticks))
    xticklabels(YearMonthJP(xticks))
    ylim([GDP_ylim, 100])
    
    %     xlim([xmin, xmax])
    
    subplot(3, 3, 7)
    eTitle = 'Transitions of ERN';
    jTitle = '実効再生産数';
    plot_function(TH, TH_index, ERN, SimERN, ...
        YearMonthWeekEN, YearMonthWeekJP, WeekNumber, Tdata, Tdata, linecolor, lineWidth, lineName, ...
        eTitle, jTitle, fs, lgfs, fn, ft, "%.1f", column, l, show_other, 'Northwest')
    Handle = legend;
    set(Handle, 'Visible', 'off');
    if Scenario_switch == 3
        legend({'基本ワクチンペース', 'ワクチン6月末'}) 
    elseif Scenario_switch == 1
        legend({'許容新規感染者数 6000人','許容新規感染者数 10000人(医療体制1.5倍)','許容新規感染者数 18000人'})
    else
        legend({'基本再生産数 3','基本再生産数 4', '基本再生産数 5', '基本再生産数 6'})
    end
    lgd = legend;
    lgd.FontSize = 7;
    lgd.Location = 'Northeast';
    xticks(find(WeekNumber == 1))
    xtickangle(45)
    xlim([xmin, xmax])
    %     xticks(find(WeekNumber == 1 & abs(1 - mod(MonthNumber, 4)) < 0.01))
    xticks(find(WeekNumber == 1))
    %     xticklabels(YearMonthWeekJP(xticks))
    xticklabels(YearMonthJP(xticks))
    
    yline(1, 'LineWidth', 1, 'HandleVisibility', 'off')
    
    
    xline(xline_ind2, 'LineWidth', 1.5, 'HandleVisibility', 'off');
    
    subplot(3, 3, 8) %Cumulative vaccinated
    
    plot_vaccinepath_separate_percentage(2, VT, V1_medical, V2_medical, V1_elderly, V2_elderly, V1_others, V2_others, ps, YearMonthWeek(:, l), WeekNumber, Tdata, fs, 8, fn, x_left, x_right, l, POP0);
    yticks(0:10:100)
    grid on
    xlim([x_left, xmax])
    %     xticks(find(WeekNumber == 1 & abs(1 - mod(MonthNumber, 4)) < 0.01))
    xticks(find(WeekNumber == 1))
    %     xticklabels(YearMonthWeekJP(xticks))
    xticklabels(YearMonthJP(xticks))
    lgd = legend;
    lgd.FontSize = 12;
    lgd.Location = 'Southeast';
    
    
    xline(xline_ind2, 'LineWidth', 1.5, 'HandleVisibility', 'off');
    
    %--- Trade-off Curve ---%
    subplot(3, 3, 9)
    plot_Tradeoff2(AlphaM / 10000, DM, waves, TH, TH_index, l, linecolor, fs, fn)
    grid on
    xticks(0:2.5:30)
    
    ylim([max(0,mean(DM) - 7500) mean(DM) + 7500])
    
    if figure_save == 1
        saveas(f, [home 'Figures/' char(pref) '/' char(figname_main) char(lng) '.png']);
    end
    
end %End of language loop = figure loop

%%
th_wave = 1;

for i = 1:nTH
    
    if abs(TH(i) - TH_index(th_wave)) < 0.0001
        BackDataN(:, th_wave) = [N(end - 7:end); NPath(:, i)];
        BackDataAlpha(:, th_wave) = [alpha(end - 7:end); AlphaPath(:, i)];
        BackDataERN(:, th_wave) = [ERN(end - 7:end); SimERN(:, i)];
        BackDatadD(:, th_wave) = [dD(end - 7:end); Sim_dDPath(:, i)];
        BackDataHospital(:, th_wave) = [hospital(end - 7:end); SimHospital(2:end, i)];
        th_wave = th_wave + 1;
        
        if th_wave > length(TH_index)
            th_wave = length(TH_index);
        end
        
    end
    
end

if data_save == 1
    titleN = strings(1, 1 + length(TH_index) * 6);
    titleN(1) = "週";
    
    for ti = 1:length(TH_index)
        titleN(1, 1 + ti) = append("新規感染者数（", Scenario(ti), "）");
        titleN(1, 1 + length(TH_index) + ti) = append("経済活動（", Scenario(ti), "）");
        titleN(1, 1 + length(TH_index) * 2 + ti) = append("実効再生産数（", Scenario(ti), "）");
        titleN(1, 1 + length(TH_index) * 3 + ti) = append("重症者数_国基準（", Scenario(ti), "）");
        titleN(1, 1 + length(TH_index) * 4 + ti) = append("重症者数_都基準（", Scenario(ti), "）");
        titleN(1, 1 + length(TH_index) * 5 + ti) = append("新規死亡者数（", Scenario(ti), "）");
        titleN(1, 1 + length(TH_index) * 6 + ti) = append("入院患者数（", Scenario(ti), "）");
    end
    
    TN = table([titleN; YearMonthWeekJP(Tdata - 7:end - 1), ...
        round(BackDataN(:, 1:length(TH_index)) / 7), ...
        round(100 * (1 - BackDataAlpha(:, 1:length(TH_index))), 1), ...
        round(BackDataERN(:, 1:length(TH_index)), 2), ...
        round(BackDataICU_nation(:, 1:length(TH_index))), ...
        round(BackDataICU_pref(:, 1:length(TH_index))), ...
        round(BackDatadD(:, 1:length(TH_index)) / 7), ...
        round(BackDataHospital(:, 1:length(TH_index)))]);
    
    titleAD = ["経済損失（兆円）", "死亡者数", "ケース"];
    TAD = table([titleAD; BackDataDA(1:length(TH), :)]);
    writetable(TN, [home 'Figures/' char(pref) '/BackData_' char(figname_main) char(pref) '.xls'], 'Sheet', '新規感染者数（1日平均）', 'WriteVariableNames', false);
    
    %     TVAC = table([titleVAC; ...
    %         MonthWeekJP(x_left-3:x_right),...
    %         round(BackData_Area_nv_all(x_left-3:x_right,:))*10000]);
    TVAC_new = table([titleVAC; ...
        YearMonthWeekJP(x_left - 3:x_right), ...
        round(BackData_Area_nv_all(x_left - 3:x_right, :) * 10000)]);
    
    TVAC_cum = table([titleVAC; ...
        YearMonthWeekJP(x_left - 3:x_right), ...
        round(BackData_Area_cv_all(x_left - 3:x_right, :) * 100000000)]);
    
    writetable(TVAC_new, [home 'Figures/' char(pref) '/BackData_' char(figname_main) char(pref) '.xls'], 'Sheet', 'ワクチン新規接種パス', 'WriteVariableNames', false);
    writetable(TVAC_cum, [home 'Figures/' char(pref) '/BackData_' char(figname_main) char(pref) '.xls'], 'Sheet', 'ワクチン累計接種パス', 'WriteVariableNames', false);
    writetable(TAD, [home 'Figures/' char(pref) '/BackData_' char(figname_main) char(pref) '.xls'], 'Sheet', '経済損失と死亡者数', 'WriteVariableNames', false);
end

%% Other Plot
lgfs = 16;
column = 3;
l = 2; %Japanese
show_other = 0; % Do not show lines other than TH index
yft = '%.0f';

% Transitions of N and I

figname_NI = 'NI_transitions';
lineName = cell(nTH, 1);
lineName2 = cell(nTH, 1);

for i = 1:nTH
    lineName{i} = append("I,", Scenario(i));
    lineName2{i} = append("N,", Scenario(i));
end

eTitle = 'Transitions of N and I';
jTitle = 'NとIの推移';
figure('Name', char(figname_NI));
set(gcf, 'Position', [100, 100, 1200, 800])
plot_function2(TH, TH_index, I(2:end), SimData(2:end, 2, :), N / 7, NPath / 7, ...
    YearMonthWeekEN, YearMonthWeekJP, WeekNumber, Tdata, xline_ind, linecolor, lineName, ...
    lineName2, eTitle, jTitle, fs, lgfs, fn, ft, yft, column, l, show_other, 'SouthOutside')
% xlim([Tdata - 31 Tdata + 41])
xlim([x_left, xmax])
% xticks(find(WeekNumber == 1 & abs(1 - mod(MonthNumber, 3)) < 0.01))
xticks(find(WeekNumber == 1 & abs(1 - mod(MonthNumber, 4)) < 0.01))
%     xticklabels(YearMonthWeekJP(xticks))
xticklabels(YearMonthJP(xticks))

% Transitions of S and R
figname_SR = 'SR_transitions';
lineName = cell(nTH, 1);
lineName2 = cell(nTH, 1);

for i = 1:nTH
    lineName{i} = append("S,", Scenario(i));
    lineName2{i} = append("R,", Scenario(i));
end

eTitle = 'Transitions of S and R';
jTitle = 'SとRの推移';
figure('Name', char(figname_SR));
set(gcf, 'Position', [100, 100, 1200, 800])
plot_function2(TH, TH_index, S(2:end), SimData(2:end, 1, :), R(2:end), SimData(2:end, 3, :), ...
    YearMonthWeekEN, YearMonthWeekJP, WeekNumber, Tdata, xline_ind, linecolor, lineName, ...
    lineName2, eTitle, jTitle, fs, lgfs, fn, ft, yft, column, l, show_other, 'SouthOutside')
% xlim([Tdata - 21 Tdata + 41])
xlim([x_left, xmax])
% xticks(find(WeekNumber == 1 & abs(1 - mod(MonthNumber, 3)) < 0.01))
xticks(find(WeekNumber == 1 & abs(1 - mod(MonthNumber, 4)) < 0.01))
%     xticklabels(YearMonthWeekJP(xticks))
xticklabels(YearMonthJP(xticks))

% Transitions of Beta

figure('Name', char(figname_beta));
set(gcf, 'Position', [100, 100, 1200, 800])
lineName = cell(nTH, 1);

for i = 1:nTH
    lineName{i} = Scenario(i);
end

eTitle = 'Transitions of \beta';
jTitle = '\betaの推移';
yft = '%.3f';
plot_function(TH, TH_index, beta, betaPath, ...
    YearMonthWeekEN, YearMonthWeekJP, WeekNumber, Tdata, xline_ind, linecolor, lineWidth, lineName, ...
    eTitle, jTitle, fs, lgfs, fn, ft, yft, column, l, show_other, 'SouthOutside')
plot([NaN(Tdata - 1, 1); ones(SimPeriod + 1, 1) * simple_beta_avg], '--k', 'LineWidth', 1.5, 'DisplayName', '過去17週間平均')
plot([NaN(Tdata - 1, 1); ones(SimPeriod + 1, 1) * beta_wo_alpha], '--b', 'LineWidth', 1.5, 'DisplayName', '過去17週間平均, アルファ株影響除去')
plot([NaN(Tdata - 1, 1); ones(SimPeriod + 1, 1) * betaAvgVec(2)], '--r', 'LineWidth', 1.5, 'DisplayName', '過去17週間平均, 変異株影響除去')
plot([NaN(Tdata, 1); betaT_woAR], '-g', 'LineWidth', 1.5, 'DisplayName', 'Without any shocks')
xline(Tdata - RetroPeriod + 1, 'HandleVisibility', 'off')
% xlim([Tdata - 31 Tdata + 41])
xlim([x_left, xmax])
% xticks(find(WeekNumber == 1 & abs(1 - mod(MonthNumber, 3)) < 0.01))
xticks(find(WeekNumber == 1 & abs(1 - mod(MonthNumber, 4)) < 0.01))
%     xticklabels(YearMonthWeekJP(xticks))
xticklabels(YearMonthJP(xticks))

if figure_save == 1
    saveas(gcf, [home 'Figures/' char(pref) '/' char(figname_beta) '.png']);
end

% Transitions of Beta Tilde

figure('Name', char(figname_beta_tilde));
set(gcf, 'Position', [100, 100, 1200, 800])
eTitle = 'Transitions of \beta tilde';
jTitle = '\beta tildeの推移';
yft = '%.3f';
plot_function(TH, TH_index, beta_tilde, betaTildePath, ...
    YearMonthWeekEN, YearMonthWeekJP, WeekNumber, Tdata, xline_ind, linecolor, lineWidth, lineName, ...
    eTitle, jTitle, fs, lgfs, fn, ft, yft, column, l, show_other, 'SouthOutside')
xline(Tdata - RetroPeriod + 1, 'HandleVisibility', 'off')
% xlim([Tdata - 31 Tdata + 41])
xlim([x_left, xmax])
xticks(find(WeekNumber == 1 & abs(1 - mod(MonthNumber, 4)) < 0.01))
%     xticklabels(YearMonthWeekJP(xticks))
xticklabels(YearMonthJP(xticks))

if figure_save == 1
    saveas(gcf, [home 'Figures/' char(pref) '/' char(figname_beta_tilde) '.png']);
end

% Transitions of Variant Share Rate

figure('Name', char(figname_var));
set(gcf, 'Position', [100, 100, 1200, 800])
eTitle = 'Transitions of Variant Rate';
jTitle = '変異株割合の推移';
plot_function(TH, TH_index, var_prev2, varSharePath, ...
    YearMonthWeekEN, YearMonthWeekJP, WeekNumber, Tdata, xline_ind, linecolor, lineWidth, lineName, ...
    eTitle, jTitle, fs, lgfs, fn, ft, yft, column, l, show_other, 'SouthOutside')
% xlim([Tdata - 31 Tdata + 41])
xlim([x_left, xmax])
% xticks(find(WeekNumber == 1 & abs(1 - mod(MonthNumber, 3)) < 0.01))
xticks(find(WeekNumber == 1 & abs(1 - mod(MonthNumber, 4)) < 0.01))
%     xticklabels(YearMonthWeekJP(xticks))
xticklabels(YearMonthJP(xticks))

if figure_save == 1
    saveas(gcf, [home 'Figures/' char(pref) '/' char(figname_var) '.png']);
end

% Transitions of Death Rate
column = 2;

figure('Name', char(figname_delta));
set(gcf, 'Position', [100, 100, 1200, 800])
eTitle = 'Transitions of Death Rate';
jTitle = '死亡率の推移';
plot_function(TH, TH_index, delta, deltaPath, ...
    YearMonthWeekEN, YearMonthWeekJP, WeekNumber, Tdata, xline_ind, linecolor, lineWidth, lineName, ...
    eTitle, jTitle, fs, lgfs, fn, ft, yft, column, l, show_other, 'SouthOutside')
plot([NaN(Tdata - 1, 1); ones(SimPeriod + 1, 1) * delta_past_avg], '--k', 'LineWidth', 1.5, 'DisplayName', '過去の平均')
% plot([NaN(Tdata - 1, 1); ones(SimPeriod + 1, 1) * delta_wo_vaccination], '--b', 'LineWidth', 1.5, 'DisplayName', '過去の平均, ワクチン影響除去')
plot([NaN(Tdata - 1, 1); ones(SimPeriod + 1, 1) * delta_wo_alpha], ':r', 'LineWidth', 1.5, 'DisplayName', '過去の平均, ワクチン影響除去+アルファ株影響除去')
plot([NaN(Tdata - 1, 1); ones(SimPeriod + 1, 1) * delta_average], '--r', 'LineWidth', 1.5, 'DisplayName', '過去の平均, ワクチン影響除去+変異株影響除去')
xline(Tdata - RetroPeriodDelta + 1, 'HandleVisibility', 'off')
% xlim([Tdata - 31 Tdata + 41])
xlim([x_left, xmax])
% xticks(find(WeekNumber == 1 & abs(1 - mod(MonthNumber, 3)) < 0.01))
xticks(find(WeekNumber == 1 & abs(1 - mod(MonthNumber, 4)) < 0.01))
%     xticklabels(YearMonthWeekJP(xticks))
xticklabels(YearMonthJP(xticks))

if figure_save == 1
    saveas(gcf, [home 'Figures/' char(pref) '/' char(figname_delta) '.png']);
end

% Transitions of ICU Rate
figure('Name', char(figname_ICU_nation));
set(gcf, 'Position', [100, 100, 1200, 800])
eTitle = 'Transitions of ICU Rate (National Standard)';
jTitle = '重症化率の推移(国基準)';
plot_function(TH, TH_index, delta .* ICU_nation_inflow, ICU_nation_inflow_avg * delta_ICU_nationPath, ...
    YearMonthWeekEN, YearMonthWeekJP, WeekNumber, Tdata, xline_ind, linecolor, lineWidth, lineName, ...
    eTitle, jTitle, fs, lgfs, fn, ft, yft, column, l, show_other, 'SouthOutside')
plot([NaN(Tdata - 1, 1); ones(SimPeriod + 1, 1) * delta_ICU_nation_past_avg * ICU_nation_inflow_avg], '--k', 'LineWidth', 1.5, 'DisplayName', '過去の平均')
% plot([NaN(Tdata - 1, 1); ones(SimPeriod + 1, 1) * delta_ICU_nation_wo_vaccination * ICU_nation_inflow_avg], '--b', 'LineWidth', 1.5, 'DisplayName', '過去の平均, ワクチン影響除去')
plot([NaN(Tdata - 1, 1); ones(SimPeriod + 1, 1) * delta_ICU_nation_wo_alpha * ICU_nation_inflow_avg], ':r', 'LineWidth', 1.5, 'DisplayName', '過去の平均, ワクチン影響除去+アルファ株影響除去')
plot([NaN(Tdata - 1, 1); ones(SimPeriod + 1, 1) * delta_ICU_nation_average * ICU_nation_inflow_avg], '--r', 'LineWidth', 1.5, 'DisplayName', '過去の平均, ワクチン影響除去+変異株影響除去')
xline(Tdata - RetroPeriodICU_nation + 1, 'HandleVisibility', 'off')
% xlim([Tdata - 31 Tdata + 41])
xlim([x_left, xmax])
% xticks(find(WeekNumber == 1 & abs(1 - mod(MonthNumber, 3)) < 0.01))
xticks(find(WeekNumber == 1 & abs(1 - mod(MonthNumber, 4)) < 0.01))
%     xticklabels(YearMonthWeekJP(xticks))
xticklabels(YearMonthJP(xticks))

if figure_save == 1
    saveas(gcf, [home 'Figures/' char(pref) '/' char(figname_ICU_nation) '.png']);
end

% Transitions of ICU Rate

figure('Name', char(figname_ICU_local));
set(gcf, 'Position', [100, 100, 1200, 800])
eTitle = 'Transitions of ICU Rate (Local Standard)';
jTitle = '重症化率の推移(都基準)';
plot_function(TH, TH_index, delta .* ICU_pref_inflow, ICU_pref_inflow_avg * delta_ICU_prefPath, ...
    YearMonthWeekEN, YearMonthWeekJP, WeekNumber, Tdata, xline_ind, linecolor, lineWidth, lineName, ...
    eTitle, jTitle, fs, lgfs, fn, ft, yft, column, l, show_other, 'SouthOutside')
plot([NaN(Tdata - 1, 1); ones(SimPeriod + 1, 1) * delta_ICU_pref_past_avg * ICU_pref_inflow_avg], '--k', 'LineWidth', 1.5, 'DisplayName', '過去の平均')
% plot([NaN(Tdata - 1, 1); ones(SimPeriod + 1, 1) * delta_ICU_pref_wo_vaccination * ICU_pref_inflow_avg], '--b', 'LineWidth', 1.5, 'DisplayName', '過去の平均, ワクチン影響除去')
plot([NaN(Tdata - 1, 1); ones(SimPeriod + 1, 1) * delta_ICU_pref_wo_alpha * ICU_pref_inflow_avg], ':r', 'LineWidth', 1.5, 'DisplayName', '過去の平均, ワクチン影響除去+アルファ株影響除去')
plot([NaN(Tdata - 1, 1); ones(SimPeriod + 1, 1) * delta_ICU_pref_average * ICU_pref_inflow_avg], '--r', 'LineWidth', 1.5, 'DisplayName', '過去の平均, ワクチン影響除去+変異株影響除去')
xline(Tdata - RetroPeriodICU_pref + 1, 'HandleVisibility', 'off')
% xlim([Tdata - 31 Tdata + 41])
xlim([x_left, xmax])
% xticks(find(WeekNumber == 1 & abs(1 - mod(MonthNumber, 3)) < 0.01))
xticks(find(WeekNumber == 1 & abs(1 - mod(MonthNumber, 4)) < 0.01))
%     xticklabels(YearMonthWeekJP(xticks))
xticklabels(YearMonthJP(xticks))

if figure_save == 1
    saveas(gcf, [home 'Figures/' char(pref) '/' char(figname_ICU_local) '.png']);
end

% Transitions of Hospital Rate

figure('Name', char(figname_Hospital));
set(gcf, 'Position', [100, 100, 1200, 800])
eTitle = 'Transitions of Hospital Rate';
jTitle = '入院率の推移';
plot_function(TH, TH_index, delta .* Hospital_inflow, Hospital_inflow_avg * delta_HospitalPath, ...
    YearMonthWeekEN, YearMonthWeekJP, WeekNumber, Tdata, xline_ind, linecolor, lineWidth, lineName, ...
    eTitle, jTitle, fs, lgfs, fn, ft, yft, column, l, show_other, 'SouthOutside')
plot([NaN(Tdata - 1, 1); ones(SimPeriod + 1, 1) * delta_Hospital_past_avg * Hospital_inflow_avg], '--k', 'LineWidth', 1.5, 'DisplayName', '過去の平均')
% plot([NaN(Tdata - 1, 1); ones(SimPeriod + 1, 1) * delta_Hospital_wo_vaccination * Hospital_inflow_avg], '--b', 'LineWidth', 1.5, 'DisplayName', '過去の平均, ワクチン影響除去')
plot([NaN(Tdata - 1, 1); ones(SimPeriod + 1, 1) * delta_Hospital_wo_alpha * Hospital_inflow_avg], ':r', 'LineWidth', 1.5, 'DisplayName', '過去の平均, ワクチン影響除去+アルファ株影響除去')
plot([NaN(Tdata - 1, 1); ones(SimPeriod + 1, 1) * delta_Hospital_average * Hospital_inflow_avg], '--r', 'LineWidth', 1.5, 'DisplayName', '過去の平均, ワクチン影響除去+変異株影響除去')
xline(Tdata - RetroPeriodHospital + 1, 'HandleVisibility', 'off')
% xlim([Tdata - 31 Tdata + 41])
xlim([x_left, xmax])
% xticks(find(WeekNumber == 1 & abs(1 - mod(MonthNumber, 3)) < 0.01))
xticks(find(WeekNumber == 1 & abs(1 - mod(MonthNumber, 4)) < 0.01))
%     xticklabels(YearMonthWeekJP(xticks))
xticklabels(YearMonthJP(xticks))

if figure_save == 1
    saveas(gcf, [home 'Figures/' char(pref) '/' char(figname_Hospital) '.png']);
end

% Transitions of ERN

figure('Name', char(figname_ERN));
set(gcf, 'Position', [100, 100, 1200, 800])
eTitle = 'Transitions of ERN';
jTitle = '実効再生産数の推移';
plot_function(TH, TH_index, ERN, SimERN, ...
    YearMonthWeekEN, YearMonthWeekJP, WeekNumber, Tdata, xline_ind, linecolor, lineWidth, lineName, ...
    eTitle, jTitle, fs, lgfs, fn, ft, yft, column, l, show_other, 'SouthOutside')
% xlim([Tdata - 31 Tdata + 41])
xlim([x_left, xmax])
% xticks(find(WeekNumber == 1 & abs(1 - mod(MonthNumber, 3)) < 0.01))
xticks(find(WeekNumber == 1 & abs(1 - mod(MonthNumber, 4)) < 0.01))
%     xticklabels(YearMonthWeekJP(xticks))
xticklabels(YearMonthJP(xticks))

if figure_save == 1
    saveas(gcf, [home 'Figures/' char(pref) '/' char(figname_ERN) '.png']);
end

% Transitions of New deaths

figure('Name', char(figname_dD));
set(gcf, 'Position', [100, 100, 1200, 800])
eTitle = 'Transitions of dD';
jTitle = '新規死亡者数の推移';
plot_function(TH, TH_index, dD, Sim_dDPath, ...
    YearMonthWeekEN, YearMonthWeekJP, WeekNumber, Tdata, xline_ind, linecolor, lineWidth, lineName, ...
    eTitle, jTitle, fs, lgfs, fn, ft, yft, column, l, show_other, 'SouthOutside')
% xlim([Tdata - 31 Tdata + 41])
xlim([x_left, xmax])
% xticks(find(WeekNumber == 1 & abs(1 - mod(MonthNumber, 3)) < 0.01))
xticks(find(WeekNumber == 1 & abs(1 - mod(MonthNumber, 4)) < 0.01))
%     xticklabels(YearMonthWeekJP(xticks))
xticklabels(YearMonthJP(xticks))

if figure_save == 1
    saveas(gcf, [home 'Figures/' char(pref) '/' char(figname_dD) '.png']);
end


figure(10000)
plot(betaTildePath./(gammaT + deltaT))
