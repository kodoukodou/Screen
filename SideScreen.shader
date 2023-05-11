Shader "Unlit/SideScreen"
{
    Properties{
         [Toggle] _Apply_Array("Apply Array", Float) = 0
        //[KeywordEnum(ARRAY, SINGLE)] _Color("Color", Float) = 0

         [HDR] _EmissionColor("_EmissionColor", Color) = (0,0,0)
         _MainTex("Base (RGB)", 2DArray) = "white" { }
         _MainTex2("Base2 (RGB)", 2D) = "white" { }
         _TextureNo("Texture No", Range(0,11)) = 0
         _Mask("Culling Mask", 2D) = "white" { }
         _RotationIntensity("RotationIntensity", Float) = 0
         _Cutoff("Alpha cutoff", Range(0.000000,1.000000)) = 0.100000
    }
    SubShader{
        Tags { "Queue" = "Transparent" }
        Pass {
            Tags { "Queue" = "Transparent" }
            //ZWrite Off
            Blend SrcAlpha OneMinusSrcAlpha
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 2.0
            #include "UnityCG.cginc"
            #pragma multi_compile_fog
            #define USING_FOG (defined(FOG_LINEAR) || defined(FOG_EXP) || defined(FOG_EXP2))

            // uniforms
            UNITY_DECLARE_TEX2DARRAY(_MainTex);
            float _TextureNo;
            float4 _Mask_ST;
            float4 _MainTex_ST;
            float4 _MainTex2_ST;
            float _RotationIntensity;

            // vertex shader input data
            struct appdata {
              float3 pos : POSITION;
              float3 uv0 : TEXCOORD0;
              UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            // vertex-to-fragment interpolators
            struct v2f {
              fixed4 color : COLOR0;
              float2 uv0 : TEXCOORD0;
              float2 uv1 : TEXCOORD1;
              float2 uv2 : TEXCOORD2;
              #if USING_FOG
                fixed fog : TEXCOORD2;
              #endif
              float4 pos : SV_POSITION;
              UNITY_VERTEX_OUTPUT_STEREO
            };

            #pragma shader_feature _APPLY_ARRAY_ON

            // vertex shader
            v2f vert(appdata i) {
              v2f o;
              UNITY_SETUP_INSTANCE_ID(IN);
              UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
              half4 color = half4(0,0,0,1.1);
              float3 eyePos = mul(UNITY_MATRIX_MV, float4(i.pos,1)).xyz;
              half3 viewDir = 0.0;
              o.color = saturate(color);
              o.uv0 = i.uv0.xy * _Mask_ST.xy + _Mask_ST.zw;

            #ifdef _APPLY_ARRAY_ON
                  o.uv1 = i.uv0.xy * _MainTex_ST.xy + _MainTex_ST.zw;
            #else
                o.uv2 = i.uv0.xy * _MainTex2_ST.xy + _MainTex2_ST.zw;
            #endif

              #if USING_FOG
                float fogCoord = length(eyePos.xyz); // radial fog distance
                UNITY_CALC_FOG_FACTOR_RAW(fogCoord);
                o.fog = saturate(unityFogFactor);
              #endif
                // transform position
                o.pos = UnityObjectToClipPos(i.pos);
                return o;
              }

            // textures
            sampler2D _Mask;
            float4 _EmissionColor;
            sampler2D _MainTex2;
            fixed _Cutoff;

            // fragment shader
            fixed4 frag(v2f i) : SV_Target {
              float2x2 rotate = float2x2(cos(_RotationIntensity), -sin(_RotationIntensity), sin(_RotationIntensity), cos(_RotationIntensity));
              float2 uv = i.uv1 - 0.5;
              i.uv1 = mul(uv, rotate) + 0.5;

              fixed4 col;
              fixed4 tex, tmp0, tmp1, tmp2;
              // SetTexture #0
              tex = tex2D(_Mask, i.uv0.xy);
              col = tex;
              // SetTexture #1

                #ifdef _APPLY_ARRAY_ON
                              tex = UNITY_SAMPLE_TEX2DARRAY(_MainTex, float3(i.uv1, floor(_TextureNo)));
                #else
                              tex = tex2D(_MainTex2, i.uv2.xy);
                #endif

              col.rgb = tex;
              col.a = col.a;
              // alpha test
              if (col.a < _Cutoff) clip(-1);
              // fog
              #if USING_FOG
                col.rgb = lerp(unity_FogColor.rgb, col.rgb, i.fog);
              #endif
              return col* _EmissionColor;
            }

        ENDCG
         }
     }
}