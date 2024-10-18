using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class GaussianBlur : PostEffectsBase
{
    public Shader gaussianBlurShader;
    private Material gaussianBlurMaterial;

    public Material material{
        get{
            gaussianBlurMaterial = CheckShaderAndCreateMaterial(gaussianBlurShader,gaussianBlurMaterial);
            return gaussianBlurMaterial;
        }
    }

    [Range(0,4)]
    public int iterations = 3;

    [Range(0.2f,3.0f)]
    public float blurSpread = 0.6f;

    [Range(1,8)]
    public int downSample = 2;

    private void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        if (material != null)
        {
            int rtW = src.width / downSample;
            int rtH = src.height / downSample;

            //��˹ģ����Ҫ�������� Pass ,������Ҫʹ��һ���м仺�����洢��һ�� Pass ִ����Ϻ�õ���ģ�����
            RenderTexture buffer0 = RenderTexture.GetTemporary(rtW, rtH, 0);
            buffer0.filterMode = FilterMode.Bilinear;

            Graphics.Blit(src, buffer0);


            //����������ʱ�����ڵ���֮����н���
            for(int i=0; i < iterations;i++){
                material.SetFloat("_BlurSize",1.0f + i * blurSpread);
                RenderTexture buffer1 = RenderTexture.GetTemporary(rtW,rtH, 0);
                Graphics.Blit (buffer0, buffer1, material, 0);
                
                RenderTexture.ReleaseTemporary (buffer0);
                buffer0 = buffer1;
                
                //�Ѿ� Blit ���ˣ��������µ�buffer
                buffer1 = RenderTexture.GetTemporary(rtW, rtH, 0);
                Graphics.Blit(buffer0,buffer1, material,1);
                
                RenderTexture.ReleaseTemporary (buffer0);
                buffer0 = buffer1;
            }
            
            Graphics.Blit(buffer0, dest);

            RenderTexture.ReleaseTemporary(buffer0);

        }
        else {
            Graphics.Blit(src, dest);
        }
    }
}
