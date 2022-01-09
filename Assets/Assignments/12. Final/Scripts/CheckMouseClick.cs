using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class CheckMouseClick : MonoBehaviour {
    [SerializeField] private LayerMask targeMask;
    [SerializeField] private Material scanMaterial;
    private void Update() {
        if (Input.GetMouseButtonDown(0)) {
            Ray ray = Camera.main.ScreenPointToRay(Input.mousePosition);
            Physics.Raycast(ray, out RaycastHit hit, 15000000, targeMask);

            if (hit.collider) {
                scanMaterial.SetVector("_ScanPos", hit.point);
                if (hit.collider.TryGetComponent<Radius>(out Radius rad)) {
                    scanMaterial.SetFloat("_scanRadius", rad.radius);
                }
            }
        }
    }
}
