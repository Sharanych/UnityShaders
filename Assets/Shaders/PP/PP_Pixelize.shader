Shader "Custom/Post Process/Pixelize"
{
    Properties
    {
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
    }

    SubShader
    {
        Cull Off 
        ZWrite Off 
        ZTest Always

        Pass 
        {
            CGPROGRAM

            #pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
			};

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				
				return o;
			}

            sampler2D _MainTex;

            float3 frag (v2f i) : SV_Target
            {
                float nx = 200.0;
				float ny = 200.0;

                float2 pos;

                pos.x = floor(i.uv.x * nx) / nx;
                pos.y = floor(i.uv.y * ny) / ny;

                return tex2D(_MainTex, pos);
            }

            ENDCG
        }
    }
    FallBack "Diffuse"
}
