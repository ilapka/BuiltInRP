
//  All code outside of "Pass" is ShaderLab code of Unity, that generate own settings for communicate with driver api further

//Name of Shader
Shader "Custom/Unlit/MyUnlitShader" 
{
    Properties
    {
        //Shader properties     
        _Color ("Tint", Color) = (1,1,1,1)
        _MainTex ("Texture", 2D) = "white" {}
        
        [Space] [Header(Shader Blending)]
        [Enum(UnityEngine.Rendering.CullMode)] _Cull ("Cull", Int) = 0
        [Enum(None, 0, Alpha, 1, RGB, 14, RGBA, 15)] _ColorMask ("out Color Mask", Float) = 15
        [Enum(Off, 0, On, 1)] _ZWrite ("Z-Write", Int) = 0
        [Enum(UnityEngine.Rendering.CompareFunction)] _ZTest ("Z-Test", Int) = 2
    }
    SubShader
    {
        //Tags for subshader (https://docs.unity3d.com/Manual/SL-SubShaderTags.html)
        //(Relates only to inner Unity logic, that convert that for drivers/draw calls itself)
        Tags 
        { 
            "PreviewType" = "Plane"
            //"Queue" = "Geometry"
            "RenderType" = "Opaque"
            "IgnoreProjector" = "True" // no consider in unity projectors (legacy tech for decals)
            "ForceNoShadowCasting" = "True" // no cast shadows
            
            "RenderPipeline" = "UniversalPipeline"
            "DisableBatching" = "False" //"LODFading"
        }
        
        //Render state Commands for SubShader - for all Passes (https://docs.unity3d.com/Manual/SL-Commands.html) (https://docs.unity3d.com/Manual/shader-shaderlab-legacy.html)
        
        //Blend [_BlendSrc] [_BlendDst]
        ColorMask [_ColorMask] //Mask for color channels
        Cull [_Cull] //Cull mode for geometry
        ZWrite [_ZWrite] //Write to depth buffer
        ZTest [_ZTest] //Depth testing for geometry
        Lighting Off //Disabling of legacy outdated language inside shader
        //Offset 1000, 1000 //Offset for geometry (for avoid z-fighting)
        Stencil // StencilBuffer - custom mask (as ZTest, but with advanced custom settings)
        {
            //For example, we can use it for render only geometry that intersect with another geometry etc
            //Was used in game Portal for render portals
        }
        LOD 100 //Shader run by distance
 
        //"DRAW CALL"
        Pass
        {
            Name "MyFirstPass"
            
            //Tags for Pass (https://docs.unity3d.com/Manual/SL-PassTags.html)
            Tags 
            { 
                //"LightMode" = "Always"
                //"PassFlags" = "OnlyDirectional" (only for build-in RP)
                //"RequireOptions" = "SoftVegetation" (only for build-in RP)
            }
            
            //Render state Commands for this Pass (https://docs.unity3d.com/Manual/SL-Commands.html) (https://docs.unity3d.com/Manual/shader-shaderlab-legacy.html)
            //Cull Back //(Front | Off) Cut off polygons that facing the camera (back or front) | Can be useful for rendering material sides by different ways by 2 pass
            //ZTest LEqual // "Depth testing" for geometry (whether to draw geometry if it is under the previous one or on top of the previous one)
            //Blend One One //Set additive setting for draw call
            
            //--------> cgFx or HLSL code start here <--------
            
            CGPROGRAM // <----- cgFx code
            #pragma target 3.0
            //Instruction for shader compiler that explain to shader what is what
            #pragma vertex vert //(vertex function - "vert")
            #pragma fragment frag //(fragment function - "frag")
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 os : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            //Vertex function (== vertex shader)
            v2f vert (appdata v)
            {
                //Examples of Swizzles - computationally free operations for reorganization vector components
                float4 x4 = v.vertex.xxxx;
                float3 x3 = v.vertex.xxx;
                float4 invertedVertex = v.vertex.wzyx;
                
                v2f o;
                o.os = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 _Color;

            //Fragment function (== fragment/pixel shader)
            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                // "tex2D" is intrinsic function (of cgFx and HLSL) for lookup 2D texture
                // (all functions: https://learn.microsoft.com/en-us/windows/win32/direct3dhlsl/dx-graphics-hlsl-intrinsic-functions)
                fixed4 col = tex2D(_MainTex, i.uv) * _Color;
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }

    //Fallback shader if no one sub shaders not work
    //Fallback "Standart"
    
    //Custom editor for shader
    //CustomEditor ""
}
