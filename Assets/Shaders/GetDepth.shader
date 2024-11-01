// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Texture/GetDepth"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Cull Off 
        ZWrite Off 
        ZTest Always 

        Pass{
            CGPROGRAM
            
            #pragma vertex vert 
            #pragma fragment frag 

            #include "UnityCG.cginc"

            sampler2D _CameraDepthNormalsTexture;
            sampler2D _CameraDepthTexture;
            float4x4 UNITY_MATRIX_IV;

            sampler2D _MainTex;
            float4 _MainTex_ST;
                        
            struct v2f{
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            v2f vert(appdata_img v){
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = v.texcoord;
                return o;
            }

            fixed4 frag(v2f i):SV_Target{
               
               //Normal Depth
               /*
               float4 NormalDepth;
                    DecodeDepthNormal(tex2D(_CameraDepthNormalsTexture, i.uv), NormalDepth.w, NormalDepth.xyz);
                    float3 worldNormal = normalize(mul((float3x3)UNITY_MATRIX_IT_MV, NormalDepth.xyz));
                    fixed4 col;
                    if (i.uv.x > 0.5) col.rgb = NormalDepth.w;
                    else col.rgb = worldNormal;
                    return col;
                */
                //OnlyDepth
                
                    float depth = UNITY_SAMPLE_DEPTH(tex2D(_CameraDepthTexture, i.uv));
                    float linear01Depth = Linear01Depth(depth);
                    return fixed4(linear01Depth, linear01Depth, linear01Depth, 1);
                

                //None
                //  return tex2D(_MainTex, i.uv);
               
            }

            ENDCG 
        
    }
    }

    FallBack "Diffuse"
}
