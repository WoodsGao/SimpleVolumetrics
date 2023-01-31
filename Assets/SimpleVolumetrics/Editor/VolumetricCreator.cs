using UnityEngine;
using UnityEditor;

namespace SimpleVolumetrics
{
    public class VolumetricCreator
    {
        static void InstantiatePrefab(MenuCommand menuCommand, string path)
        {
            GameObject prefab = Resources.Load<GameObject>(path);
            GameObject obj = PrefabUtility.InstantiatePrefab(prefab) as GameObject;
            GameObjectUtility.SetParentAndAlign(obj, menuCommand.context as GameObject);
            Undo.RegisterCreatedObjectUndo(obj, "Create " + obj.name);
            Selection.activeObject = obj;

            // instantiate material
            MeshRenderer renderer = obj.GetComponent<MeshRenderer>();
            renderer.sharedMaterial = Material.Instantiate(renderer.sharedMaterial);

            // update mesh bounds
            MeshFilter filter = obj.GetComponent<MeshFilter>();
            Bounds bounds = filter.sharedMesh.bounds;
            bounds.size = new Vector3(float.MaxValue, float.MaxValue, float.MaxValue);
            filter.sharedMesh.bounds = bounds;
        }

        private const string _baseName = "Volumetric Base";
        [MenuItem("GameObject/SimpleVolumetric/" + _baseName, false, 10)]
        public static void CreateVolumetricBase(MenuCommand menuCommand)
        {
            InstantiatePrefab(menuCommand, _baseName);
        }

        private const string _spotLightName = "Volumetric SpotLight";
        [MenuItem("GameObject/SimpleVolumetric/" + _spotLightName, false, 11)]
        public static void CreateVolumetricSpotLight(MenuCommand menuCommand)
        {
            InstantiatePrefab(menuCommand, _spotLightName);
        }

        private const string _pointLightName = "Volumetric PointLight";
        [MenuItem("GameObject/SimpleVolumetric/" + _pointLightName, false, 11)]
        public static void CreateVolumetricPointLight(MenuCommand menuCommand)
        {
            InstantiatePrefab(menuCommand, _pointLightName);
        }

        private const string _VATName = "Volumetric VAT";
        [MenuItem("GameObject/SimpleVolumetric/" + _VATName, false, 12)]
        public static void CreateVolumetricVAT(MenuCommand menuCommand)
        {
            InstantiatePrefab(menuCommand, _VATName);
        }
    }
}