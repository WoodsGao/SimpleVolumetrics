using UnityEditor;
using UnityEngine;
using System;
using System.Collections.Generic;

namespace SimpleVolumetrics
{
    public class Utils
    {
        public static string SavePath = "Assets/SimpleVolumetrics/Textures/ShadowMapCache";
        public static void RefreshShadowMapByMaterial(Material material)
        {
            Debug.Log("Simple Volumetrics: RefreshShadowMapByMaterial " + material);
            GameObject[] objs = GameObject.FindGameObjectsWithTag("SimpleVolumetrics");
            List<GameObject> objsWithMaterial = new List<GameObject>();
            foreach (var obj in objs)
            {
                MeshRenderer renderer = obj.GetComponent<MeshRenderer>();
                if (renderer.sharedMaterial == material)
                {
                    objsWithMaterial.Add(obj);
                }
            }
            if (objsWithMaterial.Count == 0)
            {
                Debug.LogError("Simple Volumetrics: No GameObject use this material, can not refresh shadow map.");
            }
            else
            {
                if (objsWithMaterial.Count > 1)
                {
                    string output = "";
                    foreach (var obj in objsWithMaterial)
                    {
                        output += "\n" + obj.name + " " + obj.GetInstanceID();
                    }
                    Debug.LogWarning($"Simple Volumetrics: More than one GameObject use this material. {output}");
                }
                CaptureShadowMap(objsWithMaterial[0]);
            }
        }

        [MenuItem("GameObject/SimpleVolumetric/RefreshAllShadowMap", false, 22)]
        public static void RefreshAllShadowMap(MenuCommand menuCommand)
        {
            Debug.Log("Simple Volumetrics: RefreshAllShadowMap");
            GameObject[] objs = GameObject.FindGameObjectsWithTag("SimpleVolumetrics");
            HashSet<Material> materials = new HashSet<Material>();
            foreach (var obj in objs)
            {
                materials.Add(obj.GetComponent<MeshRenderer>().sharedMaterial);
            }
            foreach (var material in materials)
            {
                RefreshShadowMapByMaterial(material);
            }
        }


        private static Texture2D RT2Texture2D(RenderTexture rt)
        {
            Texture2D tex = new Texture2D(rt.width, rt.height, TextureFormat.RFloat, false);
            // ReadPixels looks at the active RenderTexture.
            RenderTexture.active = rt;
            tex.ReadPixels(new Rect(0, 0, rt.width, rt.height), 0, 0);
            tex.Apply();
            RenderTexture.active = null;
            return tex;
        }

        private static Texture2D CaptureShadowMapOneFace(Camera camera, Quaternion rotation)
        {
            camera.gameObject.transform.rotation = rotation;
            camera.fieldOfView = 90;
            camera.nearClipPlane = 0.1f;
            camera.farClipPlane = 1000;

            camera.gameObject.SetActive(true);

            camera.Render();

            Texture2D tex2d = RT2Texture2D(camera.targetTexture);
            tex2d.wrapMode = TextureWrapMode.Clamp;

            camera.gameObject.SetActive(false);
            return tex2d;
        }

        private static void CaptureShadowMap(GameObject volumetricObj)
        {
            Camera camera = volumetricObj.transform.Find("VolumetricCamera").GetComponent<Camera>();
            Material material = volumetricObj.GetComponent<MeshRenderer>().sharedMaterial;

            Cubemap cubemap = new Cubemap(camera.targetTexture.width, TextureFormat.RFloat, false);
            cubemap.SetPixels(CaptureShadowMapOneFace(camera, Quaternion.LookRotation(Vector3.back)).GetPixels(), CubemapFace.PositiveZ);
            cubemap.SetPixels(CaptureShadowMapOneFace(camera, Quaternion.LookRotation(Vector3.forward)).GetPixels(), CubemapFace.NegativeZ);
            cubemap.SetPixels(CaptureShadowMapOneFace(camera, Quaternion.LookRotation(Vector3.right)).GetPixels(), CubemapFace.NegativeX);
            cubemap.SetPixels(CaptureShadowMapOneFace(camera, Quaternion.LookRotation(Vector3.left)).GetPixels(), CubemapFace.PositiveX);
            cubemap.SetPixels(CaptureShadowMapOneFace(camera, Quaternion.LookRotation(Vector3.up, Vector3.forward)).GetPixels(), CubemapFace.NegativeY);
            cubemap.SetPixels(CaptureShadowMapOneFace(camera, Quaternion.LookRotation(Vector3.down, Vector3.back)).GetPixels(), CubemapFace.PositiveY);
            cubemap.Apply();

            string savePath = $"{SavePath}/Shadowmap_{material.GetInstanceID()}.cubemap";
            AssetDatabase.CreateAsset(cubemap, savePath);

            material.SetTexture("_ShadowMap", cubemap);
            Debug.Log("Simple Volumetrics: Refresh Shadowmap success " + savePath);
        }
    }
}
