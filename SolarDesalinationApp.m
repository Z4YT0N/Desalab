classdef Water DesalantionalinationApp < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                        matlab.ui.Figure
        TabGroup                        matlab.ui.container.TabGroup
        InputTab                        matlab.ui.container.Tab
        RunSimulationButton             matlab.ui.control.Button
        AbsorberParametersPanel         matlab.ui.container.Panel
        AbsorberTypeDropdownLabel       matlab.ui.control.Label
        AbsorberTypeDropdown            matlab.ui.control.DropDown
        Dimension1EditFieldLabel        matlab.ui.control.Label
        Dimension1EditField             matlab.ui.control.NumericEditField
        Dimension2EditFieldLabel        matlab.ui.control.Label
        Dimension2EditField             matlab.ui.control.NumericEditField
        FactorEditFieldLabel            matlab.ui.control.Label
        FactorEditField                 matlab.ui.control.NumericEditField
        InstructionsTextArea            matlab.ui.control.TextArea
        ResultsTab                      matlab.ui.container.Tab
        EfficiencyLabel                 matlab.ui.control.Label
        MassFluxLabel                   matlab.ui.control.Label
        ResultsTable                    matlab.ui.control.Table
        UIAxes1                         matlab.ui.control.UIAxes
        UIAxes2                         matlab.ui.control.UIAxes
        WeightTable                     matlab.ui.control.Table
        TemperatureTable                matlab.ui.control.Table
    end

    properties (Access = private)
        % Private properties
        NumIntervals = 13; % Number of time intervals
        TimeIntervals;     % Time intervals array
    end

    % Callbacks that handle component events
    methods (Access = private)

        % App initialization
        function startupFcn(app)
            % Initialize time intervals (every 5 minutes)
            app.TimeIntervals = linspace(0, (app.NumIntervals - 1) * 5, app.NumIntervals);

            % Default values for weight and temperature
            defaultWeights = [220.48; 220.42; 220.37; 220.30; 220.25; 220.19; 220.12; 220.06; 220.00; 219.93; 219.87; 219.81; 219.76];
            defaultTemperatures = [24; 32; 32; 32; 34; 34; 34; 34; 34; 34; 34; 34; 34];

            % Initialize tables with default values
            app.WeightTable.Data = defaultWeights;
            app.TemperatureTable.Data = defaultTemperatures;

            % Initialize absorber type and dimensions
            app.updateAbsorberFields();

            % Improve UI appearance
            app.improveUIAppearance();
        end

        % Improve UI appearance
        function improveUIAppearance(app)
            % Modern color palette
            colors = struct( ...
                'primary', [0.2, 0.6, 0.8], ...        % Blue
                'secondary', [0.25, 0.25, 0.25], ...  % Dark Gray
                'background', [0.96, 0.96, 0.96], ... % Light Gray
                'card', [1, 1, 1], ...                % White
                'accent', [0.4, 0.4, 0.8], ...        % Purple
                'success', [0.2, 0.7, 0.4], ...       % Green
                'warning', [0.85, 0.33, 0.10]);       % Orange

            % Main window styling
            app.UIFigure.Color = colors.background;
            app.UIFigure.Name = '🌞 Solar Desalination Simulator';

            % Tab styling
            app.InputTab.BackgroundColor = colors.background;
            app.InputTab.Title = '📋 Input';
            app.ResultsTab.BackgroundColor = colors.background;
            app.ResultsTab.Title = '📊 Results';

            % Instructions text area
            app.InstructionsTextArea.BackgroundColor = colors.card;
            app.InstructionsTextArea.FontSize = 14;
            app.InstructionsTextArea.FontName = 'Helvetica';
            app.InstructionsTextArea.FontWeight = 'bold';
            app.InstructionsTextArea.Value = {
                '📝 Quick Guide:', ...
                '1️⃣ Input weight and temperature values.', ...
                '2️⃣ Select absorber shape and specify dimensions.', ...
                '3️⃣ Adjust the factor value if needed.', ...
                '4️⃣ Click "▶ Run Simulation" for results.'
            };

            % Buttons styling
            app.styleButton(app.RunSimulationButton, colors.primary, '▶ Run Simulation');

            % Absorber Panel styling
            app.AbsorberParametersPanel.BackgroundColor = colors.card;
            app.AbsorberParametersPanel.FontWeight = 'bold';
            app.AbsorberParametersPanel.FontSize = 14;
            app.AbsorberParametersPanel.BorderType = 'etchedin';
            app.AbsorberParametersPanel.Title = '🌟 Absorber Parameters';

            % Tables styling
            app.styleTable(app.WeightTable, '⚖ Weight Measurements (g)');
            app.styleTable(app.TemperatureTable, '🌡 Temperature Records (°C)');
            app.styleTable(app.ResultsTable, '📊 Results Table');

            % Dropdown styling
            app.AbsorberTypeDropdown.BackgroundColor = colors.card;
            app.AbsorberTypeDropdown.FontSize = 12;

            % Edit fields styling
            app.styleEditField(app.Dimension1EditField);
            app.styleEditField(app.Dimension2EditField);
            app.styleEditField(app.FactorEditField);

            % Results labels
            app.styleResultLabel(app.EfficiencyLabel, '⚡ Efficiency:');
            app.styleResultLabel(app.MassFluxLabel, '⚖ Mass Flux:');

            % Plots styling
            app.stylePlot(app.UIAxes1, 'Cumulative Mass Loss Over Time', 'Time (minutes)', 'Mass Loss (kg)');
            app.stylePlot(app.UIAxes2, 'Mass Loss per m²', 'Time (minutes)', 'Mass Loss (kg/m²)');
        end

        % Helper function to style buttons
        function styleButton(app, button, color, text)
            button.BackgroundColor = color;
            button.FontColor = [1 1 1];
            button.FontWeight = 'bold';
            button.FontSize = 14;
            button.Text = text;
            button.Position(4) = 40; % Increase height
            button.FontName = 'Helvetica';
            % Remove unsupported properties
            % button.BorderWidth = 0;
            % button.Roundness = 5;
        end

        % Helper function to style tables
        function styleTable(app, table, title)
            table.BackgroundColor = [1 1 1];
            table.FontSize = 12;
            table.FontName = 'Helvetica';
            table.ColumnName = {title};
            table.RowStriping = 'on';
        end

        % Helper function to style edit fields
        function styleEditField(app, field)
            field.BackgroundColor = [1 1 1];
            field.FontSize = 12;
            field.Position(4) = 30; % Increase height
            field.FontName = 'Helvetica';
            % Remove unsupported property
            % field.Roundness = 5;
        end

        % Helper function to style result labels
        function styleResultLabel(app, label, prefix)
            label.FontSize = 16;
            label.FontWeight = 'bold';
            label.FontName = 'Helvetica';
            label.Text = [prefix ' N/A'];
            label.FontColor = [0.15 0.15 0.15];
        end

        % Helper function to style plots
        function stylePlot(app, axesHandle, titleText, xLabelText, yLabelText)
            axesHandle.FontSize = 11;
            axesHandle.FontName = 'Helvetica';
            axesHandle.Title.String = titleText;
            axesHandle.Title.FontWeight = 'bold';
            axesHandle.Title.FontSize = 13;
            axesHandle.XLabel.String = xLabelText;
            axesHandle.YLabel.String = yLabelText;
            axesHandle.Box = 'on';
            axesHandle.GridLineStyle = ':';
            axesHandle.GridAlpha = 0.2;
            axesHandle.GridColor = [0.5 0.5 0.5];
            axesHandle.Color = [1 1 1];
            axesHandle.XGrid = 'on';
            axesHandle.YGrid = 'on';
        end

        % Button pushed function: RunSimulationButton
        function RunSimulationButtonPushed(app, event)
            % Collect data from tables
            weights = app.WeightTable.Data;
            temperatures = app.TemperatureTable.Data;

            % Validate data
            if any(isnan(weights)) || any(isnan(temperatures))
                uialert(app.UIFigure, 'Please fill all the values in the tables.', 'Input Error');
                return;
            end

            % Validate that weights are decreasing
            if any(diff(weights) > 0)
                uialert(app.UIFigure, 'Weight values should be decreasing over time.', 'Input Error');
                return;
            end

            % Validate temperature range
            if any(temperatures < 0) || any(temperatures > 100)
                uialert(app.UIFigure, 'Temperature values should be between 0 and 100°C.', 'Input Error');
                return;
            end

            % Get absorber area based on selected shape and input dimensions
            [absorber_area, error_msg] = app.calculateAbsorberArea();
            if ~isempty(error_msg)
                uialert(app.UIFigure, error_msg, 'Input Error');
                return;
            end

            % Get the factor value from the user input
            factor = app.FactorEditField.Value;

            % Run simulation
            [efficiency, mass_flux, resultsData] = app.runSimulation(weights, temperatures, absorber_area, factor);

            % Update results
            app.EfficiencyLabel.Text = sprintf('⚡ Efficiency: %.2f%%', efficiency);
            app.MassFluxLabel.Text = sprintf('⚖ Mass Flux: %.4f g/m²·s', mass_flux);

            % Format data for display
            resultsCell = table2cell(resultsData);
            columnNames = resultsData.Properties.VariableNames;

            for i = 1:size(resultsCell, 1)
                % Time_min (integer with no decimal places)
                resultsCell{i, 1} = sprintf('%.0f', resultsCell{i, 1});
                % Mass_g (two decimal places)
                resultsCell{i, 2} = sprintf('%.2f', resultsCell{i, 2});
                % Mass_Loss_g (two decimal places)
                resultsCell{i, 3} = sprintf('%.2f', resultsCell{i, 3});
                % Mass_Loss_kg (five decimal places)
                resultsCell{i, 4} = sprintf('%.5f', resultsCell{i, 4});
                % Mass_Loss_kg_m2_Solar_Simulator2 (eight decimal places)
                resultsCell{i, 5} = sprintf('%.8f', resultsCell{i, 5});
                % Mass_Loss_kg_m2_Solar_Simulator3 (eight decimal places)
                resultsCell{i, 6} = sprintf('%.8f', resultsCell{i, 6});
                % Temperature_C (one decimal place)
                resultsCell{i, 7} = sprintf('%.1f', resultsCell{i, 7});
            end

            % Update results table
            app.ResultsTable.Data = resultsCell;
            app.ResultsTable.ColumnName = columnNames;

            % Update plots
            app.updatePlots(resultsData);
        end

        % Simulation function
        function [efficiency, mass_flux, resultsData] = runSimulation(app, weights, temperatures, absorber_area, factor)
            % Constants
            CH2O = 4.18; % J/g°C, specific heat capacity of water
            Hvap = 2400; % J/g, latent heat of vaporization of water

            % Calculate temperature difference
            bulk_temp = mean(temperatures); % Average bulk temperature
            surf_temp = max(temperatures); % Surface temperature
            temp_diff = surf_temp - bulk_temp;

            % Calculate mass loss (positive values)
            mass = weights;
            mass_loss_g = weights - weights(1); % Mass loss in grams
            mass_loss_kg = mass_loss_g * 0.001; % Convert to kg
            mass_loss_per_m2 = mass_loss_kg / absorber_area; % Loss per m²

            % Calculate Mass Loss (kg/m²) Solar Simulator 3 using the user-input factor
            mass_loss_per_m2_SS3 = mass_loss_per_m2 * factor;

            % Mass flux calculation in g/m²·s
            total_mass_loss_g = mass_loss_per_m2_SS3(end) * 1000; % Total mass loss in grams per m²
            total_time_seconds = 60 * 60; % Total time in seconds
            mass_flux = total_mass_loss_g / total_time_seconds; % g/m²·s

            % Efficiency calculation
            efficiency = abs((mass_flux * temp_diff * CH2O) + (mass_flux * Hvap)) / (1 * 1000) * 100;

            % Prepare results table
            resultsData = table(app.TimeIntervals', mass, mass_loss_g, mass_loss_kg, mass_loss_per_m2, mass_loss_per_m2_SS3, temperatures, ...
                'VariableNames', {'Time_min', 'Mass_g', 'Mass_Loss_g', 'Mass_Loss_kg', 'Mass_Loss_kg_m2_Solar_Simulator2', 'Mass_Loss_kg_m2_Solar_Simulator3', 'Temperature_C'});
        end

        % Update plots function
        function updatePlots(app, resultsData)
            % Plot cumulative mass loss over time
            plot(app.UIAxes1, resultsData.Time_min, resultsData.Mass_Loss_kg, '-o', 'LineWidth', 2, 'Color', [0.2 0.6 0.8]);
            title(app.UIAxes1, 'Cumulative Mass Loss Over Time');
            xlabel(app.UIAxes1, 'Time (minutes)');
            ylabel(app.UIAxes1, 'Mass Loss (kg)');
            grid(app.UIAxes1, 'on');

            % Plot mass loss per square meter (Solar Simulator 2)
            plot(app.UIAxes2, resultsData.Time_min, resultsData.Mass_Loss_kg_m2_Solar_Simulator2, '-x', 'LineWidth', 2, 'Color', [0.8 0.4 0.4]);
            title(app.UIAxes2, 'Mass Loss per Square Meter Over Time (Solar Simulator 2)');
            xlabel(app.UIAxes2, 'Time (minutes)');
            ylabel(app.UIAxes2, 'Mass Loss (kg/m²)');
            grid(app.UIAxes2, 'on');
        end

        % Absorber area calculation
        function [area, error_msg] = calculateAbsorberArea(app)
            absorberType = app.AbsorberTypeDropdown.Value;
            d1 = app.Dimension1EditField.Value;
            d2 = app.Dimension2EditField.Value;

            error_msg = '';
            area = 0;

            switch absorberType
                case 'Circle'
                    if d1 <= 0
                        error_msg = 'Radius must be a positive number.';
                        return;
                    end
                    radius = d1 / 100; % Convert cm to m
                    area = pi * (radius)^2;
                case 'Square'
                    if d1 <= 0
                        error_msg = 'Side length must be a positive number.';
                        return;
                    end
                    side = d1 / 100; % Convert cm to m
                    area = side^2;
                case 'Rectangle'
                    if d1 <= 0 || d2 <= 0
                        error_msg = 'Length and width must be positive numbers.';
                        return;
                    end
                    length = d1 / 100; % Convert cm to m
                    width = d2 / 100; % Convert cm to m
                    area = length * width;
                case 'Triangle'
                    if d1 <= 0 || d2 <= 0
                        error_msg = 'Base and height must be positive numbers.';
                        return;
                    end
                    base = d1 / 100; % Convert cm to m
                    height = d2 / 100; % Convert cm to m
                    area = 0.5 * base * height;
                otherwise
                    error_msg = 'Unknown absorber shape.';
                    return;
            end
        end

        % Absorber type selection changed
        function AbsorberTypeDropdownValueChanged(app, event)
            app.updateAbsorberFields();
        end

        % Update absorber dimension fields based on selected type
        function updateAbsorberFields(app)
            absorberType = app.AbsorberTypeDropdown.Value;
            switch absorberType
                case 'Circle'
                    app.Dimension1EditFieldLabel.Text = 'Radius (cm)';
                    app.Dimension1EditField.Visible = 'on';
                    app.Dimension2EditFieldLabel.Visible = 'off';
                    app.Dimension2EditField.Visible = 'off';
                case 'Square'
                    app.Dimension1EditFieldLabel.Text = 'Side Length (cm)';
                    app.Dimension1EditField.Visible = 'on';
                    app.Dimension2EditFieldLabel.Visible = 'off';
                    app.Dimension2EditField.Visible = 'off';
                case 'Rectangle'
                    app.Dimension1EditFieldLabel.Text = 'Length (cm)';
                    app.Dimension1EditField.Visible = 'on';
                    app.Dimension2EditFieldLabel.Text = 'Width (cm)';
                    app.Dimension2EditFieldLabel.Visible = 'on';
                    app.Dimension2EditField.Visible = 'on';
                case 'Triangle'
                    app.Dimension1EditFieldLabel.Text = 'Base (cm)';
                    app.Dimension1EditField.Visible = 'on';
                    app.Dimension2EditFieldLabel.Text = 'Height (cm)';
                    app.Dimension2EditFieldLabel.Visible = 'on';
                    app.Dimension2EditField.Visible = 'on';
                otherwise
                    app.Dimension1EditField.Visible = 'off';
                    app.Dimension2EditField.Visible = 'off';
            end
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Position = [100 100 1200 700];
            app.UIFigure.Name = '🌞 Solar Desalination Simulator';

            % Create TabGroup
            app.TabGroup = uitabgroup(app.UIFigure);
            app.TabGroup.Position = [1 1 1200 700];

            % Create InputTab
            app.InputTab = uitab(app.TabGroup);
            app.InputTab.Title = '📋 Input';

            % Create InstructionsTextArea
            app.InstructionsTextArea = uitextarea(app.InputTab);
            app.InstructionsTextArea.Editable = 'off';
            app.InstructionsTextArea.Position = [20 620 1160 60];
            app.InstructionsTextArea.FontSize = 14;
            app.InstructionsTextArea.FontName = 'Helvetica';
            app.InstructionsTextArea.FontWeight = 'bold';
            app.InstructionsTextArea.Value = {
                '📝 Quick Guide:', ...
                '1️⃣ Enter weight and temperature values.', ...
                '2️⃣ Select absorber shape and input dimensions.', ...
                '3️⃣ Adjust factor value if necessary.', ...
                '4️⃣ Click "▶ Run Simulation" for results.'
            };

            % Create WeightTable
            app.WeightTable = uitable(app.InputTab);
            app.WeightTable.ColumnName = {'Weight (g)'};
            app.WeightTable.RowName = 'numbered';
            app.WeightTable.Position = [20 320 560 250];
            app.WeightTable.ColumnEditable = true;

            % Create TemperatureTable
            app.TemperatureTable = uitable(app.InputTab);
            app.TemperatureTable.ColumnName = {'Temperature (°C)'};
            app.TemperatureTable.RowName = 'numbered';
            app.TemperatureTable.Position = [620 320 560 250];
            app.TemperatureTable.ColumnEditable = true;

            % Create AbsorberParametersPanel
            app.AbsorberParametersPanel = uipanel(app.InputTab);
            app.AbsorberParametersPanel.Title = '🌟 Absorber Parameters';
            app.AbsorberParametersPanel.Position = [20 150 1160 150];
            app.AbsorberParametersPanel.FontSize = 14;
            app.AbsorberParametersPanel.FontName = 'Helvetica';
            app.AbsorberParametersPanel.FontWeight = 'bold';

            % Create AbsorberTypeDropdownLabel
            app.AbsorberTypeDropdownLabel = uilabel(app.AbsorberParametersPanel);
            app.AbsorberTypeDropdownLabel.HorizontalAlignment = 'right';
            app.AbsorberTypeDropdownLabel.Position = [20 80 100 22];
            app.AbsorberTypeDropdownLabel.Text = 'Absorber Shape';
            app.AbsorberTypeDropdownLabel.FontName = 'Helvetica';

            % Create AbsorberTypeDropdown
            app.AbsorberTypeDropdown = uidropdown(app.AbsorberParametersPanel);
            app.AbsorberTypeDropdown.Items = {'Circle', 'Square', 'Rectangle', 'Triangle'};
            app.AbsorberTypeDropdown.ValueChangedFcn = createCallbackFcn(app, @AbsorberTypeDropdownValueChanged, true);
            app.AbsorberTypeDropdown.Position = [135 80 100 22];
            app.AbsorberTypeDropdown.Value = 'Circle';

            % Create Dimension1EditFieldLabel
            app.Dimension1EditFieldLabel = uilabel(app.AbsorberParametersPanel);
            app.Dimension1EditFieldLabel.HorizontalAlignment = 'right';
            app.Dimension1EditFieldLabel.Position = [260 80 100 22];
            app.Dimension1EditFieldLabel.Text = 'Radius (cm)';
            app.Dimension1EditFieldLabel.FontName = 'Helvetica';

            % Create Dimension1EditField
            app.Dimension1EditField = uieditfield(app.AbsorberParametersPanel, 'numeric');
            app.Dimension1EditField.Position = [375 80 100 30];

            % Create Dimension2EditFieldLabel
            app.Dimension2EditFieldLabel = uilabel(app.AbsorberParametersPanel);
            app.Dimension2EditFieldLabel.HorizontalAlignment = 'right';
            app.Dimension2EditFieldLabel.Position = [500 80 100 22];
            app.Dimension2EditFieldLabel.FontName = 'Helvetica';

            % Create Dimension2EditField
            app.Dimension2EditField = uieditfield(app.AbsorberParametersPanel, 'numeric');
            app.Dimension2EditField.Position = [615 80 100 30];
            app.Dimension2EditField.Visible = 'off';
            app.Dimension2EditFieldLabel.Visible = 'off';

            % Create FactorEditFieldLabel
            app.FactorEditFieldLabel = uilabel(app.AbsorberParametersPanel);
            app.FactorEditFieldLabel.HorizontalAlignment = 'right';
            app.FactorEditFieldLabel.Position = [740 80 50 22];
            app.FactorEditFieldLabel.Text = 'Factor';
            app.FactorEditFieldLabel.FontName = 'Helvetica';

            % Create FactorEditField
            app.FactorEditField = uieditfield(app.AbsorberParametersPanel, 'numeric');
            app.FactorEditField.Position = [805 80 100 30];
            app.FactorEditField.Value = 0.472; % Default value

            % Create RunSimulationButton
            app.RunSimulationButton = uibutton(app.InputTab, 'push');
            app.RunSimulationButton.ButtonPushedFcn = createCallbackFcn(app, @RunSimulationButtonPushed, true);
            app.RunSimulationButton.Position = [550 20 150 40];
            app.RunSimulationButton.Text = '▶ Run Simulation';
            app.RunSimulationButton.FontSize = 14;
            app.RunSimulationButton.FontWeight = 'bold';
            app.RunSimulationButton.FontName = 'Helvetica';

            % Create ResultsTab
            app.ResultsTab = uitab(app.TabGroup);
            app.ResultsTab.Title = '📊 Results';

            % Create UIAxes1
            app.UIAxes1 = uiaxes(app.ResultsTab);
            title(app.UIAxes1, 'Cumulative Mass Loss Over Time')
            xlabel(app.UIAxes1, 'Time (minutes)')
            ylabel(app.UIAxes1, 'Mass Loss (kg)')
            app.UIAxes1.Position = [20 360 560 250];

            % Create UIAxes2
            app.UIAxes2 = uiaxes(app.ResultsTab);
            title(app.UIAxes2, 'Mass Loss per Square Meter Over Time (Solar Simulator 2)')
            xlabel(app.UIAxes2, 'Time (minutes)')
            ylabel(app.UIAxes2, 'Mass Loss (kg/m²)')
            app.UIAxes2.Position = [600 360 560 250];

            % Create ResultsTable
            app.ResultsTable = uitable(app.ResultsTab);
            app.ResultsTable.Position = [20 20 1140 320];
            app.ResultsTable.ColumnName = {}; % Column names will be set dynamically
            app.ResultsTable.RowName = 'numbered';

            % Create MassFluxLabel
            app.MassFluxLabel = uilabel(app.ResultsTab);
            app.MassFluxLabel.Position = [600 620 400 22];
            app.MassFluxLabel.Text = '⚖ Mass Flux: N/A';
            app.MassFluxLabel.FontSize = 16;
            app.MassFluxLabel.FontWeight = 'bold';
            app.MassFluxLabel.FontName = 'Helvetica';

            % Create EfficiencyLabel
            app.EfficiencyLabel = uilabel(app.ResultsTab);
            app.EfficiencyLabel.Position = [600 650 400 22];
            app.EfficiencyLabel.Text = '⚡ Efficiency: N/A';
            app.EfficiencyLabel.FontSize = 16;
            app.EfficiencyLabel.FontWeight = 'bold';
            app.EfficiencyLabel.FontName = 'Helvetica';

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = Water DesalantionalinationApp

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.UIFigure)

            % Execute the startup function
            runStartupFcn(app, @startupFcn)

        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.UIFigure)
        end
    end
end
