// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Unity Shaders Book/Chapter 12/Brightness Saturation And Contrast"{
	Properties{
		_MainTex ("Base (RGB)",2D) = "white" {}
		_Brightness ("Brightness",Float) = 1
		_Saturation ("Saturation",Float) = 1
		_Contrast ("Contrast",Float)  =1
	}
	SubShader{		
		Pass{
			ZTest Always Cull Off ZWrite Off
			
			CGPROGRAM

			#include "Lighting.cginc"

			#pragma vertex vert
			#pragma fragment frag
			
			sampler2D _MainTex;
			half _Brightness;
			half _Saturation;
			half _Contrast;

			struct a2v{
				float4 vertex : POSITION;
				float2 texcoord : TEXCOORD0;
			};

			struct v2f{
				float4 pos : SV_POSITION;
				half2 uv : TEXCOORD0;
			};
			//appdata_img v
			v2f vert(a2v v){
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv = v.texcoord;
				return o;
			}

			fixed4 frag(v2f i) : SV_Target{
				fixed4 renderTex = tex2D(_MainTex,i.uv);
				fixed3 finalColor = renderTex.rgb * _Brightness;

				//RGB转为灰度值的公式
				//在线性色彩空间下是 luminance = 0.2125 * color.r + 0.7154 * color.g + 0.0721 * color.b
				fixed luminance = 0.2125 * renderTex.r + 0.7154 * renderTex.g + 0.0721 * renderTex.b;
				fixed3 luminanceColor = fixed3(luminance,luminance,luminance);
				finalColor = lerp(luminanceColor,finalColor,_Saturation);
				fixed avgColor = fixed3(0.5,0.5,0.5);
				finalColor = lerp(avgColor,finalColor,_Contrast);

				return fixed4(finalColor,renderTex.a);
			}

			ENDCG
		}
	
	
	}


}