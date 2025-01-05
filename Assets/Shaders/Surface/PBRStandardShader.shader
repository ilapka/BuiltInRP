Shader "Custom/PBRStandardShader"
{
    Properties
    {
        _MaskTex ("Mask texture", 2D) = "black" {}
        _EmissionMaskTex ("Emission mask texture", 2D) = "black" {}

        [Header(My Header)]
        _MainTex1 ("Main texture 1", 2D) = "white" {}
        _MainTex2 ("Main texture 2", 2D) = "white" {}
        _MainTex3 ("Main texture 3", 2D) = "white" {}
        
        _EmissionColor ("Emission Color", Color) = (0,0,0,0)
        _EmissionAppearance ("Emission Appearance", Range(0, 1)) = 1
        
        _BumpMap ("Normal Map", 2D) = "bump" {}
        
        [Header(Glare sharpness (Smoothness))]
        _Shiness1 ("Shiness1", Range(0, 1)) = 0.07
        _Shiness2 ("Shiness2", Range(0, 1)) = 0.07
        _Shiness3 ("Shiness3", Range(0, 1)) = 0.07
        
        [Header(Visibility of glare (Metallic))]
        _Specularity1 ("Specularity1", Range(0, 1)) = 0.5
        _Specularity2 ("Specularity2", Range(0, 1)) = 0.5
        _Specularity3 ("Specularity3", Range(0, 1)) = 0.5
    }
    SubShader
    {
        CGPROGRAM

        // Surface shader compile compile directives (https://docs.unity3d.com/2019.3/Documentation/Manual/SL-SurfaceShaders.html)
        #pragma surface surf Standard

        sampler2D
            _MaskTex,
            _MainTex1,
            _MainTex2,
            _MainTex3,
            _EmissionMaskTex,
            _BumpMap;

        fixed3
            _EmissionColor;
        
        fixed
            _EmissionAppearance,
            _Specularity1,
            _Specularity2,
            _Specularity3;
        
        half
            _Shiness1,
            _Shiness2,
            _Shiness3;

        struct Input
        {
            half2 uv_MaskTex;
            half2 uv_MainTex1;
        };

        void surf (Input inp, inout SurfaceOutputStandard outp)
        {
            //-- Albedo --
            
            fixed3 masks = tex2D(_MaskTex, inp.uv_MaskTex).rgb;
            fixed3 clr = tex2D(_MainTex1, inp.uv_MainTex1).rgb * masks.r;
            clr += tex2D(_MainTex2, inp.uv_MainTex1).rgb * masks.g;
            clr += tex2D(_MainTex3, inp.uv_MainTex1).rgb * masks.b;
            outp.Albedo = clr;

            //-- Emission --
            
            fixed3 emTex = tex2D(_EmissionMaskTex, inp.uv_MainTex1).rgb;
            fixed emissionAppearMask = emTex.b;
            //Procedural emission appearance 
            _EmissionAppearance = 1 - _EmissionAppearance;
            emissionAppearMask = smoothstep((_EmissionAppearance - 0.5) * 2, _EmissionAppearance * 2, emissionAppearMask);
            outp.Emission = emissionAppearMask * emTex.r * _EmissionColor;

            //-- Normal map --
            outp.Normal = UnpackNormal(tex2D(_BumpMap, inp.uv_MainTex1));

            //-- Glare --
             outp.Metallic =
                 _Specularity1 * masks.r +
                 _Specularity2 * masks.g +
                 _Specularity3 * masks.b;
            
            outp.Smoothness = (_Shiness1 * masks.r +_Shiness2 * masks.g +_Shiness3 * masks.b);
        }
        
        ENDCG
    }
    
    FallBack "Diffuse"
}
