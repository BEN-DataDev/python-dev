# Quick Start Guide

Quick reference checklists for setting up geospatial development environments.

---

## ArcPy Setup Checklist

### Prerequisites
- [ ] ArcGIS Desktop or ArcGIS Pro installed
- [ ] Python 3.9+ (for ArcGIS Pro 3.0+) or Python 2.7 (for Desktop 10.x)
- [ ] Admin privileges for environment setup

### Installation Steps
- [ ] Verify ArcGIS installation path
- [ ] Confirm Python version matches ArcGIS release
- [ ] Check ArcPy availability: `import arcpy`
- [ ] Verify Spatial Analyst extension (if needed)
- [ ] Test with sample geodatabase

### Environment Configuration
- [ ] Add ArcGIS Python path to system PATH
- [ ] Configure IDE (PyCharm/VS Code) with correct Python interpreter
- [ ] Set up workspace: `arcpy.env.workspace = "path/to/geodatabase"`
- [ ] Enable overwrite output: `arcpy.env.overwriteOutput = True`
- [ ] Configure spatial reference if needed

### Verify Installation
```python
import arcpy
print(arcpy.GetInstallInfo()['Version'])
arcpy.CheckOutExtension("Spatial")
```

### Common Issues
- [ ] If import fails, check Python version compatibility
- [ ] Reinstall ArcGIS Python package if modules missing
- [ ] Run as Administrator for permission-related errors
- [ ] Clear Python cache: Delete `__pycache__` directories

---

## PyQGIS Setup Checklist

### Prerequisites
- [ ] QGIS 3.x installed (recommend LTR version)
- [ ] Python 3.7+ available
- [ ] OSGeo4W or native QGIS installation

### Installation Steps
- [ ] Install QGIS with Python bindings
- [ ] Verify QGIS Python path: `C:\Program Files\QGIS 3.x\apps\Python39`
- [ ] Test import: `from qgis.core import QgsApplication`
- [ ] Initialize QGIS application if standalone script
- [ ] Verify PyQGIS plugins directory access

### Environment Configuration
- [ ] Set PYTHONPATH to include QGIS bin and python directories
- [ ] Configure IDE to use QGIS Python interpreter
- [ ] Initialize QgsApplication for standalone scripts:
  ```python
  from qgis.core import QgsApplication
  QgsApplication.setPrefixPath("/path/to/qgis", True)
  qgs = QgsApplication([], False)
  qgs.initQgisResources()
  ```
- [ ] Set project coordinate system
- [ ] Load plugins if required

### Verify Installation
```python
from qgis.core import QgsVectorLayer, QgsProject
layer = QgsVectorLayer("path/to/shapefile.shp", "layer_name", "ogr")
```

### Common Issues
- [ ] If import fails, verify QGIS installation path
- [ ] Check PYTHONPATH environment variable
- [ ] Update LD_LIBRARY_PATH on Linux
- [ ] Reinstall Python bindings if module issues occur
- [ ] Use QGIS OSGeo4W console for guaranteed environment

---

## GDAL/OGR Setup Checklist

### Prerequisites
- [ ] GDAL/OGR libraries installed (3.0+)
- [ ] Python 3.7+ available
- [ ] Build tools for compilation (if installing from source)

### Installation Steps - Windows
- [ ] Install from conda: `conda install -c conda-forge gdal`
- [ ] OR install prebuilt wheels from Unofficial Binaries
- [ ] Verify installation: `gdalinfo --version`
- [ ] Check Python bindings: `import osgeo.gdal`
- [ ] Verify all drivers: `osgeo.gdal.GetDriverCount()`

### Installation Steps - Linux
- [ ] Install system dependencies: `sudo apt-get install libgdal-dev`
- [ ] Install Python bindings: `pip install GDAL`
- [ ] Verify: `gdalinfo --version`
- [ ] Check environment: `gdal-config --version`

### Installation Steps - macOS
- [ ] Install via Homebrew: `brew install gdal`
- [ ] OR use conda: `conda install -c conda-forge gdal`
- [ ] Set environment: `export GDAL_DATA=$(gdal-config --datadir)`
- [ ] Verify: `gdalinfo --version`

### Environment Configuration
- [ ] Set GDAL_DATA environment variable (usually auto-set)
- [ ] Configure PROJ data: `export PROJ_LIB=$(conda info --base)/share/proj`
- [ ] Add GDAL binary directory to PATH (Windows)
- [ ] Verify driver availability: `osgeo.gdal.GetDriverCount()`

### Verify Installation
```python
from osgeo import gdal, ogr
gdal.AllRegister()
driver = gdal.GetDriverByName('GTiff')
print(f"GDAL Version: {gdal.__version__}")
```

### Common Issues
- [ ] Conda conflicts: Use `mamba` for faster resolution
- [ ] Missing GDAL_DATA: Set manually or use conda environment
- [ ] Wrong Python version: Ensure Python matches GDAL build
- [ ] Projection issues: Verify PROJ library installation
- [ ] Build from source only if necessary (complex and time-consuming)

---

## PostGIS Setup Checklist

### Prerequisites
- [ ] PostgreSQL 12+ installed and running
- [ ] PostGIS extension (3.0+) available
- [ ] psycopg2 Python driver
- [ ] pgAdmin 4 (recommended, optional)

### Database Setup
- [ ] Start PostgreSQL service
- [ ] Create database: `createdb gis_database`
- [ ] Connect as superuser: `psql -U postgres -d gis_database`
- [ ] Enable PostGIS extension: `CREATE EXTENSION postgis;`
- [ ] Enable administrative functions: `CREATE EXTENSION postgis_topology;`
- [ ] Verify installation:
  ```sql
  SELECT PostGIS_version();
  SELECT ST_AsText(ST_GeomFromText('POINT(0 0)', 4326));
  ```

### Python Connection Setup
- [ ] Install psycopg2: `pip install psycopg2-binary`
- [ ] Test connection:
  ```python
  import psycopg2
  conn = psycopg2.connect(
      host="localhost",
      database="gis_database",
      user="postgres",
      password="password"
  )
  ```
- [ ] Optional: Install SQLAlchemy with GeoAlchemy2
  ```bash
  pip install sqlalchemy geoalchemy2
  ```

### Sample Data Setup
- [ ] Download sample datasets (Natural Earth, OSM, etc.)
- [ ] Import shapefiles:
  ```bash
  shp2pgsql -I -S -c shapefile.shp public.tablename | psql -d gis_database
  ```
- [ ] OR use ogr2ogr:
  ```bash
  ogr2ogr -f PostgreSQL PG:"host=localhost dbname=gis_database user=postgres" shapefile.shp
  ```
- [ ] Verify tables created: `\dt` in psql

### Environment Configuration
- [ ] Set connection environment variables (optional):
  ```bash
  export PGHOST=localhost
  export PGDATABASE=gis_database
  export PGUSER=postgres
  export PGPASSWORD=password
  ```
- [ ] Configure pgAdmin for GUI management
- [ ] Set up backup strategy (pg_dump/pg_restore)
- [ ] Configure connection pooling if needed (PgBouncer)

### Verify Installation
```python
import psycopg2
from psycopg2 import sql

conn = psycopg2.connect("dbname=gis_database user=postgres")
cur = conn.cursor()
cur.execute("SELECT PostGIS_version();")
print(cur.fetchone())
cur.close()
conn.close()
```

### Common Issues
- [ ] Connection refused: Verify PostgreSQL service is running
- [ ] Authentication failed: Check credentials and pg_hba.conf
- [ ] Extension not found: Reinstall PostGIS or check installation
- [ ] Spatial queries slow: Create indexes: `CREATE INDEX idx_geom ON table USING GIST(geometry_column);`
- [ ] Memory issues: Adjust postgresql.conf shared_buffers and work_mem

---

## Quick Reference Commands

### Python Environment Management
```bash
# Create virtual environment
python -m venv geospatial_env
source geospatial_env/bin/activate  # Linux/macOS
geospatial_env\Scripts\activate     # Windows

# Install common geospatial packages
pip install geopandas fiona rasterio shapely
pip install numpy pandas scipy matplotlib
```

### GDAL Command Line Tools
```bash
# Get raster information
gdalinfo input.tif

# Translate raster format
gdal_translate -of GeoTIFF input.img output.tif

# Reproject
gdalwarp -t_srs EPSG:4326 input.tif output.tif

# Vector info
ogrinfo shapefile.shp

# Convert vector format
ogr2ogr -f "GeoJSON" output.geojson input.shp
```

### PostGIS SQL Templates
```sql
-- Create geometry column
SELECT AddGeometryColumn('public', 'table_name', 'geom', 4326, 'POINT', 2);

-- Create spatial index
CREATE INDEX idx_table_geom ON table_name USING GIST(geom);

-- Buffer operation
SELECT ST_Buffer(geom, 100) FROM table_name;

-- Distance calculation
SELECT ST_Distance(geom1, geom2) FROM table1 JOIN table2;

-- Point in polygon
SELECT * FROM table1 WHERE ST_Contains(geom_polygon, geom_point);
```

---

## Additional Resources

- [ArcGIS Pro Python API Documentation](https://pro.arcgis.com/en/pro-app/latest/arcpy/get-started/what-is-arcpy-.htm)
- [QGIS Python Console Documentation](https://docs.qgis.org/latest/en/docs/pyqgis_developer_guide/)
- [GDAL/OGR Documentation](https://gdal.org/)
- [PostGIS Documentation](https://postgis.net/documentation/)
- [GeoPandas Documentation](https://geopandas.org/)
- [Rasterio Documentation](https://rasterio.readthedocs.io/)

---

## Troubleshooting Summary

| Issue | Solution |
|-------|----------|
| Import module not found | Verify installation, check PYTHONPATH, reinstall if needed |
| Version conflicts | Use virtual environments, pin specific versions in requirements.txt |
| Permission errors | Run as Administrator (Windows) or use sudo (Linux) |
| Spatial reference issues | Explicitly set EPSG codes, use PROJ library correctly |
| Performance issues | Create spatial indexes, optimize queries, increase memory allocation |
| Connection errors | Verify service running, check credentials, review firewall settings |

---

**Last Updated:** 2026-01-05

For questions or issues, refer to the respective library documentation or community forums.
