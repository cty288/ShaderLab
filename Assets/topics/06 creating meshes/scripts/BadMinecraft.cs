using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[RequireComponent(typeof (MeshFilter))]
[RequireComponent(typeof (MeshRenderer))]
public class BadMinecraft : MonoBehaviour
{
    Mesh mesh;

    void Start()
    {
        MakeCube();
    }

    void MakeCube()
    {
        Vector3[] c = new Vector3[] {
            new Vector3(0,0,0), //0
            new Vector3(1,0,0), //1
            new Vector3(1,1,0), //2
            new Vector3(0,1,0), //3
            new Vector3(0,1,1), //4
            new Vector3(1,1,1), //5
            new Vector3(1,0,1), //6
            new Vector3(0,0,1)  //7
        };

        Vector3[] vertices = new Vector3[] {
            //0 1 2 3
            c[0], c[1], c[2], c[3], //south
            //4 5 6 7
            c[3], c[2], c[5], c[4], //top
            //8 9 10 11
            c[1], c[6], c[5], c[2], //east
            //12 13 14 15
            c[0], c[3], c[4], c[7], //west
            //16 17 18 19
            c[7], c[4], c[5], c[6], //north
            //20 21 22 23
            c[0], c[1], c[6], c[7], //bottom
        };

        Vector3 south = Vector3.back;
        Vector3 up = Vector3.up;
        Vector3 east = Vector3.right;
        Vector3 west = Vector3.left;
        Vector3 north = Vector3.forward;
        Vector3 bottom = Vector3.down;

        Vector3[] normals = new Vector3[] {
            south, south, south, south,
            up, up, up, up,
            east, east, east, east,
            west, west, west, west,
            north, north, north, north,
            bottom, bottom, bottom, bottom
        };

        Vector2[] uvs = new[] {
            new Vector2(0, 0), new Vector2(0.5f, 0), new Vector2(0.5f, 0.5f), new Vector2(0, 0.5f), //south
            new Vector2(0, 0.5f), new Vector2(0.5f, 0.5f), new Vector2(0.5f, 1), new Vector2(0, 1), //top
            new Vector2(0, 0), new Vector2(0.5f, 0), new Vector2(0.5f, 0.5f), new Vector2(0, 0.5f), //east
            new Vector2(0.5f, 0), new Vector2(0.5f, 0.5f), new Vector2(0, 0.5f), new Vector2(0, 0), //west
            new Vector2(0.5f, 0), new Vector2(0.5f, 0.5f), new Vector2(0, 0.5f), new Vector2(0, 0), //north
            new Vector2(0.5f, 0), new Vector2(1, 0), new Vector2(1, 0.5f), new Vector2(0.5f, 0.5f)
        };

        int[] triangles = new[] {
            0,3,2, //south
            0,2,1,
            4,7,6,
            4,6,5,
            8,11,10,
            8,10,9,
            12,15,14,
            12,14,13,
            16,19,18,
            16,18,17,
            20,21,22,
            20,22,23
        };

        mesh = GetComponent<MeshFilter>().mesh;
        mesh.Clear();
        mesh.vertices = vertices;
        mesh.uv = uvs;
        mesh.normals = normals;
        mesh.triangles = triangles;
    }

    private void OnDestroy()
    {
        Destroy(mesh);
    }
}
