using System.Collections.Generic;
using System.IO;
using UnityEngine;
using UnityEditor;

namespace SimpleVolumetrics
{
    [ExecuteInEditMode]
    public class VolumetricBase : MonoBehaviour
    {
        public bool ShadowOn = true;
        private bool _shadowOn = true;

        private string _savePath;
        protected Material _material;
        private GameObject _cameraObj;
        private Camera _camera;

#if UNITY_EDITOR
        [ContextMenu("Refresh ShadowMap")]
        void RefreshShadowMap()
        {

            Cubemap cubemap = new Cubemap(_camera.targetTexture.width, TextureFormat.RFloat, false);
            cubemap.SetPixels(CaptureShadowMap(Quaternion.LookRotation(Vector3.back)).GetPixels(), CubemapFace.PositiveZ);
            cubemap.SetPixels(CaptureShadowMap(Quaternion.LookRotation(Vector3.forward)).GetPixels(), CubemapFace.NegativeZ);
            cubemap.SetPixels(CaptureShadowMap(Quaternion.LookRotation(Vector3.right)).GetPixels(), CubemapFace.NegativeX);
            cubemap.SetPixels(CaptureShadowMap(Quaternion.LookRotation(Vector3.left)).GetPixels(), CubemapFace.PositiveX);
            cubemap.SetPixels(CaptureShadowMap(Quaternion.LookRotation(Vector3.up, Vector3.forward)).GetPixels(), CubemapFace.NegativeY);
            cubemap.SetPixels(CaptureShadowMap(Quaternion.LookRotation(Vector3.down, Vector3.back)).GetPixels(), CubemapFace.PositiveY);
            cubemap.Apply();

            _savePath = $"{Config.SavePath}/Shadowmap_{GetInstanceID()}.cubemap";
            AssetDatabase.CreateAsset(cubemap, _savePath);

            _material.SetTexture("_ShadowMap", cubemap);
            Debug.Log("Refresh Shadowmap success");
        }

        Texture2D CaptureShadowMap(Quaternion rotation)
        {
            _cameraObj.transform.rotation = rotation;
            _camera.fieldOfView = 90;
            _camera.nearClipPlane = 0.1f;
            _camera.farClipPlane = 1000;

            _cameraObj.SetActive(true);

            _camera.Render();

            Texture2D tex2d = RT2Texture2D(_camera.targetTexture);
            tex2d.wrapMode = TextureWrapMode.Clamp;

            _cameraObj.SetActive(false);
            return tex2d;
        }
#endif

        // life circle
        protected virtual void OnValidate()
        {
            if (_material == null) return;
            if (ShadowOn == _shadowOn) return;
            if (ShadowOn)
            {
                Invoke("RefreshShadowMap", 0.1f);
                _material.EnableKeyword("VOLUMETRIC_SHADOW_ON");
            }
            else
            {
                _material.DisableKeyword("VOLUMETRIC_SHADOW_ON");
            }
            _shadowOn = ShadowOn;
        }

        protected virtual void Awake()
        {
            MeshRenderer renderer = GetComponent<MeshRenderer>();
            _material = renderer.material;
            if (ShadowOn)
            {
                _material.EnableKeyword("VOLUMETRIC_SHADOW_ON");
            }
            else
            {
                _material.DisableKeyword("VOLUMETRIC_SHADOW_ON");
            }

            _cameraObj = transform.Find("VolumetricCamera").gameObject;
            _camera = _cameraObj.GetComponent<Camera>();
        }

        protected virtual void Update()
        {
        }

        // helper funtions
        private Texture2D RT2Texture2D(RenderTexture rt)
        {
            Texture2D tex = new Texture2D(rt.width, rt.height, TextureFormat.RFloat, false);
            // ReadPixels looks at the active RenderTexture.
            RenderTexture.active = rt;
            tex.ReadPixels(new Rect(0, 0, rt.width, rt.height), 0, 0);
            tex.Apply();
            RenderTexture.active = null;
            return tex;
        }
    }
}