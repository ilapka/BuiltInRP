Shader "Custom/DiffuseTransparentShander"
{
    Properties
    {
        _Color ("Main Color", Color) = (1,1,1,1)
        _MainTex ("Base (RGB)", 2D) = "white" {}
    }
    SubShader
    {
        Tags 
        {
            //Inform Unity what type of this shader to Unity knows how to render it
            "RenderType"="Transparent"
            "Queue"="Transparent" 
            //This shadow will work wrong with particles which sprites always rotate to camera + decrease calculation
            "IgnoreProjector"="True" //Disable fake shadow casting system of Unity for transparent objects (like particles)
        }
        Lod 200
        Cull Off
        
        CGPROGRAM

        // Surface shader compile compile directives (https://docs.unity3d.com/2019.3/Documentation/Manual/SL-SurfaceShaders.html)
        #pragma surface surf Lambert alpha:fade //Inform Unity to use 'alpha' transparent for this shader (alpha:auto/fade/premul)

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
