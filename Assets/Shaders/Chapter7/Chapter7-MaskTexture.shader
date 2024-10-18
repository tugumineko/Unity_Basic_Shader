// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Unity Shaders Book/Chapter 7/Mask Texture"{
	Properties{
		_Color ("Color Tint",Color) = (1,1,1,1)
		_MainTex ("Main Tex",2D) = "white" {}
		_BumpMap ("Bump Map",2D) = "bump" {}
		_BumpScale ("Bump Scale",Float) = 1.0
		_SpecularMask ("Specular Mask",2D) = "white" {}
		_SpecularScale ("Specular Scale",Float) = 1.0
		_Specular ("Specular",Color) = (1,1,1,1)
		_Gloss ("Gloss",Range(8.0,256))=20
	}
	SubShader{
		Pass{
			Tags {"LightMode"="ForwardBase"}

			CGPROGRAM 

			#pragma vertex vert
			#pragma fragment frag

			#include "Lighting.cginc"

			float4 _Color;
			float4 _Specular;

			//共用一个 _MainTex_ST ,节省插值寄存器
			sampler2D _MainTex;
			float4 _MainTex_ST;
			sampler2D _BumpMap;
			sampler2D _SpecularMask;
			
			float _BumpScale;
			float _SpecularScale;
			float _Gloss;


			struct a2v{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float4 tangent : TANGENT;
				float4 texcoord : TEXCOORD0;
			};

			struct v2f{
				float4 pos : SV_POSITION;
				float2 uv : TEXCOORD0;
				float3 lightDir : TEXCOORD1;
				float3 viewDir : TEXCOORD2;
			};

			v2f vert(a2v v){
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv.xy = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;

				float3 binormal = cross(normalize(v.normal),normalize(v.tangent.xyz))* v.tangent.w;
				float3x3 rotation = float3x3(v.tangent.xyz,binormal,v.normal);
				o.lightDir = mul(rotation,ObjSpaceLightDir(v.vertex));
				o.viewDir = mul(rotation,ObjSpaceLightDir(v.vertex));

				return o;
			}

			fixed4 frag(v2f i):SV_Target{
				fixed3 tangentLightDir = normalize(i.lightDir);
				fixed3 tangentViewDir = normalize(i.viewDir);

				fixed4 packedNormal = tex2D(_BumpMap,i.uv);
				fixed3 tangentNormal;

				//tangentNormal不需要normalize
				tangentNormal = UnpackNormal(packedNormal);
				tangentNormal.xy *= _BumpScale;
				tangentNormal.z = sqrt(1-dot(tangentNormal.xy , tangentNormal.xy));

				fixed3 albelo = tex2D(_MainTex,i.uv.xy) * _Color;

				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albelo;

				fixed3 diffuse = _LightColor0.rgb * albelo * saturate(dot(tangentNormal,tangentLightDir));
				
				fixed3 halfDir = normalize(tangentViewDir + tangentLightDir);

				//只用一个通道
				fixed specularMask = tex2D(_SpecularMask,i.uv).r * _SpecularScale;

				fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(tangentNormal,halfDir)),_Gloss) * specularMask;
				
				return fixed4(ambient + diffuse + specular ,1.0) ;
			}


			ENDCG
		}
		}

	FallBack "Specular"
}