using System.Collections.Generic;
using UnityEngine;

public class VolumetricSpotLight : MonoBehaviour
{

    public float Range = 10f;
    public float Angle = 10f;

    private string _name = "VolumetricRenderer";
    [ContextMenu("Clear")]
    void Clear()
    {
        var child = transform.Find(_name);
        if (child != null)
            DestroyImmediate(child.gameObject);
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
        Clear();

        GameObject child = new GameObject();
        child.name = _name;
        child.transform.SetParent(transform);

        Mesh cone = CreateCone(Range, Angle);

        MeshFilter filter = child.AddComponent<MeshFilter>();
        filter.mesh = cone;

        MeshRenderer renderer = child.AddComponent<MeshRenderer>();
    }
}