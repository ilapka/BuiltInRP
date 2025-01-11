Shader "Custom/MeshParticle"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _SpriteSize ("Size", Float) = 1.0
        _Intensity ("Intensity", Float) = 5.0
        _AlphaIntensity ("AlphaIntensity", Range(0, 1)) = 0.3
        
        [Space] [Header(Shader Blending)]
		[Enum(UnityEngine.Rendering.CullMode)] _Cull ("Cull", Int) = 0
		[Enum(None,0,Alpha,1,RGB,14,RGBA,15)] _ColorMask ("out Color Mask", Float) = 15
		[Enum(Off, 0, On, 1)] _zWrite ("Z-Write", Int) = 0
		[Enum(UnityEngine.Rendering.CompareFunction)] _zTest ("Z-Test", Int) = 2
    }
    
    CGINCLUDE
        #pragma vertex vert
        #pragma fragment frag
        // make fog work
        #pragma multi_compile_fog

        #include "UnityCG.cginc"

        struct appdata
        {
            float3 vertex : POSITION;
            half4 texcoord0 : TEXCOORD0;
            half3 meshColor : COLOR;
        };

        struct v2f
        {
            float4 vertex : SV_POSITION;
            half4 texcoord0 : TEXCOORD0;
            half3 meshColor : TEXCOORD1; //Use TEXCOORD1 instead of color, cause unity can compress color to 0 - 1 value
        };

        sampler2D _MainTex;
        float _SpriteSize;

        //Define macros for quick use axis of matrix unity_CameraToWorld
        //Matrix unity_CameraToWorld transfer vector from camera to world space
        #define cameraWorldSAxis_X unity_CameraToWorld._m00_m10_m20
        #define cameraWorldSAxis_Y unity_CameraToWorld._m01_m11_m21
        #define cameraWorldSAxis_Z unity_CameraToWorld._m02_m12_m22
    
        float3 worldSpriteOffsets(float2 offset2D)
        {
            float3 offset2DToWorldMtxX = normalize(cameraWorldSAxis_X);
            float3 offset2DToWorldMtxY = normalize(cameraWorldSAxis_Y);
            float3 worldOffset = offset2D.xxx * offset2DToWorldMtxX + offset2D.yyy * offset2DToWorldMtxY; //Equals to mul(unity_CameraToWorld, float3(offset2D, 0)), but normalized for cases when camera scale is changed
            return worldOffset * _SpriteSize;
        }

        v2f vert (appdata v)
        {
            v2f o;
            float3 worldPos = mul(unity_ObjectToWorld, float4(v.vertex, 1.0)).xyz;
            float2 offsets2D = v.texcoord0 * 2 - 1; //Shift vertex so that we can have center point of quad
            
            worldPos += worldSpriteOffsets(offsets2D);
            
            o.vertex = mul(UNITY_MATRIX_VP, float4(worldPos, 1.0));
            o.texcoord0 = v.texcoord0;
            o.meshColor = v.meshColor;
            return o;
        }

        half _Intensity;
        half _AlphaIntensity;

        fixed4 frag (v2f i) : SV_Target
        {
            //Calculate main trajectory
            float progress = _Time.y % 1; // Progress always animates from 0 to 1, but with different speed, because we take different digits from _Time
            progress += i.texcoord0.z; //z is some random value
            float colorAnimation = min(cos(progress * UNITY_TWO_PI) * 0.5 + 0.5 + 0.3, 1);

            half mask = tex2D(_MainTex, i.texcoord0).a;
            mask = mask * mask * mask; // we raise it to the 3rd power to get very fine detail in the dark tones
            
            fixed4 col = mask * half4(i.meshColor * _Intensity * colorAnimation, _AlphaIntensity);
            return col;
        }
    ENDCG
    
    Category
    {
        Tags 
        {
            "PreviewType"="Plane"
            "Queue"="Transparent" //Shader Order
            "RenderType"="Transparent" //Shader Type
            "IgnoreProjector"="True"
            "ForceNoShadowCasting"="True"
        }
        
        Blend One OneMinusSrcAlpha
		Cull [_Cull]
        ColorMask [_ColorMask]
        ZWrite [_zWrite]
        ZTest [_zTest]
		Lighting Off 
        
        SubShader
        {
            Pass
            {
                Name "Target 3.0"
                
                CGPROGRAM
                #pragma target 3.0
                //This pass will run code from 'CGINCLUDE' above
                ENDCG
            }
            Pass
            {
                Name "Target 2.5 (Default)"
                
                CGPROGRAM
                #pragma target 2.5 //Default render target
                //This pass will run code from 'CGINCLUDE' above
                ENDCG
            }
            Pass
            {
                Name "Target 2.0"

                CGPROGRAM
                #pragma target 2.0
                //This pass will run code from 'CGINCLUDE' above
                ENDCG
            }
        }
    }
}
