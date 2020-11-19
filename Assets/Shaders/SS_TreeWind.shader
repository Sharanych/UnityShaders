Shader "Custom/SS_TreeWind"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        [Normal] [NoScaleOffset]
		_NormalTex ("Normal Map", 2D) = "bump" {}
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0

        [Space(10)] 
		_WindDirection ("Wind_Direction", Vector) = (1,0,1,0)
        _Frequency ("Frequency", Range(0,10)) = 1.5
        _Amplitude ("Amplitude", Range(0,1)) = 0.03
        _Cutoff ("Alpha cutoff", Range(0,1)) = 0.5

        [Space(10)] [NoScaleOffset]
		_NoiseTex ("Wind Noise", 2D) = "gray" {}
		_NoiseScale ("Noise Position Scale", Range(0,10)) = 0.1
		_NoiseSpeed ("Noise Speed", Range(0,10)) = 0.1
		_NoiseStrength ("Noise Strength", Range(0,10)) = 0.3
    }

    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Standard vertex:vert alphatest:_Cutoff addshadow fullforwardshadows nolightmap

        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0

        sampler2D _MainTex;
        sampler2D _NormalTex;
		sampler2D _NoiseTex;

        float PI = 3.141592654;

        struct appdata 
        {
            float4 vertex : POSITION;
			float3 normal : NORMAL;
			float4 tangent : TANGENT;
			float4 color : COLOR;
			float2 texcoord : TEXCOORD0;
        };

        struct Input
        {
            float4 pos : SV_POSITION;
            float2 uv_MainTex : TEXCOORD0;
        };

        half _Glossiness;
        half _Metallic;
        fixed4 _Color;

        fixed4 _WindDirection;
        float _NoiseScale;
		float _NoiseSpeed;
		float _NoiseStrength;
        float _Frequency;
		float _Amplitude;

        // Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
        // See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
        // #pragma instancing_options assumeuniformscaling
        UNITY_INSTANCING_BUFFER_START(Props)
        // put more per-instance properties here
        UNITY_INSTANCING_BUFFER_END(Props)

        void vert(inout appdata data)
        {
            float3 p = mul(data.vertex, unity_ObjectToWorld);
            float noise = tex2Dlod(_NoiseTex, float4(p.xz * _NoiseScale + _Time.x * float2(_NoiseSpeed, _NoiseSpeed), 0.0, 0.0)).r * _NoiseStrength;

            data.vertex.xyz += (mul(_WindDirection.xyz, unity_WorldToObject) * data.color.r * sin(data.color.b * PI + (_Time.y + noise) * _Frequency) * _Amplitude);
        }

        void surf (Input i, inout SurfaceOutputStandard o)
        {
            // Albedo comes from a texture tinted by color
            fixed4 c = tex2D (_MainTex, i.uv_MainTex) * _Color;
            o.Albedo = c.rgb;
            o.Normal = UnpackNormal(tex2D(_NormalTex, i.uv_MainTex));
            // Metallic and smoothness come from slider variables
            o.Metallic = _Metallic;
            o.Smoothness = _Glossiness;
            o.Alpha = c.a;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
