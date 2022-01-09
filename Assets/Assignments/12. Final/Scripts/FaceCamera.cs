using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class FaceCamera : MonoBehaviour
{
    private void Update() {
        transform.forward = Camera.main.transform.forward;
    }
}
