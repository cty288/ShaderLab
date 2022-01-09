using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;


[ExecuteInEditMode]
[RequireComponent(typeof(Camera))]
public class GenerateDepthTexture : MonoBehaviour {
    private void Awake() {
        GetComponent<Camera>().depthTextureMode = DepthTextureMode.Depth;
    }
}
