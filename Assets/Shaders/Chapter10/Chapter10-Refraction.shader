// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Unity Shaders Book/Chapter 10/Refraction"{
	Properties{
		_Color ("Color Tint",Color) = (1,1,1,1)
		_RefractColor ("Refraction Color",Color) = (1,1,1,1)
		_RefractAmount ("Refraction Amount",Range(0,1)) = 1
		_RefractRatio ("Refraction Ratio",Range(0.1,1)) = 0.5
		_Cubemap ("Refraction Cubemap",Cube) = "_Skybox" {}
	}
	SubShader{
	Pass{
		Tags {"LightMode"="ForwardBase"}

		CGPROGRAM

		fixed4 _Color;
		fixed4 _RefractColor;
		fixed _RefractAmount;
		fixed _RefractRatio;
		samplerCUBE _Cubemap;

		#include "Lighting.cginc"
		#include "AutoLight.cginc"


		#pragma vertex vert
		#pragma fragment frag
		
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
			o.worldPos = mul(unity_ObjectToWorld,v.vertex);
			TRANSFER_SHADOW(o);
			
			return o;
		}

		fixed4 frag(v2f i):SV_Target{
			fixed3 worldNormal = normalize(i.worldNormal);
			fixed3 worldPos = normalize(i.worldPos);
			fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
			fixed3 worldViewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));
			fixed3 worldRefr = refract(-worldViewDir,worldNormal,_RefractRatio);

			fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
			
			fixed3 diffuse = _LightColor0 * _Color *saturate(dot(worldNormal,worldLightDir));

			fixed3 refraction = texCUBE(_Cubemap,worldRefr).rgb * _RefractColor;

			UNITY_LIGHT_ATTENUATION(atten,i,i.worldPos);
			
			fixed3 color = ambient + lerp(diffuse , refraction , _RefractAmount) *atten;
			
			return fixed4(color , 1.0);
		}

		ENDCG
	
	}
	}
	FallBack "Diffuse"

}