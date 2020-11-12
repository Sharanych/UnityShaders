Shader "Custom/SS_MeshWave"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0

        _WAmplitude ("Wave Amplitude", Range(0,1)) = 0.4
		_WFrequency ("Wave Frequency", Range(1, 10)) = 2
		_WSpeed ("Speed", Range(0,5)) = 1
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "Queue"="Geometry" }
        LOD 200

        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Standard fullforwardshadows vertex:vert addshadow

        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0

        sampler2D _MainTex;

        struct Input
        {
            float2 uv_MainTex;
        };

        half _Glossiness;
        half _Metallic;
        fixed4 _Color;

        float _WAmplitude;
		float _WFrequency;
		float _WSpeed;

        // Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
        // See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
        // #pragma instancing_options assumeuniformscaling
        UNITY_INSTANCING_BUFFER_START(Props)
            // put more per-instance properties here
        UNITY_INSTANCING_BUFFER_END(Props)

        void vert(inout appdata_full data) {
            float4 mPos = data.vertex;
			mPos.y += sin(data.vertex.x * _WFrequency + _Time.y * _WSpeed) * _WAmplitude;
			
			float3 mPosTang = data.vertex + data.tangent * 0.01;
			mPosTang.y += sin(mPosTang.x * _WFrequency + _Time.y * _WSpeed) * _WAmplitude;

			float3 bitangent = cross(data.normal, data.tangent);
			float3 mPosBitang = data.vertex + bitangent * 0.01;
			mPosBitang.y += sin(mPosBitang.x * _WFrequency + _Time.y * _WSpeed) * _WAmplitude;

			float3 mTangent = mPosTang - mPos;
			float3 mBitangent = mPosBitang - mPos;

			float3 mNormal = cross(mTangent, mBitangent);
			data.normal = normalize(mNormal);
			data.vertex = mPos;
        }

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            // Albedo comes from a texture tinted by color
            fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
            o.Albedo = c.rgb;
            // Metallic and smoothness come from slider variables
            o.Metallic = _Metallic;
            o.Smoothness = _Glossiness;
            o.Alpha = c.a;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
