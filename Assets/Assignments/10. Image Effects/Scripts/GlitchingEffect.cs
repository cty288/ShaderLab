using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class GlitchingEffect : MonoBehaviour
{
    public Material effectMaterial;

    public float BlockGlitchingIntensity = 0.146f;

    private void OnRenderImage(RenderTexture src, RenderTexture dest) {
        if (EffectController.Singleton.state == EffectController.State.NightVision) {
            effectMaterial.SetFloat("_Intensity", 0.05f);
        }
        else {
            effectMaterial.SetFloat("_Intensity", 0.146f);
        }
        effectMaterial.SetFloat("_RGBGlichingIntensity", 
            EffectController.Singleton.RGBGlitchIntensity);
        Graphics.Blit(src, dest, effectMaterial);
    }
}
