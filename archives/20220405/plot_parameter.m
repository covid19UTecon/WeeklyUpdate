column_num = 1;

% Transitions of Beta
figure('Name', char(figname_beta));
set(gcf, 'Position', [100, 100, 1200, 800])
title_vec = ["Transitions of \beta", "\betaの推移"];
yft = '%.3f';
% linecolor_param = ...
%             {"r", "r", "r"; ...
%              "k", "k", "k"; ...
%              "b", "b", "b"};

linecolor_param = ...
            {"r", "r", "r","r"; ...
             "k", "k", "k","k"; ...
             "b", "b", "b","b"};

lineName_param = strings(nX,nY,2);
% LineStyles_param = ...
%    {"-",   "--",   ":"; ...
%     "-",   "--", ":"; ...
%     "-",   "--",  ":"};

LineStyles_param = ...
   {"--",  ":", "-", "-."; ...
    "--",  ":", "-", "-."; ...
    "--",  ":", "-", "-."};

for iX = 1:nX
    for iY = 1:nY
        lineName_param(iX,iY,2) = [Scenario{iX}, char(lineNameJP{iY})];
        lineName_param(iX,iY,1) = [ScenarioEN{iX}, char(lineNameEN{iY})];
    end
end

for iX = 1:nX  
    l = 2;
    plot_3Dfunction(beta, betaPath(:,:,:), iX, ...
        WeekNumber, YearMonth, xmin, xmax, ...
        FONT_NAME, FONT_SIZE, LEGEND_FONT_SIZE, AXIS_FONT_SIZE, yft, ...
        lgdLocation, column_num, l, title_vec, ...
        lineWidth, [linecolor_param{iX,:}], [LineStyles_param{iX,:}], lineName_param(iX,:,l))
    hold on
end

if FIGURE_SAVE == 1
    saveas(gcf, [FIGURE_PATH char(PREF) '/' char(figfolder) '/' char(figname_beta) '.png']);
end

% Transitions of Beta Tilde
figure('Name', char(figname_beta_tilde));
set(gcf, 'Position', [100, 100, 1200, 800])
title_vec = ["Transitions of \beta tilde", "\beta tildeの推移"];
yft = '%.3f';
for iX = 1:nX

    plot_3Dfunction(beta_tilde, betaTildePath(:,:,:), iX, ...
        WeekNumber, YearMonth, xmin, xmax, ...
        FONT_NAME, FONT_SIZE, LEGEND_FONT_SIZE, AXIS_FONT_SIZE,yft,...
        lgdLocation, column_num, l, title_vec, ...
        lineWidth, [linecolor_param{iX,:}], [LineStyles_param{iX,:}], lineName_param(iX,:,l))
end

if FIGURE_SAVE == 1
    %     saveas(gcf, [FIGURE_PATH char(PREF) '/' char(figname_beta_tilde) '.png']);
    saveas(gcf, [FIGURE_PATH char(PREF) '/' char(figfolder) '/' char(figname_beta_tilde) '.png']);
end

% Transitions of ERN
figure('Name', char(figname_ERN));
set(gcf, 'Position', [100, 100, 1200, 800])
title_vec = ["Transitions of ERN", "実効再生産数の推移"];
for iX = 1:nX

    plot_3Dfunction(ERN, SimERN(:,:,:), iX, ...
        WeekNumber, YearMonth, xmin, xmax, ...
        FONT_NAME, FONT_SIZE, LEGEND_FONT_SIZE, AXIS_FONT_SIZE,yft,...
        lgdLocation, column_num, l, title_vec, ...
        lineWidth, [linecolor_param{iX,:}], [LineStyles_param{iX,:}], lineName_param(iX,:,l))
end

if FIGURE_SAVE == 1
    %     saveas(gcf, [FIGURE_PATH char(PREF) '/' char(figname_ERN) '.png']);
    saveas(gcf, [FIGURE_PATH char(PREF) '/' char(figfolder) '/' char(figname_ERN) '.png']);
end

% Transitions of BRN

figure('Name', char(figname_BRN));
set(gcf, 'Position', [100, 100, 1200, 800])
title_vec = ["Transitions of BRN", "基本再生産数の推移"];
for iX = 1:nX

    plot_3Dfunction(BRN, SimBRN(:,:,:), iX, ...
        WeekNumber, YearMonth, xmin, xmax, ...
        FONT_NAME, FONT_SIZE, LEGEND_FONT_SIZE, AXIS_FONT_SIZE,yft,...
        lgdLocation, column_num, l, title_vec, ...
        lineWidth, [linecolor_param{iX,:}], [LineStyles_param{iX,:}], lineName_param(iX,:,l))
end

if FIGURE_SAVE == 1
    %     saveas(gcf, [FIGURE_PATH char(PREF) '/' char(figname_ERN) '.png']);
    saveas(gcf, [FIGURE_PATH char(PREF) '/' char(figfolder) '/' char(figname_BRN) '.png']);
end
%%

% Transitions of Death Rate
figure('Name', char(figname_delta));
set(gcf, 'Position', [100, 100, 1200, 800])
title_vec = ["Transitions of Death Rate", "死亡率の推移"];
yft = '%.3f';
for iX = 1:nX

    plot_3Dfunction(delta, deltaPath(:,:,:), iX, ...
        WeekNumber, YearMonth, xmin, xmax, ...
        FONT_NAME, FONT_SIZE, LEGEND_FONT_SIZE, AXIS_FONT_SIZE,yft,...
        lgdLocation, column_num, l, title_vec, ...
        lineWidth, [linecolor_param{iX,:}], [LineStyles_param{iX,:}], lineName_param(iX,:,l))
end
if FIGURE_SAVE == 1
    saveas(gcf, [FIGURE_PATH char(PREF) '/' char(figfolder) '/' char(figname_delta) '.png']);
end

% Transitions of ICU Rate
figure('Name', char(figname_ICU_nation));
set(gcf, 'Position', [100, 100, 1200, 800])
title_vec = ["Transitions of Severity Rate (National Standard)", "重症化率の推移(国基準)"];
for iX = 1:nX
    
    plot_3Dfunction(ICU_nation_rate, SimICU_nation_rate_Path(:,:,:), iX, ...
        WeekNumber, YearMonth, xmin, xmax, ...
        FONT_NAME, FONT_SIZE, LEGEND_FONT_SIZE, AXIS_FONT_SIZE,yft,...
        lgdLocation, column_num, l, title_vec, ...
        lineWidth, [linecolor_param{iX,:}], [LineStyles_param{iX,:}], lineName_param(iX,:,l))
end
if FIGURE_SAVE == 1
    %     saveas(gcf, [FIGURE_PATH char(PREF) '/' char(figname_ICU_nation) '.png']);
    saveas(gcf, [FIGURE_PATH char(PREF) '/' char(figfolder) '/' char(figname_ICU_nation) '.png']);
end


% Transitions of ICU Rate (New Local Standard)
figure('Name', char(figname_new_ICU_local));
set(gcf, 'Position', [100, 100, 1200, 800])
title_vec = ["Transitions of Severity Rate (New Local Standard)", "重症化率の推移(新都基準)"];
for iX = 1:nX
    
    plot_3Dfunction(newICU_pref_rate, SimNewICU_pref_rate_Path(:,:,:), iX, ...
        WeekNumber, YearMonth, xmin, xmax, ...
        FONT_NAME, FONT_SIZE, LEGEND_FONT_SIZE, AXIS_FONT_SIZE,yft,...
        lgdLocation, column_num, l, title_vec, ...
        lineWidth, [linecolor_param{iX,:}], [LineStyles_param{iX,:}], lineName_param(iX,:,l))
end
if FIGURE_SAVE == 1
    %     saveas(gcf, [FIGURE_PATH char(PREF) '/' char(figname_ICU_nation) '.png']);
    saveas(gcf, [FIGURE_PATH char(PREF) '/' char(figfolder) '/' char(figname_new_ICU_local) '.png']);
end

% Transitions of ICU Rate

figure('Name', char(figname_ICU_local));
set(gcf, 'Position', [100, 100, 1200, 800])
title_vec = ["Transitions of Severity Rate (Local Standard)", "重症化率の推移(都基準)"];
for iX = 1:nX
plot_3Dfunction(ICU_pref_rate, SimICU_pref_rate_Path(:,:,:), iX, ...
    WeekNumber, YearMonth, xmin, xmax, ...
    FONT_NAME, FONT_SIZE, LEGEND_FONT_SIZE, AXIS_FONT_SIZE,yft,...
    lgdLocation, column_num, l, title_vec, ...
        lineWidth, [linecolor_param{iX,:}], [LineStyles_param{iX,:}], lineName_param(iX,:,l))
end
if FIGURE_SAVE == 1
    %     saveas(gcf, [FIGURE_PATH char(PREF) '/' char(figname_ICU_local) '.png']);
    saveas(gcf, [FIGURE_PATH char(PREF) '/' char(figfolder) '/' char(figname_ICU_local) '.png']);
end

% Transitions of Hospital Rate
figure('Name', [char(figname_Hospital)]);
    set(gcf, 'Position', [100, 100, 1200, 800])
    title_vec = ["Transitions of Hospitalized Rate", "入院率の推移"];
for iX = 1:nX

    plot_3Dfunction(Hospital_rate, SimHospital_rate_Path(:,:,:), iX, ...
        WeekNumber, YearMonth, xmin, xmax, ...
        FONT_NAME, FONT_SIZE, LEGEND_FONT_SIZE, AXIS_FONT_SIZE,yft,...
        lgdLocation, column_num, l, title_vec, ...
        lineWidth, [linecolor_param{iX,:}], [LineStyles_param{iX,:}], lineName_param(iX,:,l))
end
  %ここも変更
    if FIGURE_SAVE == 1
        saveas(gcf, [FIGURE_PATH char(PREF) '/' char(figfolder) '/' char(figname_Hospital) '.png']);
    end
