using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[RequireComponent(typeof(Camera))]
[ExecuteInEditMode]
public class DepthToWorldMatrix : MonoBehaviour {
    [SerializeField] private Material scanMaterial;

    private void Update() {
        Camera cam = GetComponent<Camera>();
        Matrix4x4 matrix = cam.projectionMatrix * cam.worldToCameraMatrix;
        scanMaterial.SetMatrix("_FragToWorldMatrix", matrix.inverse);
       
    }

   
}
