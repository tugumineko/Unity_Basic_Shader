// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Unity Shaders Book/Chapter 5/Simple Shader"{
	Properties{
		_Color ("Color Tint", Color) = (1.0,1.0,1.0,1.0)
	}
		
	SubShader{
		Pass{
			CGPROGRAM

			//使用vert作为顶点着色器
			//使用frag作为片元着色器
			#pragma vertex vert
			#pragma fragment frag

			fixed4 _Color;

			//使用结构体来定义顶点着色器的输入
			//application to vertex : 从应用阶段传递到顶点着色器中
			struct a2v{
				float4 vertex : POSITION;  //语义和结构体元素起到对应作用
				//语义从材质的 Mesh Render组件提供 
				float3 normal : NORMAL;
				float4 texcoord : TEXCOORD0;//0表示模型的第一套纹理
			};

			//使用结构体定义顶点着色器的输出
			//vertex to fragment : 从顶点着色器传递到片元着色器中
			struct v2f{
				//顶点着色器的输出必须包含SV_POSITION
				float4 pos : SV_POSITION; 
				fixed3 color : COLOR0;
			};

			//unity将POSITION输入，得到SV_POSITION输出
			v2f vert(a2v v) {
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				//传递法线方向（-1，1）-->(0,1)
				o.color = v.normal * 0.5 + fixed3(0.5,0.5,0.5);
				return o;
			}
			//unity不作输入，得到SV_Target输出
			fixed4 frag(v2f i) : SV_Target{
				fixed3 c = i.color;
				c *= _Color.rgb;
				//fixed低精度数，颜色上表示RGBA[0,1]，空间上表示XYZW
				return fixed4(c,1.0);
			}

 			ENDCG
		}
	}
}