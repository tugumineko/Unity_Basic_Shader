// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "NPR/RimOffect"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Color ("Color",Color) = (0,0,0,0)
        _RimOffect ("Rim Offect",Range(0,1)) = 0.5 
        _Threshold ("Threshold",Range(-1,1)) = 0.5
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM

            #include "UnityCG.cginc" 
            #pragma vertex vert 
            #pragma fragment frag 

            struct v2f {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
                float clipW : TEXCOORD1;
                float3 worldNormal : TEXCOORD2;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _CameraDepthTexture;

            float4 _Color;
            fixed _RimOffect;
            fixed _Threshold;

            v2f vert(appdata_full v){
                v2f o;
                o.pos =  UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.texcoord,_MainTex);
                //透视除法之前的w分量
                o.clipW = o.pos.w;
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                return o;
            }

            fixed4 frag(v2f i):SV_Target{
                fixed3 worldNormal = normalize(i.worldNormal);
                fixed3 viewNormal = normalize(mul((float3x3)UNITY_MATRIX_V,worldNormal));
                
                //x * y 的屏幕映射到 0 - 1
                float2 screenParam01 = float2(i.pos.x / _ScreenParams.x,i.pos.y / _ScreenParams.y); 
                
                float2 offectSamplePos = screenParam01 + viewNormal.xy * _RimOffect; //float2(_RimOffect/i.clipW,0)
                float offectDepth = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture,offectSamplePos);
                float trueDepth = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture,screenParam01);
                fixed linear01EyeOffectDepth = Linear01Depth(offectDepth);
                fixed linear01EyeTrueDepth = Linear01Depth(trueDepth);
                fixed depthDiffer = linear01EyeOffectDepth - linear01EyeTrueDepth;
                
                float rimIntensity = step(_Threshold,depthDiffer);
                fixed4 col = fixed4(rimIntensity,rimIntensity,rimIntensity,1);
                col *= tex2D(_MainTex,i.uv)*_Color;
                

                return col;
            }                    

            ENDCG
        }
    }
    //从Camera接收Depth
    FallBack "Diffuse"
}
