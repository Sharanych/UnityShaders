Shader "Custom/Surface/LightChTex"
{
    Properties
    {
        _LightTex ("Texture under the light", 2D) = "white" {}
        _ShadowTex ("Texture in the shade", 2D) = "white" {}
    }
    
    SubShader
    {
        Tags { "LightMode" = "ForwardBase" }

        Pass 
        {
            CGPROGRAM
         
            #pragma vertex vert
            #pragma fragment frag
         
            #include "UnityCG.cginc"
 
            struct v2f 
            {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
                float light : TEXCOORD1;
            };
 
            sampler2D _LightTex;
            sampler2D _ShadowTex;
 
            v2f vert(appdata_base v) 
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = v.texcoord;
            
                float3 wNormal = normalize(mul(v.normal, (float3x3) unity_WorldToObject));
                float3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
                o.light = max(0, dot(wNormal, lightDir));
            
                return o;
            }
 
            fixed4 frag(v2f i) : SV_Target 
            {
                fixed4 col1 = tex2D(_LightTex, i.uv);
                fixed4 col2 = tex2D(_ShadowTex, i.uv);
            
                return lerp(col2, col1, i.light);
            }
 
            ENDCG
        }
    }
}
