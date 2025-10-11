from flask import Flask, render_template, request, jsonify
import numpy as np
import pandas as pd
import plotly
import json
import plotly.graph_objs as go

app = Flask(__name__)

class SolarDesalination:
    def __init__(self):
        self.CH2O = 4.18  # J/g°C, specific heat capacity of water
        self.Hvap = 2400  # J/g, latent heat of vaporization of water
        self.num_intervals = 13
        self.time_intervals = np.linspace(0, (13 - 1) * 5, 13)
        self.time_array = np.array(self.time_intervals)
        self.total_time_seconds = 60 * 60
        self.conversion_factor = 0.001  # g to kg

    def calculate_area(self, shape, dim1, dim2=None):
        """Calculate area for the given shape"""
        if shape == 'circle':
            radius = dim1 / 100  # Convert cm to m
            return np.pi * (radius) ** 2
        elif shape == 'square':
            side = dim1 / 100
            return side ** 2
        elif shape == 'rectangle':
            length = dim1 / 100
            width = dim2 / 100
            return length * width
        elif shape == 'triangle':
            base = dim1 / 100
            height = dim2 / 100
            return 0.5 * base * height
        return 0

    def run_simulation(self, weights, temperatures, absorber_area, factor):
        # Convert inputs to numpy arrays
        weights = np.asarray(weights, dtype=np.float64)
        temperatures = np.asarray(temperatures, dtype=np.float64)

        # Calculate temperatures
        bulk_temp = np.mean(temperatures)
        surf_temp = np.max(temperatures)
        temp_diff = surf_temp - bulk_temp

        # Calculate mass loss
        mass_loss_g = weights - weights[0]
        mass_loss_kg = mass_loss_g * self.conversion_factor
        mass_loss_per_m2 = mass_loss_kg / absorber_area
        mass_loss_per_m2_ss3 = mass_loss_per_m2 * factor

        # Calculate mass flux and efficiency
        total_mass_loss_g = mass_loss_per_m2_ss3[-1] * 1000
        mass_flux = total_mass_loss_g / self.total_time_seconds
        efficiency = abs((mass_flux * temp_diff * self.CH2O) + (mass_flux * self.Hvap)) / (1 * 1000) * 100

        # Create results DataFrame
        results = pd.DataFrame({
            'Time_min': self.time_array,
            'Mass_g': weights,
            'Mass_Loss_g': mass_loss_g,
            'Mass_Loss_kg': mass_loss_kg,
            'Mass_Loss_kg_m2_Solar_Simulator2': mass_loss_per_m2,
            'Mass_Loss_kg_m2_Solar_Simulator3': mass_loss_per_m2_ss3,
            'Temperature_C': temperatures
        })

        return efficiency, mass_flux, results

    def create_plots(self, results_dict):
        """Create visualization plots"""
        results = pd.DataFrame(results_dict)
        
        # Plot 1: Mass loss over time
        trace1 = go.Scatter(
            x=results['Time_min'],
            y=results['Mass_Loss_kg_m2_Solar_Simulator2'],
            mode='lines+markers',
            name='Mass Loss',
            line=dict(color='#3366cc', width=2)
        )
        
        layout1 = go.Layout(
            title='Mass Loss Over Time',
            xaxis=dict(title='Time (minutes)'),
            yaxis=dict(title='Mass Loss (kg/m²)'),
            template='plotly_white'
        )
        
        plot1 = json.dumps(dict(data=[trace1], layout=layout1), cls=plotly.utils.PlotlyJSONEncoder)

        # Plot 2: Mass loss per square meter with Solar Simulator 3
        trace2 = go.Scatter(
            x=results['Time_min'],
            y=results['Mass_Loss_kg_m2_Solar_Simulator3'],
            mode='lines+markers',
            name='Mass Loss per m²',
            line=dict(color='#dc3912', width=2)
        )
        
        layout2 = go.Layout(
            title='Mass Loss per Square Meter (Solar Simulator 3)',
            xaxis=dict(title='Time (minutes)'),
            yaxis=dict(title='Mass Loss (kg/m²)'),
            template='plotly_white'
        )
        
        plot2 = json.dumps(dict(data=[trace2], layout=layout2), cls=plotly.utils.PlotlyJSONEncoder)

        return plot1, plot2

simulator = SolarDesalination()

@app.route('/')
def index():
    return render_template('index.html')

@app.route('/simulator')
def simulator_page():
    return render_template('simulator.html')

@app.route('/documentation')
def documentation():
    return render_template('documentation.html')

@app.route('/about')
def about():
    return render_template('about.html')

@app.route('/contact')
def contact():
    return render_template('contact.html')

@app.route('/presentation')
def presentation():
    return render_template('presentation.html')

@app.route('/simulate', methods=['POST'])
def simulate():
    try:
        data = request.get_json()
        
        # Extract and validate data
        try:
            weights = np.array(data['weights'], dtype=np.float64)
            temperatures = np.array(data['temperatures'], dtype=np.float64)
            shape = data['absorberShape']
            dim1 = float(data['dimension1'])
            dim2 = float(data['dimension2']) if data['dimension2'] else None
            factor = float(data['factor'])
        except (ValueError, TypeError) as e:
            return jsonify({
                'success': False,
                'error': "Invalid input data: Please check all numeric values."
            }), 400

        # Validate inputs
        if np.any(np.isnan(weights)) or np.any(np.isnan(temperatures)):
            raise ValueError("Invalid input data: All fields must be filled with numeric values.")

        if np.any(weights < 0) or np.any(temperatures < 0):
            raise ValueError("Invalid input data: Values cannot be negative.")

        if not dim1 or (shape in ['rectangle', 'triangle'] and not dim2):
            raise ValueError("Invalid dimensions for the selected shape.")

        # Calculate area
        area = simulator.calculate_area(shape, dim1, dim2)
        if area <= 0:
            raise ValueError("Invalid absorber area: Area must be greater than 0.")
        
        # Run simulation
        efficiency, mass_flux, results = simulator.run_simulation(weights, temperatures, area, factor)
        
        # Prepare results
        results_dict = results.round(6).to_dict('records')
        plot1_json, plot2_json = simulator.create_plots(results_dict)
        
        return jsonify({
            'success': True,
            'efficiency': round(efficiency, 2),
            'massFlux': round(mass_flux, 4),
            'results': results_dict,
            'plot1': plot1_json,
            'plot2': plot2_json
        })

    except Exception as e:
        return jsonify({
            'success': False,
            'error': str(e)
        }), 400

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000) 