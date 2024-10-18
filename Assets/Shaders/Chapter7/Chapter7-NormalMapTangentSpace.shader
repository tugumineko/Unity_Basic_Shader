// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Unity Shaders Book/Chapter7/Normal Map In Tangent Space"{
	Properties{
		//多了一张法线纹理 _BumpMap (normal map), 即不同位置的法线方向储存在像素上面
		//_BumpScale则是用来控制凹凸程度的
		_Color ("Color Tint",Color) = (1.0,1.0,1.0,1.0)
		_MainTex ("Main Tex",2D) = "white" {}
		_BumpMap ("Bump Map",2D) = "bump" {}
		_BumpScale ("Bump Scale",Float) = 1.0
		_Specular ("Specular",Color) = (1.0,1.0,1.0,1.0)
		_Gloss ("Gloss",Range(8.0,256)) = 20
	}
	SubShader{
		Pass{
			Tags { "LightMode"="ForwardBase"}

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag	
			
			#include "Lighting.cginc"

			fixed4 _Color;

			sampler2D _MainTex;
			float4 _MainTex_ST;
			
			sampler2D _BumpMap;
			float4 _BumpMap_ST;

			float _BumpScale;
			fixed4 _Specular;
			float _Gloss;

			struct a2v{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				//需要使用tangent.w分量来决定切线空间副切线的方向性
				//a2v的切线只用来计算切线空间变换矩阵
				float4 tangent : TANGENT;
				float4 texcoord : TEXCOORD0;
			};

			//需要在顶点着色器中计算切线空间下的光照和视角方向
			struct v2f{
				float4 pos : SV_POSITION;
				float4 uv : TEXCOORD0;
				float3 lightDir : TEXCOORD1;
				float3 viewDir : TEXCOORD2;
			};

			v2f vert(a2v v){
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);

				o.uv.xy = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				o.uv.zw = v.texcoord.xy * _BumpMap_ST.xy + _BumpMap_ST.zw;
				
				//w分量表示方向
				float3 binormal = cross(normalize(v.normal),normalize(v.tangent.xyz))*v.tangent.w;

				//切线x轴，副切线y轴，法线z轴
				//从模型空间到切线空间的变换矩阵就是从切线空间到模型空间的转置矩阵
				//所以按行排列
				float3x3 rotation = float3x3(v.tangent.xyz,binormal,v.normal);//unity内置 TANGENT_SPACE_ROTATION

				o.lightDir = mul(rotation,ObjSpaceLightDir(v.vertex)).xyz;
				o.viewDir = mul(rotation,ObjSpaceViewDir(v.vertex)).xyz;

				return o;
			}

			fixed4 frag(v2f i) : SV_Target{
				fixed3 tangentLightDir = normalize(i.lightDir);
				fixed3 tangentViewDir = normalize(i.viewDir);

				//先采样
				fixed4 packedNormal = tex2D(_BumpMap,i.uv.zw);
				fixed3 tangentNormal;

				//把压缩的纹理解包得到正确的法线方向,并考虑凹凸程度
				tangentNormal = UnpackNormal(packedNormal);
				tangentNormal.xy *= _BumpScale;

				tangentNormal.z = sqrt(1-saturate(dot(tangentNormal.xy,tangentNormal.xy)));

				fixed3 albelo = tex2D(_MainTex,i.uv.xy) * _Color.rgb;
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT * albelo;

				fixed3 diffuse = albelo * _LightColor0.rgb * saturate(dot(tangentLightDir,tangentNormal));

				fixed3 halfDir = normalize(tangentViewDir+tangentLightDir);			
	
				fixed3 specular = _Specular * _LightColor0.rgb * pow(saturate(dot(tangentNormal,halfDir)),_Gloss);

				fixed3 color = ambient + diffuse + specular;

				return fixed4(color,1.0);
			}

			ENDCG
		}
	}
	FallBack "Specular"
}
