using System.Collections;
using System.Collections.Generic;
using UnityEngine;



public class NightViewEffect : MonoBehaviour
{
    public Material effectMaterial;

    private void OnRenderImage(RenderTexture src, RenderTexture dest) {
        effectMaterial.SetFloat("_lineScale", EffectController.Singleton.lineScale);
        Graphics.Blit(src, dest, effectMaterial);
    }
}
