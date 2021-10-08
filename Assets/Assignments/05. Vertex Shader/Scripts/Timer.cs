using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Random = UnityEngine.Random;

public class Timer : MonoBehaviour
{
    Material mat;
    [SerializeField]
    private float timer = 0;
    
    [SerializeField]
    private float splashFrequency = 1;

    [SerializeField] private float pauseTimer = 1;

    private bool pause = false;

    private void Awake() {
        mat = GetComponent<MeshRenderer>().material;
    }

    private void Update() {
        if (!pause) {
            timer += Time.deltaTime;

            if (timer >= Mathf.PI / splashFrequency) {
                splashFrequency = 0;
                timer = 0;
                pause = true;
            }
        }
        else {
            pauseTimer -= Time.deltaTime;
            if (pauseTimer <= 0) {
                pauseTimer = Random.Range(0.5f, 2f);
                splashFrequency = Random.Range(1.5f, 3f);
                pause = false;
            }
        }
       

        

        mat.SetFloat("_splashTimer", timer);
        mat.SetFloat("_splashFrequency",splashFrequency);
    }

}
