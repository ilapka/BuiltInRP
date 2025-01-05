//                                  READ ME:

//      For this animation to work, it is necessary to use a special sphere mesh, 
//  in which each vertex position is set to the value of the center of the sphere (pivot), 
//  and the normals indicate the directional offset from the pivot to the true position of the vertex,
//  which the shader will calculate

//      This is necessary because in the case of batching objects, we will not be able to get the pivot position in any other way

Shader "Custom/Unlit/BouncingBall"
{
    Properties
    {
        [Header(UV0 (TEXCOORD0) xy is uv.   UV0 z is animation phase offset.   UV0 w is random speed.)]
        [Space(10)]
        _MainTex ("Texture", 2D) = "white" {}
        _MeshColorIntensity ("MeshColorIntensity", Range(0, 1)) = 0.5
        [Space(10)]
        _MinSpeed ("Min Speed", Range(0.001, 10)) = 0.5
        _RandomSpeedIntensity ("Random Speed Intensity", Range(0, 3)) = 1.0
        _MinBounceHeight ("MinBounceHeight", Float) = 1.0
        _RandomBounceHeightIntensity ("Random Bounce Height Intensity", Range(-10, 10)) = 1.0
        _SphereRadius ("Sphere Radius", Range(0.001, 10)) = 1.0
        _Dive ("Dive (On collision with ground)", Range(0, 0.9)) = 0.5
        _HorizontalMoving ("Horizontal Moving", Range(0, 10)) = 2.0
        _RotationSpeed ("Rotation Speed", Float) = 0.5
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "_MyLibraryCG.cginc"

            struct appdata
            {
                float3 vertex : POSITION;
                half3 normal : NORMAL;
                fixed4 color : COLOR;
                float4 texcoord0 : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                fixed4 meshColor : COLOR;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            fixed _MeshColorIntensity;

            float _MinSpeed,
                _RandomSpeedIntensity,
                _MinBounceHeight,
                _RandomBounceHeightIntensity,
                _SphereRadius,
                _Dive,
                _HorizontalMoving,
                _RotationSpeed;

            /*
             * mul() is a function that multiplies two matrices together (or matrix and vector)
             * UNITY_MATRIX_VP and unity_ObjectToWorld are built-in variables that contain the View-Projection matrix and the Object-to-World matrix respectively:
             * https://docs.unity3d.com/Manual/SL-UnityShaderVariables.html
             */

            // Method for horizontal compression of a sphere based on the vertical scale
            float3 getScalerForWorldOffsetByVertical(float verticalScale)
            {
                verticalScale = max(verticalScale, 0.1); // Prevent division by zero
                float invertScale = pow(1.0 / verticalScale, 0.3); // Formula for horizontal compression of a sphere based on the vertical scale
                return float3(invertScale, verticalScale, invertScale);
            }

            // Squash ball when it dives "under ground"
            void squashBall(in float diameter, inout float3 worldOffsetDir, inout float offsetY)
            {
                float diveUnderGround = max(-offsetY, 0); //Value how much the ball dives under ground in absolute value in world space
                offsetY += diveUnderGround; //Stop moving ball vertices down when they collides with the ground
                float verticalShrink = 1 - diveUnderGround / diameter; //Value of how much the ball dives under ground relative to ball size
                worldOffsetDir *= getScalerForWorldOffsetByVertical(verticalShrink);
            }

            v2f vert (appdata v)
            {
                v2f o;
                
                float diameter = _SphereRadius * 2;
                
                float3 animationOffset;
                float3x3 animationRotation;
                {   //Calculate main trajectory
                    float speed = (_MinSpeed + _RandomSpeedIntensity * v.texcoord0.w) / 4; 
                    float cycleLength = 1 / speed;
                    float progress = (_Time.y % cycleLength) * speed; // Progress always animates from 0 to 1, but with different speed, because we take different digits from _Time
                    progress += v.texcoord0.z; // Bouncing phase offset (unique for each ball)
                    animationOffset.y = cos(progress * UNITY_TWO_PI * 4) * 0.5 + 0.5;
                    float bounceHeight = _MinBounceHeight + abs(v.texcoord0.z - v.texcoord0.w) * _RandomBounceHeightIntensity;
                    animationOffset.y = pow(animationOffset.y, 0.5) * bounceHeight - _Dive * diameter; //Squaring the value of the cos to change its graph to a greater bend => the speed of the ball will change nonlinearly
                    
                    animationOffset.x = sin(progress * UNITY_TWO_PI * 2) * _HorizontalMoving;
                    animationOffset.z = sin(progress * UNITY_TWO_PI) * _HorizontalMoving;

                    float3 rotationAxis = normalize(v.color * 2 - float3(1, 1, 1)); // Transform color values to [-1, 1] range and use as rotation axis (unique color for each ball inside mesh)
                    animationRotation = rotMtxCustomAxis(progress * UNITY_TWO_PI * _RotationSpeed, rotationAxis);
                }

                half3 rotatedNormal = mul(animationRotation, v.normal);
                float3 worldPivot = mul(unity_ObjectToWorld, float4(v.vertex, 1.0)).xyz; // - float3(0, normalLenght, 0);
                float3 worldOffsetDir = UnityObjectToWorldDir(rotatedNormal) * _SphereRadius + float3(0, _SphereRadius, 0);
                
                // Squash ball when it dives "under ground"
                squashBall(diameter, /* inout */ worldOffsetDir, /* inout */ animationOffset.y);

                float3 worldPos = worldPivot + worldOffsetDir;
                worldPos += animationOffset;
                
                o.vertex = mul(UNITY_MATRIX_VP, float4(worldPos, 1.0));
                o.meshColor = v.color;

                o.uv = TRANSFORM_TEX(v.texcoord0, _MainTex);
                
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv) + i.meshColor * _MeshColorIntensity;
                return col;
            }
            ENDCG
        }
    }
}
