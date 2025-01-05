Shader "Custom/DiffuseTransparentCutoutShander"
{
    Properties
    {
        _Color ("Main Color", Color) = (1,1,1,1)
        _MainTex ("Base (RGB)", 2D) = "white" {}
        [Header(Clipping threshold below which we consider a pixel transparent above which we consider a pixel opaque)]
        _Cutoff ("Alpha cutoff", Range(0,1)) = 0.5
    }
    SubShader
    {
        Tags 
        {
            //Inform Unity what type of this shader to Unity knows how to render it
            "RenderType"="TransparentCutout"
            //for "TransparentCutout" type we need to explicitly inform Unity that we want use 'alpha' queue
            "Queue"="AlphaTest" //Test the alpha value of pixel and only fill it if it passes the test
            "IgnoreProjector"="True" //Disable fake shadow casting system of Unity
        }
        Lod 200
        Cull Off
        
        CGPROGRAM

        // Surface shader compile compile directives (https://docs.unity3d.com/2019.3/Documentation/Manual/SL-SurfaceShaders.html)
        #pragma surface surf Lambert alphatest:_Cutoff addshadow //add parameter for alpha cutoff direct to shader declaration

        sampler2D _MainTex;
        fixed4 _Color;

        struct Input
        {
            float2 uv_MainTex;
        };

        void surf (Input inp, inout SurfaceOutput outp)
        {
            //-- Albedo --
            fixed4 clr = tex2D(_MainTex, inp.uv_MainTex) * _Color;
            outp.Albedo = clr.rgb;
            //-- Alpha --
            outp.Alpha = clr.a;
        }
        
        ENDCG
    }
    
    FallBack "Diffuse"
}
