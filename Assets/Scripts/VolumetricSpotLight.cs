using System.Collections.Generic;
using System.IO;
using UnityEngine;
using UnityEditor;

[ExecuteInEditMode]
public class VolumetricSpotLight : MonoBehaviour
{

    public float Range = 10f;
    public float Angle = 90f;

    public GameObject RendererObj;
    public GameObject CameraObj;

    private string _texPath = "VolumetricCamera";
    private string _texRoot = "Assets/Texture";
    private Material _material;
    private Camera _camera;


#if UNITY_EDITOR
    // [ContextMenu("Generate Volumetric Renderer")]
    void GenerateVolumetricRenderer()
    {
        Mesh cone = CreateCone(Range, Angle);

        MeshFilter filter = RendererObj.GetComponent<MeshFilter>();
        filter.mesh = cone;

        SetShadowMap();
    }
#endif

    // life circle
    void OnValidate()
    {
        if (_camera == null || _material == null) return;
        Angle = Mathf.Min(179.9f, Angle);
        _camera.farClipPlane = Range;
        _camera.fieldOfView = Angle;
        _material.SetFloat("_Angle", Angle);
        _material.SetFloat("_Range", Range);
#if UNITY_EDITOR
        if (IsInvoking()) CancelInvoke();
        Invoke("GenerateVolumetricRenderer", 1f);
#endif
    }

    void OnEnable()
    {
        MeshRenderer renderer = RendererObj.GetComponent<MeshRenderer>();
        _material = renderer.sharedMaterial;

        _camera = CameraObj.GetComponent<Camera>();
        UpdateMaterialProps();
    }

    void Update()
    {
        UpdateMaterialProps();
    }

    // custom proceduels
    private void UpdateMaterialProps()
    {
        _material.SetMatrix("_ShadowMapViewMatrix", _camera.worldToCameraMatrix);
        _material.SetMatrix("_ShadowMapProjectMatrix", _camera.projectionMatrix * _camera.worldToCameraMatrix);
    }

    private void SetShadowMap()
    {
        Debug.Log("Render Shadowmap");
        CameraObj.SetActive(true);
        _camera.Render();

        Texture2D texTemp = RT2Texture2D(_camera.targetTexture);
        texTemp.wrapMode = TextureWrapMode.Clamp;
        byte[] dataBytes = texTemp.EncodeToPNG();
        string savePath = Application.dataPath + "/SampleCircle.png";
        FileStream fileStream = File.Open(savePath, FileMode.OpenOrCreate);
        fileStream.Write(dataBytes, 0, dataBytes.Length);
        fileStream.Close();

        TextureImporter texImporter = AssetImporter.GetAtPath("Assets/SampleCircle.png") as TextureImporter;
        texImporter.sRGBTexture = false;
        Texture2D tex = AssetDatabase.LoadAssetAtPath<Texture2D>("Assets/SampleCircle.png");
        
        _material.SetTexture("_ShadowMap", tex);

        CameraObj.SetActive(false);

        AssetDatabase.SaveAssets();
        AssetDatabase.Refresh();
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
        Texture2D tex = new Texture2D(rt.width, rt.height, TextureFormat.RGBA32, false);
        // ReadPixels looks at the active RenderTexture.
        RenderTexture.active = rt;
        tex.ReadPixels(new Rect(0, 0, rt.width, rt.height), 0, 0);
        tex.Apply();
        return tex;
    }
}