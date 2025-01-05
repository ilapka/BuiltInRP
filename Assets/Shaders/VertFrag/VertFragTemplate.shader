Shader "Custom/Unlit/VertFragTemplate" 
{
    Properties
    {
        _Color ("Tint", Color) = (1,1,1,1)
        _MainTex ("Texture", 2D) = "white" {}
        
        [Space] [Header(Shader Blending)]
        [Enum(UnityEngine.Rendering.CullMode)] _Cull ("Cull", Int) = 0
        [Enum(None, 0, Alpha, 1, RGB, 14, RGBA, 15)] _ColorMask ("out Color Mask", Float) = 15
        [Enum(Off, 0, On, 1)] _ZWrite ("Z-Write", Int) = 0
        [Enum(UnityEngine.Rendering.CompareFunction)] _ZTest ("Z-Test", Int) = 2
    }
    
    //CG compile directives that will work for all subshaders and passes (https://docs.unity3d.com/6000.0/Documentation/Manual/SL-PragmaDirectives.html)
    CGINCLUDE
    #pragma target 3.0
    
    #pragma vertex vert 
    #pragma fragment frag 
    #pragma multi_compile_fog

    #include "_MyLibraryCG.cginc"
    ENDCG
    
    //Shader lab construction that allows setup settings (tags and commands) for all subshaders and passes
    Category
    {
        //https://docs.unity3d.com/Manual/SL-SubShaderTags.html
        Tags 
        { 
            //"PreviewType" = "Plane"
            //"Queue" = "Geometry"
            //"RenderType" = "Opaque"
            //"IgnoreProjector" = "True" 
            //"ForceNoShadowCasting" = "True" 
            //"RenderPipeline" = "UniversalPipeline"
            //"DisableBatching" = "False"
        }
        
        //https://docs.unity3d.com/Manual/SL-Commands.html (https://docs.unity3d.com/Manual/shader-shaderlab-legacy.html) 
        ColorMask [_ColorMask] 
        Cull [_Cull] 
        ZWrite [_ZWrite] 
        ZTest [_ZTest] 
        Lighting Off 
        LOD 100
        
        Subshader
        {
            //Functions: https://learn.microsoft.com/en-us/windows/win32/direct3dhlsl/dx-graphics-hlsl-intrinsic-functions
            Pass //"DRAW CALL" for 3.0 model
            {
                CGPROGRAM
                #pragma target 3.0

                ENDCG
            }
            Pass //"DRAW CALL" for 2.5 model
            {
                CGPROGRAM
                //default shader target 2.0 model
                ENDCG
            }
            Pass //"DRAW CALL"
            {
                CGPROGRAM
                #pragma target 2.0
                
                ENDCG
            }
        }
    }
    
    Fallback Off
}
