"""
ArcPy Example: Basic Geodatabase Operations
This script demonstrates common ArcPy operations for working with geodatabases,
including listing feature classes, examining properties, and performing basic geoprocessing.
"""

import arcpy
import os

# Set workspace to geodatabase
gdb_path = r"C:\path\to\your\geodatabase.gdb"
arcpy.env.workspace = gdb_path

# Enable overwriting of output datasets
arcpy.env.overwriteOutput = True


def list_feature_classes():
    """List all feature classes in the geodatabase."""
    print("Feature Classes in Geodatabase:")
    print("-" * 40)
    
    try:
        # List all feature classes
        feature_classes = arcpy.ListFeatureClasses()
        
        if feature_classes:
            for fc in feature_classes:
                print(f"  - {fc}")
        else:
            print("  No feature classes found.")
    except arcpy.ExecuteError as e:
        print(f"Error listing feature classes: {e}")


def examine_feature_class(fc_name):
    """Examine properties of a specific feature class."""
    print(f"\nFeature Class Properties: {fc_name}")
    print("-" * 40)
    
    try:
        fc_path = os.path.join(gdb_path, fc_name)
        
        # Get feature class properties
        desc = arcpy.Describe(fc_path)
        print(f"  Shape Type: {desc.shapeType}")
        print(f"  Feature Count: {arcpy.GetCount_management(fc_path)}")
        print(f"  Spatial Reference: {desc.spatialReference.name}")
        
        # List fields
        print(f"\n  Fields:")
        fields = arcpy.ListFields(fc_path)
        for field in fields:
            print(f"    - {field.name}: {field.type}")
            
    except arcpy.ExecuteError as e:
        print(f"Error examining feature class: {e}")


def create_feature_class(fc_name, shape_type="POINT"):
    """Create a new feature class in the geodatabase."""
    print(f"\nCreating Feature Class: {fc_name}")
    print("-" * 40)
    
    try:
        # Create feature class
        fc_path = os.path.join(gdb_path, fc_name)
        arcpy.CreateFeatureclass_management(
            out_path=gdb_path,
            out_name=fc_name,
            geometry_type=shape_type,
            spatial_reference=arcpy.SpatialReference(4326)  # WGS84
        )
        print(f"  Successfully created: {fc_name}")
        
        # Add some sample fields
        arcpy.AddField_management(fc_path, "NAME", "TEXT", field_length=100)
        arcpy.AddField_management(fc_path, "DESCRIPTION", "TEXT", field_length=255)
        arcpy.AddField_management(fc_path, "DATE_CREATED", "DATE")
        print(f"  Added sample fields to {fc_name}")
        
    except arcpy.ExecuteError as e:
        print(f"Error creating feature class: {e}")


def buffer_feature_class(input_fc, output_fc, buffer_distance):
    """Create a buffer around features."""
    print(f"\nBuffering Feature Class: {input_fc}")
    print("-" * 40)
    
    try:
        input_path = os.path.join(gdb_path, input_fc)
        output_path = os.path.join(gdb_path, output_fc)
        
        # Perform buffer operation
        arcpy.Buffer_analysis(
            in_features=input_path,
            out_feature_class=output_path,
            buffer_distance_or_field=buffer_distance,
            line_side="FULL",
            line_end_type="ROUND",
            dissolve_option="NONE"
        )
        print(f"  Successfully created buffer: {output_fc}")
        
    except arcpy.ExecuteError as e:
        print(f"Error creating buffer: {e}")


def spatial_join(target_fc, join_fc, output_fc, join_operation="JOIN_ONE_TO_ONE"):
    """Perform a spatial join between two feature classes."""
    print(f"\nPerforming Spatial Join")
    print("-" * 40)
    
    try:
        target_path = os.path.join(gdb_path, target_fc)
        join_path = os.path.join(gdb_path, join_fc)
        output_path = os.path.join(gdb_path, output_fc)
        
        # Perform spatial join
        arcpy.SpatialJoin_analysis(
            target_features=target_path,
            join_features=join_path,
            out_feature_class=output_path,
            join_operation=join_operation,
            join_type="KEEP_ALL",
            match_option="INTERSECT"
        )
        print(f"  Successfully created spatial join: {output_fc}")
        
    except arcpy.ExecuteError as e:
        print(f"Error performing spatial join: {e}")


def main():
    """Main function to demonstrate ArcPy operations."""
    print("ArcPy Geodatabase Operations Example")
    print("=" * 40)
    
    # Check if geodatabase exists
    if not os.path.exists(gdb_path):
        print(f"Error: Geodatabase not found at {gdb_path}")
        print("Please update the gdb_path variable to point to your geodatabase.")
        return
    
    # List feature classes
    list_feature_classes()
    
    # Examine a specific feature class (if it exists)
    feature_classes = arcpy.ListFeatureClasses()
    if feature_classes:
        examine_feature_class(feature_classes[0])
    
    # Example: Create a new feature class (uncomment to use)
    # create_feature_class("sample_points", "POINT")
    
    # Example: Buffer operation (uncomment to use)
    # buffer_feature_class("input_fc", "buffered_fc", "100 Meters")
    
    # Example: Spatial join (uncomment to use)
    # spatial_join("target_fc", "join_fc", "joined_fc")
    
    print("\n" + "=" * 40)
    print("Operations completed successfully!")


if __name__ == "__main__":
    main()
