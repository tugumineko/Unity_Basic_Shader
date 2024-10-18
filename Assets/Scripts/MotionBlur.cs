using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MotionBlur : PostEffectsBase
{
    public Shader motionBlurShader;
    private Material motionBlurMaterial = null;

    public Material material{
        get{
            motionBlurMaterial = CheckShaderAndCreateMaterial(motionBlurShader,motionBlurMaterial);
            return motionBlurMaterial;
        }
    }

    [Range(0.0f,0.9f)]
    public float blurAmount = 0.5f;

    private RenderTexture accmulationTexture;

    
    //我们希望在下一次开始应用运动模糊时重新叠加图像
    private void OnDisable()
    {
        DestroyImmediate(accmulationTexture);        
    }

    private void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        if(material != null){
            if(accmulationTexture == null || accmulationTexture.width != src.width || accmulationTexture.height != src.height){ 
                DestroyImmediate(accmulationTexture);
                accmulationTexture = new RenderTexture(src.width,src.height,0);
                accmulationTexture.hideFlags = HideFlags.HideAndDontSave;//这个变量不会保存在场景中，也不会显示在 Hierarchy 中
                Graphics.Blit(src, accmulationTexture);
            }
            //已弃用。accmulationTexture.MarkRestoreExpected();//恢复操作,只是起到表明我们需要进行渲染纹理的一个操作

            material.SetFloat("_BlurAmount", 1.0f - blurAmount);

            Graphics.Blit(src,accmulationTexture,material);
            Graphics.Blit(accmulationTexture, dest);
        }
        else {
            Graphics.Blit(src, dest);
        }
    }

}
