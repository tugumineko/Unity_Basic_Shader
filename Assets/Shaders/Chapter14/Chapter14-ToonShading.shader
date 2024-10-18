// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Unity Shaders Book/Chapter 14/Toon Shading"{
	Properties{
		_Color ("Color Tint",Color) = (1,1,1,1)
		_MainTex ("Main Tex",2D) = "white" {}
		_Ramp ("Ramp Texture",2D) = "white" {}
		_Outline ("Outline",Range(0,1)) = 0.1
		_OutlineColor ("Outline Color",Color) = (0,0,0,1)
		_Specular ("Specular",Color) = (1,1,1,1)
		_SpecularScale ("Specular Scale",Range(0,0.1)) = 0.01
	}

	SubShader{
		Tags { "RenderType"="Opaque" "Queue"="Geometry"}
		
		Pass{
			NAME "OUTLINE"

			Cull Front
			
			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"

			float _Outline;
			fixed4 _OutlineColor;

			struct a2v{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
			};

			struct v2f{
				float4 pos : SV_POSITION;
			};

			v2f vert(a2v v){
				v2f o;
				float4 pos = mul(UNITY_MATRIX_MV,v.vertex);
				float3 normal = mul((float3x3)UNITY_MATRIX_IT_MV,v.normal);
				normal.z = -0.5;
				pos = pos + float4(normalize(normal),0) * _Outline;

				o.pos = mul(UNITY_MATRIX_P,pos);

				return o;
			}

			fixed4 frag(v2f i):SV_Target{
				return float4(_OutlineColor.rgb,1);
			}

			ENDCG
		}

		Pass{
			Tags {"LightMode"="ForwardBase"}

			Cull Back
			
			CGPROGRAM

			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "AutoLight.cginc"
			#include "UnityShaderVariables.cginc"

			#pragma vertex vert
			#pragma fragment frag
			
			#pragma multi_compile_fwdbase

			fixed4 _Color;
			sampler2D _MainTex;
			float4 _MainTex_ST;
			sampler2D _Ramp;
			fixed4 _Specular;
			fixed _SpecularScale;
			


			struct a2v{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float2 texcoord : TEXCOORD0;
			};

			struct v2f{
				float4 pos : SV_POSITION;
				float2 uv : TEXCOORD0;
				float3 worldNormal : TEXCOORD1;
				float3 worldPos : TEXCOORD2;
				SHADOW_COORDS(3)
			};

			v2f vert(a2v v){
				v2f o;

				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.vertex,_MainTex);
				o.worldNormal = UnityObjectToWorldNormal(v.normal);
				o.worldPos = mul(unity_ObjectToWorld,v.vertex);
				
				TRANSFER_SHADOW(o);

				return o;
			}

			fixed4 frag(v2f i):SV_Target{
				fixed3 worldNormal = normalize(i.worldNormal);
				fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
				fixed3 worldViewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));
				fixed3 halfDir = normalize(worldLightDir + worldViewDir);
				
				fixed4 c = tex2D(_MainTex,i.uv);
				fixed3 albelo = c.rgb * _Color.rgb;

				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albelo;

				UNITY_LIGHT_ATTENUATION(atten,i,i.worldPos);

				//halfLambert
				fixed diff = dot(worldNormal,worldLightDir);
				diff = (diff * 0.5 +0.5) * atten;
				
				fixed3 diffuse = _LightColor0.rgb * albelo * tex2D(_Ramp,float2(diff,diff)).rgb;

				fixed spec = dot(worldNormal,halfDir);
				fixed w = fwidth(spec) * 2.0 ;//偏导过渡
				fixed3 specular = _Specular.rgb * lerp(0,1,smoothstep(-w,w,spec + _SpecularScale - 1) ) 
									* step(0.0001,_SpecularScale);//为了在 _SpecularScale 为0时，可以完全消除高光反射的光照
				
				return fixed4(ambient + diffuse + specular,1.0);
			}
			ENDCG
		}
	
	
	}

	FallBack "Diffuse"
}