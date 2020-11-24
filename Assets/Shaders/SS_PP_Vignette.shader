Shader "Custom/SS_PP_Vignette"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _Radius("Vignette Radius", Range(0.0, 1.0)) = 0.5
		_Soft("Vignette Softness", Range(0.0, 1.0)) = 0.5
    }

    SubShader
    {
        Pass
        {
            CGPROGRAM

            #pragma vertex vert_img
            #pragma fragment frag

            #include "UnityCG.cginc"

            fixed4 _Color;
            sampler2D _MainTex;
            float _Radius;
            float _Soft;

            float4 frag(v2f_img i) : COLOR
            {
                float4 dif = tex2D(_MainTex, i.uv);
                dif = dif * _Color;

                float d = distance(i.uv.xy, float2(0.5, 0.5));
                float v = smoothstep(_Radius, _Radius - _Soft, d);
                dif = saturate(dif*v);

                return dif;
            }

            ENDCG
        }
    }
    FallBack "Diffuse"
}
