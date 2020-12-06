Shader "Custom/Surface/TextureMix"
{
    Properties 
	{
		_SplatTex("Splat Map", 2D) = "white" {}
		
		[NoScaleOffset] _RTex ("R", 2D) = "white" {}
		[NoScaleOffset] _GTex ("G", 2D) = "white" {}
		[NoScaleOffset] _BTex ("B", 2D) = "white" {}
		[NoScaleOffset] _ATex ("A", 2D) = "white" {}
	}

	SubShader 
	{
		Pass 
		{
			CGPROGRAM

			#pragma vertex Vertex
			#pragma fragment Fragment

			#include "UnityCG.cginc"

			sampler2D _SplatTex;
			float4 _SplatTex_ST;
			sampler2D _RTex;
			sampler2D _GTex;
			sampler2D _BTex;
			sampler2D _ATex;

			struct Interpolators
			{
				float4 position : SV_POSITION;
				float2 uv_splat : TEXCOORD0;
				float2 uv_tex : TEXCOORD1;
			};

			struct VertexData
			{
				float4 position : POSITION;
				float2 uv : TEXCOORD0;
			};

			Interpolators Vertex(VertexData v)
			{
				Interpolators i;
				i.position = UnityObjectToClipPos(v.position);
				i.uv_splat = v.uv;
				// tilling
				i.uv_tex = v.uv * _SplatTex_ST.xy + _SplatTex_ST.zw;
				
				return i;
			}

			float4 Fragment(Interpolators i) : SV_TARGET
			{
				float4 splat = tex2D(_SplatTex,i.uv_splat);
				float4 color = tex2D(_RTex,i.uv_tex) * splat.r +
							   tex2D(_GTex,i.uv_tex) * splat.g +
							   tex2D(_BTex,i.uv_tex) * splat.b +
							   tex2D(_ATex,i.uv_tex) * (1 - (splat.r + splat.g + splat.b));
				
				return color;
			}

			ENDCG
		}
	}
}
