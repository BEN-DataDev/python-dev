"""
PyQGIS Example: Layer Operations and Project Handling

This module demonstrates common PyQGIS operations including:
- Loading and managing QGIS projects
- Working with layers (vector and raster)
- Layer property manipulation
- Project save and load operations
- Layer filtering and selection
- Attribute manipulation

Requires QGIS Python bindings to be installed.
"""

from qgis.core import (
    QgsProject,
    QgsVectorLayer,
    QgsRasterLayer,
    QgsLayerTreeModel,
    QgsApplication,
    QgsFeature,
    QgsGeometry,
    QgsPoint,
    QgsFields,
    QgsField,
    QgsVectorFileWriter,
)
from qgis.gui import QgsLayerTreeView
from PyQt5.QtCore import QVariant
import os
import sys


class QGISProjectManager:
    """Manages QGIS projects and layer operations."""

    def __init__(self, project_path=None):
        """
        Initialize QGIS Project Manager.

        Args:
            project_path (str): Path to QGIS project file (.qgs)
        """
        self.project = QgsProject.instance()
        self.project_path = project_path
        if project_path and os.path.exists(project_path):
            self.load_project(project_path)

    def load_project(self, project_path):
        """
        Load a QGIS project from file.

        Args:
            project_path (str): Path to the .qgs project file

        Returns:
            bool: True if successful, False otherwise
        """
        try:
            self.project_path = project_path
            success = self.project.read(project_path)
            if success:
                print(f"Project loaded: {project_path}")
                print(f"Number of layers: {len(self.project.mapLayers())}")
            else:
                print(f"Failed to load project: {project_path}")
            return success
        except Exception as e:
            print(f"Error loading project: {e}")
            return False

    def save_project(self, save_path=None):
        """
        Save the current project.

        Args:
            save_path (str): Path to save the project. Uses project_path if not provided.

        Returns:
            bool: True if successful, False otherwise
        """
        try:
            path = save_path or self.project_path
            if not path:
                print("No project path specified")
                return False

            success = self.project.write(path)
            if success:
                print(f"Project saved: {path}")
                self.project_path = path
            else:
                print(f"Failed to save project: {path}")
            return success
        except Exception as e:
            print(f"Error saving project: {e}")
            return False

    def add_vector_layer(self, file_path, layer_name=None):
        """
        Add a vector layer to the project.

        Args:
            file_path (str): Path to vector file (shp, geojson, gpkg, etc.)
            layer_name (str): Name for the layer in the project

        Returns:
            QgsVectorLayer: The added layer or None if failed
        """
        try:
            name = layer_name or os.path.splitext(os.path.basename(file_path))[0]
            layer = QgsVectorLayer(file_path, name, "ogr")

            if not layer.isValid():
                print(f"Failed to load vector layer: {file_path}")
                return None

            self.project.addMapLayer(layer)
            print(f"Vector layer added: {name}")
            return layer
        except Exception as e:
            print(f"Error adding vector layer: {e}")
            return None

    def add_raster_layer(self, file_path, layer_name=None):
        """
        Add a raster layer to the project.

        Args:
            file_path (str): Path to raster file (tif, jp2, etc.)
            layer_name (str): Name for the layer in the project

        Returns:
            QgsRasterLayer: The added layer or None if failed
        """
        try:
            name = layer_name or os.path.splitext(os.path.basename(file_path))[0]
            layer = QgsRasterLayer(file_path, name)

            if not layer.isValid():
                print(f"Failed to load raster layer: {file_path}")
                return None

            self.project.addMapLayer(layer)
            print(f"Raster layer added: {name}")
            return layer
        except Exception as e:
            print(f"Error adding raster layer: {e}")
            return None

    def list_layers(self):
        """
        List all layers in the project.

        Returns:
            list: List of layer information dictionaries
        """
        layers_info = []
        for layer_id, layer in self.project.mapLayers().items():
            layer_info = {
                "id": layer_id,
                "name": layer.name(),
                "type": layer.type(),
                "valid": layer.isValid(),
                "crs": layer.crs().authid() if layer.crs() else "Unknown",
            }
            layers_info.append(layer_info)
            print(f"Layer: {layer.name()} ({layer.type()}) - CRS: {layer_info['crs']}")

        return layers_info

    def get_layer_by_name(self, layer_name):
        """
        Get a layer by its name.

        Args:
            layer_name (str): Name of the layer

        Returns:
            QgsLayer: The layer or None if not found
        """
        for layer in self.project.mapLayers().values():
            if layer.name() == layer_name:
                return layer
        print(f"Layer not found: {layer_name}")
        return None

    def remove_layer(self, layer_name):
        """
        Remove a layer from the project.

        Args:
            layer_name (str): Name of the layer to remove

        Returns:
            bool: True if successful, False otherwise
        """
        try:
            layer = self.get_layer_by_name(layer_name)
            if layer:
                self.project.removeMapLayer(layer.id())
                print(f"Layer removed: {layer_name}")
                return True
            return False
        except Exception as e:
            print(f"Error removing layer: {e}")
            return False

    def get_layer_features(self, layer_name, limit=None):
        """
        Get features from a vector layer.

        Args:
            layer_name (str): Name of the vector layer
            limit (int): Maximum number of features to retrieve

        Returns:
            list: List of features
        """
        try:
            layer = self.get_layer_by_name(layer_name)
            if not layer or layer.type() != 0:  # 0 = Vector layer
                print("Invalid layer or not a vector layer")
                return []

            features = []
            for i, feature in enumerate(layer.getFeatures()):
                if limit and i >= limit:
                    break
                features.append(feature)

            print(f"Retrieved {len(features)} features from {layer_name}")
            return features
        except Exception as e:
            print(f"Error retrieving features: {e}")
            return []

    def get_layer_attributes(self, layer_name):
        """
        Get attribute field names from a vector layer.

        Args:
            layer_name (str): Name of the vector layer

        Returns:
            list: List of attribute field names
        """
        try:
            layer = self.get_layer_by_name(layer_name)
            if not layer or layer.type() != 0:
                print("Invalid layer or not a vector layer")
                return []

            fields = [field.name() for field in layer.fields()]
            print(f"Layer attributes: {fields}")
            return fields
        except Exception as e:
            print(f"Error retrieving attributes: {e}")
            return []

    def filter_features(self, layer_name, attribute, value):
        """
        Filter features by attribute value.

        Args:
            layer_name (str): Name of the vector layer
            attribute (str): Attribute field name
            value: Value to filter by

        Returns:
            list: List of matching features
        """
        try:
            layer = self.get_layer_by_name(layer_name)
            if not layer or layer.type() != 0:
                print("Invalid layer or not a vector layer")
                return []

            matching_features = []
            for feature in layer.getFeatures():
                if feature.attribute(attribute) == value:
                    matching_features.append(feature)

            print(f"Found {len(matching_features)} features matching {attribute}={value}")
            return matching_features
        except Exception as e:
            print(f"Error filtering features: {e}")
            return []

    def select_features(self, layer_name, feature_ids):
        """
        Select features by their IDs.

        Args:
            layer_name (str): Name of the vector layer
            feature_ids (list): List of feature IDs to select

        Returns:
            bool: True if successful, False otherwise
        """
        try:
            layer = self.get_layer_by_name(layer_name)
            if not layer or layer.type() != 0:
                print("Invalid layer or not a vector layer")
                return False

            layer.selectByIds(feature_ids)
            print(f"Selected {len(feature_ids)} features in {layer_name}")
            return True
        except Exception as e:
            print(f"Error selecting features: {e}")
            return False

    def clear_selection(self, layer_name):
        """
        Clear selection in a vector layer.

        Args:
            layer_name (str): Name of the vector layer

        Returns:
            bool: True if successful, False otherwise
        """
        try:
            layer = self.get_layer_by_name(layer_name)
            if not layer or layer.type() != 0:
                print("Invalid layer or not a vector layer")
                return False

            layer.removeSelection()
            print(f"Selection cleared in {layer_name}")
            return True
        except Exception as e:
            print(f"Error clearing selection: {e}")
            return False

    def get_layer_crs(self, layer_name):
        """
        Get the CRS (Coordinate Reference System) of a layer.

        Args:
            layer_name (str): Name of the layer

        Returns:
            str: CRS authority code (e.g., 'EPSG:4326')
        """
        try:
            layer = self.get_layer_by_name(layer_name)
            if not layer:
                return None
            return layer.crs().authid()
        except Exception as e:
            print(f"Error retrieving CRS: {e}")
            return None

    def get_layer_extent(self, layer_name):
        """
        Get the extent (bounding box) of a layer.

        Args:
            layer_name (str): Name of the layer

        Returns:
            dict: Dictionary with xmin, ymin, xmax, ymax
        """
        try:
            layer = self.get_layer_by_name(layer_name)
            if not layer:
                return None

            extent = layer.extent()
            extent_dict = {
                "xmin": extent.xMinimum(),
                "ymin": extent.yMinimum(),
                "xmax": extent.xMaximum(),
                "ymax": extent.yMaximum(),
            }
            print(f"Layer extent: {extent_dict}")
            return extent_dict
        except Exception as e:
            print(f"Error retrieving extent: {e}")
            return None

    def set_layer_visibility(self, layer_name, visible):
        """
        Set layer visibility.

        Args:
            layer_name (str): Name of the layer
            visible (bool): True to show, False to hide

        Returns:
            bool: True if successful, False otherwise
        """
        try:
            layer = self.get_layer_by_name(layer_name)
            if not layer:
                return False

            # Get root node and find layer in tree
            root = self.project.layerTreeRoot()
            node = root.findLayer(layer.id())
            if node:
                node.setItemVisibilityChecked(visible)
                print(f"Layer visibility set: {layer_name} = {visible}")
                return True
            return False
        except Exception as e:
            print(f"Error setting layer visibility: {e}")
            return False

    def export_vector_layer(self, layer_name, output_path, driver_name="ESRI Shapefile"):
        """
        Export a vector layer to a file.

        Args:
            layer_name (str): Name of the vector layer
            output_path (str): Path for the output file
            driver_name (str): OGR driver name

        Returns:
            bool: True if successful, False otherwise
        """
        try:
            layer = self.get_layer_by_name(layer_name)
            if not layer or layer.type() != 0:
                print("Invalid layer or not a vector layer")
                return False

            error = QgsVectorFileWriter.writeAsVectorFormat(
                layer, output_path, "utf-8", layer.crs(), driver_name
            )

            if error == QgsVectorFileWriter.NoError:
                print(f"Layer exported to: {output_path}")
                return True
            else:
                print(f"Export failed with error code: {error}")
                return False
        except Exception as e:
            print(f"Error exporting layer: {e}")
            return False


def example_usage():
    """Example usage of the QGISProjectManager class."""
    print("=== PyQGIS Example: Layer Operations and Project Handling ===\n")

    # Initialize QGIS Application (required for non-GUI usage)
    if not QgsApplication.instance():
        qgs = QgsApplication([], False)
        qgs.initQgis()

    # Create project manager
    manager = QGISProjectManager()

    # Example: Add layers (paths would need to be adjusted for your system)
    print("\n--- Adding Layers ---")
    # manager.add_vector_layer('/path/to/shapefile.shp', 'My Shapefile')
    # manager.add_raster_layer('/path/to/raster.tif', 'My Raster')

    # Example: List all layers
    print("\n--- Listing Layers ---")
    manager.list_layers()

    # Example: Layer operations
    print("\n--- Layer Operations ---")
    # layer = manager.get_layer_by_name('My Shapefile')
    # crs = manager.get_layer_crs('My Shapefile')
    # extent = manager.get_layer_extent('My Shapefile')
    # attributes = manager.get_layer_attributes('My Shapefile')

    # Example: Working with features
    print("\n--- Feature Operations ---")
    # features = manager.get_layer_features('My Shapefile', limit=10)
    # filtered = manager.filter_features('My Shapefile', 'field_name', 'value')
    # manager.select_features('My Shapefile', [1, 2, 3])
    # manager.clear_selection('My Shapefile')

    # Example: Project operations
    print("\n--- Project Operations ---")
    # manager.save_project('/path/to/project.qgs')
    # manager.load_project('/path/to/project.qgs')

    print("\nExample complete. Uncomment code sections and adjust paths for your data.")


if __name__ == "__main__":
    example_usage()
