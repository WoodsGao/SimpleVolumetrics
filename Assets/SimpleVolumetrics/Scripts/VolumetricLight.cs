using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace SimpleVolumetrics
{
    [ExecuteInEditMode]
    [RequireComponent(typeof(Light))]
    public class VolumetricLight : MonoBehaviour
    {
        private Light _light;
        private Material _material;
        void Awake()
        {
            _light = GetComponent<Light>();
            _material = GetComponent<MeshRenderer>().sharedMaterial;
        }
        void Update()
        {
#if UNITY_EDITOR
            _material = GetComponent<MeshRenderer>().sharedMaterial;
#endif
            _material.SetFloat("_Range", _light.range);
            _material.SetFloat("_Angle", Mathf.Tan(Mathf.Deg2Rad * _light.spotAngle * 0.5f));
        }
    }
}