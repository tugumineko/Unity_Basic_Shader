// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Unity Shaders Book/Chapter 13/Motion Blur With Depth Texture"{
	Properties{
		_MainTex("Base (RGB)",2D) = "white" {}
		_BlurSize("Blur Size",Float) = 1.0	
	}
	SubShader{

		CGINCLUDE
		
		#include "UnityCG.cginc"

		sampler2D _MainTex;
		half4 _MainTex_TexelSize;//���������Ĳ����������ƽ̨���컯����
		sampler2D _CameraDepthTexture;
		float4x4 _CurrentViewProjectionInverseMatrix;
		float4x4 _PreviousViewProjectionMatrix;
		half _BlurSize;

		struct v2f{
			float4 pos : SV_POSITION;
			half2 uv : TEXCOORD0;
			half2 uv_depth : TEXCOORD1;
		};

		v2f vert(appdata_img v){
			v2f o;
			o.pos = UnityObjectToClipPos(v.vertex);

			o.uv = v.texcoord;
			o.uv_depth = v.texcoord;

			#if UNITY_UV_STARTS_AT_TOP
				o.uv_depth.y = 1 - o.uv_depth.y;
			#endif

			return o;
		}
		
		fixed4 frag(v2f i):SV_Target{
			float d = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture,i.uv_depth);
			#if defined(UNITY_REVERSED_Z)
				d = 1.0 - d;
			#endif
			float4 H = float4(i.uv.x * 2 - 1, i.uv.y * 2 - 1,d*2-1,1);//[-1,1]
			float4 D = mul(_CurrentViewProjectionInverseMatrix,H);//�õ�����ռ��µ�����
			float4 worldPos = D / D.w;

			float4 currentPos = H;
			float4 previousPos = mul(_PreviousViewProjectionMatrix,worldPos);//ǰһ֡������
			previousPos /= previousPos.w;

			float2 velocity = (currentPos.xy - previousPos.xy) / 2.0f;

			float2 uv = i.uv;
			float4 c = tex2D(_MainTex,uv);

			//ʹ���ٶ�ֵ�������������ؽ��в�������Ӻ�ȡƽ��ֵ�õ�һ��ģ����Ч��
			uv += velocity * _BlurSize;
			for(int it = 1;it<3;it++,uv += velocity * _BlurSize){
				float4 currentColor = tex2D(_MainTex,uv);
				c += currentColor;		
			}
			c /= 3;

			return fixed4(c.rgb,1.0);
		}
		ENDCG

		Pass{
			ZTest always
			Cull Off
			ZWrite Off
			
			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag

			ENDCG
		}
	
	}

	FallBack Off
}