Shader "Custom/SS_FresnelEffect"
{
    Properties {
        _Color ("Tint", Color) = (0,0,0,1)
        _MainTex ("Texture", 2D) = "white" {}
        _Smoothness ("Smoothness", Range(0,1)) = 0
        _Metallic ("Metalness", Range(0,1)) = 0 
        [HDR] _Emission ("Emission", color) = (0,0,0)
        _FresnelColor ("Fresnel color", color) = (1,1,1,1)
        [PowerSlider(5)] _FresnelExp ("Fresnel Exponent", Range(0.1, 5)) = 1
    }

    SubShader {
        Tags { "RenderType" = "Opaque" "Queue" = "Geometry" }

        CGPROGRAM
            #pragma surface surf Standard fullforwardshadows
            #pragma target 5.0

            sampler2D _MainTex;
            fixed4 _Color;
            half _Smoothness;
            half _Metallic;
            half3 _Emission;
            float4 _FresnelColor;
            float _FresnelExp;

            struct Input {
                float2 uv_MainTex;
                float3 worldNormal;
                float3 viewDir;
                INTERNAL_DATA
            };

            void surf (Input i, inout SurfaceOutputStandard o) {
                fixed4 color = tex2D(_MainTex, i.uv_MainTex);
                color *= _Color;

                o.Albedo = color.rgb;
                o.Metallic = _Metallic;
                o.Smoothness = _Smoothness;

                float fr = dot(i.worldNormal, i.viewDir);
                fr = saturate(1-fr);
                fr = pow(fr, _FresnelExp);

                float3 frColor = fr * _FresnelColor;
                o.Emission = _Emission + frColor;
            }

        ENDCG
    }
    FallBack "Diffuse"
}
