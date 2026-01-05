# PowerShell Script: setup-venvs.ps1
# Purpose: Automate virtual environment creation for geospatial Python development
# Author: BEN-DataDev
# Created: 2026-01-05
# Description: This script provides functions to set up virtual environments with
#              support for ArcPy, PyQGIS, GDAL, and PostGIS geospatial libraries

#Requires -Version 5.0

# ==============================================================================
# Configuration
# ==============================================================================

$script:VenvRootPath = ".\venvs"
$script:PythonVersion = "3.9"  # Adjust as needed for your geospatial libraries
$script:VerboseOutput = $true

# ==============================================================================
# Helper Functions
# ==============================================================================

<#
.SYNOPSIS
    Logs messages to console with timestamp
.PARAMETER Message
    The message to log
.PARAMETER Level
    Log level: INFO, WARNING, ERROR, SUCCESS
#>
function Write-Log {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Message,
        
        [Parameter(Mandatory = $false)]
        [ValidateSet("INFO", "WARNING", "ERROR", "SUCCESS")]
        [string]$Level = "INFO"
    )
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $color = @{
        "INFO"    = "Cyan"
        "WARNING" = "Yellow"
        "ERROR"   = "Red"
        "SUCCESS" = "Green"
    }
    
    Write-Host "[$timestamp] [$Level] $Message" -ForegroundColor $color[$Level]
}

<#
.SYNOPSIS
    Checks if a Python version is installed
.PARAMETER Version
    Python version to check (e.g., "3.9")
.RETURNS
    Path to Python executable if found, $null otherwise
#>
function Test-PythonInstallation {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Version
    )
    
    $pythonPath = $null
    
    # Try to find Python in PATH
    try {
        $pythonPath = (Get-Command python.exe -ErrorAction Stop).Source
        $pythonVersion = & $pythonPath --version 2>&1 | Select-String -Pattern "\d+\.\d+"
        Write-Log "Found Python: $pythonVersion at $pythonPath" "SUCCESS"
        return $pythonPath
    }
    catch {
        Write-Log "Python not found in PATH" "WARNING"
    }
    
    return $null
}

<#
.SYNOPSIS
    Creates a directory if it doesn't exist
.PARAMETER Path
    Directory path to create
#>
function New-DirectoryIfNotExists {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path
    )
    
    if (-not (Test-Path -Path $Path)) {
        New-Item -ItemType Directory -Path $Path -Force | Out-Null
        Write-Log "Created directory: $Path" "SUCCESS"
    }
    else {
        Write-Log "Directory already exists: $Path" "INFO"
    }
}

<#
.SYNOPSIS
    Executes pip install with error handling
.PARAMETER PythonPath
    Path to Python executable
.PARAMETER Packages
    Array of package names to install
.PARAMETER Requirements
    Path to requirements.txt file (alternative to Packages)
#>
function Install-PythonPackages {
    param(
        [Parameter(Mandatory = $true)]
        [string]$PythonPath,
        
        [Parameter(Mandatory = $false)]
        [string[]]$Packages,
        
        [Parameter(Mandatory = $false)]
        [string]$Requirements
    )
    
    try {
        if ($Requirements) {
            Write-Log "Installing packages from $Requirements" "INFO"
            & $PythonPath -m pip install --upgrade pip setuptools wheel
            & $PythonPath -m pip install -r $Requirements
        }
        else {
            Write-Log "Installing packages: $($Packages -join ', ')" "INFO"
            & $PythonPath -m pip install --upgrade pip setuptools wheel
            & $PythonPath -m pip install $Packages
        }
        
        Write-Log "Package installation completed successfully" "SUCCESS"
    }
    catch {
        Write-Log "Error installing packages: $_" "ERROR"
        return $false
    }
    
    return $true
}

# ==============================================================================
# Virtual Environment Creation Functions
# ==============================================================================

<#
.SYNOPSIS
    Creates a base virtual environment
.PARAMETER VenvName
    Name of the virtual environment
.PARAMETER PythonPath
    Path to Python executable (optional)
.RETURNS
    Path to the created virtual environment
#>
function New-VirtualEnvironment {
    param(
        [Parameter(Mandatory = $true)]
        [string]$VenvName,
        
        [Parameter(Mandatory = $false)]
        [string]$PythonPath
    )
    
    New-DirectoryIfNotExists -Path $script:VenvRootPath
    
    $venvPath = Join-Path -Path $script:VenvRootPath -ChildPath $VenvName
    
    if (Test-Path -Path $venvPath) {
        Write-Log "Virtual environment already exists: $venvPath" "WARNING"
        return $venvPath
    }
    
    try {
        Write-Log "Creating virtual environment: $VenvName" "INFO"
        
        if ($PythonPath) {
            & $PythonPath -m venv $venvPath
        }
        else {
            python -m venv $venvPath
        }
        
        Write-Log "Virtual environment created successfully: $venvPath" "SUCCESS"
        return $venvPath
    }
    catch {
        Write-Log "Error creating virtual environment: $_" "ERROR"
        return $null
    }
}

<#
.SYNOPSIS
    Activates a virtual environment and returns the activation script path
.PARAMETER VenvPath
    Path to the virtual environment
.RETURNS
    Path to the activate script
#>
function Get-VenvActivationScript {
    param(
        [Parameter(Mandatory = $true)]
        [string]$VenvPath
    )
    
    $activateScript = Join-Path -Path $venvPath -ChildPath "Scripts\Activate.ps1"
    
    if (-not (Test-Path -Path $activateScript)) {
        Write-Log "Activation script not found at: $activateScript" "ERROR"
        return $null
    }
    
    return $activateScript
}

<#
.SYNOPSIS
    Gets the Python executable path for a virtual environment
.PARAMETER VenvPath
    Path to the virtual environment
.RETURNS
    Path to python.exe in the virtual environment
#>
function Get-VenvPythonPath {
    param(
        [Parameter(Mandatory = $true)]
        [string]$VenvPath
    )
    
    $pythonPath = Join-Path -Path $venvPath -ChildPath "Scripts\python.exe"
    
    if (-not (Test-Path -Path $pythonPath)) {
        Write-Log "Python executable not found at: $pythonPath" "ERROR"
        return $null
    }
    
    return $pythonPath
}

# ==============================================================================
# Geospatial Library Setup Functions
# ==============================================================================

<#
.SYNOPSIS
    Sets up a virtual environment for ArcPy development
.PARAMETER VenvName
    Name of the virtual environment (default: arcpy-venv)
.PARAMETER PythonPath
    Path to Python executable (optional)
.DESCRIPTION
    Creates a virtual environment configured for ArcPy development.
    Note: ArcPy requires specific Python versions depending on ArcGIS version.
    Typically requires Python 3.7-3.11 depending on ArcGIS version.
#>
function Setup-ArcPyEnvironment {
    param(
        [Parameter(Mandatory = $false)]
        [string]$VenvName = "arcpy-venv",
        
        [Parameter(Mandatory = $false)]
        [string]$PythonPath
    )
    
    Write-Log "Setting up ArcPy virtual environment..." "INFO"
    
    $venvPath = New-VirtualEnvironment -VenvName $VenvName -PythonPath $PythonPath
    if (-not $venvPath) {
        return $false
    }
    
    $pythonExe = Get-VenvPythonPath -VenvPath $venvPath
    if (-not $pythonExe) {
        return $false
    }
    
    # ArcPy packages
    $packages = @(
        "arcpy",
        "numpy",
        "pandas",
        "matplotlib",
        "scipy",
        "shapely",
        "pytest",
        "jupyter",
        "ipykernel"
    )
    
    $success = Install-PythonPackages -PythonPath $pythonExe -Packages $packages
    
    if ($success) {
        Write-Log "ArcPy environment setup completed: $venvPath" "SUCCESS"
        # Create a requirements file for reference
        $reqFile = Join-Path -Path $venvPath -ChildPath "requirements-arcpy.txt"
        $packages | Out-File -FilePath $reqFile
        Write-Log "Requirements file created: $reqFile" "INFO"
    }
    
    return $success
}

<#
.SYNOPSIS
    Sets up a virtual environment for PyQGIS development
.PARAMETER VenvName
    Name of the virtual environment (default: qgis-venv)
.PARAMETER PythonPath
    Path to Python executable (optional)
.DESCRIPTION
    Creates a virtual environment configured for PyQGIS development.
    Note: PyQGIS typically requires using QGIS's bundled Python or
    careful dependency management for standalone environments.
#>
function Setup-PyQGISEnvironment {
    param(
        [Parameter(Mandatory = $false)]
        [string]$VenvName = "qgis-venv",
        
        [Parameter(Mandatory = $false)]
        [string]$PythonPath
    )
    
    Write-Log "Setting up PyQGIS virtual environment..." "INFO"
    
    $venvPath = New-VirtualEnvironment -VenvName $VenvName -PythonPath $PythonPath
    if (-not $venvPath) {
        return $false
    }
    
    $pythonExe = Get-VenvPythonPath -VenvPath $venvPath
    if (-not $pythonExe) {
        return $false
    }
    
    # PyQGIS packages
    $packages = @(
        "pyqgis",
        "numpy",
        "pandas",
        "matplotlib",
        "scipy",
        "shapely",
        "geopandas",
        "pytest",
        "jupyter",
        "ipykernel"
    )
    
    $success = Install-PythonPackages -PythonPath $pythonExe -Packages $packages
    
    if ($success) {
        Write-Log "PyQGIS environment setup completed: $venvPath" "SUCCESS"
        # Create a requirements file for reference
        $reqFile = Join-Path -Path $venvPath -ChildPath "requirements-qgis.txt"
        $packages | Out-File -FilePath $reqFile
        Write-Log "Requirements file created: $reqFile" "INFO"
    }
    
    return $success
}

<#
.SYNOPSIS
    Sets up a virtual environment for GDAL development
.PARAMETER VenvName
    Name of the virtual environment (default: gdal-venv)
.PARAMETER PythonPath
    Path to Python executable (optional)
.DESCRIPTION
    Creates a virtual environment configured for GDAL/OGR development.
    Includes rasterio and fiona for comprehensive geospatial data handling.
#>
function Setup-GDALEnvironment {
    param(
        [Parameter(Mandatory = $false)]
        [string]$VenvName = "gdal-venv",
        
        [Parameter(Mandatory = $false)]
        [string]$PythonPath
    )
    
    Write-Log "Setting up GDAL virtual environment..." "INFO"
    
    $venvPath = New-VirtualEnvironment -VenvName $VenvName -PythonPath $PythonPath
    if (-not $venvPath) {
        return $false
    }
    
    $pythonExe = Get-VenvPythonPath -VenvPath $venvPath
    if (-not $pythonExe) {
        return $false
    }
    
    # GDAL/OGR packages
    $packages = @(
        "gdal",
        "rasterio",
        "fiona",
        "geopandas",
        "shapely",
        "numpy",
        "pandas",
        "matplotlib",
        "scipy",
        "affine",
        "pytest",
        "jupyter",
        "ipykernel"
    )
    
    $success = Install-PythonPackages -PythonPath $pythonExe -Packages $packages
    
    if ($success) {
        Write-Log "GDAL environment setup completed: $venvPath" "SUCCESS"
        # Create a requirements file for reference
        $reqFile = Join-Path -Path $venvPath -ChildPath "requirements-gdal.txt"
        $packages | Out-File -FilePath $reqFile
        Write-Log "Requirements file created: $reqFile" "INFO"
    }
    
    return $success
}

<#
.SYNOPSIS
    Sets up a virtual environment for PostGIS development
.PARAMETER VenvName
    Name of the virtual environment (default: postgis-venv)
.PARAMETER PythonPath
    Path to Python executable (optional)
.DESCRIPTION
    Creates a virtual environment configured for PostGIS database development.
    Includes psycopg2, SQLAlchemy, and GeoAlchemy2 for database operations.
#>
function Setup-PostGISEnvironment {
    param(
        [Parameter(Mandatory = $false)]
        [string]$VenvName = "postgis-venv",
        
        [Parameter(Mandatory = $false)]
        [string]$PythonPath
    )
    
    Write-Log "Setting up PostGIS virtual environment..." "INFO"
    
    $venvPath = New-VirtualEnvironment -VenvName $VenvName -PythonPath $PythonPath
    if (-not $venvPath) {
        return $false
    }
    
    $pythonExe = Get-VenvPythonPath -VenvPath $venvPath
    if (-not $pythonExe) {
        return $false
    }
    
    # PostGIS/PostgreSQL packages
    $packages = @(
        "psycopg2-binary",
        "sqlalchemy",
        "geoalchemy2",
        "geopandas",
        "shapely",
        "numpy",
        "pandas",
        "matplotlib",
        "scipy",
        "alembic",
        "pytest",
        "jupyter",
        "ipykernel"
    )
    
    $success = Install-PythonPackages -PythonPath $pythonExe -Packages $packages
    
    if ($success) {
        Write-Log "PostGIS environment setup completed: $venvPath" "SUCCESS"
        # Create a requirements file for reference
        $reqFile = Join-Path -Path $venvPath -ChildPath "requirements-postgis.txt"
        $packages | Out-File -FilePath $reqFile
        Write-Log "Requirements file created: $reqFile" "INFO"
    }
    
    return $success
}

<#
.SYNOPSIS
    Sets up a complete geospatial development environment with all libraries
.PARAMETER VenvName
    Name of the virtual environment (default: geo-dev-venv)
.PARAMETER PythonPath
    Path to Python executable (optional)
.DESCRIPTION
    Creates a comprehensive virtual environment with ArcPy, PyQGIS, GDAL,
    and PostGIS libraries. Note: Some libraries may have conflicting dependencies.
#>
function Setup-ComprehensiveGeoEnvironment {
    param(
        [Parameter(Mandatory = $false)]
        [string]$VenvName = "geo-dev-venv",
        
        [Parameter(Mandatory = $false)]
        [string]$PythonPath
    )
    
    Write-Log "Setting up comprehensive geospatial development environment..." "INFO"
    
    $venvPath = New-VirtualEnvironment -VenvName $VenvName -PythonPath $PythonPath
    if (-not $venvPath) {
        return $false
    }
    
    $pythonExe = Get-VenvPythonPath -VenvPath $venvPath
    if (-not $pythonExe) {
        return $false
    }
    
    # Comprehensive geospatial stack
    $packages = @(
        "numpy",
        "pandas",
        "scipy",
        "matplotlib",
        "shapely",
        "geopandas",
        "gdal",
        "rasterio",
        "fiona",
        "psycopg2-binary",
        "sqlalchemy",
        "geoalchemy2",
        "affine",
        "pyproj",
        "folium",
        "basemap",
        "cartopy",
        "pytest",
        "jupyter",
        "ipykernel",
        "black",
        "pylint",
        "flake8"
    )
    
    $success = Install-PythonPackages -PythonPath $pythonExe -Packages $packages
    
    if ($success) {
        Write-Log "Comprehensive geospatial environment setup completed: $venvPath" "SUCCESS"
        # Create a requirements file for reference
        $reqFile = Join-Path -Path $venvPath -ChildPath "requirements-geo-dev.txt"
        $packages | Out-File -FilePath $reqFile
        Write-Log "Requirements file created: $reqFile" "INFO"
    }
    
    return $success
}

# ==============================================================================
# Utility Functions
# ==============================================================================

<#
.SYNOPSIS
    Lists all virtual environments in the venv root path
#>
function Get-VirtualEnvironments {
    Write-Log "Virtual environments found:" "INFO"
    
    if (-not (Test-Path -Path $script:VenvRootPath)) {
        Write-Log "No virtual environments directory found at: $script:VenvRootPath" "WARNING"
        return
    }
    
    $venvs = Get-ChildItem -Path $script:VenvRootPath -Directory
    
    if ($venvs.Count -eq 0) {
        Write-Log "No virtual environments found" "INFO"
        return
    }
    
    foreach ($venv in $venvs) {
        $pythonPath = Join-Path -Path $venv.FullName -ChildPath "Scripts\python.exe"
        $exists = Test-Path -Path $pythonPath
        $status = if ($exists) { "Valid" } else { "Invalid" }
        Write-Host "  - $($venv.Name) [$status]" -ForegroundColor Cyan
    }
}

<#
.SYNOPSIS
    Removes a virtual environment
.PARAMETER VenvName
    Name of the virtual environment to remove
#>
function Remove-VirtualEnvironment {
    param(
        [Parameter(Mandatory = $true)]
        [string]$VenvName
    )
    
    $venvPath = Join-Path -Path $script:VenvRootPath -ChildPath $VenvName
    
    if (-not (Test-Path -Path $venvPath)) {
        Write-Log "Virtual environment not found: $venvPath" "WARNING"
        return $false
    }
    
    try {
        Write-Log "Removing virtual environment: $VenvName" "INFO"
        Remove-Item -Path $venvPath -Recurse -Force
        Write-Log "Virtual environment removed: $VenvName" "SUCCESS"
        return $true
    }
    catch {
        Write-Log "Error removing virtual environment: $_" "ERROR"
        return $false
    }
}

<#
.SYNOPSIS
    Displays help information about available functions
#>
function Show-Help {
    Write-Host @"

========================================
Geospatial Virtual Environment Setup Tool
========================================

SETUP FUNCTIONS:
  Setup-ArcPyEnvironment                 - Create ArcPy development environment
  Setup-PyQGISEnvironment                - Create PyQGIS development environment
  Setup-GDALEnvironment                  - Create GDAL/OGR development environment
  Setup-PostGISEnvironment               - Create PostGIS development environment
  Setup-ComprehensiveGeoEnvironment      - Create comprehensive geospatial environment

UTILITY FUNCTIONS:
  Get-VirtualEnvironments                - List all virtual environments
  Remove-VirtualEnvironment -VenvName X  - Remove a virtual environment

HELPER FUNCTIONS:
  New-VirtualEnvironment -VenvName X     - Create a base virtual environment
  Install-PythonPackages                 - Install packages in a virtual environment

USAGE EXAMPLES:
  # Create individual environments
  Setup-ArcPyEnvironment
  Setup-GDALEnvironment
  Setup-PostGISEnvironment
  
  # List all environments
  Get-VirtualEnvironments
  
  # Remove an environment
  Remove-VirtualEnvironment -VenvName arcpy-venv

NOTES:
  - Virtual environments are created in: .\venvs\
  - Python must be installed and available in PATH
  - Some libraries may require additional system dependencies
  - PostGIS requires PostgreSQL client libraries
  - ArcPy requires specific Python versions matching your ArcGIS installation

"@ -ForegroundColor Cyan
}

# ==============================================================================
# Main Script Entry Point
# ==============================================================================

# Display welcome message
Write-Host "`n" -NoNewline
Write-Log "Geospatial Virtual Environment Setup Script" "INFO"
Write-Log "Script loaded successfully. Use Show-Help for available commands." "SUCCESS"
Write-Host "`n" -NoNewline

# Example: Uncomment below to auto-run during script load
# Setup-ComprehensiveGeoEnvironment
