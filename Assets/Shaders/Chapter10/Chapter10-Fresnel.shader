// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Unity Shaders Book/Chapter 10/Fresnel" {
	//利用反射方向采样立方体纹理 _Skybox 即可 

	Properties{
		_Color ("Color Tint",Color) = (1,1,1,1)
		_ReflectColor ("Reflect Color",Color) = (1,1,1,1)
		_FresnelScale ("Fresnel Scale",Range(0,1)) = 0.5
		_Cubemap ("Reflection Cubemap",Cube) = "_Skybox" {}
	}
	SubShader{
		Pass{
			Tags {"LightMode"="ForwardBase"}

			CGPROGRAM

			#include "Lighting.cginc"
			#include "AutoLight.cginc"
			
			#pragma vertex vert
			#pragma fragment frag
		
			fixed4 _Color;
			fixed4 _ReflectColor;
			fixed _FresnelScale;
			samplerCUBE _Cubemap;


			struct a2v{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
			};

			struct v2f{
				float4 pos : SV_POSITION;
				float3 worldNormal : TEXCOORD0;
				float3 worldPos : TEXCOORD1;
				SHADOW_COORDS(2)
			};

			v2f vert(a2v v){
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.worldNormal = UnityObjectToWorldNormal(v.normal);
				o.worldPos = mul(unity_ObjectToWorld,v.vertex).xyz;
				TRANSFER_SHADOW(o);
				return o;
			}

			fixed4 frag(v2f i):SV_Target{
				fixed3 worldNormal = normalize(i.worldNormal);
				fixed3 worldPos = normalize(i.worldPos);
				fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
				fixed3 worldViewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));
				fixed3 worldRefl = reflect(-worldViewDir,worldNormal);
				
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
				
				fixed3 diffuse = _Color * _LightColor0 * saturate(dot(worldNormal,worldLightDir));


				//将反射光作为采样方向
				fixed3 reflection = texCUBE(_Cubemap,worldRefl).rgb * _ReflectColor.rgb;

				UNITY_LIGHT_ATTENUATION(atten,i,i.worldPos);

				fixed fresnel = _FresnelScale + (1- _FresnelScale) * pow(1-dot(worldViewDir,worldNormal),5);

				fixed3 color = (ambient + lerp(diffuse,reflection,saturate(fresnel)))*atten;

				return fixed4(color,1.0);
			}

			ENDCG
		}
	
	}
	FallBack "Diffuse"
}