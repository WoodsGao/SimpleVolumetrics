using UnityEngine;
using UnityEditor;
using System;

// The property drawer class should be placed in an editor script, inside a folder called Editor.
// Use with "[VolumetricShadow]" before a float shader property.
namespace SimpleVolumetrics
{
    public class VolumetricShadowDrawer : MaterialPropertyDrawer
    {
        // Draw the property inside the given rect
        public override void OnGUI(Rect position, MaterialProperty prop, String label, MaterialEditor editor)
        {
            bool value = (prop.floatValue != 0.0f);

            EditorGUI.BeginChangeCheck();
            EditorGUI.showMixedValue = prop.hasMixedValue;

            // Show the toggle control
            value = EditorGUI.Toggle(position, label, value);

            EditorGUI.showMixedValue = false;
            if (EditorGUI.EndChangeCheck())
            {
                // Set the new value if it has changed
                prop.floatValue = value ? 1f : 0f;
                foreach (var obj in prop.targets)
                {
                    Material material = obj as Material;
                    if (value)
                    {
                        material.EnableKeyword("VOLUMETRIC_SHADOW_ON");
                        Utils.RefreshShadowMapByMaterial(material);
                    }
                    else
                    {
                        material.DisableKeyword("VOLUMETRIC_SHADOW_ON");
                        material.SetTexture("_ShadowMap", null);
                    }
                }
            }
        }
    }
}