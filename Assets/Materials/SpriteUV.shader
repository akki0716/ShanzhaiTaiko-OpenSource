Shader "Sprite/SpriteUV"
{
	Properties
	{
		//��������
		[PerRendererData] _MainTex("Sprite Texture", 2D) = "white" {}
		//UV�ƶ�����_X��
		AnimatedOffsetUV_X_1("AnimatedOffsetUV_X_1", Range(-1, 1)) = 0.211
		//UV�ƶ�����_Y��
		AnimatedOffsetUV_Y_1("AnimatedOffsetUV_Y_1", Range(-1, 1)) = 0.211
		//UV�ƶ�����_UV����
		AnimatedOffsetUV_ZoomX_1("AnimatedOffsetUV_ZoomX_1", Range(1, 30)) = 2.205
		//UV�ƶ�����_UV����
		AnimatedOffsetUV_ZoomY_1("AnimatedOffsetUV_ZoomY_1", Range(1, 10)) = 2.591
		//UV��ֵ
		_LerpUV_Fade_1("_LerpUV_Fade_1", Range(0, 1)) = 1
		//UV����
		_SpriteFade("SpriteFade", Range(0, 1)) = 1.0

		// required for UI.Mask
		[HideInInspector]_StencilComp("Stencil Comparison", Float) = 8
		[HideInInspector]_Stencil("Stencil ID", Float) = 0
		[HideInInspector]_StencilOp("Stencil Operation", Float) = 0
		[HideInInspector]_StencilWriteMask("Stencil Write Mask", Float) = 255
		[HideInInspector]_StencilReadMask("Stencil Read Mask", Float) = 255
		[HideInInspector]_ColorMask("Color Mask", Float) = 15

	}

	SubShader
	{
		//��Ⱦ����=͸��ͨ��             ����ͶӰ                    ��Ⱦ����                    Ԥ������=ƽ��     ����ʹ�þ���ͼ��
		Tags {"Queue" = "Transparent" "IgnoreProjector" = "true" "RenderType" = "Transparent" "PreviewType" = "Plane" "CanUseSpriteAtlas" = "True" }

		ZWrite Off//��ȼ��ر�
		Blend SrcAlpha OneMinusSrcAlpha//���Ч����͸�����
		Cull Off//�����޳��ر�

		// required for UI.Mask
		Stencil
		{
			Ref[_Stencil]
			Comp[_StencilComp]
			Pass[_StencilOp]
			ReadMask[_StencilReadMask]
			WriteMask[_StencilWriteMask]
		}

		Pass
		{

			CGPROGRAM
			//����������ɫ������
			#pragma vertex vert
			//����ƬԪ��ɫ������
			#pragma fragment frag
			//ʹ�õ;���
			#pragma fragmentoption ARB_precision_hint_fastest
			#include "UnityCG.cginc"

			//������ɫ������ṹ��
			struct appdata_t {
				float4 vertex   : POSITION;//����λ����Ϣ
				float4 color    : COLOR;//��ɫ��Ϣ
				float2 texcoord : TEXCOORD0;//�������꼯
			};
			//ƬԪ��ɫ������ṹ��
			struct v2f
			{
				float2 texcoord  : TEXCOORD0;//�������꼯
				float4 vertex   : SV_POSITION;//��Ļ����ϵ��λ����Ϣ
				float4 color    : COLOR;//��ɫ��Ϣ
			};

			//��Ӧ�����������������
			sampler2D _MainTex;
			float _SpriteFade;
			float AnimatedOffsetUV_X_1;
			float AnimatedOffsetUV_Y_1;
			float AnimatedOffsetUV_ZoomX_1;
			float AnimatedOffsetUV_ZoomY_1;
			float _LerpUV_Fade_1;

			//������ɫ������
			v2f vert(appdata_t IN)
			{
				v2f OUT;
				OUT.vertex = UnityObjectToClipPos(IN.vertex);
				OUT.texcoord = IN.texcoord;
				OUT.color = IN.color;
				return OUT;
			}

			//New!  UVƫ������չ����   UV      X���ϵ�ƫ�ƶ� Y��ƫ�ƶ�       UV����        UV����        �ƶ��ٶ�
			float2 AnimatedOffsetUV(float2 uv, float offsetx, float offsety, float zoomx, float zoomy)
			{
				uv += float2(offsetx, offsety);//�����ؽ���ƫ�ƣ�(������ԭ�е�λ����λ�Ƶ��µ�����λ��)
				/*������������������������������������������
					uv *= float2(zoomx, zoomy);//����UV��չ����������
					uv = fmod(uv,1);//�ٶ�UV����ȡ�ദ����֤�õ�UV��ʾ����
				���������չ����������������������������������*/
				uv = fmod(uv * float2(zoomx, zoomy), 1);
				return uv;
			}
			float4 frag(v2f i) : COLOR
			{
				//UVƫ������չ����
				float2 AnimatedOffsetUV_1 = AnimatedOffsetUV(i.texcoord,AnimatedOffsetUV_X_1,AnimatedOffsetUV_Y_1,AnimatedOffsetUV_ZoomX_1,AnimatedOffsetUV_ZoomY_1);
				//��ֵ����(�õڶ���UV�ӽ��ڵ�һ��UV)
				i.texcoord = lerp(i.texcoord,AnimatedOffsetUV_1,_LerpUV_Fade_1);

				//��������в���
				float4 _MainTex_1 = tex2D(_MainTex,i.texcoord);
				//���յ�������
				float4 FinalResult = _MainTex_1;
				FinalResult.rgb *= i.color.rgb;
				//��͸��ͨ�����н�������(���Խ�������)
				FinalResult.a = FinalResult.a * _SpriteFade * i.color.a;

				return FinalResult;
			}

			ENDCG
		}
	}
	Fallback "Sprites/Default"
}