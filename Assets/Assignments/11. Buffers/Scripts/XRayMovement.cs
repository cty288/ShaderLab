using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class XRayMovement : MonoBehaviour {
    private float MoveSpeed;
    public float startY;
    public float endY;
    public float moveDownTime = 2.5f;
    public float WaitTime = 2.5f;

    public bool isWaiting = false;
    private MeshRenderer meshRenderer;

    private void Start() {
        transform.position = new Vector3(transform.position.x, startY, transform.position.z);
        MoveSpeed = Mathf.Abs((endY - startY) / moveDownTime);
        Debug.Log(MoveSpeed.ToString());
        meshRenderer = GetComponent<MeshRenderer>();
    }

    private void Update() {
        if (!isWaiting) {
            transform.position = new Vector3(transform.position.x,
                transform.position.y - MoveSpeed * Time.deltaTime,
                transform.position.z);

            if (transform.position.y <= endY) {
                isWaiting = true;
                meshRenderer.enabled = false;
                StartCoroutine(Hide());
            }
        }
    }

    IEnumerator Hide() {
        yield return new WaitForSeconds(WaitTime);
        isWaiting = false;
        meshRenderer.enabled = true;
        transform.position = new Vector3(transform.position.x, startY, transform.position.z);
    }
}
