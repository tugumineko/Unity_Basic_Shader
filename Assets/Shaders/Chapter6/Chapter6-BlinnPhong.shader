// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Unity Shader Book/Chapter 6/Blinn-Phong"{
	Properties{
		_Diffuse ("Diffuse",Color) = (1,1,1,1)
		_Specular ("Specular",Color) = (1,1,1,1)
		_Gloss ("Gloss",Range(8.0,256)) = 20 
	}
	SubShader{
	Pass{
		Tags { "LightMode"="ForwardBase" }
	
		CGPROGRAM

		#pragma vertex vert
		#pragma fragment frag
		
		#include "Lighting.cginc"

		//为了在Shader中使用Properties语义块中声明的属性
		fixed4 _Diffuse;
		fixed4 _Specular;
		float _Gloss;

		struct a2v{
			float4 vertex:POSITION;
			float3 normal:NORMAL;
		};

		struct v2f{
			float4 pos : SV_POSITION;
			float3 worldNormal : TEXCOORD0;
			float3 worldPos : TEXCOORD1;
		};

		v2f vert (a2v v){
			v2f o;
			o.pos = UnityObjectToClipPos(v.vertex);
			o.worldNormal = UnityObjectToWorldNormal(v.normal);
			o.worldPos = mul(unity_ObjectToWorld,v.vertex).xyz;
			return o;
		}

		fixed4 frag (v2f i):SV_target{
			 fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

			 fixed3 worldNormal = normalize(i.worldNormal);

			 fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));

			 fixed3 diffuse = _LightColor0.xyz * _Diffuse.rgb * saturate(dot(worldNormal,worldLightDir));

			 //fixed3 reflectDir = normalize(reflect(-worldLightDir,worldNormal));

			 fixed3 viewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));

			 fixed3 halfDir = normalize(worldLightDir + viewDir);

			 fixed3 specular = _LightColor0.xyz * _Specular.rgb * pow(saturate(dot(halfDir,worldNormal)),_Gloss);

			 fixed3 color = ambient + diffuse + specular;

			 return fixed4(color,1.0);
		}
		
		ENDCG
	}
	}
	
	FallBack "Specular"
}
