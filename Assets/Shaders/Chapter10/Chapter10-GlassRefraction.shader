// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Unity Shaders Book/Chapter 10/Glass Refraction"{
	Properties{
		_MainTex ("Main Tex", 2D) = "white" {}
		_BumpMap ("Normal Map",2D) = "white" {}
		//用于模拟反射的环境纹理
		_CubeMap ("Environment Cubemap",Cube) = "_Skybox" {}
		//控制模拟折射的扭曲程度
		_Distortion ("Distortion",Range(0,100)) = 10
		//折射率，数值为0时，只有反射
		_RefractAmount ("Refraction Amount", Range(0.0,1.0)) = 1.0
	}
	SubShader{
		
		Tags {"Queue"="Transparent" "RenderType" = "Opaque"}
		
		//抓取屏幕后面的图像存入 RefractionTex 纹理中
		GrabPass {"_RefractionTex"}

		Pass{
		
		CGPROGRAM
		
		#include "Lighting.cginc"
		#include "AutoLight.cginc"

		#pragma vertex vert
		#pragma fragment frag

		sampler2D _MainTex;
		float4 _MainTex_ST;
		sampler2D _BumpMap;
		float4 _BumpMap_ST;

		samplerCUBE _CubeMap;
		
		float _Distortion;
		fixed _RefractAmount;

		sampler2D _RefractionTex;
		float4 _RefractionTex_TexelSize;

		struct a2v {
			float4 vertex : POSITION;
			float3 normal : NORMAL;
			float4 tangent : TANGENT; //w分量存储方向
			float4 texcoord : TEXCOORD0;
		};

		//法线纹理存储在切线空间
		struct v2f{
			float4 pos : SV_POSITION;
			float4 scrPos : TEXCOORD0;
			float4 uv : TEXCOORD1;
			float4 TtoW0 : TEXCOORD2;
			float4 TtoW1 : TEXCOORD3;
			float4 TtoW2 : TEXCOORD4;
		};

		v2f vert(a2v v){
			v2f o;
			o.pos = UnityObjectToClipPos(v.vertex);
			
			//得到对应被抓取的屏幕图像的采样坐标
			o.scrPos = ComputeGrabScreenPos(o.pos);

			o.uv.xy = TRANSFORM_TEX(v.texcoord,_MainTex);
			o.uv.zw = TRANSFORM_TEX(v.texcoord,_BumpMap);

			float3 worldPos = mul(unity_ObjectToWorld,v.vertex).xyz;
			float3 worldNormal = UnityObjectToWorldNormal(v.normal);
			float3 worldTangent = UnityObjectToWorldDir(v.tangent.xyz) * v.tangent.w;
			float3 worldBinormal = cross(worldNormal,worldTangent) * v.tangent.w;

			//计算从切线空间到世界空间的转置矩阵
			o.TtoW0 = float4(worldTangent.x,worldBinormal.x,worldNormal.x,worldPos.x);
			o.TtoW1 = float4(worldTangent.y,worldBinormal.y,worldNormal.y,worldPos.y);
			o.TtoW2 = float4(worldTangent.z,worldBinormal.z,worldNormal.z,worldPos.z);

			return o;
		}

		fixed4 frag(v2f i):SV_Target{

			float3 worldPos = float3(i.TtoW0.w,i.TtoW1.w,i.TtoW2.w);
			float3 worldViewDir = UnityWorldSpaceViewDir(worldPos);

			fixed3 bump = UnpackNormal(tex2D(_BumpMap,i.uv.zw));

			//对屏幕图像的采样坐标进行偏移，模拟折射效果
			float2 offset = bump.xy * _Distortion * _RefractionTex_TexelSize.xy;
			i.scrPos.xy = offset + i.scrPos.xy;
			//偏移后再采样
			fixed3 refrCol = tex2D(_RefractionTex,i.scrPos.xy/i.scrPos.w).rgb;

			bump = normalize(half3(dot(i.TtoW0.xyz,bump),dot(i.TtoW1.xyz,bump),dot(i.TtoW2,bump)));

			//反射先求出方向，对其采样后再乘以底色
			fixed3 reflDir = reflect(-worldViewDir,bump);
			fixed4 texColor = tex2D(_MainTex,i.uv.xy);
			fixed3 reflCol = texCUBE(_CubeMap,reflDir).rgb * texColor.rgb;

			//最后才考虑折射率，即折射在最终颜色中所占的比例
			fixed3 finalColor = reflCol * (1-_RefractAmount) + refrCol * _RefractAmount;

			return fixed4(finalColor,1.0);
		}

		ENDCG
		
		}
	
	}

}