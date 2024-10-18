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

    
    //����ϣ������һ�ο�ʼӦ���˶�ģ��ʱ���µ���ͼ��
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
                accmulationTexture.hideFlags = HideFlags.HideAndDontSave;//����������ᱣ���ڳ����У�Ҳ������ʾ�� Hierarchy ��
                Graphics.Blit(src, accmulationTexture);
            }
            //�����á�accmulationTexture.MarkRestoreExpected();//�ָ�����,ֻ���𵽱���������Ҫ������Ⱦ�����һ������

            material.SetFloat("_BlurAmount", 1.0f - blurAmount);

            Graphics.Blit(src,accmulationTexture,material);
            Graphics.Blit(accmulationTexture, dest);
        }
        else {
            Graphics.Blit(src, dest);
        }
    }

}
