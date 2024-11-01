// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Unity Shaders Book/Chapter 8/Alpha Test Both Sided"{
	Properties{
		_Color ("Main Tint",Color) = (1,1,1,1)
		_MainTex("Main Tex",2D) = "white" {}
		
		//控制深度测试时使用的阈值
		_Cutoff ("Alpha Cutoff",Range(0,1)) = 0.5
	}

	//分为接收阴影和投射阴影两部分，
	//投射阴影由 LightMode 为 ShadowCaster 的 Pass 实现 （这里在FallBack的FallBack中实现了）
	//接收阴影由 v2f 的 SHADOW_COORDS 存储阴影纹理, vert 的 TRANSFER_SHADOW 由模型空间变换到光源空间， 最后由 UNITY_LIGHT_ATTENUATION 采样计算 atten .
	SubShader{

		Tags {"Queue"="AlphaTest" "IgnoreProjector"="True" "RenderType"="TransparentCutout"}
		
		Pass{
			Tags {"LightMode"="ForwardBase"}

			Cull Off

			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag	
			
			#include "Lighting.cginc"
			#include "AutoLight.cginc"

			fixed4 _Color;
			sampler2D _MainTex;
			float4 _MainTex_ST;
			fixed _Cutoff;
			
			struct a2v{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float4 texcoord : TEXCOORD0;
			};

			struct v2f{
				float4 pos : SV_POSITION;
				float3 worldNormal : TEXCOORD0;	
				float3 worldPos : TEXCOORD1;
				float2 uv : TEXCOORD2;
				SHADOW_COORDS(3)
			};

			v2f vert(a2v v){
				v2f o;

				o.pos = UnityObjectToClipPos(v.vertex);
				o.worldNormal = UnityObjectToWorldNormal(v.normal);
				o.worldPos = mul(unity_ObjectToWorld,v.vertex).xyz;

				o.uv = TRANSFORM_TEX(v.texcoord,_MainTex);

				TRANSFER_SHADOW(o);

				return o;
			}

			fixed4 frag(v2f i) : SV_Target{
				fixed3 worldNormal = normalize(i.worldNormal);
				fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));

				fixed4 texColor = tex2D(_MainTex,i.uv);
				
				//if(texColor.a - _Cutoff < 0.0) discard;
				clip(texColor.a - _Cutoff);

				fixed3 albelo = texColor.rgb * _Color.rgb;

				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT * albelo;

				fixed3 diffuse = _LightColor0.rgb * albelo * saturate(dot(worldNormal,worldLightDir));

				UNITY_LIGHT_ATTENUATION(atten,i,i.worldPos);

				return fixed4(ambient + diffuse * atten,1.0);
			}

			ENDCG
		}
	
	
	
	}
	FallBack "Transparent/Cutout/VertexLit"
}