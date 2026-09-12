# Smart India AgriMonitor
## Student Guide: Build, Run, and Test MATLAB App Designer GUI

Welcome to the **Smart India AgriMonitor** project. This repository contains the complete implementation, datasets, ready-to-run MATLAB code, and step-by-step App Designer snippets for building an intelligent agricultural monitoring and decision-support GUI.

---

## 📁 Project Contents

| File | Purpose |
| :--- | :--- |
| [`farm_data.csv`](file:///c:/Users/yashv/Desktop/Agrimonitor/farm_data.csv) | 72-hour hourly agricultural sensor dataset (`Timestamp`, `Temperature`, `SoilMoisture`, `Humidity`, `Rainfall`, `LightIntensity`). |
| [`starter_app.m`](file:///c:/Users/yashv/Desktop/Agrimonitor/starter_app.m) | Complete standalone runnable MATLAB App class. Recreates the full UI, layout, and agronomic intelligence matching the reference design. |
| [`APP_DESIGNER_CODE_SNIPPETS.m`](file:///c:/Users/yashv/Desktop/Agrimonitor/APP_DESIGNER_CODE_SNIPPETS.m) | Clean, modular code snippets formatted specifically for copying and pasting into MATLAB App Designer **Code View**. |
| [`README.md`](file:///c:/Users/yashv/Desktop/Agrimonitor/README.md) | Comprehensive technical documentation, threshold specifications, and verification checklist. |

---

## 🚀 Quick Start: Two Ways to Run

### Method A: Run Standalone MATLAB App Directly (Recommended)
You can run the complete app in **MATLAB Online** or **MATLAB Desktop** immediately:
1. Upload `starter_app.m` and `farm_data.csv` to your MATLAB Drive / Current Working Directory.
2. In the MATLAB Command Window, simply type:
   ```matlab
   starter_app
   ```
3. The GUI window will open. Click **Import Dataset**, select `farm_data.csv`, and then explore **Analyze Data** and **Generate Recommendation**.

---

### Method B: Build Interactively in App Designer (Visual Drag & Drop)
If your coursework requires building the app inside MATLAB App Designer (`starter_app.mlapp`):

#### 1. Open App Designer
- In MATLAB Online / Desktop: Click **Home > New > App > Blank App** (or type `appdesigner` in the Command Window).
- Save the file as `starter_app.mlapp`.

#### 2. Layout Components in Design View
Drag components from the Component Library into the canvas and group them with Panels as shown in the reference design:
- **Header Panel**: `TitleLabel`, `SubtitleLabel`, `MottoLabel`.
- **Dataset Panel**: `ImportButton`, `DataTable`.
- **Data Visualization Panel**: `UIAxes`.
- **Current Conditions Panel**: `TemperatureLabel`, `MoistureLabel`, `HumidityLabel`, `RainfallLabel`, `LightLabel`.
- **Crop Status Panel**: `StatusLamp`, `CropStatusLabel`, `StatusDescLabel`.
- **Recommendation Panel**: `RecommendationTextArea`.
- **Alerts / Messages Panel**: `AlertTextArea`.
- **Bottom Panel**: Action buttons (`ImportButton`, `AnalyzeButton`, `RecommendationButton`, `ResetButton`).

#### 3. Set Component Names (Exact Match)
In the right-hand **Component Browser**, rename components to match:

| Component Type | Component Name in App Designer |
| :--- | :--- |
| Figure Window | `UIFigure` |
| Import Button | `ImportButton` |
| Analyze Button | `AnalyzeButton` |
| Recommendation Button | `RecommendationButton` |
| Reset Button | `ResetButton` |
| Data Table | `DataTable` |
| Plot Axes | `UIAxes` |
| Temperature Label | `TemperatureLabel` |
| Soil Moisture Label | `MoistureLabel` |
| Humidity Label | `HumidityLabel` |
| Rainfall Label | `RainfallLabel` |
| Light Intensity Label | `LightLabel` |
| Status Lamp | `StatusLamp` |
| Crop Status Label | `CropStatusLabel` |
| Recommendation Text Area | `RecommendationTextArea` |
| Alert Text Area | `AlertTextArea` |

#### 4. Switch to Code View and Paste Code
Open [`APP_DESIGNER_CODE_SNIPPETS.m`](file:///c:/Users/yashv/Desktop/Agrimonitor/APP_DESIGNER_CODE_SNIPPETS.m):
- Paste **Section 1** under `properties (Access = private)`.
- In Design View, right-click each button -> **Callbacks** -> **Add ButtonPushedFcn**, then paste the contents from **Sections 2, 3, 4, and 5**.
- In Code View, click **Function > Private Function**, and paste the 4 private methods from **Section 6** (`updateDisplay`, `plotData`, `runAnalysis`, `generateRecommendations`).

---

## 🧠 Section 8 Implementation: Agronomic Intelligence & Decision Logic

### 1. Environmental Threshold Matrix

| Parameter | Healthy / Optimal (Green) | Warning / Suboptimal (Yellow) | Critical / Severe Stress (Red) |
| :--- | :--- | :--- | :--- |
| **Soil Moisture (%)** | `50% - 75%` | `40% - 49.9%` (Mild drying) or `> 80%` (Saturated) | `< 40.0%` (Severe wilt danger) |
| **Temperature (°C)** | `20.0°C - 32.0°C` | `33.0°C - 37.9°C` (Moderate heat) | `≥ 38.0°C` (Heat stress) or `< 10.0°C` (Frost) |
| **Humidity (%)** | `50% - 75%` | `75% - 85%` | `> 85%` (High pathogen & blight risk) |
| **Moisture Trend** | Stable / Incremental | `Drop > 10%` over 12 hours | Sudden sharp depletion |

### 2. Status Decision Engine (`StatusLamp` & `CropStatusLabel`)
- **CRITICAL (Red Lamp: `[0.90 0.15 0.15]`)**: Triggered when Soil Moisture $< 40\%$ or Temperature $\ge 38^\circ\text{C}$.
- **WARNING (Yellow Lamp: `[0.95 0.70 0.05]`)**: Triggered when Soil Moisture is between $40\%-50\%$, Temperature between $33^\circ\text{C}-38^\circ\text{C}$, Humidity $> 85\%$, or rapid moisture decline ($>10\%$ drop).
- **NORMAL (Green Lamp: `[0.15 0.75 0.25]`)**: When all environmental variables lie within safe agronomic parameters.

### 3. Automated Diagnostic Alerts (`AlertTextArea`)
Automatically logs diagnostic findings upon analysis:
- **`[CRITICAL ALERT]`**: Notifies farmer when soil moisture drops below wilting point ($<40\%$) or temperature exceeds $35^\circ\text{C}$.
- **`[ANOMALY]`**: Tracks cumulative extreme weather events (e.g., *4 hours of heat stress $\ge 35^\circ\text{C}$ recorded; peak $38.0^\circ\text{C}$*).
- **`[DEFICIT]`**: Records total deficit exposure (e.g., *10 hours below $40\%$ soil moisture; minimum $27.3\%$*).
- **`[PATHOGEN ALERT]`**: Detects coinciding warm temperatures ($20-30^\circ\text{C}$) and high humidity ($>80\%$) favoring fungal spore incubation.

### 4. Precision Agronomic Recommendations (`RecommendationTextArea`)
Generates actionable operational guidance:
1. **Irrigation Prescription**:
   - Critically dry: Apply 25–30 mm urgent drip irrigation during evening/dawn.
   - Moderately dry: Schedule 15–20 mm irrigation cycle within 12 hours.
   - Saturated: Suspend pumps to avert root hypoxia.
2. **Thermal & Canopy Management**:
   - Recommends 50% agro-shade netting and micro-sprinkler misting when $T \ge 35^\circ\text{C}$ or Light Intensity $> 700$.
3. **Disease Control & IPM**:
   - Prescribes canopy pruning and bio-fungicide (*Trichoderma viride*) during elevated humidity.
4. **Fertigation Safety**:
   - Restricts chemical granular fertilizers during drought to protect roots against osmotic shock.

---

## 📊 Dataset Analysis Summary (`farm_data.csv`)

Running analysis on the supplied 72-hour dataset produces the following verification values:
- **Total Observations**: 72 rows (from `2026-09-09 00:00` to `2026-09-11 23:00`).
- **Latest Observation Values (Displayed on Dashboard)**:
  - Temperature: **21.2 °C**
  - Soil Moisture: **37.4 %** *(triggers CRITICAL status because $< 40\%$)*
  - Humidity: **79.0 %**
  - Rainfall: **0.0 mm**
  - Light Intensity: **0**
- **Historical Extrema**:
  - Maximum Temperature: **38.0 °C** (Heatwave at `2026-09-10 11:00`)
  - Minimum Soil Moisture: **27.3 %** (Severe drought trough at `2026-09-11 12:00`)
  - Cumulative Rainfall: **28.4 mm**

---

## ✅ Final Student Checklist (Step 11 Verification)

| Item | Requirement | Status | Verification Note |
| :---: | :--- | :---: | :--- |
| 1 | App opens without errors | ✅ Pass | Verified clean launch with `starter_app`. |
| 2 | CSV imports successfully | ✅ Pass | `uigetfile` dialog reads `farm_data.csv` smoothly. |
| 3 | Data table displays all required columns | ✅ Pass | Displays Timestamp, Temperature, SoilMoisture, Humidity, Rainfall, LightIntensity. |
| 4 | Sensor values update | ✅ Pass | Latest row values populate the Current Conditions labels. |
| 5 | At least one useful chart is shown | ✅ Pass | Multi-variable line plot with distinct colors, legend, and grid. |
| 6 | Analyze button performs team-created analysis | ✅ Pass | Executes comprehensive statistical and agronomic evaluation. |
| 7 | Green/Yellow/Red status is visible with text | ✅ Pass | Status lamp changes color dynamically with corresponding label badge. |
| 8 | Recommendation is generated | ✅ Pass | 4-point actionable prescription rendered in `RecommendationTextArea`. |
| 9 | At least one automated alert exists | ✅ Pass | Multi-tier timestamped alerts generated in `AlertTextArea`. |
| 10 | Reset button clears/restores app safely | ✅ Pass | Resets table, plot, sensor labels, lamp, and text areas to initial state. |
