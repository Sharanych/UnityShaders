Shader "Custom/SS_SimpleToonShading"
{
	Properties {
		_Color ("Tint Color", Color) = (0, 0, 0, 1)
		_MainTex ("Main Texture", 2D) = "white" {}
		[HDR] _Emission ("Emission Color", color) = (0,0,0)
		_ToonTexture ("Toon Texture", 2D) = "white" {}
	}

	SubShader {
		Tags { "RenderType"="Opaque" "Queue"="Geometry" }

		CGPROGRAM
			#pragma surface surf Custom fullforwardshadows
			#pragma target 3.0

			sampler2D _MainTex;
			fixed4 _Color;
			half3 _Emission;
			sampler2D _ToonTexture;

			float4 LightingCustom(SurfaceOutput o, float3 lightDir, float a) {
				float shadowVec = dot(o.Normal, lightDir);
				shadowVec = shadowVec * 0.5 + 0.5;

				float3 lightIntensity = tex2D(_ToonTexture, shadowVec).rgb;
				
				float4 color;
				color.rgb = lightIntensity * o.Albedo * a * _LightColor0.rgb;
				color.a = o.Alpha;

				return color;
			}

			struct Input {
				float2 uv_MainTex;
			};

			void surf (Input i, inout SurfaceOutput o) {
				fixed4 color = tex2D(_MainTex, i.uv_MainTex);
				color *= _Color;
				o.Albedo = color.rgb;

				o.Emission = _Emission;
			}
		ENDCG
	}
	FallBack "Standard"
}
