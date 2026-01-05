# Python Virtual Environment (venv) Commands and Workflows

## Table of Contents
1. [Creating Virtual Environments](#creating-virtual-environments)
2. [Activating Virtual Environments](#activating-virtual-environments)
3. [Deactivating Virtual Environments](#deactivating-virtual-environments)
4. [Managing Dependencies](#managing-dependencies)
5. [Common Workflows](#common-workflows)
6. [Troubleshooting](#troubleshooting)
7. [Best Practices](#best-practices)

---

## Creating Virtual Environments

### Basic Creation
Create a virtual environment named `venv` in the current directory:
```bash
python -m venv venv
```

### Create with Specific Python Version
Create a virtual environment using a specific Python version:
```bash
python3.11 -m venv venv
```

### Create with Custom Name
Create a virtual environment with a custom name:
```bash
python -m venv myenv
```

### Create with Specific Location
Create a virtual environment in a specific directory:
```bash
python -m venv /path/to/project/venv
```

### Create with Upgrade pip/setuptools
Create and immediately upgrade pip and setuptools:
```bash
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
pip install --upgrade pip setuptools wheel
```

---

## Activating Virtual Environments

### Linux/macOS
Activate the virtual environment:
```bash
source venv/bin/activate
```

### Windows (Command Prompt)
Activate on Windows using Command Prompt:
```bash
venv\Scripts\activate.bat
```

### Windows (PowerShell)
Activate on Windows using PowerShell:
```bash
venv\Scripts\Activate.ps1
```

**Note:** If you get an execution policy error in PowerShell, run:
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### Verify Activation
Check that the virtual environment is active:
```bash
which python  # Linux/macOS
where python  # Windows
# Should show path inside venv directory
```

---

## Deactivating Virtual Environments

### Deactivate (All Platforms)
Exit the virtual environment:
```bash
deactivate
```

The command prompt will return to normal, and you'll be using your system Python again.

---

## Managing Dependencies

### List Installed Packages
Show all installed packages:
```bash
pip list
```

### Show Package Details
Get detailed information about a specific package:
```bash
pip show package_name
```

### Install Single Package
Install a specific package:
```bash
pip install package_name
```

### Install Specific Version
Install a specific version of a package:
```bash
pip install package_name==1.2.3
```

### Install Multiple Packages
Install from a list of package names:
```bash
pip install package1 package2 package3
```

### Install from Requirements File
Install all dependencies from requirements.txt:
```bash
pip install -r requirements.txt
```

### Install Development Dependencies
Install with extras (development dependencies):
```bash
pip install -e ".[dev]"
```

### Generate Requirements File
Create a requirements.txt from installed packages:
```bash
pip freeze > requirements.txt
```

### Uninstall Packages
Remove a package:
```bash
pip uninstall package_name
```

### Uninstall All Packages
Remove all packages (dangerous, use with caution):
```bash
pip freeze | xargs pip uninstall -y
```

### Upgrade Package
Update an installed package:
```bash
pip install --upgrade package_name
```

### Upgrade pip
Update pip itself:
```bash
pip install --upgrade pip
```

---

## Common Workflows

### Workflow 1: Fresh Project Setup
Complete setup from scratch:
```bash
# 1. Create virtual environment
python -m venv venv

# 2. Activate it
source venv/bin/activate  # Linux/macOS
# or
venv\Scripts\activate  # Windows

# 3. Upgrade pip and build tools
pip install --upgrade pip setuptools wheel

# 4. Install dependencies
pip install -r requirements.txt

# 5. Verify installation
pip list
```

### Workflow 2: Development Environment with Dev Dependencies
Set up for active development:
```bash
# 1. Create virtual environment
python -m venv venv

# 2. Activate
source venv/bin/activate

# 3. Install dependencies and dev tools
pip install -r requirements.txt
pip install -r requirements-dev.txt

# 4. Install package in editable mode
pip install -e .
```

### Workflow 3: Update Dependencies
Update your project dependencies:
```bash
# 1. Ensure venv is activated
source venv/bin/activate

# 2. Install/upgrade packages
pip install --upgrade package_name

# 3. Update requirements.txt
pip freeze > requirements.txt

# 4. Commit changes
git add requirements.txt
git commit -m "Update dependencies"
```

### Workflow 4: Clone Project and Install
Set up an existing project:
```bash
# 1. Clone repository
git clone https://github.com/user/repo.git
cd repo

# 2. Create virtual environment
python -m venv venv

# 3. Activate
source venv/bin/activate

# 4. Install dependencies
pip install -r requirements.txt

# 5. Ready to go!
python script.py
```

### Workflow 5: Multiple Projects
Working with multiple projects:
```bash
# Project 1
cd ~/projects/project1
source venv/bin/activate
# ... work on project1

# Switch to Project 2
deactivate
cd ~/projects/project2
source venv/bin/activate
# ... work on project2

# Back to Project 1
deactivate
cd ~/projects/project1
source venv/bin/activate
```

### Workflow 6: Clean and Rebuild Environment
Start fresh without deleting code:
```bash
# 1. Deactivate current environment
deactivate

# 2. Remove the venv directory
rm -rf venv  # Linux/macOS
# or
rmdir /s venv  # Windows

# 3. Create fresh environment
python -m venv venv

# 4. Activate and reinstall
source venv/bin/activate
pip install -r requirements.txt
```

---

## Troubleshooting

### Issue: Command Not Found (venv)
**Problem:** `bash: venv: command not found`

**Solution:** The venv might not be activated. Run:
```bash
source venv/bin/activate  # Linux/macOS
# or
venv\Scripts\activate  # Windows
```

### Issue: Python Not Found in venv
**Problem:** Python script runs system version instead of venv version

**Solution:** Verify venv activation:
```bash
which python  # Should show venv path
python --version
```

If not using venv path, explicitly use:
```bash
./venv/bin/python script.py  # Linux/macOS
# or
venv\Scripts\python.exe script.py  # Windows
```

### Issue: Permission Denied on Activate
**Problem:** `Permission denied: ./venv/bin/activate`

**Solution (Linux/macOS):**
```bash
chmod +x venv/bin/activate
source venv/bin/activate
```

### Issue: PowerShell Execution Policy
**Problem:** `PowerShell: File cannot be loaded because running scripts is disabled`

**Solution:**
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
venv\Scripts\Activate.ps1
```

### Issue: pip SSL Certificate Error
**Problem:** `SSLError: [SSL: CERTIFICATE_VERIFY_FAILED]`

**Solution (temporary, not recommended):**
```bash
pip install --trusted-host pypi.org --trusted-host files.pythonhosted.org package_name
```

Better solution: Update certificates or use a corporate proxy.

### Issue: Conflicting Package Versions
**Problem:** Package version conflicts

**Solution:**
```bash
# 1. Clean environment
deactivate
rm -rf venv
python -m venv venv
source venv/bin/activate

# 2. Install with constraints
pip install -r requirements.txt
```

### Issue: venv Broken After Python Update
**Problem:** Virtual environment breaks when system Python updates

**Solution:**
```bash
# 1. Deactivate and remove
deactivate
rm -rf venv

# 2. Recreate
python -m venv venv
source venv/bin/activate

# 3. Reinstall packages
pip install -r requirements.txt
```

---

## Best Practices

### 1. Always Use Virtual Environments
- ✅ **DO:** Create a venv for each project
- ❌ **DON'T:** Install packages globally

### 2. Version Control
```bash
# Include in .gitignore
echo "venv/" >> .gitignore
echo "*.pyc" >> .gitignore
echo "__pycache__/" >> .gitignore
```

### 3. Keep requirements.txt Updated
```bash
# After installing new packages
pip freeze > requirements.txt
git add requirements.txt
git commit -m "Update dependencies"
```

### 4. Use Separate Requirements Files
```
requirements.txt        # Production dependencies
requirements-dev.txt    # Development dependencies
requirements-test.txt   # Testing dependencies
```

### 5. Document Setup Process
Create a README with setup instructions:
```markdown
## Setup

1. Create virtual environment: `python -m venv venv`
2. Activate: `source venv/bin/activate`
3. Install dependencies: `pip install -r requirements.txt`
```

### 6. Use Python Version Specifiers
In requirements.txt:
```
# Specify Python version requirements
# This is a comment in requirements.txt
package1==1.0.0
package2>=2.0.0,<3.0.0
```

### 7. Regular Maintenance
```bash
# Periodically check for updates
pip list --outdated

# Update critical packages
pip install --upgrade package_name
```

### 8. Use venv-wrapper (Optional)
For easier venv management:
```bash
# Install virtualenvwrapper
pip install virtualenvwrapper

# Create venv
mkvirtualenv myproject

# Activate
workon myproject

# Deactivate
deactivate
```

### 9. CI/CD Integration
In your CI/CD pipeline:
```bash
python -m venv venv
source venv/bin/activate
pip install -r requirements.txt
pip install -r requirements-dev.txt
pytest
```

### 10. Team Collaboration
- Share `requirements.txt` via Git
- Use the same Python version (document in README)
- Use `.python-version` for pyenv users

```bash
echo "3.11.0" > .python-version
```

---

## Quick Reference

| Task | Command |
|------|---------|
| Create venv | `python -m venv venv` |
| Activate (Linux/Mac) | `source venv/bin/activate` |
| Activate (Windows) | `venv\Scripts\activate` |
| Deactivate | `deactivate` |
| Install package | `pip install package_name` |
| Install from file | `pip install -r requirements.txt` |
| List packages | `pip list` |
| Save dependencies | `pip freeze > requirements.txt` |
| Remove package | `pip uninstall package_name` |
| Upgrade pip | `pip install --upgrade pip` |

---

## Additional Resources

- [Official Python venv Documentation](https://docs.python.org/3/library/venv.html)
- [pip Documentation](https://pip.pypa.io/)
- [Virtual Environments Best Practices](https://realpython.com/python-virtual-environments-a-primer/)
- [Poetry - Alternative Package Manager](https://python-poetry.org/)
- [Conda - Alternative Environment Manager](https://docs.conda.io/)

---

**Last Updated:** 2026-01-05

This guide covers comprehensive virtual environment management for Python development.
