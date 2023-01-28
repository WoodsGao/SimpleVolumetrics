using System.Collections.Generic;
using System.IO;
using UnityEngine;
using UnityEditor;

namespace SimpleVolumetrics
{
    [ExecuteInEditMode]
    public class VolumetricSpotLight : MonoBehaviour
    {
        public float Range = 10f;
        private float _range = 10f;
        public float Angle = 90f;
        private float _angle = 10f;
        public bool ShadowOn = true;

        private string _savePath;
        private Material _material;
        private GameObject _cameraObj;
        private Camera _camera;

#if UNITY_EDITOR
        [ContextMenu("Refresh ShadowMap")]
        void GenerateVolumetricRenderer()
        {
            Mesh cone = CreateCone(Range, Angle);

            MeshFilter filter = GetComponent<MeshFilter>();
            filter.mesh = cone;

            SetShadowMap();
        }
#endif

        // life circle
        void OnValidate()
        {
            if (_camera == null || _material == null) return;
            if (Range == _range && Angle == _angle) return;
            Angle = Mathf.Min(179.9f, Angle);
            _camera.fieldOfView = Angle;
            if (ShadowOn)
                _material.EnableKeyword("VOLUMETRIC_SHADOW_ON");
            else
                _material.DisableKeyword("VOLUMETRIC_SHADOW_ON");
#if UNITY_EDITOR
            if (IsInvoking()) CancelInvoke();
            if (ShadowOn)
                Invoke("GenerateVolumetricRenderer", 1f);
#endif
            _range = Range;
            _angle = Angle;
        }

        void OnEnable()
        {
            MeshRenderer renderer = GetComponent<MeshRenderer>();
            _material = renderer.material;

            _cameraObj = transform.Find("VolumetricCamera").gameObject;
            _camera = _cameraObj.GetComponent<Camera>();
            UpdateMaterialProps();
        }

        void Update()
        {
            UpdateMaterialProps();
        }

        // custom proceduels
        private void UpdateMaterialProps()
        {
            _material.SetMatrix("_ShadowMapProjectMatrix", _camera.projectionMatrix);
        }

        private void SetShadowMap()
        {
            Debug.Log("Render Shadowmap:" + GetInstanceID());
            Debug.Log(_camera.projectionMatrix);
            _cameraObj.SetActive(true);

            // RenderTexture rt = RenderTexture.GetTemporary(2048, 2048, 16, RenderTextureFormat.RFloat, RenderTextureReadWrite.Linear);
            // _camera.targetTexture = rt;
            _camera.Render();
            Debug.Log(_camera.projectionMatrix);

            Texture2D tex2d = RT2Texture2D(_camera.targetTexture);
            tex2d.wrapMode = TextureWrapMode.Clamp;

            _savePath = $"{Config.SavePath}/SpotLightShadowmap_{GetInstanceID()}.texture2D";
            AssetDatabase.CreateAsset(tex2d, _savePath);

            _material.SetTexture("_ShadowMap", tex2d);

            // _camera.targetTexture = null;
            // RenderTexture.ReleaseTemporary(rt);
            _cameraObj.SetActive(false);
        }

        // helper funtions
        private Mesh CreateCone(float range, float angle, int edges = 100)
        {
            Mesh cone = new Mesh();
            cone.name = "Cone";

            Vector3[] vertices = new Vector3[edges + 2];
            Vector3 center = new Vector3(0, 0, range);
            float radius = Mathf.Tan(angle * Mathf.Deg2Rad * 0.5f);
            radius = Mathf.Min(radius, 1000) * range;

            float indexToRad = 2f * Mathf.PI / edges;
            for (int i = 0; i < edges; i++)
            {
                vertices[i] = center + new Vector3(Mathf.Sin(i * indexToRad), Mathf.Cos(i * indexToRad), 0) * radius;
            }
            vertices[edges] = center;
            vertices[edges + 1] = new Vector3(0, 0, 0);

            int[] triangles = new int[2 * 3 * edges];
            for (int i = 0; i < edges; i++)
            {
                triangles[6 * i] = edges;
                triangles[6 * i + 1] = (i + 1) % edges;
                triangles[6 * i + 2] = i;
                triangles[6 * i + 3] = edges + 1;
                triangles[6 * i + 4] = i;
                triangles[6 * i + 5] = (i + 1) % edges;
            }

            cone.vertices = vertices;
            cone.triangles = triangles;

            cone.RecalculateNormals();
            cone.Optimize();
            return cone;
        }

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