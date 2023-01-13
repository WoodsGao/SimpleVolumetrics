using System.Collections.Generic;
using UnityEngine;

public class VolumetricSpotLight : MonoBehaviour
{

    public float Range = 10f;
    public float Angle = 10f;
    private string _rendererName = "VolumetricRenderer";
    private string _cameraName = "VolumetricCamera";

    [ContextMenu("Clear")]
    void Clear()
    {
        var renderer = transform.Find(_rendererName);
        if (renderer != null)
            DestroyImmediate(renderer.gameObject);

        var camera = transform.Find(_cameraName);
        if (camera != null)
            DestroyImmediate(camera.gameObject);
    }

    Mesh CreateCone(float range, float angle, int edges = 100)
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

    [ContextMenu("Generate Volumetric Renderer")]
    void GenerateVolumetricRenderer()
    {
        // Clear();

        GameObject child = transform.Find(_rendererName).gameObject;
        child.name = _rendererName;
        // child.transform.SetParent(transform);
        // child.transform.localPosition = new Vector3(0, 0, 0);
        // child.transform.localRotation = Quaternion.identity;

        Mesh cone = CreateCone(Range, Angle);

        MeshFilter filter = child.GetComponent<MeshFilter>();
        filter.mesh = cone;

        MeshRenderer renderer = child.GetComponent<MeshRenderer>();
        // Material material = new Material(Shader.Find("Volumetric/ConeVolumetric"));
        Material material = renderer.sharedMaterial;

        SetShadowMap(material);
        material.SetFloat("_Angle", Angle);
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

    void SetShadowMap(Material material)
    {
        // GameObject child = new GameObject();
        // child.name = _cameraName;
        // child.transform.SetParent(transform);
        GameObject child = transform.Find(_cameraName).gameObject;
        child.SetActive(true);

        Camera camera = child.GetComponent<Camera>();
        camera.farClipPlane = Range;
        // camera.ResetProjectionMatrix();
        camera.Render();

        Texture2D tex = RT2Texture2D(camera.targetTexture);
        tex.wrapMode = TextureWrapMode.Clamp;
        material.SetMatrix("_ShadowMapViewMatrix", camera.worldToCameraMatrix);
        material.SetMatrix("_ShadowMapProjectMatrix", camera.projectionMatrix);
        material.SetFloat("_Range", camera.farClipPlane);
        material.SetTexture("_ShadowMap", tex);


        child.SetActive(false);
    }
}