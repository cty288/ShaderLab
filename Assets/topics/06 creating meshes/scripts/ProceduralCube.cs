using System;
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
       
        Vector3[] vertices = new Vector3[] {
            new Vector3(0,0,0),
            new Vector3(1,0,0),
            new Vector3(1,1,0),
            new Vector3(0,1,0),
            new Vector3(0,1,1),
            new Vector3(1,1,1),
            new Vector3(1,0,1),
            new Vector3(0,0,1)
        };

        int[] triangles = new[] {
            0,3,2, //south
            0,2,1,
            3,4,5, //top
            3,5,2,
            1,2,5, //east
            1,5,6,
            7,4,3, //west
            7,3,0,
            6,5,7,//north
            5,4,7,
            1,6,0, //down
            0,6,7
        };

        mesh = GetComponent<MeshFilter>().mesh;
        mesh.Clear();
        mesh.vertices = vertices;
        mesh.triangles = triangles;
    }

    private void OnDestroy() {
        Destroy(mesh);
    }
}
