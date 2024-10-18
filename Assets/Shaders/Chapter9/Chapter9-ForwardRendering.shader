// Upgrade NOTE: replaced '_LightMatrix0' with 'unity_WorldToLight'

// Upgrade NOTE: replaced '_LightMatrix0' with 'unity_WorldToLight'

// Upgrade NOTE: replaced '_LightMatrix0' with 'unity_WorldToLight'
// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Unity Shaders Book/Chapter 9/Forward Rendering"{
	Properties{
		_Diffuse ("Diffuse",Color) = (1,1,1,1)
		_Specular ("Specular",Color) = (1,1,1,1)
		_Gloss ("Gloss",Range(8.0,256)) = 20
	}
	SubShader{
		Pass{
			//Base Pass需要#pragma multi_compile_fwdbase,其他不变
			Tags {"LightMode"= "ForwardBase"}

			CGPROGRAM

			#pragma multi_compile_fwdbase

			#include "Lighting.cginc"
			

			#pragma vertex vert
			#pragma fragment frag
			
			fixed4 _Diffuse;
			fixed4 _Specular;
			float _Gloss;

			struct a2v{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
			};

			struct v2f{
				float4 pos : SV_POSITION;
				float3 worldNormal : TEXCOORD0;
				float4 worldPos : TEXCOORD1;
			};

			v2f vert (a2v v){
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.worldNormal = UnityObjectToWorldNormal(v.normal);
				o.worldPos = mul(unity_ObjectToWorld,v.vertex);

				return o;
			}

			fixed4 frag(v2f i):SV_Target{
				fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos.xyz));
				fixed3 worldNormal = normalize(i.worldNormal);

				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

				fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(worldNormal,worldLightDir));

				fixed3 worldViewDir = normalize(UnityWorldSpaceViewDir(i.worldPos.xyz));
				fixed3 halfDir = normalize(worldLightDir + worldViewDir); 	
				
				fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(worldNormal,halfDir)),_Gloss);
				
				fixed atten = 1.0;

				return fixed4((ambient + diffuse + specular)*atten,1.0);
			}

			ENDCG
					
		}
		
		Pass{
			//Additional Pass需要更改LightMode
			Tags {"LightMode"="ForwardAdd"}

			//Additional Pass可以在帧缓存中与之前的光照结果相叠加
			Blend One One

			CGPROGRAM
		
			#pragma multi_compile_fwdadd
			
			#include "Lighting.cginc"
			#include "AutoLight.cginc"
			#pragma vertex vert
			#pragma fragment frag
			
			fixed4 _Diffuse;
			fixed4 _Specular;
			float _Gloss;

			struct a2v{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
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
				o.worldPos = mul(unity_ObjectToWorld,v.vertex);

				return o;
			}

			fixed4 frag(v2f i):SV_Target{
				
				#ifdef USING_DIRECTIONAL_LIGHT
					fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);
				#else
					fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz - i.worldPos.xyz);
				#endif

				fixed3 worldNormal = normalize(i.worldNormal);


				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

				fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(worldNormal,worldLightDir));

				fixed3 worldViewDir = normalize(UnityWorldSpaceViewDir(i.worldPos.xyz));
				fixed3 halfDir = normalize(worldLightDir + worldViewDir); 	
				
				fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(worldNormal,halfDir)),_Gloss);
				
				//计算光照衰减，为节省资源，使用衰减纹理的平方进行采样
				#if defined (POINT)
					float3 lightCoord = mul(unity_WorldToLight, float4(i.worldPos, 1)).xyz;
					fixed atten = tex2D(_LightTexture0, dot(lightCoord, lightCoord).rr).UNITY_ATTEN_CHANNEL;
				#elif defined (SPOT)
					float4 lightCoord = mul(unity_WorldToLight, float4(i.worldPos, 1));
					fixed atten = (lightCoord.z > 0) * tex2D(_LightTexture0, lightCoord.xy / lightCoord.w + 0.5).w * tex2D(_LightTextureB0, dot(lightCoord, lightCoord).rr).UNITY_ATTEN_CHANNEL;
				#else
					fixed atten = 1.0;
				#endif

				return fixed4((ambient + diffuse + specular)*atten,1.0);
			}
			ENDCG
		
		
		}
	
	}

	FallBack "Specular"



}
