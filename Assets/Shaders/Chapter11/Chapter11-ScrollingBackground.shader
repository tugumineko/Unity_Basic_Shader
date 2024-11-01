// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Unity Shaders Book/Chapter 11/Scrolling Background"{
	Properties{
		_MainTex ("Base Layer (RGB)",2D) = "white" {}
		_DetailTex ("2nd Layer (RGB)",2D) = "white" {}
		_ScorllX ("Base layer Scorll Speed",Float) = 1.0
		_Scorll2X ("2nd layer Scorll Speed",Float) = 1.0
		
		//控制纹理的整体亮度
		_Multiplier ("Layer Multiplier",Float) = 1	
	}
	SubShader{
		
		Pass{
			
			Tags {"LightMode" = "ForwardBase"}

			CGPROGRAM

			#include "Lighting.cginc"
			#include "AutoLight.cginc"

			#pragma vertex vert
			#pragma fragment frag
			
			sampler2D _MainTex;
			float4 _MainTex_ST;

			sampler2D _DetailTex;
			float4 _DetailTex_ST;

			float _ScorllX;
			float _Scorll2X;

			float _Multiplier;

			struct a2v{
				float4 vertex : POSITION;
				float4 texcoord : TEXCOORD0;
			};

			struct v2f{
				float4 pos : SV_POSITION;			
				float4 uv : TEXCOORD0;			
			};

			v2f vert(a2v v){
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv.xy = TRANSFORM_TEX(v.texcoord,_MainTex)+frac(float2(_ScorllX,0.0) * _Time.y);
				o.uv.zw = TRANSFORM_TEX(v.texcoord,_DetailTex) + frac(float2(_Scorll2X,0.0)*_Time.y);

				return o;
			}

			fixed4 frag(v2f i):SV_Target {
				fixed4 firstLayer = tex2D(_MainTex,i.uv.xy);
				fixed4 secondLayer = tex2D(_DetailTex,i.uv.zw);

				fixed4 c = lerp(firstLayer,secondLayer,secondLayer.a);
				c.rgb *= _Multiplier;
	
				return c;
			}

			ENDCG
		}
	
	}

	FallBack "VertexLit"
}