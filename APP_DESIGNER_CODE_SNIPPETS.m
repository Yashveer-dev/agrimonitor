% ==============================================================================
% SMART INDIA AGRIMONITOR - APP DESIGNER CODE VIEW COPY-PASTE SNIPPETS
% ==============================================================================
% Instructions for MATLAB Online / Desktop App Designer:
% 1. Open starter_app.mlapp in App Designer.
% 2. Switch from "Design View" to "Code View" (top toggle above the canvas).
% 3. Copy and paste the corresponding blocks below into the designated sections.
% ==============================================================================

%% -----------------------------------------------------------------------------
% SECTION 1: PRIVATE PROPERTIES (Step 4 & Section 8)
% -----------------------------------------------------------------------------
% In App Designer: Click "Property" -> "Private Property" on the Editor tab.
% Paste the following:

properties (Access = private)
    Data = table()              % Agricultural dataset table
    DataLoaded = false          % Flag indicating if dataset is imported
    CropHealthStatus = 'NONE'   % Status state: 'NORMAL', 'WARNING', 'CRITICAL'
end


%% -----------------------------------------------------------------------------
% SECTION 2: IMPORT BUTTON CALLBACK (Step 5)
% -----------------------------------------------------------------------------
% In Design View: Select ImportButton -> Callbacks -> Add ButtonPushedFcn.
% Paste this inside the generated function:

function ImportButtonPushed(app, event)
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
             'Status: Ready. Click "Analyze Data" to evaluate crop health.'};
        app.updateDisplay();
        app.plotData();
    catch ME
        app.AlertTextArea.Value = {['Error loading dataset: ' ME.message]};
    end
end


%% -----------------------------------------------------------------------------
% SECTION 3: ANALYZE BUTTON CALLBACK (Step 8: Student Intelligence)
% -----------------------------------------------------------------------------
% In Design View: Select AnalyzeButton -> Callbacks -> Add ButtonPushedFcn.
% Paste this inside:

function AnalyzeButtonPushed(app, event)
    app.runAnalysis();
end


%% -----------------------------------------------------------------------------
% SECTION 4: RECOMMENDATION BUTTON CALLBACK (Step 8: Student Intelligence)
% -----------------------------------------------------------------------------
% In Design View: Select RecommendationButton -> Callbacks -> Add ButtonPushedFcn.
% Paste this inside:

function RecommendationButtonPushed(app, event)
    app.generateRecommendations();
end


%% -----------------------------------------------------------------------------
% SECTION 5: RESET BUTTON CALLBACK (Step 8 & 11)
% -----------------------------------------------------------------------------
% In Design View: Select ResetButton -> Callbacks -> Add ButtonPushedFcn.
% Paste this inside:

function ResetButtonPushed(app, event)
    % 1. Clear internal dataset and status flags
    app.Data = table();
    app.DataLoaded = false;
    app.CropHealthStatus = 'NONE';
    
    % 2. Clear UI Table
    app.DataTable.Data = table();
    
    % 3. Clear UI Plot
    cla(app.UIAxes);
    title(app.UIAxes, 'Agricultural Sensor Data Over Time', 'FontWeight', 'bold');
    xlabel(app.UIAxes, 'Observation');
    ylabel(app.UIAxes, 'Sensor Value');
    grid(app.UIAxes, 'on');
    
    % 4. Reset Sensor Display Labels
    app.TemperatureLabel.Text = '-- °C';
    app.MoistureLabel.Text    = '-- %';
    app.HumidityLabel.Text    = '-- %';
    app.RainfallLabel.Text    = '-- mm';
    app.LightLabel.Text       = '--';
    
    % 5. Reset Status Lamp & Label to initial neutral state
    app.StatusLamp.Color = [0.70 0.70 0.70]; % Neutral Gray
    app.CropStatusLabel.Text = 'AWAITING DATA';
    app.CropStatusLabel.FontColor = [0.40 0.40 0.40];
    
    % 6. Reset Text Areas with informative prompts
    app.AlertTextArea.Value = {'App reset successfully.', 'Please import farm_data.csv to begin.'};
    app.RecommendationTextArea.Value = {'No recommendation available.', 'Import and analyze the dataset to generate agronomic insights.'};
end


%% -----------------------------------------------------------------------------
% SECTION 6: PRIVATE HELPER METHODS (Steps 6 & 8)
% -----------------------------------------------------------------------------
% In App Designer: Click "Function" -> "Private Function" on the Editor tab.
% Add the four private functions below:

% --- Method 1: Update Sensor Value Display ---
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

% --- Method 2: Visualize Sensor Trends ---
function plotData(app)
    if isempty(app.Data) || height(app.Data) == 0
        return;
    end
    cla(app.UIAxes);
    hold(app.UIAxes, 'on');
    x = 1:height(app.Data);
    
    % High-contrast, clean multi-sensor plots
    plot(app.UIAxes, x, app.Data.Temperature, 'LineWidth', 1.8, 'Color', [0.85 0.33 0.10]); % Temp (Orange-Red)
    plot(app.UIAxes, x, app.Data.SoilMoisture, 'LineWidth', 1.8, 'Color', [0.00 0.45 0.74]); % Moisture (Blue)
    plot(app.UIAxes, x, app.Data.Humidity,     'LineWidth', 1.8, 'Color', [0.47 0.67 0.19]); % Humidity (Green)
    plot(app.UIAxes, x, app.Data.Rainfall,     'LineWidth', 1.8, 'Color', [0.49 0.18 0.56]); % Rainfall (Purple)
    plot(app.UIAxes, x, app.Data.LightIntensity / 10, 'LineWidth', 1.8, 'Color', [0.93 0.69 0.13]); % Light/10 (Amber)
    
    hold(app.UIAxes, 'off');
    title(app.UIAxes, 'Agricultural Sensor Data Over Time', 'FontWeight', 'bold', 'FontSize', 12);
    xlabel(app.UIAxes, 'Observation (Hourly Timesteps)');
    ylabel(app.UIAxes, 'Sensor Value');
    legend(app.UIAxes, {'Temperature (°C)', 'Soil Moisture (%)', 'Humidity (%)', ...
        'Rainfall (mm)', 'Light Intensity / 10'}, 'Location', 'northeast', 'FontSize', 8);
    grid(app.UIAxes, 'on');
    app.UIAxes.Box = 'on';
end

% --- Method 3: Intelligence & Automated Alerts ---
function runAnalysis(app)
    if ~app.DataLoaded || isempty(app.Data)
        app.AlertTextArea.Value = {'[ERROR] No dataset loaded. Click "Import Dataset" first.'};
        return;
    end

    % Extract latest observation
    lastIdx = height(app.Data);
    T_curr = app.Data.Temperature(lastIdx);
    M_curr = app.Data.SoilMoisture(lastIdx);
    H_curr = app.Data.Humidity(lastIdx);
    R_curr = app.Data.Rainfall(lastIdx);
    L_curr = app.Data.LightIntensity(lastIdx);

    % Statistical aggregates & anomaly detectors
    maxTemp         = max(app.Data.Temperature);
    minMoisture     = min(app.Data.SoilMoisture);
    meanMoist       = mean(app.Data.SoilMoisture);
    totalRain       = sum(app.Data.Rainfall);
    heatStressHours = sum(app.Data.Temperature >= 35.0);
    drySoilHours    = sum(app.Data.SoilMoisture < 40.0);

    % Rate of drying over last 12 observations
    recentWindow  = max(1, lastIdx - 11):lastIdx;
    moistureTrend = app.Data.SoilMoisture(lastIdx) - app.Data.SoilMoisture(recentWindow(1));

    % 1. Green / Yellow / Red Status Decision Logic
    if M_curr < 40.0 || T_curr >= 38.0
        app.CropHealthStatus = 'CRITICAL';
        app.StatusLamp.Color = [0.90 0.15 0.15]; % Red Lamp
        app.CropStatusLabel.Text = 'CRITICAL';
        app.CropStatusLabel.FontColor = [0.80 0.10 0.10];
    elseif (M_curr >= 40.0 && M_curr < 50.0) || (T_curr >= 33.0 && T_curr < 38.0) || (H_curr > 85.0) || (moistureTrend < -10.0)
        app.CropHealthStatus = 'WARNING';
        app.StatusLamp.Color = [0.95 0.70 0.05]; % Yellow/Amber Lamp
        app.CropStatusLabel.Text = 'WARNING';
        app.CropStatusLabel.FontColor = [0.85 0.55 0.00];
    else
        app.CropHealthStatus = 'NORMAL';
        app.StatusLamp.Color = [0.15 0.75 0.25]; % Green Lamp
        app.CropStatusLabel.Text = 'NORMAL';
        app.CropStatusLabel.FontColor = [0.10 0.60 0.20];
    end

    % 2. Automated Diagnostic Alerts
    alerts = {};
    alerts{end+1} = sprintf('=== ANALYSIS SUMMARY (%d Observations Evaluated) ===', height(app.Data));
    alerts{end+1} = sprintf('Crop Health Status: %s', app.CropHealthStatus);

    if M_curr < 40.0
        alerts{end+1} = sprintf('[CRITICAL ALERT] Soil Moisture (%.1f%%) < 40%% threshold! Root zone severely dried.', M_curr);
    elseif M_curr < 50.0
        alerts{end+1} = sprintf('[WARNING] Soil Moisture (%.1f%%) is low. Irrigation required soon.', M_curr);
    else
        alerts{end+1} = sprintf('[OK] Soil Moisture (%.1f%%) is adequate.', M_curr);
    end

    if T_curr >= 35.0
        alerts{end+1} = sprintf('[CRITICAL ALERT] Temperature (%.1f°C) exceeds 35°C heat stress threshold!', T_curr);
    elseif T_curr >= 32.0
        alerts{end+1} = sprintf('[WARNING] Elevated Temperature (%.1f°C). High transpiration risk.', T_curr);
    end

    if heatStressHours > 0
        alerts{end+1} = sprintf('[ANOMALY] %d hours of heat stress (>=35°C) recorded. Peak: %.1f°C.', heatStressHours, maxTemp);
    end

    if drySoilHours > 0
        alerts{end+1} = sprintf('[DEFICIT] Crop endured %d hours below 40%% soil moisture. Minimum: %.1f%%.', drySoilHours, minMoisture);
    end

    if H_curr >= 80.0 && T_curr >= 20.0 && T_curr <= 30.0
        alerts{end+1} = sprintf('[PATHOGEN ALERT] Humidity (%.1f%%) & warm temperature favor fungal spore growth.', H_curr);
    end

    alerts{end+1} = sprintf('[METRICS] Mean Moisture: %.1f%% | Cumulative Rain: %.1f mm', meanMoist, totalRain);
    alerts{end+1} = '[READY] Click "Generate Recommendation" for actionable agronomic steps.';

    app.AlertTextArea.Value = alerts;
end

% --- Method 4: Actionable Agronomic Recommendations ---
function generateRecommendations(app)
    if ~app.DataLoaded || isempty(app.Data)
        app.RecommendationTextArea.Value = {'Please import and analyze the dataset first.'};
        return;
    end

    if strcmp(app.CropHealthStatus, 'NONE')
        app.runAnalysis();
    end

    lastIdx = height(app.Data);
    T = app.Data.Temperature(lastIdx);
    M = app.Data.SoilMoisture(lastIdx);
    H = app.Data.Humidity(lastIdx);
    L = app.Data.LightIntensity(lastIdx);

    recs = {};
    recs{end+1} = sprintf('*** AGRONOMIC PRESCRIPTION (%s STATUS) ***', app.CropHealthStatus);
    recs{end+1} = '';

    % 1. Irrigation Prescription
    if M < 40.0
        recs{end+1} = sprintf('1. IRRIGATION [URGENT]: Soil moisture is critically low at %.1f%% (<40%% threshold). Apply 25-30 mm drip irrigation immediately during evening or dawn hours to minimize evaporation.', M);
    elseif M < 50.0
        recs{end+1} = sprintf('1. IRRIGATION [SCHEDULED]: Soil moisture is %.1f%%. Schedule 15-20 mm irrigation cycle within the next 12 hours.', M);
    elseif M > 75.0
        recs{end+1} = sprintf('1. IRRIGATION [SUSPEND]: Soil moisture is %.1f%%. Pause irrigation pumps to avoid waterlogging and root anoxia.', M);
    else
        recs{end+1} = sprintf('1. IRRIGATION [OPTIMAL]: Soil moisture is %.1f%%. Maintain regular scheduled fertigation.', M);
    end
    recs{end+1} = '';

    % 2. Thermal & Microclimate Shielding
    if T >= 35.0 || L > 700
        recs{end+1} = sprintf('2. MICROCLIMATE PROTECTION: Current temp (%.1f°C) and solar radiation (%.0f) cause high water loss. Deploy 50%% shade netting and activate misting nozzles between 11:00-14:00.', T, L);
    else
        recs{end+1} = '2. CANOPY MANAGEMENT: Solar radiation and temperature are balanced. Canopy photosynthetic efficiency is optimal.';
    end
    recs{end+1} = '';

    % 3. Disease & Integrated Pest Management
    if H >= 80.0
        recs{end+1} = sprintf('3. DISEASE PREVENTION: High relative humidity (%.1f%%) promotes fungal foliar blight. Thin crop canopy for airflow; apply preventive biological fungicide (Trichoderma).', H);
    else
        recs{end+1} = '3. DISEASE CONTROL: Humidity levels are in safe range. Continue standard IPM inspections.';
    end
    recs{end+1} = '';

    % 4. Soil Health & Nutrient Timing
    if M < 40.0
        recs{end+1} = '4. FERTIGATION CAUTION: Hold chemical granular fertilizers until soil moisture is restored above 50% to prevent salt stress and root burn.';
    else
        recs{end+1} = '4. FERTIGATION: Moisture levels support nutrient uptake. Proceed with normal N-P-K fertigation.';
    end

    app.RecommendationTextArea.Value = recs;
end
