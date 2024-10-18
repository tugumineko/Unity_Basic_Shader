// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Unity Shaders Book/Chapter7/Normal Map In Tangent Space"{
	Properties{
		//����һ�ŷ������� _BumpMap (normal map), ����ͬλ�õķ��߷��򴢴�����������
		//_BumpScale�����������ư�͹�̶ȵ�
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
				//��Ҫʹ��tangent.w�������������߿ռ丱���ߵķ�����
				//a2v������ֻ�����������߿ռ�任����
				float4 tangent : TANGENT;
				float4 texcoord : TEXCOORD0;
			};

			//��Ҫ�ڶ�����ɫ���м������߿ռ��µĹ��պ��ӽǷ���
			struct v2f{
				float4 pos : SV_POSITION;
				float4 uv : TEXCOORD0;
				float3 lightDir : TEXCOORD1;
				float3 viewDir : TEXCOORD2;
			};

			v2f vert(a2v v){
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);

				o.uv.xy = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				o.uv.zw = v.texcoord.xy * _BumpMap_ST.xy + _BumpMap_ST.zw;
				
				//w������ʾ����
				float3 binormal = cross(normalize(v.normal),normalize(v.tangent.xyz))*v.tangent.w;

				//����x�ᣬ������y�ᣬ����z��
				//��ģ�Ϳռ䵽���߿ռ�ı任������Ǵ����߿ռ䵽ģ�Ϳռ��ת�þ���
				//���԰�������
				float3x3 rotation = float3x3(v.tangent.xyz,binormal,v.normal);//unity���� TANGENT_SPACE_ROTATION

				o.lightDir = mul(rotation,ObjSpaceLightDir(v.vertex)).xyz;
				o.viewDir = mul(rotation,ObjSpaceViewDir(v.vertex)).xyz;

				return o;
			}

			fixed4 frag(v2f i) : SV_Target{
				fixed3 tangentLightDir = normalize(i.lightDir);
				fixed3 tangentViewDir = normalize(i.viewDir);

				//�Ȳ���
				fixed4 packedNormal = tex2D(_BumpMap,i.uv.zw);
				fixed3 tangentNormal;

				//��ѹ�����������õ���ȷ�ķ��߷���,�����ǰ�͹�̶�
				tangentNormal = UnpackNormal(packedNormal);
				tangentNormal.xy *= _BumpScale;

				tangentNormal.z = sqrt(1-saturate(dot(tangentNormal.xy,tangentNormal.xy)));

				fixed3 albelo = tex2D(_MainTex,i.uv.xy) * _Color.rgb;
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT * albelo;

				fixed3 diffuse = albelo * _LightColor0.rgb * saturate(dot(tangentLightDir,tangentNormal));

				fixed3 halfDir = normalize(tangentViewDir+tangentLightDir);			
	
				fixed3 specular = _Specular * _LightColor0.rgb * pow(saturate(dot(tangentNormal,halfDir)),_Gloss);

				fixed3 color = ambient + diffuse + specular;

				return fixed4(color,1.0);
			}

			ENDCG
		}
	}
	FallBack "Specular"
}
