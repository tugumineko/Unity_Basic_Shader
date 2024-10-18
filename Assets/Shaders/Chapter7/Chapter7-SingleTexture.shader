// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Unity Shaders Book/Chapter 7/Single Texture"{
	Properties{
		//纹理渲染需要一个底色和纹理
		_Color ("Color Tint",Color)	=(1,1,1,1)
		_MainTex ("Main Tex",2D) = "white" {}
		_Specular ("Specular",Color) = (1,1,1,1)
		_Gloss ("Gloss",Range(8.0,256)) = 20
	}
	SubShader{
	Pass{
		Tags {"LightMode"="ForwardBase"}

		CGPROGRAM
		#pragma vertex vert
		#pragma fragment frag
		
		#include "Lighting.cginc"

		fixed4 _Color;
		sampler2D _MainTex;
		//使用 纹理名_ST 得到某个纹理的属性，其中xy表示缩放，zw表示平移
		float4 _MainTex_ST;
		fixed4 _Specular;
		float _Gloss;

		struct a2v{
			//texcoord是输入的纹理样式，xy表示坐标。
			float4 vertex : POSITION;
			float3 normal : NORMAL;
			float4 texcoord : TEXCOORD0;
		};

		struct v2f{
			float4 pos : SV_POSITION;
			float3 worldNormal : TEXCOORD0;
			float3 worldPos : TEXCOORD1;
			float2 uv : TEXCOORD2;
		};
		
		v2f vert(a2v v){
			v2f o;
			o.pos = UnityObjectToClipPos(v.vertex);
			
			o.worldNormal = UnityObjectToWorldNormal(v.normal);
			o.worldPos = mul(unity_ObjectToWorld,v.vertex).xyz;

			//我们通过unity自己的输入，经过第一步处理得到模型空间下的纹理坐标
			o.uv = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
			//o.uv = TRAMSFORM_TEX(v.texcoord, _MainTex);
		
			return o;
		}

		fixed4 frag(v2f i): SV_Target{
			fixed3 worldNormal = normalize(i.worldNormal);

			//不一定单个光源，所以要用UnityWorldSpaceLightDir
			fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));

			//对纹理进行采样，获得 rgb 信息
			fixed3 albelo = tex2D(_MainTex,i.uv).rgb * _Color.rgb;

			fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT * albelo;

			fixed3 diffuse = albelo * _LightColor0.rgb * saturate(dot(worldNormal,worldLightDir));
			
			fixed3 viewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));

			fixed3 halfDir = normalize(viewDir + worldLightDir);

			fixed3 specular = _Specular * _LightColor0.rgb * pow(saturate(dot(worldNormal,halfDir)),_Gloss);
		
			fixed3 color = ambient + diffuse + specular;

			return fixed4(color,1.0);
		}

		ENDCG
	}
	
	
	}
	FallBack "Specular"

}