# Solar Desalination Simulator

A modern web application for simulating and analyzing solar desalination processes. This application provides an intuitive interface for inputting experimental data, running simulations, and visualizing results.

## Features

- 📊 Real-time data visualization with interactive plots
- 🎯 Support for multiple absorber shapes (Circle, Square, Rectangle, Triangle)
- 📈 Automatic calculation of efficiency and mass flux
- 💡 Modern, responsive user interface
- 📱 Mobile-friendly design
- 🔍 Detailed results table with comprehensive measurements

## Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd solar-desalination-simulator
```

2. Create a virtual environment (recommended):
```bash
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
```

3. Install dependencies:
```bash
pip install -r requirements.txt
```

## Usage

1. Start the Flask application:
```bash
python app.py
```

2. Open your web browser and navigate to:
```
http://localhost:5000
```

3. Input your experimental data:
   - Enter weight measurements
   - Enter temperature readings
   - Select absorber shape and dimensions
   - Adjust the factor value if needed

4. Click "Run Simulation" to see the results

## Technical Details

### Input Parameters

- **Weight Measurements**: Weight values in grams (g) at 5-minute intervals
- **Temperature Records**: Temperature values in Celsius (°C) at 5-minute intervals
- **Absorber Parameters**:
  - Shape: Circle, Square, Rectangle, or Triangle
  - Dimensions: Based on selected shape (in centimeters)
  - Factor: Adjustment factor for calculations

### Calculations

- Mass loss calculations in various units (g, kg, kg/m²)
- Efficiency calculation based on:
  - Specific heat capacity of water (4.18 J/g°C)
  - Latent heat of vaporization (2400 J/g)
- Mass flux calculation in g/m²·s

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the LICENSE file for details. 