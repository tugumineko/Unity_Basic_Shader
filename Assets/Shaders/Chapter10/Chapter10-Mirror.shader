// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Unity Shaders Book/Chapter 10/Mirror"{
	Properties{
		_MainTex ("Main Tex",2D) = "white" {}
	}
	SubShader{
		Pass{
			Tags {"LightMode"="ForwardBase"}

			CGPROGRAM

			#include "Lighting.cginc"
			#include "AutoLight.cginc"

			#pragma vertex vert
			#pragma fragment frag	
			
			sampler2D _MainTex;
			float4 _MainTex_ST;

			struct a2v{
				float4 vertex : POSITION;
				float2 texcoord : TEXCOORD0;
			};

			struct v2f{
				float4 pos : SV_POSITION;
				float2 uv : TEXCOORD0;
			};

			v2f vert(a2v v){
				//将渲染纹理水平翻转即可
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv = v.texcoord;
				o.uv.x = 1 - o.uv.x;
				return o;
			}

			fixed4 frag(v2f i):SV_Target{
				return tex2D(_MainTex,i.uv);			
			}

			ENDCG
		}
	}
	FallBack "Diffuse"
}




