// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Environment/Cloud Sea"{
	Properties{
		_MainTex("Cloud",2D) = "white"{}
		_Color ("Tint Color",Color) = (0,0,0,0)
		_Height("Height",Range(0,3)) =  1 //�����Ƶİ�͹�̶�
		_HeightAmount ("Height Amount",Range(0,3)) = 1
		_HeightTileSpeed ("Height Tile Speed",Vector4) = (1,1,1,1)
		_HeightFogColor ("Height Fog Color",Color) = (1,1,1,1)
	}
	SubShader{

		Pass{

			Tags {"Lighting" = "ForwardBase"}

			CGPROGRAM
			
			#include "UnityCG.cginc"
			#include "AutoLight.cginc"
			#include "Lighting.cginc"

			#pragma multi_compile_fwdbase
			#pragma vertex vert 
			#pragma fragment frag 
			#pragma multi_compile_fog 

			sampler2D _MainTex;
			float4 _MainTex_ST;
			float4 _HeightTileSpeed;

			struct v2f{
				float4 pos : SV_POSITION;
				float4 uv : TEXCOORD0;//�߶Ⱥ���ɫ��ͼ��uv
				float2 uv2 : TEXCOORD1;//���Ŷ��õ�uv
				float3 worldNormal : TEXCOORD2;
				float4 worldPos : TEXCOORD3;
				float3 tangentView : TEXCOORD4;//���߿ռ��µ�����
				fixed4 color : TEXCOORD5;
				UNITY_FOG_COORDS(7)
			};

			v2f vert(appdata_full v){
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);

				o.uv =  TRANSFORM_TEX(v.texcoord,_MainTex) + frac(_Time.y * _HeightTileSpeed.zw);
				o.uv2 = v.texcoord * _HeightTileSpeed.xy;
				o.worldPos = mul(unity_ObjectToWorld,v.vertex);
				o.worldNormal = UnityObjectToWorldNormal(v.normal);
				TANGENT_SPACE_ROTATION;
				o.tangentView = mul(rotation,ObjSpaceViewDir(v.vertex));
				o.color = v.color;
			#if USING_FOG
				HeightFog(o.worldPos.xyz,o.fog);
			#endif 
				UNITY_TRANSFER_FOG(o,o.fog);
				return o;
			}

			fixed4 frag(v2f i):SV_Target{
				float3 viewRay = normalize(-i.tangentView);
				viewRay.z = abs(viewRay.z) + 0.42; //trick ��ֹ V N �нǹ���
				viewRay.xy *= _Height;
				
				float3 shadeP = float3(i.uv,0); //xy �ǲ���uv , z ��¼���
				float3 shadeP2 = float3(i.uv2,0);//xy��¼�Ŷ�uv2
				
				//RPM �õ�����ǰ�������Ȼ����ֲ���

				const int linearStep = 2;
				const int binaryStep = 5;
				//T ָ���
				float4 T = tex2D(_MainTex,shaderP2.xy);
				float h2 = T.a + _HeightAmount;

				//lineat search
				float3 lioffset = viewRay / (viewRay.z * (linearStep +1));//�ֲ�
				for(int k=0;k<linearStep;k++)
				{
				//tex2Dlod ��ʽ����mipmap
					float d = 1.0 - tex2Dlod(_MainTex,float4(shadeP.xy,0,0)).a * h2;//��ת ���߶�ת�������
					shadeP += lioffset * step(shadeP.z,d);
				}
				//binary search
				float3 biOffset = lioffset;
				for(int j=0;j<binaryStep;j++){
					biOffset = biOffset * 0.5;
					float d = 1.0 - tex2Dlod(_MainTex,float4(ShadeP.xy,0,0)).a * h2;
					shadeP += biOffset * sign(d -  shadeP.z);
				}
				
				//end RPM

				fixed4 c = tex2D(_MainTex,shadeP.xy) * T * _Color; 
				fixed Alpha = i.color.r;
				fixed3 worldNormal = normalize(i.worldNormal);
				fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));

				fixed NdotL = saturate(dot(worldNormal,worldLightDir));

				#if USING_FOG
					fixed3 viewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));
					fixed sunFog =  saturate(dot(-viewDir,lightDir));
					half3 sunFogColor = lerp(_HeightFogColor,_sunFogColor,pow(sunFog,2));
					fixed3 finalColor = c.rgb * (NdotL * _LightColor0 + unity_AmbientEquator.rgb * sunFogColor * _LightIntensity);
				  unity_FogColor.rgb = lerp(sunFogColor,unity_FogColor.rgb,i.fog.y * i.fog.y);
				  finalColor.rgb = lerp(finalColor.rgb,unity_FogColor.rgb,i.fog.x);
				#else
					fixed3 finalColor = c.rgb * (NdotL * _LightColor0 + unity_AmbientEquator.rgb);
				#endif 
				UNITY_APPLY_FOG(i.fogCoord,finalColor);

				return fixed4(finalColor,Alpha);

			};


			ENDCG
		
		
		
		
		
		
		}
	
	
	
	
	
	}

	FallBack Off

}