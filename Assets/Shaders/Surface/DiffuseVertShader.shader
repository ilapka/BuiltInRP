Shader "Custom/DiffuseVertShader" {

    Properties
    {
        _Color ("Main Color", Color) = (1,1,1,1)
        _MainTex ("Base (RGB)", 2D) = "white" {}
        _Extrude ("Extrude", Float) = 0.0
        _DispMap ("Displacement Map", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        CGPROGRAM

        #pragma target 3.0
        #pragma surface surf Lambert vertex:vert
  
        sampler2D
            _MainTex,
            _DispMap;
        
        fixed4 _Color;
        float _Extrude;

        struct Input
        {
            float2 uv_MainTex;
        };

        //Can get/fill vertex data from/to appdata_full and fill data to Input, that will be passed to surf further
        void vert (inout appdata_full v, out Input o)
        {
            //Macro to initialize output value and escape compilation error
            UNITY_INITIALIZE_OUTPUT(Input, o);

            //Function of 3.0 shader model, that allows to get data from texture in vertex shader for specific mipmap level (w component of float4 parameter (0))
            fixed dispacement = tex2Dlod(_DispMap, float4(v.texcoord.xy, 0, 0)).r;
            //Create offset for vertex in normal direction by displacement map
            float3 normalOffset = v.normal * _Extrude * dispacement;
            v.vertex.xyz += normalOffset;
        }

        void surf (Input IN, inout SurfaceOutput o)
        {
            fixed4 c = tex2D(_MainTex, IN.uv_MainTex) * _Color;
            o.Albedo = c.rgb;
            o.Alpha = c.a;
        }
        ENDCG
    }

    Fallback "Legacy Shaders/VertexLit"
}