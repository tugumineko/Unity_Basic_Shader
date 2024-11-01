// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Unity Shaders Book/Chapter7/Normal Map In World Space"{
	Properties{
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
				float4 tangent : TANGENT;
				float4 texcoord : TEXCOORD0;
			};

			struct v2f{
				float4 pos : SV_POSITION;
				float4 uv : TEXCOORD0;
				//存矩阵,世界空间下的顶点位置存储在w分量上
				//注意：使用更多的插值着色器容易使表面着色器报错
				float4 TtoW0 : TEXCOORD1;
				float4 TtoW1 : TEXCOORD2;
				float4 TtoW2 : TEXCOORD3;
			};

			v2f vert(a2v v){
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);

				o.uv.xy = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				o.uv.zw = v.texcoord.xy * _BumpMap_ST.xy + _BumpMap_ST.zw;
				
				float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
				float3 worldNormal = UnityObjectToWorldNormal(v.normal);
				float3 worldTangent = UnityObjectToWorldDir(v.tangent.xyz);
				float3 worldBinormal = cross(worldNormal,worldTangent)*v.tangent.w; 

				//保存了世界空间到切线空间的矩阵，直接按列摆放即可
				o.TtoW0 = float4(worldTangent.x,worldBinormal.x,worldNormal.x,worldPos.x);
				o.TtoW1 = float4(worldTangent.y,worldBinormal.y,worldNormal.y,worldPos.y);
				o.TtoW2 = float4(worldTangent.z,worldBinormal.z,worldNormal.z,worldPos.z);

				return o;
			}

			fixed4 frag(v2f i) : SV_Target{
				
				float3 worldPos = float3(i.TtoW0.w,i.TtoW1.w,i.TtoW2.w);
				fixed3 lightDir = normalize(UnityWorldSpaceLightDir(worldPos));
				fixed3 viewDir = normalize(UnityWorldSpaceViewDir(worldPos));

				fixed3 bump = UnpackNormal(tex2D(_BumpMap,i.uv.zw));
				bump.xy *= _BumpScale;
				bump.z = sqrt(1-saturate(dot(bump.xy, bump.xy)));

				//矩阵乘法
				bump = normalize(half3(dot(i.TtoW0.xyz,bump),dot(i.TtoW1.xyz,bump),dot(i.TtoW2.xyz,bump)));

				fixed3 albelo = tex2D(_MainTex,i.uv.xy) * _Color.rgb;
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT * albelo;

				fixed3 diffuse = albelo * _LightColor0.rgb * saturate(dot(lightDir,bump));

				fixed3 halfDir = normalize(viewDir+lightDir);			
	
				fixed3 specular = _Specular * _LightColor0.rgb * pow(saturate(dot(bump,halfDir)),_Gloss);

				fixed3 color = ambient + diffuse + specular;

				return fixed4(color,1.0);
			}

			ENDCG
		}
	}
	FallBack "Specular"
}
