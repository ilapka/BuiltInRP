Shader "Custom/Unlit/FirstUnlitShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Color ("Color", Color) = (1,1,1,1)
        _NormalOffset ("Normal Offset", Float) = 0
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
            // make fog work
            #pragma multi_compile_fog

            //Include Unity's shader library (that contains all necessary functions)
            #include "UnityCG.cginc"

            //"ApplicationData" | Struct for transfer data from application to vertex shader 
            struct appdata
            {
                float4 vertex : POSITION; //Vertex position in object space
                float2 uv : TEXCOORD0; //All uv coordinates that contains in mesh
                half3 normal : NORMAL; //Normal vector of vertex
                
                // half4 tangent : TANGENT; //Tangent vector of vertex
                // fixed4 color0 : COLOR0; //Colors of mesh
            };

            //"VertexToFragment" | Struck for transfer data from vertex shader to fragment shader
            //Note: we can use only SV_POSITION, TEXCOORD[N] and COLOR[N] in this struct, so if we want to pass normal or tangent we need to use TEXCOORD[N]
            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 pos : SV_POSITION; //Vertex position in screen space
                UNITY_FOG_COORDS(1)
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            fixed4 _Color;
            float _NormalOffset;

            //Functions: https://learn.microsoft.com/en-us/windows/win32/direct3dhlsl/dx-graphics-hlsl-intrinsic-functions

            v2f vert (appdata v)
            {
                v2f o;

                v.vertex.xyz += v.normal * _NormalOffset;
                
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex); //Scale texture by uv coordinates (Tilling/Offset)
                UNITY_TRANSFER_FOG(o,o.vertex); //Setup default Unity's fog 
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                //Read the texture by uv coordinates
                fixed4 col = tex2D(_MainTex, i.uv) * _Color;
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col); //Apply default Unity's fog
                return col; //Return result (pixel color) to SV_Target (to FrameBuffer)
            }
            ENDCG
        }
    }
}
