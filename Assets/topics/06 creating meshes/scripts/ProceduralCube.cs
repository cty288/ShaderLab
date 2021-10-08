using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[RequireComponent(typeof (MeshFilter))]
[RequireComponent(typeof (MeshRenderer))]
public class ProceduralCube : MonoBehaviour
{
    Mesh mesh;

    void Start()
    {
        MakeCube();
    }

    void MakeCube() {

    }
}
