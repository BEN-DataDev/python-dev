# VS Code Python Development Guide for Windows (venv Edition)

A comprehensive guide for setting up and managing Python development environments on Windows using virtual environments (venv). This guide covers geospatial and GIS development with ArcPy, PyQGIS, GDAL/OGR, and PostGIS integration.

**Last Updated:** 2026-01-05  
**Author:** BEN-DataDev  
**Scope:** Windows OS, Python venv, VS Code IDE

---

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Initial Setup](#initial-setup)
3. [Virtual Environment Management](#virtual-environment-management)
4. [VS Code Configuration](#vs-code-configuration)
5. [GIS Library Setup](#gis-library-setup)
   - [ArcPy Development](#arcpy-development)
   - [PyQGIS Development](#pyqgis-development)
   - [GDAL/OGR Development](#gdalogr-development)
   - [PostGIS Development](#postgis-development)
6. [Troubleshooting](#troubleshooting)
7. [Best Practices](#best-practices)

---

## Prerequisites

### System Requirements

- **Windows 10/11** (64-bit or 32-bit)
- **Python 3.8+** (Python 3.9+ recommended for compatibility)
- **Visual Studio Code** (latest version)
- **Git** (for version control)
- At least **2GB free disk space** per virtual environment

### Required Software

- Python: https://www.python.org/downloads/
- VS Code: https://code.visualstudio.com/
- Git: https://git-scm.com/
- GIS-specific tools (see individual sections below)

### Required VS Code Extensions

- Python (Microsoft)
- Pylance (Microsoft)
- Python Docstring Generator (Nils Werner)
- Black Formatter (Microsoft)
- Pylint (Microsoft)
- GitLens (Eric Amodio)

---

## Initial Setup

### 1. Install Python

1. Download Python from [python.org](https://www.python.org/downloads/)
2. Run the installer
3. **IMPORTANT:** Check "Add Python to PATH" during installation
4. Choose "Install for all users" (optional but recommended)

### 2. Verify Python Installation

```bash
python --version
pip --version
```

### 3. Create a Development Directory

```bash
mkdir C:\dev\python-projects
cd C:\dev\python-projects
```

### 4. Install Virtual Environment Tools

```bash
pip install --upgrade pip setuptools wheel
pip install virtualenv  # Optional, but provides additional features
```

---

## Virtual Environment Management

### Creating a Virtual Environment

```bash
# Navigate to your project directory
cd C:\dev\python-projects\my-project

# Create a virtual environment named 'venv'
python -m venv venv

# Alternative: Create with specific Python version
py -3.9 -m venv venv
```

### Activating a Virtual Environment

```bash
# On Windows Command Prompt (cmd)
venv\Scripts\activate.bat

# On Windows PowerShell
venv\Scripts\Activate.ps1

# On Windows Git Bash
source venv/Scripts/activate
```

**Note:** If PowerShell shows an execution policy error, run:
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### Deactivating a Virtual Environment

```bash
deactivate
```

### Deleting a Virtual Environment

```bash
# Simply remove the venv directory
rmdir /s venv  # Command Prompt
Remove-Item -Recurse venv  # PowerShell
```

### Managing Dependencies

```bash
# Install packages
pip install package_name

# Install from requirements file
pip install -r requirements.txt

# Generate requirements file
pip freeze > requirements.txt

# List installed packages
pip list
```

---

## VS Code Configuration

### 1. Select Python Interpreter

1. Open VS Code
2. Press `Ctrl+Shift+P` to open the Command Palette
3. Type "Python: Select Interpreter"
4. Choose the interpreter from your virtual environment: `.\venv\Scripts\python.exe`

### 2. Create Workspace Settings

Create `.vscode/settings.json` in your project root:

```json
{
  "python.defaultInterpreterPath": "${workspaceFolder}/venv/Scripts/python.exe",
  "python.formatting.provider": "black",
  "python.linting.enabled": true,
  "python.linting.pylintEnabled": true,
  "python.linting.pylintArgs": [
    "--disable=C0111",
    "--disable=R0913"
  ],
  "editor.formatOnSave": true,
  "[python]": {
    "editor.defaultFormatter": "ms-python.python",
    "editor.formatOnSave": true,
    "editor.codeActionsOnSave": {
      "source.organizeImports": true
    }
  },
  "python.testing.pytestEnabled": true,
  "python.testing.pytestArgs": [
    "tests"
  ]
}
```

### 3. Create Launch Configuration

Create `.vscode/launch.json` in your project root:

```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "Python: Current File",
      "type": "python",
      "request": "launch",
      "program": "${file}",
      "console": "integratedTerminal",
      "justMyCode": true
    },
    {
      "name": "Python: Module",
      "type": "python",
      "request": "launch",
      "module": "enter-your-module-name-here",
      "console": "integratedTerminal"
    }
  ]
}
```

### 4. Install Python Tools in Virtual Environment

```bash
# Activate your virtual environment
venv\Scripts\activate.bat

# Install development tools
pip install black pylint pytest pytest-cov
```

---

## GIS Library Setup

### ArcPy Development

#### Overview
ArcPy is the Python site-package for working with Esri's ArcGIS Pro and ArcMap. It provides GIS analysis, data management, and mapping capabilities.

#### Installation

**Requirement:** ArcGIS Pro must be installed on your system.

```bash
# Method 1: Using ArcGIS Pro's Python environment (Recommended for ArcGIS Pro)
# ArcGIS Pro comes with a built-in Python installation at:
# C:\Program Files\ArcGIS\Pro\bin\Python\envs\arcgispro-py3

# Method 2: Clone ArcGIS Pro's Python environment
cd C:\Program Files\ArcGIS\Pro\bin\Python
python -m venv C:\dev\python-projects\arcpy-env --system-site-packages
```

#### Virtual Environment Setup

```bash
# Create a dedicated ArcPy project directory
mkdir C:\dev\python-projects\arcpy-project
cd C:\dev\python-projects\arcpy-project

# Clone from ArcGIS Pro's environment
"C:\Program Files\ArcGIS\Pro\bin\Python\envs\arcgispro-py3\python.exe" -m venv venv --system-site-packages

# Activate virtual environment
venv\Scripts\activate.bat

# Install additional packages
pip install numpy pandas matplotlib requests
```

#### Verify ArcPy Installation

```python
import arcpy
print(arcpy.GetInstallInfo())
print(arcpy.CheckProduct("ArcInfo"))  # or "ArcEditor" or "ArcView"
```

#### ArcPy Example Script

```python
# arcpy_example.py
import arcpy
import os

# Set workspace
arcpy.env.workspace = r"C:\data\geodatabase.gdb"

# List feature classes
feature_classes = arcpy.ListFeatureClasses()
for fc in feature_classes:
    print(f"Feature Class: {fc}")
    count = arcpy.GetCount_management(fc)
    print(f"  Record count: {count[0]}")

# Create a buffer
input_features = "buildings"
output_features = "building_buffers"
buffer_distance = "100 Meters"

arcpy.Buffer_analysis(input_features, output_features, buffer_distance)
print(f"Buffer created: {output_features}")
```

#### Recommended Packages for ArcPy

```bash
pip install numpy pandas matplotlib requests geopandas shapely fiona
```

#### Key Resources

- ArcPy Documentation: https://pro.arcgis.com/en/pro-app/latest/arcpy/
- ArcPy Class Reference: https://pro.arcgis.com/en/pro-app/latest/arcpy/classes/

---

### PyQGIS Development

#### Overview
PyQGIS is the Python API for QGIS, allowing automation and extension of QGIS functionality. QGIS is open-source and supports complex geospatial analysis.

#### Installation

**Requirement:** QGIS must be installed (OSGeo4W or standalone).

```bash
# Method 1: Using QGIS's bundled Python (Windows)
# QGIS comes with Python at: C:\OSGeo4W (if using OSGeo4W)
# or C:\Program Files\QGIS x.x (if using standalone)

# Create project directory
mkdir C:\dev\python-projects\qgis-project
cd C:\dev\python-projects\qgis-project

# Create virtual environment with system-site-packages
# Assuming OSGeo4W installation
"C:\OSGeo4W\bin\python3.exe" -m venv venv --system-site-packages

# For standalone QGIS
"C:\Program Files\QGIS\apps\Python39\python.exe" -m venv venv --system-site-packages
```

#### Environment Variable Setup

Edit `.vscode\launch.json` to set QGIS environment variables:

```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "PyQGIS: Debug",
      "type": "python",
      "request": "launch",
      "program": "${file}",
      "console": "integratedTerminal",
      "justMyCode": true,
      "env": {
        "QGIS_PREFIX_PATH": "C:\\OSGeo4W",
        "PYTHONPATH": "C:\\OSGeo4W\\apps\\qgis\\python;C:\\OSGeo4W\\apps\\qgis\\python\\plugins"
      }
    }
  ]
}
```

#### Verify PyQGIS Installation

```python
# qgis_test.py
from qgis.core import QgsApplication, QgsProject

# Initialize QGIS application
qgs = QgsApplication([], False)
qgs.initQgisSettings()

# Load a project
project = QgsProject.instance()
project.read('path_to_your_project.qgz')

print(f"Loaded project: {project.fileName()}")
print(f"Layer count: {len(project.mapLayers())}")

# List layers
for layer_id, layer in project.mapLayers().items():
    print(f"Layer: {layer.name()}")
    if hasattr(layer, 'featureCount'):
        print(f"  Features: {layer.featureCount()}")

qgs.exitQgis()
```

#### PyQGIS Example Script

```python
# qgis_buffer.py
from qgis.core import QgsApplication, QgsProject, QgsVectorLayer
from processing.core.QgsProcessingFeedback import QgsProcessingFeedback
import processing

# Initialize QGIS
qgs = QgsApplication([], False)
qgs.initQgisSettings()

# Load project
project = QgsProject.instance()
project.read(r'C:\data\project.qgz')

# Access a layer
layers = project.mapLayersByName("buildings")
if layers:
    input_layer = layers[0]
    
    # Run buffer analysis
    params = {
        'INPUT': input_layer,
        'DISTANCE': 100,
        'SEGMENTS': 5,
        'END_CAP_STYLE': 0,
        'JOIN_STYLE': 0,
        'MITER_LIMIT': 2,
        'DISSOLVE': False,
        'OUTPUT': 'memory:'
    }
    
    result = processing.run('native:buffer', params)
    output_layer = result['OUTPUT']
    
    print(f"Buffer completed: {output_layer.name()}")
    print(f"Output features: {output_layer.featureCount()}")

qgs.exitQgis()
```

#### Recommended Packages for PyQGIS

```bash
pip install numpy pandas matplotlib shapely fiona geopandas
```

#### Key Resources

- PyQGIS Documentation: https://qgis.org/pyqgis/master/
- Processing Algorithms: https://docs.qgis.org/latest/en/docs/user_manual/processing_algs/

---

### GDAL/OGR Development

#### Overview
GDAL (Geospatial Data Abstraction Library) and OGR (Open Geospatial Data Format Library) provide tools for reading, writing, and translating geospatial data formats.

#### Installation

```bash
# Create project directory
mkdir C:\dev\python-projects\gdal-project
cd C:\dev\python-projects\gdal-project

# Create virtual environment
python -m venv venv
venv\Scripts\activate.bat

# Install GDAL for Windows
# Option 1: Using conda (easiest for Windows)
conda install -c conda-forge gdal

# Option 2: Using pre-built wheels from Unofficial Windows Binaries
# Download from: https://github.com/cgohlke/geospatial-wheels
# pip install gdal-3.8.0-cp311-cp311-win_amd64.whl

# Option 3: From OSGeo project
pip install GDAL==3.8.0  # Requires compilation tools
```

#### Verify GDAL Installation

```python
# gdal_test.py
from osgeo import gdal, ogr, osr

# Check GDAL version
print(f"GDAL Version: {gdal.VersionInfo()}")

# List available drivers
driver_count = ogr.GetDriverCount()
print(f"\nAvailable OGR Drivers ({driver_count}):")
for i in range(min(5, driver_count)):
    driver = ogr.GetDriver(i)
    print(f"  {driver.GetName()}")
```

#### GDAL/OGR Example Scripts

**Raster Processing:**

```python
# gdal_raster.py
from osgeo import gdal
import numpy as np

# Open a raster
dataset = gdal.Open(r'C:\data\dem.tif')
if dataset is None:
    print("Failed to open raster")
    exit(1)

# Get dataset info
print(f"Raster size: {dataset.RasterXSize} x {dataset.RasterYSize}")
print(f"Band count: {dataset.RasterCount}")

# Read a band
band = dataset.GetRasterBand(1)
data = band.ReadAsArray()
print(f"Data type: {data.dtype}")
print(f"Min/Max: {data.min()} / {data.max()}")

# Calculate statistics
band.ComputeStatistics(False)
stats = band.GetStatistics(False, False)
print(f"Statistics: Mean={stats[2]:.2f}, StdDev={stats[3]:.2f}")

dataset = None  # Close dataset
```

**Vector Processing:**

```python
# gdal_vector.py
from osgeo import ogr

# Open a vector dataset
driver = ogr.GetDriverByName("ESRI Shapefile")
dataset = driver.Open(r'C:\data\buildings.shp', 0)

if dataset is None:
    print("Failed to open shapefile")
    exit(1)

# Get layer
layer = dataset.GetLayer()
feature_count = layer.GetFeatureCount()
print(f"Feature count: {feature_count}")

# Iterate features
for feature in layer:
    geometry = feature.GetGeometryRef()
    print(f"Geometry type: {geometry.GetGeometryName()}")
    
    # Get attributes
    for field in layer.schema:
        field_name = field.GetName()
        field_value = feature.GetField(field_name)
        print(f"  {field_name}: {field_value}")

dataset = None  # Close dataset
```

**Format Conversion:**

```python
# gdal_convert.py
from osgeo import ogr, osr

# Open source shapefile
driver = ogr.GetDriverByName("ESRI Shapefile")
source_ds = driver.Open(r'C:\data\input.shp', 0)
source_layer = source_ds.GetLayer()

# Create GeoJSON output
output_driver = ogr.GetDriverByName("GeoJSON")
output_ds = output_driver.CreateDataSource(r'C:\data\output.geojson')
output_layer = output_ds.CreateLayer(source_layer.GetName(), source_layer.GetSpatialRef())

# Copy features
for feature in source_layer:
    output_layer.CreateFeature(feature)

# Clean up
source_ds = None
output_ds = None
print("Conversion complete")
```

#### Recommended Packages for GDAL

```bash
pip install numpy scipy matplotlib pandas rasterio fiona geopandas shapely
```

#### Key Resources

- GDAL Documentation: https://gdal.org/
- OGR Vector Formats: https://gdal.org/drivers/vector/
- GDAL Raster Formats: https://gdal.org/drivers/raster/

---

### PostGIS Development

#### Overview
PostGIS is a PostgreSQL extension that adds support for geographic objects and spatial queries. Python development typically uses `psycopg2` or `SQLAlchemy` for database connectivity.

#### Prerequisites

- PostgreSQL installed with PostGIS extension
- PostgreSQL connection string or credentials

#### Installation

```bash
# Create project directory
mkdir C:\dev\python-projects\postgis-project
cd C:\dev\python-projects\postgis-project

# Create virtual environment
python -m venv venv
venv\Scripts\activate.bat

# Install database drivers and tools
pip install psycopg2-binary SQLAlchemy geoalchemy2 pandas geopandas
```

#### PostgreSQL Connection Setup

Create a connection configuration file `.env`:

```env
DB_HOST=localhost
DB_PORT=5432
DB_NAME=gis_database
DB_USER=postgres
DB_PASSWORD=your_password
```

Install python-dotenv for configuration management:

```bash
pip install python-dotenv
```

#### Verify PostGIS Installation

```python
# postgis_test.py
import psycopg2
from psycopg2 import sql
from dotenv import load_dotenv
import os

# Load environment variables
load_dotenv()

# Connection parameters
conn_params = {
    'host': os.getenv('DB_HOST'),
    'port': os.getenv('DB_PORT'),
    'database': os.getenv('DB_NAME'),
    'user': os.getenv('DB_USER'),
    'password': os.getenv('DB_PASSWORD')
}

try:
    # Connect to database
    conn = psycopg2.connect(**conn_params)
    cursor = conn.cursor()
    
    # Check PostGIS version
    cursor.execute("SELECT postgis_version();")
    version = cursor.fetchone()
    print(f"PostGIS Version: {version[0]}")
    
    # List spatial tables
    cursor.execute("""
        SELECT table_name 
        FROM information_schema.tables 
        WHERE table_schema = 'public'
        AND table_type = 'BASE TABLE'
    """)
    tables = cursor.fetchall()
    print(f"\nTables in database:")
    for table in tables:
        print(f"  - {table[0]}")
    
    cursor.close()
    conn.close()
    
except Exception as e:
    print(f"Connection error: {e}")
```

#### PostGIS Example Scripts

**Using psycopg2:**

```python
# postgis_query.py
import psycopg2
from dotenv import load_dotenv
import os

load_dotenv()

conn_params = {
    'host': os.getenv('DB_HOST'),
    'database': os.getenv('DB_NAME'),
    'user': os.getenv('DB_USER'),
    'password': os.getenv('DB_PASSWORD')
}

try:
    conn = psycopg2.connect(**conn_params)
    cursor = conn.cursor()
    
    # Query geometries and calculate areas
    query = """
        SELECT 
            id, 
            name, 
            ST_Area(geometry) as area_sqm,
            ST_AsText(ST_Centroid(geometry)) as centroid
        FROM buildings
        WHERE ST_Area(geometry) > 1000
        ORDER BY ST_Area(geometry) DESC
        LIMIT 10;
    """
    
    cursor.execute(query)
    results = cursor.fetchall()
    
    print("Large Buildings:")
    print("-" * 80)
    for row in results:
        print(f"ID: {row[0]}, Name: {row[1]}, Area: {row[2]:.2f} m², Centroid: {row[3]}")
    
    cursor.close()
    conn.close()
    
except Exception as e:
    print(f"Error: {e}")
```

**Using SQLAlchemy with GeoAlchemy2:**

```python
# postgis_sqlalchemy.py
from sqlalchemy import create_engine, Column, Integer, String, select
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import Session
from geoalchemy2 import Geometry
from dotenv import load_dotenv
import os

load_dotenv()

# Database URL
db_url = (
    f"postgresql://{os.getenv('DB_USER')}:{os.getenv('DB_PASSWORD')}"
    f"@{os.getenv('DB_HOST')}:{os.getenv('DB_PORT')}"
    f"/{os.getenv('DB_NAME')}"
)

Base = declarative_base()

# Define a model
class Building(Base):
    __tablename__ = 'buildings'
    
    id = Column(Integer, primary_key=True)
    name = Column(String)
    geometry = Column(Geometry('POLYGON'))

# Connect and query
engine = create_engine(db_url)

with Session(engine) as session:
    # Query buildings
    buildings = session.query(Building).limit(5).all()
    
    print("Buildings:")
    for building in buildings:
        print(f"  ID: {building.id}, Name: {building.name}")
    
    # Spatial query: buildings within a distance
    from sqlalchemy import func
    
    stmt = select(Building).where(
        func.ST_DWithin(
            Building.geometry,
            func.ST_GeomFromText('POINT(0 0)', 4326),
            1000  # meters
        )
    )
    
    nearby = session.execute(stmt).scalars().all()
    print(f"\nBuildings within 1km of origin: {len(nearby)}")
```

**Batch Insert Geometries:**

```python
# postgis_insert.py
import psycopg2
from dotenv import load_dotenv
import os

load_dotenv()

conn_params = {
    'host': os.getenv('DB_HOST'),
    'database': os.getenv('DB_NAME'),
    'user': os.getenv('DB_USER'),
    'password': os.getenv('DB_PASSWORD')
}

try:
    conn = psycopg2.connect(**conn_params)
    cursor = conn.cursor()
    
    # Insert geometries
    data = [
        (1, 'Building A', 'POINT(0 0)'),
        (2, 'Building B', 'POINT(1 1)'),
        (3, 'Building C', 'POINT(2 2)')
    ]
    
    for id_val, name, geom_wkt in data:
        cursor.execute(
            "INSERT INTO buildings (id, name, geometry) VALUES (%s, %s, ST_GeomFromText(%s, 4326))",
            (id_val, name, geom_wkt)
        )
    
    conn.commit()
    print(f"Inserted {cursor.rowcount} records")
    
    cursor.close()
    conn.close()
    
except Exception as e:
    print(f"Error: {e}")
```

#### Recommended Packages for PostGIS

```bash
pip install psycopg2-binary SQLAlchemy geoalchemy2 pandas geopandas shapely
```

#### Key Resources

- PostGIS Documentation: https://postgis.net/docs/
- GeoAlchemy2: https://geoalchemy2.readthedocs.io/
- psycopg2 Documentation: https://www.psycopg.org/

---

## Troubleshooting

### Common Issues

#### 1. Virtual Environment Not Found

**Problem:** "venv not found" or Python not recognized

**Solution:**
```bash
# Verify Python installation
python --version

# Create venv with full path
python -m venv "C:\path\to\project\venv"

# Use py launcher for specific version
py -3.9 -m venv venv
```

#### 2. ArcPy Import Error

**Problem:** `ModuleNotFoundError: No module named 'arcpy'`

**Solution:**
```bash
# Ensure virtual environment uses --system-site-packages
"C:\Program Files\ArcGIS\Pro\bin\Python\envs\arcgispro-py3\python.exe" -m venv venv --system-site-packages

# Verify ArcGIS Pro installation
"C:\Program Files\ArcGIS\Pro\bin\Python\python.exe" -c "import arcpy; print(arcpy.GetInstallInfo())"
```

#### 3. GDAL Installation Issues

**Problem:** `ModuleNotFoundError: No module named 'osgeo'`

**Solution:**
```bash
# Use pre-built wheels (most reliable on Windows)
# Download from: https://github.com/cgohlke/geospatial-wheels
pip install gdal-3.8.0-cp311-cp311-win_amd64.whl

# Or use conda
conda install -c conda-forge gdal
```

#### 4. PostGIS Connection Refused

**Problem:** `psycopg2.OperationalError: could not connect to server`

**Solution:**
```python
# Check connection parameters
import psycopg2

try:
    conn = psycopg2.connect(
        host="localhost",
        port=5432,
        database="postgres",
        user="postgres",
        password="your_password"
    )
    print("Connected successfully")
    conn.close()
except psycopg2.OperationalError as e:
    print(f"Connection failed: {e}")
    # Verify PostgreSQL is running
    # Check firewall settings
    # Verify credentials
```

#### 5. PyQGIS Initialization Error

**Problem:** `QgsApplication: error - no application created`

**Solution:**
```python
# Initialize QGIS properly
from qgis.core import QgsApplication
import os

# Set QGIS prefix path before initialization
os.environ['QGIS_PREFIX_PATH'] = r'C:\OSGeo4W'

qgs = QgsApplication([], False)
qgs.initQgisSettings()
# ... your code ...
qgs.exitQgis()
```

#### 6. Wheels Not Compatible

**Problem:** `ERROR: Could not find a version that satisfies the requirement`

**Solution:**
```bash
# Check Python version and architecture
python -c "import struct; print(f'{struct.calcsize(\"P\")*8}-bit')"

# Download correct wheel from:
# - https://github.com/cgohlke/geospatial-wheels (GDAL)
# - https://www.lfd.uci.edu/~gohlke/pythonlibs/ (General packages)

# Install specific wheel
pip install package-version-py39-win_amd64.whl
```

---

## Best Practices

### 1. Virtual Environment Management

- **Create one venv per project** to avoid dependency conflicts
- **Use descriptive names** for venv directories
- **Add venv to .gitignore** to avoid committing large directories
- **Use `--system-site-packages` sparingly** (mainly for ArcPy/PyQGIS)

### 2. Dependency Management

```bash
# Always maintain requirements.txt
pip freeze > requirements.txt

# Use version pinning for critical packages
# Example requirements.txt
GDAL==3.8.0
SQLAlchemy==2.0.23
psycopg2-binary==2.9.9

# Use constraints file for maximum versions
pip install -c constraints.txt
```

### 3. Code Organization

```
project/
├── venv/                  # Virtual environment (git-ignored)
├── src/                   # Source code
│   ├── __init__.py
│   ├── main.py
│   └── gis_utils.py
├── tests/                 # Unit tests
│   ├── __init__.py
│   └── test_gis_utils.py
├── data/                  # Sample data (external storage recommended)
├── .vscode/               # VS Code settings
│   ├── settings.json
│   └── launch.json
├── .gitignore
├── requirements.txt
├── README.md
└── setup.py               # Package setup (if creating a package)
```

### 4. Environment Variables

Use `.env` files with `python-dotenv`:

```python
# .env
ARCGIS_LICENSE_PATH=C:\path\to\license
DB_HOST=localhost
DB_PORT=5432
QGIS_PREFIX_PATH=C:\OSGeo4W

# config.py
from dotenv import load_dotenv
import os

load_dotenv()
DB_HOST = os.getenv('DB_HOST', 'localhost')
DB_PORT = os.getenv('DB_PORT', 5432)
```

### 5. Version Control

Create `.gitignore`:

```
# Virtual environments
venv/
ENV/
env/
.venv

# Python
__pycache__/
*.py[cod]
*$py.class
*.egg-info/
dist/
build/

# IDE
.vscode/
.idea/
*.swp
*.swo

# Environment variables
.env
.env.local

# Data files (use external storage for large files)
*.shp
*.dbf
*.shx
*.prj
*.tif
*.geojson
```

### 6. Testing

Set up pytest for consistent testing:

```bash
pip install pytest pytest-cov
```

Create `tests/test_example.py`:

```python
# tests/test_example.py
import pytest
from src.gis_utils import calculate_buffer

def test_calculate_buffer():
    result = calculate_buffer(100)
    assert result > 0

def test_buffer_with_negative_distance():
    with pytest.raises(ValueError):
        calculate_buffer(-100)
```

Run tests:

```bash
pytest tests/
pytest tests/ --cov=src  # With coverage report
```

### 7. Documentation

Use docstrings for all modules and functions:

```python
def calculate_buffer(distance: float) -> float:
    """
    Calculate buffer distance in different units.
    
    Args:
        distance (float): Buffer distance in meters
        
    Returns:
        float: Buffer distance in feet
        
    Raises:
        ValueError: If distance is negative
        
    Example:
        >>> calculate_buffer(100)
        328.084
    """
    if distance < 0:
        raise ValueError("Distance must be positive")
    return distance * 3.28084
```

### 8. Performance Optimization

```python
# Use batch processing for PostGIS
cursor.executemany(
    "INSERT INTO table (col1, col2) VALUES (%s, %s)",
    data_list
)

# Use spatial indexing in QGIS
layer.createSpatialIndex()

# Cache GDAL datasets
gdal.SetConfigOption('GDAL_CACHEMAX', '512')

# Use memory layers for temporary data
memory_layer = QgsVectorLayer("Point?crs=EPSG:4326", "memory_layer", "memory")
```

### 9. Security Considerations

```python
# Never hardcode credentials
# ❌ Wrong
password = "mypassword123"

# ✅ Correct
from dotenv import load_dotenv
password = os.getenv('DB_PASSWORD')

# Use environment variables for sensitive data
# Rotate PostGIS credentials regularly
# Use firewall rules to restrict database access
# Enable encryption for database connections
```

### 10. Updating Packages

```bash
# Update pip, setuptools, wheel
pip install --upgrade pip setuptools wheel

# Update specific package
pip install --upgrade GDAL

# Update all packages (use with caution)
pip install -U -r requirements.txt
```

---

## Additional Resources

### Official Documentation

- **Python:** https://docs.python.org/3/
- **pip:** https://pip.pypa.io/
- **venv:** https://docs.python.org/3/library/venv.html
- **VS Code Python:** https://code.visualstudio.com/docs/languages/python

### GIS Documentation

- **ArcPy:** https://pro.arcgis.com/en/pro-app/latest/arcpy/
- **PyQGIS:** https://qgis.org/pyqgis/master/
- **GDAL/OGR:** https://gdal.org/
- **PostGIS:** https://postgis.net/docs/
- **GeoAlchemy2:** https://geoalchemy2.readthedocs.io/

### Community Resources

- **Stack Overflow:** `[python]`, `[arcpy]`, `[qgis]`, `[gdal]`, `[postgis]`
- **GIS Stack Exchange:** https://gis.stackexchange.com/
- **QGIS Community:** https://qgis.org/en/site/forusers/support.html
- **Esri Community:** https://community.esri.com/

---

## Contributing

To contribute to this guide:

1. Create a feature branch
2. Make your improvements
3. Submit a pull request with detailed descriptions

## License

This guide is provided as-is for educational and professional development purposes.

---

**Last Updated:** 2026-01-05  
**Maintained by:** BEN-DataDev  
**Version:** 1.0.0
