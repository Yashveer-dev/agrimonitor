classdef starter_app < matlab.apps.AppBase

    % Properties that correspond to app components (Step 3 naming requirements)
    properties (Access = public)
        UIFigure                   matlab.ui.Figure
        
        % Header Banner
        HeaderPanel                matlab.ui.container.Panel
        TitleLabel                 matlab.ui.control.Label
        SubtitleLabel              matlab.ui.control.Label
        MottoLabel                 matlab.ui.control.Label
        
        % Left Column: Dataset & Visualization
        DatasetPanel               matlab.ui.container.Panel
        DataTable                  matlab.ui.control.Table
        
        VisualizationPanel         matlab.ui.container.Panel
        UIAxes                     matlab.ui.control.UIAxes
        
        % Right Column: Conditions, Status, Insights
        CurrentConditionsPanel     matlab.ui.container.Panel
        TemperatureLabel           matlab.ui.control.Label
        MoistureLabel              matlab.ui.control.Label
        HumidityLabel              matlab.ui.control.Label
        RainfallLabel              matlab.ui.control.Label
        LightLabel                 matlab.ui.control.Label
        
        CropStatusPanel            matlab.ui.container.Panel
        StatusLamp                 matlab.ui.control.Lamp
        CropStatusLabel            matlab.ui.control.Label
        StatusDescLabel            matlab.ui.control.Label
        
        RecommendationPanel        matlab.ui.container.Panel
        RecommendationTextArea     matlab.ui.control.TextArea
        
        AlertsPanel                matlab.ui.container.Panel
        AlertTextArea              matlab.ui.control.TextArea
        
        % Bottom Toolbar & Action Buttons
        BottomPanel                matlab.ui.container.Panel
        ImportButton               matlab.ui.control.Button
        AnalyzeButton              matlab.ui.control.Button
        RecommendationButton       matlab.ui.control.Button
        ResetButton                matlab.ui.control.Button
        FooterLabel                matlab.ui.control.Label
    end

    % Properties that correspond to app data (Step 4 requirement)
    properties (Access = private)
        Data = table()             % Agricultural dataset
        DataLoaded = false         % Flag indicating whether dataset is loaded
        CropHealthStatus = 'NONE'  % Health classification status ('NORMAL','WARNING','CRITICAL')
    end

    % Private Helper Methods (Step 6 & Section 8 Intelligence)
    methods (Access = private)

        % --- Step 6: Update latest sensor display ---
        function updateDisplay(app)
            if isempty(app.Data) || height(app.Data) == 0
                return;
            end
            i = height(app.Data);
            app.TemperatureLabel.Text = sprintf('%.1f °C', app.Data.Temperature(i));
            app.MoistureLabel.Text    = sprintf('%.1f %%', app.Data.SoilMoisture(i));
            app.HumidityLabel.Text    = sprintf('%.1f %%', app.Data.Humidity(i));
            app.RainfallLabel.Text    = sprintf('%.1f mm', app.Data.Rainfall(i));
            app.LightLabel.Text       = sprintf('%.0f',    app.Data.LightIntensity(i));
        end

        % --- Step 6: Multi-sensor trend visualization ---
        function plotData(app)
            if isempty(app.Data) || height(app.Data) == 0
                return;
            end
            cla(app.UIAxes);
            hold(app.UIAxes, 'on');
            x = 1:height(app.Data);
            
            % Distinct, colorblind-friendly agricultural palette
            plot(app.UIAxes, x, app.Data.Temperature, 'LineWidth', 1.8, 'Color', [0.85 0.33 0.10]); % Red/Orange
            plot(app.UIAxes, x, app.Data.SoilMoisture, 'LineWidth', 1.8, 'Color', [0.00 0.45 0.74]); % Blue
            plot(app.UIAxes, x, app.Data.Humidity,     'LineWidth', 1.8, 'Color', [0.47 0.67 0.19]); % Green
            plot(app.UIAxes, x, app.Data.Rainfall,     'LineWidth', 1.8, 'Color', [0.49 0.18 0.56]); % Purple
            plot(app.UIAxes, x, app.Data.LightIntensity / 10, 'LineWidth', 1.8, 'Color', [0.93 0.69 0.13]); % Yellow/Amber
            
            hold(app.UIAxes, 'off');
            title(app.UIAxes, 'Agricultural Sensor Data Over Time', 'FontWeight', 'bold', 'FontSize', 12);
            xlabel(app.UIAxes, 'Observation (Hourly Timesteps)');
            ylabel(app.UIAxes, 'Sensor Value');
            legend(app.UIAxes, {'Temperature (°C)', 'Soil Moisture (%)', 'Humidity (%)', ...
                'Rainfall (mm)', 'Light Intensity / 10'}, 'Location', 'northeast', 'FontSize', 8);
            grid(app.UIAxes, 'on');
            app.UIAxes.Box = 'on';
        end

        % --- Section 8 Intelligence: Agronomic Assessment ---
        function runAnalysis(app)
            if ~app.DataLoaded || isempty(app.Data)
                app.AlertTextArea.Value = {'[ERROR] No dataset loaded. Click "Import Dataset" first.'};
                return;
            end

            % Current conditions (latest observation)
            lastIdx = height(app.Data);
            T_curr = app.Data.Temperature(lastIdx);
            M_curr = app.Data.SoilMoisture(lastIdx);
            H_curr = app.Data.Humidity(lastIdx);
            R_curr = app.Data.Rainfall(lastIdx);
            L_curr = app.Data.LightIntensity(lastIdx);

            % Dataset-wide anomaly & statistical checks
            maxTemp     = max(app.Data.Temperature);
            minMoisture = min(app.Data.SoilMoisture);
            meanMoist   = mean(app.Data.SoilMoisture);
            totalRain   = sum(app.Data.Rainfall);
            heatStressHours = sum(app.Data.Temperature >= 35.0);
            drySoilHours    = sum(app.Data.SoilMoisture < 40.0);

            % Trend calculation (last 12 hours)
            recentWindow = max(1, lastIdx - 11):lastIdx;
            moistureTrend = app.Data.SoilMoisture(lastIdx) - app.Data.SoilMoisture(recentWindow(1));

            % Automated Alert Generation
            alerts = {};
            alerts{end+1} = sprintf('=== ANALYSIS SUMMARY (%d Observations Evaluated) ===', height(app.Data));

            % Status Decision Logic (Green / Yellow / Red)
            % Red (CRITICAL): Soil moisture < 40% (wilting point risk) OR Temp > 38°C
            % Yellow (WARNING): Soil moisture 40-50% OR Temp 33-38°C OR High Blight Risk
            % Green (NORMAL): Optimal moisture (50-75%) and Temp (20-32°C)
            if M_curr < 40.0 || T_curr >= 38.0
                app.CropHealthStatus = 'CRITICAL';
                app.StatusLamp.Color = [0.90 0.15 0.15]; % Red
                app.CropStatusLabel.Text = 'CRITICAL';
                app.CropStatusLabel.FontColor = [0.80 0.10 0.10];
                app.StatusDescLabel.Text = 'Severe soil drought or thermal stress active!';
            elseif (M_curr >= 40.0 && M_curr < 50.0) || (T_curr >= 33.0 && T_curr < 38.0) || (H_curr > 85.0) || (moistureTrend < -10.0)
                app.CropHealthStatus = 'WARNING';
                app.StatusLamp.Color = [0.95 0.70 0.05]; % Amber / Yellow
                app.CropStatusLabel.Text = 'WARNING';
                app.CropStatusLabel.FontColor = [0.85 0.55 0.00];
                app.StatusDescLabel.Text = 'Suboptimal conditions; moisture declining.';
            else
                app.CropHealthStatus = 'NORMAL';
                app.StatusLamp.Color = [0.15 0.75 0.25]; % Green
                app.CropStatusLabel.Text = 'NORMAL';
                app.CropStatusLabel.FontColor = [0.10 0.60 0.20];
                app.StatusDescLabel.Text = 'Conditions are favorable for crop growth.';
            end

            % Automated condition alerts
            if M_curr < 40.0
                alerts{end+1} = sprintf('[CRITICAL ALERT] Current Soil Moisture (%.1f%%) is below 40%% threshold! Root zone drying rapidly.', M_curr);
            elseif M_curr < 50.0
                alerts{end+1} = sprintf('[WARNING] Soil Moisture (%.1f%%) is moderate-low. Irrigation required soon.', M_curr);
            else
                alerts{end+1} = sprintf('[OK] Soil Moisture (%.1f%%) is currently within safe agronomic range.', M_curr);
            end

            if T_curr >= 35.0
                alerts{end+1} = sprintf('[CRITICAL ALERT] Ambient Temp (%.1f°C) exceeds 35°C! Severe transpiration and heat stress.', T_curr);
            elseif T_curr >= 32.0
                alerts{end+1} = sprintf('[WARNING] High Temp (%.1f°C). Heat mitigation recommended.', T_curr);
            end

            if heatStressHours > 0
                alerts{end+1} = sprintf('[ANOMALY] Detected %d total hours of heat stress (>=35°C). Peak temp recorded: %.1f°C.', heatStressHours, maxTemp);
            end

            if drySoilHours > 0
                alerts{end+1} = sprintf('[DEFICIT] Crop experienced %d hours below 40%% moisture. Lowest moisture: %.1f%%.', drySoilHours, minMoisture);
            end

            if H_curr >= 80.0 && T_curr >= 20.0 && T_curr <= 30.0
                alerts{end+1} = sprintf('[PATHOGEN ALERT] Humidity (%.1f%%) + warm air creates high fungal/blight risk.', H_curr);
            end

            alerts{end+1} = sprintf('[METRICS] Mean Soil Moisture: %.1f%% | Cumulative Rain: %.1f mm', meanMoist, totalRain);
            alerts{end+1} = '[READY] Click "Generate Recommendation" for actionable guidance.';

            app.AlertTextArea.Value = alerts;
        end

        % --- Section 8 Intelligence: Agronomic Recommendations ---
        function generateRecommendations(app)
            if ~app.DataLoaded || isempty(app.Data)
                app.RecommendationTextArea.Value = {'Please import and analyze the dataset first.'};
                return;
            end

            % If analysis has not been executed yet, run it
            if strcmp(app.CropHealthStatus, 'NONE')
                app.runAnalysis();
            end

            lastIdx = height(app.Data);
            T = app.Data.Temperature(lastIdx);
            M = app.Data.SoilMoisture(lastIdx);
            H = app.Data.Humidity(lastIdx);
            L = app.Data.LightIntensity(lastIdx);

            recs = {};
            recs{end+1} = sprintf('*** SMART AGRONOMIC PRESCRIPTION (%s STATUS) ***', app.CropHealthStatus);
            recs{end+1} = '';

            % 1. Irrigation Prescription
            if M < 40.0
                recs{end+1} = sprintf('1. IRRIGATION [PRIORITY 1 - URGENT]: Current soil moisture is critically low at %.1f%% (<40%% wilting danger). Initiate drip irrigation immediately: apply 25-30 mm during evening or dawn to maximize infiltration and minimize evaporative loss.', M);
            elseif M < 50.0
                recs{end+1} = sprintf('1. IRRIGATION [SCHEDULED]: Soil moisture is %.1f%% (depleting). Schedule 15-20 mm irrigation cycle within next 12 hours.', M);
            elseif M > 75.0
                recs{end+1} = sprintf('1. IRRIGATION [PAUSE]: Soil moisture is high (%.1f%%). Suspend irrigation to prevent root hypoxia and fungal rot.', M);
            else
                recs{end+1} = sprintf('1. IRRIGATION [MAINTENANCE]: Soil moisture is healthy (%.1f%%). Continue current irrigation schedule.', M);
            end
            recs{end+1} = '';

            % 2. Microclimate & Solar Radiation Management
            if T >= 35.0 || L > 700
                recs{end+1} = sprintf('2. THERMAL/CANOPY MANAGEMENT: Current temperature (%.1f°C) and light intensity (%.0f) cause high vapor pressure deficit. Deploy 50%% agro-shade netting and activate overhead misters between 11:00-14:00.', T, L);
            else
                recs{end+1} = '2. CANOPY MANAGEMENT: Solar radiation and temperature are balanced. Canopy photosynthetic efficiency is optimal.';
            end
            recs{end+1} = '';

            % 3. Disease & Pest Advisory
            if H >= 80.0
                recs{end+1} = sprintf('3. DISEASE PREVENTION: Prolonged relative humidity at %.1f%% promotes downy mildew and leaf spot. Inspect lower leaves, prune dense foliage for ventilation, and consider bio-fungicide (Trichoderma viride).', H);
            else
                recs{end+1} = '3. DISEASE CONTROL: Humidity levels are safe. Maintain routine integrated pest management (IPM) scouting.';
            end
            recs{end+1} = '';

            % 4. Soil & Fertilizer Management
            if M < 40.0
                recs{end+1} = '4. FERTIGATION CAUTION: Withhold concentrated chemical fertilizers until soil moisture recovers to >50% to prevent root osmotic burn.';
            else
                recs{end+1} = '4. FERTIGATION: Soil moisture is adequate for fertigation. Apply balanced N-P-K nutrient dosage as per growth phase.';
            end

            app.RecommendationTextArea.Value = recs;
        end
    end

    % Callbacks that handle component events (Steps 5, 8)
    methods (Access = private)

        % --- Step 5: Import button callback ---
        function ImportButtonPushed(app, ~)
            [file, path] = uigetfile( ...
                {'*.csv', 'CSV Files (*.csv)'; ...
                 '*.xlsx', 'Excel Files (*.xlsx)'}, ...
                'Select Agricultural Dataset');
            if isequal(file, 0)
                app.AlertTextArea.Value = {'Dataset selection cancelled.'};
                return;
            end
            try
                app.Data = readtable(fullfile(path, file));
                app.DataTable.Data = app.Data;
                app.DataLoaded = true;
                app.AlertTextArea.Value = ...
                    {sprintf('Dataset loaded successfully: %d rows from "%s".', height(app.Data), file), ...
                     'Click "Analyze Data" to evaluate crop health.'};
                app.updateDisplay();
                app.plotData();
            catch ME
                app.AlertTextArea.Value = {['Error loading dataset: ' ME.message]};
            end
        end

        % --- Step 8: Analyze button callback ---
        function AnalyzeButtonPushed(app, ~)
            app.runAnalysis();
        end

        % --- Step 8: Recommendation button callback ---
        function RecommendationButtonPushed(app, ~)
            app.generateRecommendations();
        end

        % --- Step 8: Reset button callback ---
        function ResetButtonPushed(app, ~)
            % Clear app data
            app.Data = table();
            app.DataLoaded = false;
            app.CropHealthStatus = 'NONE';
            
            % Reset UI table
            app.DataTable.Data = table();
            
            % Clear UI axes
            cla(app.UIAxes);
            title(app.UIAxes, 'Agricultural Sensor Data Over Time', 'FontWeight', 'bold', 'FontSize', 12);
            xlabel(app.UIAxes, 'Observation');
            ylabel(app.UIAxes, 'Value');
            grid(app.UIAxes, 'on');
            
            % Reset sensor labels
            app.TemperatureLabel.Text = '-- °C';
            app.MoistureLabel.Text    = '-- %';
            app.HumidityLabel.Text    = '-- %';
            app.RainfallLabel.Text    = '-- mm';
            app.LightLabel.Text       = '--';
            
            % Reset Status Lamp & Labels
            app.StatusLamp.Color = [0.70 0.70 0.70]; % Neutral Gray
            app.CropStatusLabel.Text = 'AWAITING DATA';
            app.CropStatusLabel.FontColor = [0.40 0.40 0.40];
            app.StatusDescLabel.Text = 'Import and analyze dataset to view status.';
            
            % Reset text areas
            app.AlertTextArea.Value = {'App reset successfully.', 'Please import farm_data.csv to begin monitoring.'};
            app.RecommendationTextArea.Value = {'No recommendation available.', 'Import and analyze the dataset to generate agronomic insights.'};
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and all components
        function createComponents(app)

            % Create UIFigure
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Position = [100 80 1020 680];
            app.UIFigure.Name = 'Smart India AgriMonitor';
            app.UIFigure.Color = [0.95 0.96 0.96];

            % ---------------- HEADER BANNER ----------------
            app.HeaderPanel = uipanel(app.UIFigure);
            app.HeaderPanel.BackgroundColor = [0.12 0.48 0.24]; % Agricultural Forest Green
            app.HeaderPanel.BorderType = 'none';
            app.HeaderPanel.Position = [10 615 1000 55];

            app.TitleLabel = uilabel(app.HeaderPanel);
            app.TitleLabel.FontName = 'Segoe UI';
            app.TitleLabel.FontSize = 20;
            app.TitleLabel.FontWeight = 'bold';
            app.TitleLabel.FontColor = [1.0 1.0 1.0];
            app.TitleLabel.Position = [15 25 350 26];
            app.TitleLabel.Text = 'Smart India AgriMonitor';

            app.SubtitleLabel = uilabel(app.HeaderPanel);
            app.SubtitleLabel.FontName = 'Segoe UI';
            app.SubtitleLabel.FontSize = 11;
            app.SubtitleLabel.FontColor = [0.85 0.95 0.88];
            app.SubtitleLabel.Position = [16 5 400 18];
            app.SubtitleLabel.Text = 'Data-Driven Decisions for a Sustainable Future';

            app.MottoLabel = uilabel(app.HeaderPanel);
            app.MottoLabel.FontName = 'Segoe UI';
            app.MottoLabel.FontSize = 12;
            app.MottoLabel.FontAngle = 'italic';
            app.MottoLabel.FontColor = [0.95 1.00 0.95];
            app.MottoLabel.HorizontalAlignment = 'right';
            app.MottoLabel.Position = [680 16 300 22];
            app.MottoLabel.Text = '"Healthy Soil, Brighter Tomorrow"';

            % ---------------- LEFT: DATASET PANEL ----------------
            app.DatasetPanel = uipanel(app.UIFigure);
            app.DatasetPanel.Title = 'Dataset';
            app.DatasetPanel.FontWeight = 'bold';
            app.DatasetPanel.FontSize = 12;
            app.DatasetPanel.ForegroundColor = [0.12 0.40 0.20];
            app.DatasetPanel.BackgroundColor = [1.0 1.0 1.0];
            app.DatasetPanel.Position = [10 345 580 260];

            % Mini Import Button inside Dataset panel (matching reference design)
            datasetImportBtn = uibutton(app.DatasetPanel, 'push');
            datasetImportBtn.ButtonPushedFcn = createCallbackFcn(app, @ImportButtonPushed, true);
            datasetImportBtn.BackgroundColor = [0.12 0.47 0.84];
            datasetImportBtn.FontColor = [1 1 1];
            datasetImportBtn.FontWeight = 'bold';
            datasetImportBtn.Position = [15 195 130 30];
            datasetImportBtn.Text = 'Import Dataset';

            % DataTable
            app.DataTable = uitable(app.DatasetPanel);
            app.DataTable.Position = [15 12 550 175];
            app.DataTable.ColumnSortable = true;

            % ---------------- LEFT: DATA VISUALIZATION PANEL ----------------
            app.VisualizationPanel = uipanel(app.UIFigure);
            app.VisualizationPanel.Title = 'Data Visualization';
            app.VisualizationPanel.FontWeight = 'bold';
            app.VisualizationPanel.FontSize = 12;
            app.VisualizationPanel.ForegroundColor = [0.12 0.40 0.20];
            app.VisualizationPanel.BackgroundColor = [1.0 1.0 1.0];
            app.VisualizationPanel.Position = [10 70 580 265];

            app.UIAxes = uiaxes(app.VisualizationPanel);
            app.UIAxes.Position = [10 10 560 225];
            title(app.UIAxes, 'Agricultural Sensor Data Over Time', 'FontWeight', 'bold', 'FontSize', 11);
            xlabel(app.UIAxes, 'Observation');
            ylabel(app.UIAxes, 'Sensor Value');
            grid(app.UIAxes, 'on');

            % ---------------- RIGHT: CURRENT CONDITIONS PANEL ----------------
            app.CurrentConditionsPanel = uipanel(app.UIFigure);
            app.CurrentConditionsPanel.Title = 'Current Conditions';
            app.CurrentConditionsPanel.FontWeight = 'bold';
            app.CurrentConditionsPanel.FontSize = 12;
            app.CurrentConditionsPanel.ForegroundColor = [0.12 0.40 0.20];
            app.CurrentConditionsPanel.BackgroundColor = [1.0 1.0 1.0];
            app.CurrentConditionsPanel.Position = [600 455 410 150];

            % Sensor 1: Temperature
            lbl = uilabel(app.CurrentConditionsPanel);
            lbl.Position = [20 95 120 20];
            lbl.Text = 'Temperature:';
            lbl.FontWeight = 'bold';
            app.TemperatureLabel = uilabel(app.CurrentConditionsPanel);
            app.TemperatureLabel.Position = [140 95 70 20];
            app.TemperatureLabel.Text = '-- °C';
            app.TemperatureLabel.FontWeight = 'bold';
            app.TemperatureLabel.FontColor = [0.85 0.30 0.10];

            % Sensor 2: Soil Moisture
            lbl = uilabel(app.CurrentConditionsPanel);
            lbl.Position = [220 95 110 20];
            lbl.Text = 'Soil Moisture:';
            lbl.FontWeight = 'bold';
            app.MoistureLabel = uilabel(app.CurrentConditionsPanel);
            app.MoistureLabel.Position = [330 95 70 20];
            app.MoistureLabel.Text = '-- %';
            app.MoistureLabel.FontWeight = 'bold';
            app.MoistureLabel.FontColor = [0.10 0.45 0.85];

            % Sensor 3: Humidity
            lbl = uilabel(app.CurrentConditionsPanel);
            lbl.Position = [20 58 120 20];
            lbl.Text = 'Humidity:';
            lbl.FontWeight = 'bold';
            app.HumidityLabel = uilabel(app.CurrentConditionsPanel);
            app.HumidityLabel.Position = [140 58 70 20];
            app.HumidityLabel.Text = '-- %';
            app.HumidityLabel.FontWeight = 'bold';
            app.HumidityLabel.FontColor = [0.20 0.65 0.30];

            % Sensor 4: Rainfall
            lbl = uilabel(app.CurrentConditionsPanel);
            lbl.Position = [220 58 110 20];
            lbl.Text = 'Rainfall:';
            lbl.FontWeight = 'bold';
            app.RainfallLabel = uilabel(app.CurrentConditionsPanel);
            app.RainfallLabel.Position = [330 58 70 20];
            app.RainfallLabel.Text = '-- mm';
            app.RainfallLabel.FontWeight = 'bold';
            app.RainfallLabel.FontColor = [0.45 0.20 0.65];

            % Sensor 5: Light Intensity
            lbl = uilabel(app.CurrentConditionsPanel);
            lbl.Position = [20 20 120 20];
            lbl.Text = 'Light Intensity:';
            lbl.FontWeight = 'bold';
            app.LightLabel = uilabel(app.CurrentConditionsPanel);
            app.LightLabel.Position = [140 20 70 20];
            app.LightLabel.Text = '--';
            app.LightLabel.FontWeight = 'bold';
            app.LightLabel.FontColor = [0.85 0.60 0.05];

            % ---------------- RIGHT: CROP STATUS PANEL ----------------
            app.CropStatusPanel = uipanel(app.UIFigure);
            app.CropStatusPanel.Title = 'Crop Status';
            app.CropStatusPanel.FontWeight = 'bold';
            app.CropStatusPanel.FontSize = 12;
            app.CropStatusPanel.ForegroundColor = [0.12 0.40 0.20];
            app.CropStatusPanel.BackgroundColor = [1.0 1.0 1.0];
            app.CropStatusPanel.Position = [600 365 410 82];

            app.StatusLamp = uilamp(app.CropStatusPanel);
            app.StatusLamp.Position = [25 22 26 26];
            app.StatusLamp.Color = [0.70 0.70 0.70];

            app.CropStatusLabel = uilabel(app.CropStatusPanel);
            app.CropStatusLabel.Position = [65 24 160 26];
            app.CropStatusLabel.Text = 'AWAITING DATA';
            app.CropStatusLabel.FontSize = 16;
            app.CropStatusLabel.FontWeight = 'bold';
            app.CropStatusLabel.FontColor = [0.40 0.40 0.40];

            app.StatusDescLabel = uilabel(app.CropStatusPanel);
            app.StatusDescLabel.Position = [65 6 320 18];
            app.StatusDescLabel.Text = 'Import farm_data.csv to evaluate health.';
            app.StatusDescLabel.FontSize = 10;
            app.StatusDescLabel.FontColor = [0.50 0.50 0.50];

            % ---------------- RIGHT: RECOMMENDATION PANEL ----------------
            app.RecommendationPanel = uipanel(app.UIFigure);
            app.RecommendationPanel.Title = 'Recommendation';
            app.RecommendationPanel.FontWeight = 'bold';
            app.RecommendationPanel.FontSize = 12;
            app.RecommendationPanel.ForegroundColor = [0.12 0.40 0.20];
            app.RecommendationPanel.BackgroundColor = [1.0 1.0 1.0];
            app.RecommendationPanel.Position = [600 215 410 142];

            app.RecommendationTextArea = uitextarea(app.RecommendationPanel);
            app.RecommendationTextArea.Position = [10 8 390 106];
            app.RecommendationTextArea.Editable = 'off';
            app.RecommendationTextArea.Value = { ...
                'No recommendation available.', ...
                'Import and analyze the dataset to generate agronomic insights.'};

            % ---------------- RIGHT: ALERTS / MESSAGES PANEL ----------------
            app.AlertsPanel = uipanel(app.UIFigure);
            app.AlertsPanel.Title = 'Alerts / Messages';
            app.AlertsPanel.FontWeight = 'bold';
            app.AlertsPanel.FontSize = 12;
            app.AlertsPanel.ForegroundColor = [0.12 0.40 0.20];
            app.AlertsPanel.BackgroundColor = [1.0 1.0 1.0];
            app.AlertsPanel.Position = [600 70 410 137];

            app.AlertTextArea = uitextarea(app.AlertsPanel);
            app.AlertTextArea.Position = [10 8 390 102];
            app.AlertTextArea.Editable = 'off';
            app.AlertTextArea.Value = {'Please import a dataset to begin.'};

            % ---------------- BOTTOM TOOLBAR PANEL ----------------
            app.BottomPanel = uipanel(app.UIFigure);
            app.BottomPanel.BackgroundColor = [0.90 0.92 0.93];
            app.BottomPanel.BorderType = 'none';
            app.BottomPanel.Position = [10 10 1000 50];

            % 1. Import Button (Step 3 name: ImportButton)
            app.ImportButton = uibutton(app.BottomPanel, 'push');
            app.ImportButton.ButtonPushedFcn = createCallbackFcn(app, @ImportButtonPushed, true);
            app.ImportButton.BackgroundColor = [0.12 0.47 0.84]; % Blue
            app.ImportButton.FontColor = [1 1 1];
            app.ImportButton.FontWeight = 'bold';
            app.ImportButton.Position = [15 9 140 32];
            app.ImportButton.Text = 'Import Dataset';

            % 2. Analyze Button (Step 3 name: AnalyzeButton)
            app.AnalyzeButton = uibutton(app.BottomPanel, 'push');
            app.AnalyzeButton.ButtonPushedFcn = createCallbackFcn(app, @AnalyzeButtonPushed, true);
            app.AnalyzeButton.BackgroundColor = [0.18 0.58 0.34]; % Green
            app.AnalyzeButton.FontColor = [1 1 1];
            app.AnalyzeButton.FontWeight = 'bold';
            app.AnalyzeButton.Position = [170 9 140 32];
            app.AnalyzeButton.Text = 'Analyze Data';

            % 3. Recommendation Button (Step 3 name: RecommendationButton)
            app.RecommendationButton = uibutton(app.BottomPanel, 'push');
            app.RecommendationButton.ButtonPushedFcn = createCallbackFcn(app, @RecommendationButtonPushed, true);
            app.RecommendationButton.BackgroundColor = [0.93 0.60 0.12]; % Amber / Orange
            app.RecommendationButton.FontColor = [1 1 1];
            app.RecommendationButton.FontWeight = 'bold';
            app.RecommendationButton.Position = [325 9 200 32];
            app.RecommendationButton.Text = 'Generate Recommendation';

            % 4. Reset Button (Step 3 name: ResetButton)
            app.ResetButton = uibutton(app.BottomPanel, 'push');
            app.ResetButton.ButtonPushedFcn = createCallbackFcn(app, @ResetButtonPushed, true);
            app.ResetButton.BackgroundColor = [0.85 0.25 0.20]; % Red
            app.ResetButton.FontColor = [1 1 1];
            app.ResetButton.FontWeight = 'bold';
            app.ResetButton.Position = [540 9 100 32];
            app.ResetButton.Text = 'Reset';

            % Footer Note
            app.FooterLabel = uilabel(app.BottomPanel);
            app.FooterLabel.HorizontalAlignment = 'right';
            app.FooterLabel.FontAngle = 'italic';
            app.FooterLabel.FontColor = [0.35 0.35 0.35];
            app.FooterLabel.Position = [660 14 320 22];
            app.FooterLabel.Text = 'Agriculture Today | A Better Tomorrow (MATLAB App)';

            % Show the figure after all components are constructed
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = starter_app()
            createComponents(app);
            registerApp(app, app.UIFigure);
            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)
            delete(app.UIFigure);
        end
    end
end
