// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Unity Shaders Book/Chapter 11/BillBoard"{
	Properties{
		_MainTex ("Main Tex",2D) = "white" {}
		_Color ("Color Tint",Color) = (1,1,1,1)
		_VerticalBillBoarding ("Vertical Restrains",Range(0,1)) = 1
	}
	SubShader{
		
		Tags {"Queue" = "Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" "DisableBatching" = "True"}

		Pass{
			
			Tags {"LightMode"="ForwardBase"}

			ZWrite Off
			Blend SrcAlpha OneMinusSrcAlpha
			Cull Off

			CGPROGRAM

			#include "Lighting.cginc"
			#include "AutoLight.cginc"
			
			#pragma vertex vert 
			#pragma fragment frag 

			sampler2D _MainTex;
			float4 _MainTex_ST;
			fixed4 _Color;
			int _VerticalBillBoarding;

			struct a2v{
				float4 vertex : POSITION;
				float2 texcoord: TEXCOORD0;			
			};

			struct v2f{
				float4 pos : SV_POSITION;
				float2 uv :TEXCOORD0;
			};

			v2f vert(a2v v){
				v2f o;

				float3 center = float3(0,0,0);
				float3 viewer = mul(unity_WorldToObject,float4(_WorldSpaceCameraPos,1));
				//设置一个我们想要的法线方向，
				//这里使得物体的正面永远面对摄像机
				float3 normalDir = viewer - center;

				//_VerticalBillBoarding为1时，面对摄像机；_VerticalBillBoarding为0时，向上方向固定为(0,1,0)
				normalDir.y = normalDir.y * _VerticalBillBoarding;
				normalDir = normalize(normalDir);
				float3 upDir = abs(normalDir.y) > 0.999 ? float3(0,0,1) : float3(0,1,0);
				float3 rightDir =  normalize(cross(upDir,normalDir));
				upDir = normalize(cross(normalDir,rightDir));

				//根据原始的位置相对于锚点的偏移量以及3个正交矢量积，以计算得到新的顶点位置
				float3 centerOffs = v.vertex.xyz - center;
				float3 localPos = center + rightDir * centerOffs.x + upDir * centerOffs.y + normalDir * centerOffs.z;

				o.pos = UnityObjectToClipPos(float4(localPos,1));
				o.uv = TRANSFORM_TEX(v.texcoord,_MainTex);
				return o;
			}

			fixed4 frag(v2f i):SV_Target{
				fixed4 c = tex2D( _MainTex,i.uv);
				c.rgb *= _Color.rgb; 
				return c;		
			}

			ENDCG
		}
	}

	FallBack ""

}