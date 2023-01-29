using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace SimpleVolumetrics
{
    [ExecuteInEditMode]
    [RequireComponent(typeof(Light))]
    public class VolumetricLight : VolumetricBase
    {
        private Light _light;
        protected override void Awake()
        {
            base.Awake();
            _light = GetComponent<Light>();
        }
        protected override void Update()
        {
            base.Update();
            base._material.SetFloat("_Range", _light.range);
            base._material.SetFloat("_Angle", Mathf.Tan(Mathf.Deg2Rad * _light.spotAngle * 0.5f));
        }
    }
}