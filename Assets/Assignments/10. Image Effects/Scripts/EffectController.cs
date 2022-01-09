using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Random = UnityEngine.Random;


public class EffectController : MonoBehaviour {
    public enum State {
        NightVision,
        Glitching
    }

    public float lineScaleChangeInterval = 0.8f;
    public float GlitchProbablity = 0.3f;
    public float GlitchTime = 5f;

    [HideInInspector] public float RGBGlitchIntensity;

    public float lineScale;
    
    public static EffectController Singleton;


    public NightViewEffect NightVisionEffectBasic;
    

    public State state = State.NightVision;
    private float timer = 0;
    private int targetLineScale = 100;
    [SerializeField]
    private float lerp = 0.1f;

    private float currentLerp;
    private float targetTime;
    private bool switching = false;
    private void Awake() {
        Singleton = this;
        targetTime = lineScaleChangeInterval;
    }

    private void Start() {
        
    }

    private void Update() {
       
       
        timer += Time.deltaTime;

        if (timer >= targetTime && !switching)
        {
            timer = 0;
            bool isGlitch = Random.Range(0, 101) <= 100 * GlitchProbablity;

            if (!isGlitch || state == State.Glitching)
            {
                targetLineScale = Random.Range(20, 500);
                targetTime = lineScaleChangeInterval;
                state = State.NightVision;
                NightVisionEffectBasic.enabled = true;
                currentLerp = lerp;
            }
            else
            {
                targetTime = GlitchTime;
                currentLerp = 0.005f;
                targetLineScale = 0;
                RGBGlitchIntensity = 0.7f;
                switching = true;
            }
        }

        
        lineScale = Mathf.Lerp(lineScale, targetLineScale, currentLerp);

        if (switching)
        {
            if (lineScale <= 10) {
                lineScale = 0;
               
                StartCoroutine(WaitForGlitch());
            }
        }
    }

    IEnumerator WaitForGlitch() {
        yield return new WaitForSeconds(Random.Range(0.2f,2f));
        state = State.Glitching;
        switching = false;
        NightVisionEffectBasic.enabled = false;
        RGBGlitchIntensity = 0.016f;
    }
}
