// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Unity Shaders Book/Chapter 5/Simple Shader"{
	Properties{
		_Color ("Color Tint", Color) = (1.0,1.0,1.0,1.0)
	}
		
	SubShader{
		Pass{
			CGPROGRAM

			//ʹ��vert��Ϊ������ɫ��
			//ʹ��frag��ΪƬԪ��ɫ��
			#pragma vertex vert
			#pragma fragment frag

			fixed4 _Color;

			//ʹ�ýṹ�������嶥����ɫ��������
			//application to vertex : ��Ӧ�ý׶δ��ݵ�������ɫ����
			struct a2v{
				float4 vertex : POSITION;  //����ͽṹ��Ԫ���𵽶�Ӧ����
				//����Ӳ��ʵ� Mesh Render����ṩ 
				float3 normal : NORMAL;
				float4 texcoord : TEXCOORD0;//0��ʾģ�͵ĵ�һ������
			};

			//ʹ�ýṹ�嶨�嶥����ɫ�������
			//vertex to fragment : �Ӷ�����ɫ�����ݵ�ƬԪ��ɫ����
			struct v2f{
				//������ɫ��������������SV_POSITION
				float4 pos : SV_POSITION; 
				fixed3 color : COLOR0;
			};

			//unity��POSITION���룬�õ�SV_POSITION���
			v2f vert(a2v v) {
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				//���ݷ��߷���-1��1��-->(0,1)
				o.color = v.normal * 0.5 + fixed3(0.5,0.5,0.5);
				return o;
			}
			//unity�������룬�õ�SV_Target���
			fixed4 frag(v2f i) : SV_Target{
				fixed3 c = i.color;
				c *= _Color.rgb;
				//fixed�;���������ɫ�ϱ�ʾRGBA[0,1]���ռ��ϱ�ʾXYZW
				return fixed4(c,1.0);
			}

 			ENDCG
		}
	}
}