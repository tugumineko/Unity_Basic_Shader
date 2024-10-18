using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class EdgeDetectNormalAndDepth : PostEffectsBase
{
    public Shader edgeDetectShader;
    private Material edgeDetectMaterial = null;
    public Material material {
        get{
            edgeDetectMaterial = CheckShaderAndCreateMaterial(edgeDetectShader,edgeDetectMaterial);
            return edgeDetectMaterial;
        }
    }

    [Range(0.0f,1.0f)]
    public float edgesOnly = 0.0f;

    public Color edgeColor = Color.black;

    public Color backgroundColor = Color.white;

    public float sampleDistance = 1.0f;

    public float sensitivityDepth = 1.0f;

    public float sensitivityNormals = 1.0f;

    private void OnEnable()
    {
        GetComponent<Camera>().depthTextureMode |= DepthTextureMode.DepthNormals;
    }

    [ImageEffectOpaque]
    private void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        if(material != null) {
            material.SetFloat("_EdgeOnly", edgesOnly);
            material.SetColor("_EdgeColor", edgeColor);
            material.SetColor("_BackgroundColor", backgroundColor);
            material.SetFloat("_SampleDistance", sampleDistance);
            material.SetVector("_Sensitivity", new Vector4(sensitivityNormals,sensitivityDepth,0,0));
            Graphics.Blit(src, dest, material);
        }
        else {
        Graphics.Blit(src, dest);
        }
    }
}
