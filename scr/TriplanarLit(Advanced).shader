Shader "Triplanar/TriplanarLit (Advanced)"
{
    Properties
    {
        [NoScaleOffset]_Diffuse("Diffuse", 2D) = "white" {}
        [NoScaleOffset]_Normal_Map("Normal Map", 2D) = "white" {}
        _Normal_Strength("Normal Strength", Float) = 0
        _Blend("Blend", Float) = 0.5
        _Tiling("Tiling", Float) = 0.5
        _Smoothness("Smoothness", Range(0, 1)) = 0
        [NoScaleOffset]_Smoothness_Map("Smoothness Map", 2D) = "white" {}
        _Metallic("Metallic", Range(0, 1)) = 0
        [NoScaleOffset]_Metallic_Map("Metallic Map", 2D) = "white" {}
        _Ambient_Occlusion("Ambient Occlusion", Float) = 1
        [NoScaleOffset]_Ambient_Occlusion_Map("Ambient Occlusion Map", 2D) = "white" {}
        _Opacity("Opacity", Float) = 1
        [NoScaleOffset]_Alpha_Map("Alpha Map", 2D) = "white" {}
        [HDR]_Emission_Color("Emission Color", Color) = (0, 0, 0, 0)
        _Emission_Strength("Emission Strength", Float) = 0
        [NoScaleOffset]_Emission_Map("Emission Map", 2D) = "white" {}
        [ToggleUI]_Apply_Filters("Apply Filters", Float) = 0
        __Filter_Color("(Filter) Color", Color) = (0.7058824, 0.7058824, 0.7058824, 0)
        __Filter_Contrast("(Filter) Contrast", Float) = 0
        __Filter_Saturation("(Filter) Saturation", Float) = 1
        [HideInInspector]_BUILTIN_QueueOffset("Float", Float) = 0
        [HideInInspector]_BUILTIN_QueueControl("Float", Float) = -1
    }
    SubShader
    {
        Tags
        {
            // RenderPipeline: <None>
            "RenderType"="Transparent"
            "BuiltInMaterialType" = "Lit"
            "Queue"="Transparent"
            "ShaderGraphShader"="true"
            "ShaderGraphTargetId"="BuiltInLitSubTarget"
        }
        Pass
        {
            Name "BuiltIn Forward"
            Tags
            {
                "LightMode" = "ForwardBase"
            }
        
        // Render State
        Cull Back
        Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
        ZTest LEqual
        ZWrite Off
        ColorMask RGB
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 3.0
        #pragma multi_compile_instancing
        #pragma multi_compile_fog
        #pragma multi_compile_fwdbase
        #pragma vertex vert
        #pragma fragment frag
        
        // DotsInstancingOptions: <None>
        // HybridV1InjectedBuiltinProperties: <None>
        
        // Keywords
        #pragma multi_compile _ _SCREEN_SPACE_OCCLUSION
        #pragma multi_compile _ LIGHTMAP_ON
        #pragma multi_compile _ DIRLIGHTMAP_COMBINED
        #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
        #pragma multi_compile _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS _ADDITIONAL_OFF
        #pragma multi_compile _ _ADDITIONAL_LIGHT_SHADOWS
        #pragma multi_compile _ _SHADOWS_SOFT
        #pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
        #pragma multi_compile _ SHADOWS_SHADOWMASK
        // GraphKeywords: <None>
        
        // Defines
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD1
        #define VARYINGS_NEED_POSITION_WS
        #define VARYINGS_NEED_NORMAL_WS
        #define VARYINGS_NEED_TANGENT_WS
        #define VARYINGS_NEED_VIEWDIRECTION_WS
        #define VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_FORWARD
        #define BUILTIN_TARGET_API 1
        #define _BUILTIN_SURFACE_TYPE_TRANSPARENT 1
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
        #ifdef _BUILTIN_SURFACE_TYPE_TRANSPARENT
        #define _SURFACE_TYPE_TRANSPARENT _BUILTIN_SURFACE_TYPE_TRANSPARENT
        #endif
        #ifdef _BUILTIN_ALPHATEST_ON
        #define _ALPHATEST_ON _BUILTIN_ALPHATEST_ON
        #endif
        #ifdef _BUILTIN_AlphaClip
        #define _AlphaClip _BUILTIN_AlphaClip
        #endif
        #ifdef _BUILTIN_ALPHAPREMULTIPLY_ON
        #define _ALPHAPREMULTIPLY_ON _BUILTIN_ALPHAPREMULTIPLY_ON
        #endif
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/Shim/Shims.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/LegacySurfaceVertex.hlsl"
        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/ShaderGraphFunctions.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv1 : TEXCOORD1;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 positionWS;
             float3 normalWS;
             float4 tangentWS;
             float3 viewDirectionWS;
            #if defined(LIGHTMAP_ON)
             float2 lightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
             float3 sh;
            #endif
             float4 fogFactorAndVertexLight;
             float4 shadowCoord;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float3 WorldSpaceNormal;
             float3 TangentSpaceNormal;
             float3 WorldSpaceTangent;
             float3 WorldSpaceBiTangent;
             float3 WorldSpacePosition;
             float3 AbsoluteWorldSpacePosition;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float3 interp0 : INTERP0;
             float3 interp1 : INTERP1;
             float4 interp2 : INTERP2;
             float3 interp3 : INTERP3;
             float2 interp4 : INTERP4;
             float3 interp5 : INTERP5;
             float4 interp6 : INTERP6;
             float4 interp7 : INTERP7;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.positionWS;
            output.interp1.xyz =  input.normalWS;
            output.interp2.xyzw =  input.tangentWS;
            output.interp3.xyz =  input.viewDirectionWS;
            #if defined(LIGHTMAP_ON)
            output.interp4.xy =  input.lightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
            output.interp5.xyz =  input.sh;
            #endif
            output.interp6.xyzw =  input.fogFactorAndVertexLight;
            output.interp7.xyzw =  input.shadowCoord;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.positionWS = input.interp0.xyz;
            output.normalWS = input.interp1.xyz;
            output.tangentWS = input.interp2.xyzw;
            output.viewDirectionWS = input.interp3.xyz;
            #if defined(LIGHTMAP_ON)
            output.lightmapUV = input.interp4.xy;
            #endif
            #if !defined(LIGHTMAP_ON)
            output.sh = input.interp5.xyz;
            #endif
            output.fogFactorAndVertexLight = input.interp6.xyzw;
            output.shadowCoord = input.interp7.xyzw;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _Diffuse_TexelSize;
        float4 _Normal_Map_TexelSize;
        float _Tiling;
        float _Blend;
        float _Normal_Strength;
        float _Smoothness;
        float _Metallic;
        float4 __Filter_Color;
        float4 _Emission_Color;
        float4 _Alpha_Map_TexelSize;
        float _Opacity;
        float4 _Emission_Map_TexelSize;
        float _Emission_Strength;
        float4 _Smoothness_Map_TexelSize;
        float4 _Metallic_Map_TexelSize;
        float _Ambient_Occlusion;
        float4 _Ambient_Occlusion_Map_TexelSize;
        float __Filter_Contrast;
        float _Apply_Filters;
        float __Filter_Saturation;
        CBUFFER_END
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_Diffuse);
        SAMPLER(sampler_Diffuse);
        TEXTURE2D(_Normal_Map);
        SAMPLER(sampler_Normal_Map);
        TEXTURE2D(_Alpha_Map);
        SAMPLER(sampler_Alpha_Map);
        TEXTURE2D(_Emission_Map);
        SAMPLER(sampler_Emission_Map);
        TEXTURE2D(_Smoothness_Map);
        SAMPLER(sampler_Smoothness_Map);
        TEXTURE2D(_Metallic_Map);
        SAMPLER(sampler_Metallic_Map);
        TEXTURE2D(_Ambient_Occlusion_Map);
        SAMPLER(sampler_Ambient_Occlusion_Map);
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // Graph Functions
        
        void Unity_Branch_float4(float Predicate, float4 True, float4 False, out float4 Out)
        {
            Out = Predicate ? True : False;
        }
        
        void Unity_Blend_Overlay_float4(float4 Base, float4 Blend, out float4 Out, float Opacity)
        {
            float4 result1 = 1.0 - 2.0 * (1.0 - Base) * (1.0 - Blend);
            float4 result2 = 2.0 * Base * Blend;
            float4 zeroOrOne = step(Base, 0.5);
            Out = result2 * zeroOrOne + (1 - zeroOrOne) * result1;
            Out = lerp(Base, Out, Opacity);
        }
        
        void Unity_Branch_float(float Predicate, float True, float False, out float Out)
        {
            Out = Predicate ? True : False;
        }
        
        void Unity_Contrast_float(float3 In, float Contrast, out float3 Out)
        {
            float midpoint = pow(0.5, 2.2);
            Out =  (In - midpoint) * Contrast + midpoint;
        }
        
        void Unity_Saturation_float(float3 In, float Saturation, out float3 Out)
        {
            float luma = dot(In, float3(0.2126729, 0.7151522, 0.0721750));
            Out =  luma.xxx + Saturation.xxx * (In - luma.xxx);
        }
        
        void Unity_NormalStrength_float(float3 In, float Strength, out float3 Out)
        {
            Out = float3(In.rg * Strength, lerp(1, In.b, saturate(Strength)));
        }
        
        void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float3 BaseColor;
            float3 NormalTS;
            float3 Emission;
            float Metallic;
            float Smoothness;
            float Occlusion;
            float Alpha;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float _Property_7b5fcd77ad264a83a7858d8f8361dbd7_Out_0 = _Apply_Filters;
            float4 _Property_e0ca4e34dd184733915c6122832975e4_Out_0 = __Filter_Color;
            float4 _Branch_ef11623f9e8b4e6191fcc3ea8bc1312a_Out_3;
            Unity_Branch_float4(_Property_7b5fcd77ad264a83a7858d8f8361dbd7_Out_0, _Property_e0ca4e34dd184733915c6122832975e4_Out_0, float4(0.5, 0.5, 0.5, 0), _Branch_ef11623f9e8b4e6191fcc3ea8bc1312a_Out_3);
            UnityTexture2D _Property_6c8663f0373d4b058ae8b9af5db9f43e_Out_0 = UnityBuildTexture2DStructNoScale(_Diffuse);
            float _Property_0d71a168115a4531a21482c995ff11b8_Out_0 = _Tiling;
            float _Property_a5f4da8e125f4a69b3ef8e0eee9629a9_Out_0 = _Blend;
            float3 Triplanar_f96cb0998e494774b09fab89ebb65eb5_UV = IN.AbsoluteWorldSpacePosition * _Property_0d71a168115a4531a21482c995ff11b8_Out_0;
            float3 Triplanar_f96cb0998e494774b09fab89ebb65eb5_Blend = SafePositivePow_float(IN.WorldSpaceNormal, min(_Property_a5f4da8e125f4a69b3ef8e0eee9629a9_Out_0, floor(log2(Min_float())/log2(1/sqrt(3)))) );
            Triplanar_f96cb0998e494774b09fab89ebb65eb5_Blend /= dot(Triplanar_f96cb0998e494774b09fab89ebb65eb5_Blend, 1.0);
            float4 Triplanar_f96cb0998e494774b09fab89ebb65eb5_X = SAMPLE_TEXTURE2D(_Property_6c8663f0373d4b058ae8b9af5db9f43e_Out_0.tex, _Property_6c8663f0373d4b058ae8b9af5db9f43e_Out_0.samplerstate, Triplanar_f96cb0998e494774b09fab89ebb65eb5_UV.zy);
            float4 Triplanar_f96cb0998e494774b09fab89ebb65eb5_Y = SAMPLE_TEXTURE2D(_Property_6c8663f0373d4b058ae8b9af5db9f43e_Out_0.tex, _Property_6c8663f0373d4b058ae8b9af5db9f43e_Out_0.samplerstate, Triplanar_f96cb0998e494774b09fab89ebb65eb5_UV.xz);
            float4 Triplanar_f96cb0998e494774b09fab89ebb65eb5_Z = SAMPLE_TEXTURE2D(_Property_6c8663f0373d4b058ae8b9af5db9f43e_Out_0.tex, _Property_6c8663f0373d4b058ae8b9af5db9f43e_Out_0.samplerstate, Triplanar_f96cb0998e494774b09fab89ebb65eb5_UV.xy);
            float4 _Triplanar_f96cb0998e494774b09fab89ebb65eb5_Out_0 = Triplanar_f96cb0998e494774b09fab89ebb65eb5_X * Triplanar_f96cb0998e494774b09fab89ebb65eb5_Blend.x + Triplanar_f96cb0998e494774b09fab89ebb65eb5_Y * Triplanar_f96cb0998e494774b09fab89ebb65eb5_Blend.y + Triplanar_f96cb0998e494774b09fab89ebb65eb5_Z * Triplanar_f96cb0998e494774b09fab89ebb65eb5_Blend.z;
            float4 _Blend_24c4787dcd7349eaae00fa6c3d9ca4ee_Out_2;
            Unity_Blend_Overlay_float4(_Branch_ef11623f9e8b4e6191fcc3ea8bc1312a_Out_3, _Triplanar_f96cb0998e494774b09fab89ebb65eb5_Out_0, _Blend_24c4787dcd7349eaae00fa6c3d9ca4ee_Out_2, 1);
            float _Property_4bd6ac78ba874554b874b76acf5eb180_Out_0 = _Apply_Filters;
            float _Property_8294ca47c1a14914a77bfa2e11e7db60_Out_0 = __Filter_Contrast;
            float _Branch_7646794670b149f6b60b9fe083ccac25_Out_3;
            Unity_Branch_float(_Property_4bd6ac78ba874554b874b76acf5eb180_Out_0, _Property_8294ca47c1a14914a77bfa2e11e7db60_Out_0, 1, _Branch_7646794670b149f6b60b9fe083ccac25_Out_3);
            float3 _Contrast_5087ef763a7e408686e5684e2bd7fd3d_Out_2;
            Unity_Contrast_float((_Blend_24c4787dcd7349eaae00fa6c3d9ca4ee_Out_2.xyz), _Branch_7646794670b149f6b60b9fe083ccac25_Out_3, _Contrast_5087ef763a7e408686e5684e2bd7fd3d_Out_2);
            float _Property_507c099bfb814af6aeb4eebfbbf3d34a_Out_0 = _Apply_Filters;
            float _Property_5d9b092d0e4645c594f92d6e73dc7c4c_Out_0 = __Filter_Saturation;
            float _Branch_9912f29c61804626a6ab83b323d383d5_Out_3;
            Unity_Branch_float(_Property_507c099bfb814af6aeb4eebfbbf3d34a_Out_0, _Property_5d9b092d0e4645c594f92d6e73dc7c4c_Out_0, 1, _Branch_9912f29c61804626a6ab83b323d383d5_Out_3);
            float3 _Saturation_07d8daef15d04c6db1e1f18efb74c91f_Out_2;
            Unity_Saturation_float(_Contrast_5087ef763a7e408686e5684e2bd7fd3d_Out_2, _Branch_9912f29c61804626a6ab83b323d383d5_Out_3, _Saturation_07d8daef15d04c6db1e1f18efb74c91f_Out_2);
            UnityTexture2D _Property_4d22bb373eee4057a5413b8162f92e45_Out_0 = UnityBuildTexture2DStructNoScale(_Normal_Map);
            float3 Triplanar_5e2f2d627ffc47e7b32959be7a69b8c1_UV = IN.AbsoluteWorldSpacePosition * _Property_0d71a168115a4531a21482c995ff11b8_Out_0;
            float3 Triplanar_5e2f2d627ffc47e7b32959be7a69b8c1_Blend = SafePositivePow_float(IN.WorldSpaceNormal, min(_Property_a5f4da8e125f4a69b3ef8e0eee9629a9_Out_0, floor(log2(Min_float())/log2(1/sqrt(3)))) );
            Triplanar_5e2f2d627ffc47e7b32959be7a69b8c1_Blend /= (Triplanar_5e2f2d627ffc47e7b32959be7a69b8c1_Blend.x + Triplanar_5e2f2d627ffc47e7b32959be7a69b8c1_Blend.y + Triplanar_5e2f2d627ffc47e7b32959be7a69b8c1_Blend.z ).xxx;
            float3 Triplanar_5e2f2d627ffc47e7b32959be7a69b8c1_X = UnpackNormal(SAMPLE_TEXTURE2D(_Property_4d22bb373eee4057a5413b8162f92e45_Out_0.tex, _Property_4d22bb373eee4057a5413b8162f92e45_Out_0.samplerstate, Triplanar_5e2f2d627ffc47e7b32959be7a69b8c1_UV.zy));
            float3 Triplanar_5e2f2d627ffc47e7b32959be7a69b8c1_Y = UnpackNormal(SAMPLE_TEXTURE2D(_Property_4d22bb373eee4057a5413b8162f92e45_Out_0.tex, _Property_4d22bb373eee4057a5413b8162f92e45_Out_0.samplerstate, Triplanar_5e2f2d627ffc47e7b32959be7a69b8c1_UV.xz));
            float3 Triplanar_5e2f2d627ffc47e7b32959be7a69b8c1_Z = UnpackNormal(SAMPLE_TEXTURE2D(_Property_4d22bb373eee4057a5413b8162f92e45_Out_0.tex, _Property_4d22bb373eee4057a5413b8162f92e45_Out_0.samplerstate, Triplanar_5e2f2d627ffc47e7b32959be7a69b8c1_UV.xy));
            Triplanar_5e2f2d627ffc47e7b32959be7a69b8c1_X = float3(Triplanar_5e2f2d627ffc47e7b32959be7a69b8c1_X.xy + IN.WorldSpaceNormal.zy, abs(Triplanar_5e2f2d627ffc47e7b32959be7a69b8c1_X.z) * IN.WorldSpaceNormal.x);
            Triplanar_5e2f2d627ffc47e7b32959be7a69b8c1_Y = float3(Triplanar_5e2f2d627ffc47e7b32959be7a69b8c1_Y.xy + IN.WorldSpaceNormal.xz, abs(Triplanar_5e2f2d627ffc47e7b32959be7a69b8c1_Y.z) * IN.WorldSpaceNormal.y);
            Triplanar_5e2f2d627ffc47e7b32959be7a69b8c1_Z = float3(Triplanar_5e2f2d627ffc47e7b32959be7a69b8c1_Z.xy + IN.WorldSpaceNormal.xy, abs(Triplanar_5e2f2d627ffc47e7b32959be7a69b8c1_Z.z) * IN.WorldSpaceNormal.z);
            float4 _Triplanar_5e2f2d627ffc47e7b32959be7a69b8c1_Out_0 = float4(normalize(Triplanar_5e2f2d627ffc47e7b32959be7a69b8c1_X.zyx * Triplanar_5e2f2d627ffc47e7b32959be7a69b8c1_Blend.x + Triplanar_5e2f2d627ffc47e7b32959be7a69b8c1_Y.xzy * Triplanar_5e2f2d627ffc47e7b32959be7a69b8c1_Blend.y + Triplanar_5e2f2d627ffc47e7b32959be7a69b8c1_Z.xyz * Triplanar_5e2f2d627ffc47e7b32959be7a69b8c1_Blend.z), 1);
            float3x3 Triplanar_5e2f2d627ffc47e7b32959be7a69b8c1_Transform = float3x3(IN.WorldSpaceTangent, IN.WorldSpaceBiTangent, IN.WorldSpaceNormal);
            _Triplanar_5e2f2d627ffc47e7b32959be7a69b8c1_Out_0.rgb = TransformWorldToTangent(_Triplanar_5e2f2d627ffc47e7b32959be7a69b8c1_Out_0.rgb, Triplanar_5e2f2d627ffc47e7b32959be7a69b8c1_Transform);
            float _Property_465f1954a0214426b47c7da2af048f07_Out_0 = _Normal_Strength;
            float3 _NormalStrength_530366de39034d288415f2bd44ee2d24_Out_2;
            Unity_NormalStrength_float((_Triplanar_5e2f2d627ffc47e7b32959be7a69b8c1_Out_0.xyz), _Property_465f1954a0214426b47c7da2af048f07_Out_0, _NormalStrength_530366de39034d288415f2bd44ee2d24_Out_2);
            UnityTexture2D _Property_36a8b919311a4525bb742e047b0c7fad_Out_0 = UnityBuildTexture2DStructNoScale(_Emission_Map);
            float3 Triplanar_d184924eec244d279d611947e624fc09_UV = IN.AbsoluteWorldSpacePosition * _Property_0d71a168115a4531a21482c995ff11b8_Out_0;
            float3 Triplanar_d184924eec244d279d611947e624fc09_Blend = SafePositivePow_float(IN.WorldSpaceNormal, min(_Property_a5f4da8e125f4a69b3ef8e0eee9629a9_Out_0, floor(log2(Min_float())/log2(1/sqrt(3)))) );
            Triplanar_d184924eec244d279d611947e624fc09_Blend /= dot(Triplanar_d184924eec244d279d611947e624fc09_Blend, 1.0);
            float4 Triplanar_d184924eec244d279d611947e624fc09_X = SAMPLE_TEXTURE2D(_Property_36a8b919311a4525bb742e047b0c7fad_Out_0.tex, _Property_36a8b919311a4525bb742e047b0c7fad_Out_0.samplerstate, Triplanar_d184924eec244d279d611947e624fc09_UV.zy);
            float4 Triplanar_d184924eec244d279d611947e624fc09_Y = SAMPLE_TEXTURE2D(_Property_36a8b919311a4525bb742e047b0c7fad_Out_0.tex, _Property_36a8b919311a4525bb742e047b0c7fad_Out_0.samplerstate, Triplanar_d184924eec244d279d611947e624fc09_UV.xz);
            float4 Triplanar_d184924eec244d279d611947e624fc09_Z = SAMPLE_TEXTURE2D(_Property_36a8b919311a4525bb742e047b0c7fad_Out_0.tex, _Property_36a8b919311a4525bb742e047b0c7fad_Out_0.samplerstate, Triplanar_d184924eec244d279d611947e624fc09_UV.xy);
            float4 _Triplanar_d184924eec244d279d611947e624fc09_Out_0 = Triplanar_d184924eec244d279d611947e624fc09_X * Triplanar_d184924eec244d279d611947e624fc09_Blend.x + Triplanar_d184924eec244d279d611947e624fc09_Y * Triplanar_d184924eec244d279d611947e624fc09_Blend.y + Triplanar_d184924eec244d279d611947e624fc09_Z * Triplanar_d184924eec244d279d611947e624fc09_Blend.z;
            float4 _Property_d19f06a576904574bc1ce7a4bc0705de_Out_0 = IsGammaSpace() ? LinearToSRGB(_Emission_Color) : _Emission_Color;
            float _Property_8538694bbc6046818d0fe00a0884c6e1_Out_0 = _Emission_Strength;
            float4 _Multiply_a9f07d97808a4c1a81856fe1fc446ee1_Out_2;
            Unity_Multiply_float4_float4(_Property_d19f06a576904574bc1ce7a4bc0705de_Out_0, (_Property_8538694bbc6046818d0fe00a0884c6e1_Out_0.xxxx), _Multiply_a9f07d97808a4c1a81856fe1fc446ee1_Out_2);
            float4 _Multiply_b2871317a9804ae491f162ac9a41c7ee_Out_2;
            Unity_Multiply_float4_float4(_Triplanar_d184924eec244d279d611947e624fc09_Out_0, _Multiply_a9f07d97808a4c1a81856fe1fc446ee1_Out_2, _Multiply_b2871317a9804ae491f162ac9a41c7ee_Out_2);
            UnityTexture2D _Property_2645d69dc6fc44eabeb03b508fa73fa2_Out_0 = UnityBuildTexture2DStructNoScale(_Metallic_Map);
            float3 Triplanar_72251408cf774e2cb2bb6dade546d69f_UV = IN.AbsoluteWorldSpacePosition * _Property_0d71a168115a4531a21482c995ff11b8_Out_0;
            float3 Triplanar_72251408cf774e2cb2bb6dade546d69f_Blend = SafePositivePow_float(IN.WorldSpaceNormal, min(_Property_a5f4da8e125f4a69b3ef8e0eee9629a9_Out_0, floor(log2(Min_float())/log2(1/sqrt(3)))) );
            Triplanar_72251408cf774e2cb2bb6dade546d69f_Blend /= dot(Triplanar_72251408cf774e2cb2bb6dade546d69f_Blend, 1.0);
            float4 Triplanar_72251408cf774e2cb2bb6dade546d69f_X = SAMPLE_TEXTURE2D(_Property_2645d69dc6fc44eabeb03b508fa73fa2_Out_0.tex, _Property_2645d69dc6fc44eabeb03b508fa73fa2_Out_0.samplerstate, Triplanar_72251408cf774e2cb2bb6dade546d69f_UV.zy);
            float4 Triplanar_72251408cf774e2cb2bb6dade546d69f_Y = SAMPLE_TEXTURE2D(_Property_2645d69dc6fc44eabeb03b508fa73fa2_Out_0.tex, _Property_2645d69dc6fc44eabeb03b508fa73fa2_Out_0.samplerstate, Triplanar_72251408cf774e2cb2bb6dade546d69f_UV.xz);
            float4 Triplanar_72251408cf774e2cb2bb6dade546d69f_Z = SAMPLE_TEXTURE2D(_Property_2645d69dc6fc44eabeb03b508fa73fa2_Out_0.tex, _Property_2645d69dc6fc44eabeb03b508fa73fa2_Out_0.samplerstate, Triplanar_72251408cf774e2cb2bb6dade546d69f_UV.xy);
            float4 _Triplanar_72251408cf774e2cb2bb6dade546d69f_Out_0 = Triplanar_72251408cf774e2cb2bb6dade546d69f_X * Triplanar_72251408cf774e2cb2bb6dade546d69f_Blend.x + Triplanar_72251408cf774e2cb2bb6dade546d69f_Y * Triplanar_72251408cf774e2cb2bb6dade546d69f_Blend.y + Triplanar_72251408cf774e2cb2bb6dade546d69f_Z * Triplanar_72251408cf774e2cb2bb6dade546d69f_Blend.z;
            float _Property_a2de0712f3e74597a69dcb9c906c8323_Out_0 = _Metallic;
            float4 _Multiply_51419fc37ba3467492dc6057f62e848a_Out_2;
            Unity_Multiply_float4_float4(_Triplanar_72251408cf774e2cb2bb6dade546d69f_Out_0, (_Property_a2de0712f3e74597a69dcb9c906c8323_Out_0.xxxx), _Multiply_51419fc37ba3467492dc6057f62e848a_Out_2);
            UnityTexture2D _Property_2044c0171961481a87c99454b70146f3_Out_0 = UnityBuildTexture2DStructNoScale(_Smoothness_Map);
            float3 Triplanar_b21e7971fc0e4b8a966ee4585dca400a_UV = IN.AbsoluteWorldSpacePosition * _Property_0d71a168115a4531a21482c995ff11b8_Out_0;
            float3 Triplanar_b21e7971fc0e4b8a966ee4585dca400a_Blend = SafePositivePow_float(IN.WorldSpaceNormal, min(_Property_a5f4da8e125f4a69b3ef8e0eee9629a9_Out_0, floor(log2(Min_float())/log2(1/sqrt(3)))) );
            Triplanar_b21e7971fc0e4b8a966ee4585dca400a_Blend /= dot(Triplanar_b21e7971fc0e4b8a966ee4585dca400a_Blend, 1.0);
            float4 Triplanar_b21e7971fc0e4b8a966ee4585dca400a_X = SAMPLE_TEXTURE2D(_Property_2044c0171961481a87c99454b70146f3_Out_0.tex, _Property_2044c0171961481a87c99454b70146f3_Out_0.samplerstate, Triplanar_b21e7971fc0e4b8a966ee4585dca400a_UV.zy);
            float4 Triplanar_b21e7971fc0e4b8a966ee4585dca400a_Y = SAMPLE_TEXTURE2D(_Property_2044c0171961481a87c99454b70146f3_Out_0.tex, _Property_2044c0171961481a87c99454b70146f3_Out_0.samplerstate, Triplanar_b21e7971fc0e4b8a966ee4585dca400a_UV.xz);
            float4 Triplanar_b21e7971fc0e4b8a966ee4585dca400a_Z = SAMPLE_TEXTURE2D(_Property_2044c0171961481a87c99454b70146f3_Out_0.tex, _Property_2044c0171961481a87c99454b70146f3_Out_0.samplerstate, Triplanar_b21e7971fc0e4b8a966ee4585dca400a_UV.xy);
            float4 _Triplanar_b21e7971fc0e4b8a966ee4585dca400a_Out_0 = Triplanar_b21e7971fc0e4b8a966ee4585dca400a_X * Triplanar_b21e7971fc0e4b8a966ee4585dca400a_Blend.x + Triplanar_b21e7971fc0e4b8a966ee4585dca400a_Y * Triplanar_b21e7971fc0e4b8a966ee4585dca400a_Blend.y + Triplanar_b21e7971fc0e4b8a966ee4585dca400a_Z * Triplanar_b21e7971fc0e4b8a966ee4585dca400a_Blend.z;
            float _Property_6ac0f3d590a04d70b9b65f930607378e_Out_0 = _Smoothness;
            float4 _Multiply_1190034063a742598e70497b24a917d6_Out_2;
            Unity_Multiply_float4_float4(_Triplanar_b21e7971fc0e4b8a966ee4585dca400a_Out_0, (_Property_6ac0f3d590a04d70b9b65f930607378e_Out_0.xxxx), _Multiply_1190034063a742598e70497b24a917d6_Out_2);
            UnityTexture2D _Property_6fda6f621b89424d81cce741b5c87cfb_Out_0 = UnityBuildTexture2DStructNoScale(_Ambient_Occlusion_Map);
            float3 Triplanar_c18df43557c74ecf9550fa6e5f01b85a_UV = IN.AbsoluteWorldSpacePosition * _Property_0d71a168115a4531a21482c995ff11b8_Out_0;
            float3 Triplanar_c18df43557c74ecf9550fa6e5f01b85a_Blend = SafePositivePow_float(IN.WorldSpaceNormal, min(_Property_a5f4da8e125f4a69b3ef8e0eee9629a9_Out_0, floor(log2(Min_float())/log2(1/sqrt(3)))) );
            Triplanar_c18df43557c74ecf9550fa6e5f01b85a_Blend /= dot(Triplanar_c18df43557c74ecf9550fa6e5f01b85a_Blend, 1.0);
            float4 Triplanar_c18df43557c74ecf9550fa6e5f01b85a_X = SAMPLE_TEXTURE2D(_Property_6fda6f621b89424d81cce741b5c87cfb_Out_0.tex, _Property_6fda6f621b89424d81cce741b5c87cfb_Out_0.samplerstate, Triplanar_c18df43557c74ecf9550fa6e5f01b85a_UV.zy);
            float4 Triplanar_c18df43557c74ecf9550fa6e5f01b85a_Y = SAMPLE_TEXTURE2D(_Property_6fda6f621b89424d81cce741b5c87cfb_Out_0.tex, _Property_6fda6f621b89424d81cce741b5c87cfb_Out_0.samplerstate, Triplanar_c18df43557c74ecf9550fa6e5f01b85a_UV.xz);
            float4 Triplanar_c18df43557c74ecf9550fa6e5f01b85a_Z = SAMPLE_TEXTURE2D(_Property_6fda6f621b89424d81cce741b5c87cfb_Out_0.tex, _Property_6fda6f621b89424d81cce741b5c87cfb_Out_0.samplerstate, Triplanar_c18df43557c74ecf9550fa6e5f01b85a_UV.xy);
            float4 _Triplanar_c18df43557c74ecf9550fa6e5f01b85a_Out_0 = Triplanar_c18df43557c74ecf9550fa6e5f01b85a_X * Triplanar_c18df43557c74ecf9550fa6e5f01b85a_Blend.x + Triplanar_c18df43557c74ecf9550fa6e5f01b85a_Y * Triplanar_c18df43557c74ecf9550fa6e5f01b85a_Blend.y + Triplanar_c18df43557c74ecf9550fa6e5f01b85a_Z * Triplanar_c18df43557c74ecf9550fa6e5f01b85a_Blend.z;
            float _Property_b41c1f0171a8491283bb490d369c1633_Out_0 = _Ambient_Occlusion;
            float4 _Multiply_8460e617a2774fc4a9bc1b8ac4b4c498_Out_2;
            Unity_Multiply_float4_float4(_Triplanar_c18df43557c74ecf9550fa6e5f01b85a_Out_0, (_Property_b41c1f0171a8491283bb490d369c1633_Out_0.xxxx), _Multiply_8460e617a2774fc4a9bc1b8ac4b4c498_Out_2);
            float _Property_85bb0cea7a3e455b96bc35eef9b04b52_Out_0 = _Opacity;
            UnityTexture2D _Property_4ffddeb9667041dea5361019922617c3_Out_0 = UnityBuildTexture2DStructNoScale(_Alpha_Map);
            float3 Triplanar_6f2fd2dbd39f45f1b46f5b62d6f1ccb8_UV = IN.AbsoluteWorldSpacePosition * _Property_0d71a168115a4531a21482c995ff11b8_Out_0;
            float3 Triplanar_6f2fd2dbd39f45f1b46f5b62d6f1ccb8_Blend = SafePositivePow_float(IN.WorldSpaceNormal, min(_Property_a5f4da8e125f4a69b3ef8e0eee9629a9_Out_0, floor(log2(Min_float())/log2(1/sqrt(3)))) );
            Triplanar_6f2fd2dbd39f45f1b46f5b62d6f1ccb8_Blend /= dot(Triplanar_6f2fd2dbd39f45f1b46f5b62d6f1ccb8_Blend, 1.0);
            float4 Triplanar_6f2fd2dbd39f45f1b46f5b62d6f1ccb8_X = SAMPLE_TEXTURE2D(_Property_4ffddeb9667041dea5361019922617c3_Out_0.tex, _Property_4ffddeb9667041dea5361019922617c3_Out_0.samplerstate, Triplanar_6f2fd2dbd39f45f1b46f5b62d6f1ccb8_UV.zy);
            float4 Triplanar_6f2fd2dbd39f45f1b46f5b62d6f1ccb8_Y = SAMPLE_TEXTURE2D(_Property_4ffddeb9667041dea5361019922617c3_Out_0.tex, _Property_4ffddeb9667041dea5361019922617c3_Out_0.samplerstate, Triplanar_6f2fd2dbd39f45f1b46f5b62d6f1ccb8_UV.xz);
            float4 Triplanar_6f2fd2dbd39f45f1b46f5b62d6f1ccb8_Z = SAMPLE_TEXTURE2D(_Property_4ffddeb9667041dea5361019922617c3_Out_0.tex, _Property_4ffddeb9667041dea5361019922617c3_Out_0.samplerstate, Triplanar_6f2fd2dbd39f45f1b46f5b62d6f1ccb8_UV.xy);
            float4 _Triplanar_6f2fd2dbd39f45f1b46f5b62d6f1ccb8_Out_0 = Triplanar_6f2fd2dbd39f45f1b46f5b62d6f1ccb8_X * Triplanar_6f2fd2dbd39f45f1b46f5b62d6f1ccb8_Blend.x + Triplanar_6f2fd2dbd39f45f1b46f5b62d6f1ccb8_Y * Triplanar_6f2fd2dbd39f45f1b46f5b62d6f1ccb8_Blend.y + Triplanar_6f2fd2dbd39f45f1b46f5b62d6f1ccb8_Z * Triplanar_6f2fd2dbd39f45f1b46f5b62d6f1ccb8_Blend.z;
            float4 _Multiply_969d0f17e76149089b7efa601089c78e_Out_2;
            Unity_Multiply_float4_float4((_Property_85bb0cea7a3e455b96bc35eef9b04b52_Out_0.xxxx), _Triplanar_6f2fd2dbd39f45f1b46f5b62d6f1ccb8_Out_0, _Multiply_969d0f17e76149089b7efa601089c78e_Out_2);
            surface.BaseColor = _Saturation_07d8daef15d04c6db1e1f18efb74c91f_Out_2;
            surface.NormalTS = _NormalStrength_530366de39034d288415f2bd44ee2d24_Out_2;
            surface.Emission = (_Multiply_b2871317a9804ae491f162ac9a41c7ee_Out_2.xyz);
            surface.Metallic = (_Multiply_51419fc37ba3467492dc6057f62e848a_Out_2).x;
            surface.Smoothness = (_Multiply_1190034063a742598e70497b24a917d6_Out_2).x;
            surface.Occlusion = (_Multiply_8460e617a2774fc4a9bc1b8ac4b4c498_Out_2).x;
            surface.Alpha = (_Multiply_969d0f17e76149089b7efa601089c78e_Out_2).x;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
            
        
            // must use interpolated tangent, bitangent and normal before they are normalized in the pixel shader.
            float3 unnormalizedNormalWS = input.normalWS;
            const float renormFactor = 1.0 / length(unnormalizedNormalWS);
        
            // use bitangent on the fly like in hdrp
            // IMPORTANT! If we ever support Flip on double sided materials ensure bitangent and tangent are NOT flipped.
            float crossSign = (input.tangentWS.w > 0.0 ? 1.0 : -1.0)* GetOddNegativeScale();
            float3 bitang = crossSign * cross(input.normalWS.xyz, input.tangentWS.xyz);
        
            output.WorldSpaceNormal = renormFactor * input.normalWS.xyz;      // we want a unit length Normal Vector node in shader graph
            output.TangentSpaceNormal = float3(0.0f, 0.0f, 1.0f);
        
            // to preserve mikktspace compliance we use same scale renormFactor as was used on the normal.
            // This is explained in section 2.2 in "surface gradient based bump mapping framework"
            output.WorldSpaceTangent = renormFactor * input.tangentWS.xyz;
            output.WorldSpaceBiTangent = renormFactor * bitang;
        
            output.WorldSpacePosition = input.positionWS;
            output.AbsoluteWorldSpacePosition = GetAbsolutePositionWS(input.positionWS);
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        void BuildAppDataFull(Attributes attributes, VertexDescription vertexDescription, inout appdata_full result)
        {
            result.vertex     = float4(attributes.positionOS, 1);
            result.tangent    = attributes.tangentOS;
            result.normal     = attributes.normalOS;
            result.texcoord1  = attributes.uv1;
            result.vertex     = float4(vertexDescription.Position, 1);
            result.normal     = vertexDescription.Normal;
            result.tangent    = float4(vertexDescription.Tangent, 0);
            #if UNITY_ANY_INSTANCING_ENABLED
            #endif
        }
        
        void VaryingsToSurfaceVertex(Varyings varyings, inout v2f_surf result)
        {
            result.pos = varyings.positionCS;
            result.worldPos = varyings.positionWS;
            result.worldNormal = varyings.normalWS;
            result.viewDir = varyings.viewDirectionWS;
            // World Tangent isn't an available input on v2f_surf
        
            result._ShadowCoord = varyings.shadowCoord;
        
            #if UNITY_ANY_INSTANCING_ENABLED
            #endif
            #if !defined(LIGHTMAP_ON)
            #if UNITY_SHOULD_SAMPLE_SH
            result.sh = varyings.sh;
            #endif
            #endif
            #if defined(LIGHTMAP_ON)
            result.lmap.xy = varyings.lightmapUV;
            #endif
            #ifdef VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
                result.fogCoord = varyings.fogFactorAndVertexLight.x;
                COPY_TO_LIGHT_COORDS(result, varyings.fogFactorAndVertexLight.yzw);
            #endif
        
            DEFAULT_UNITY_TRANSFER_VERTEX_OUTPUT_STEREO(varyings, result);
        }
        
        void SurfaceVertexToVaryings(v2f_surf surfVertex, inout Varyings result)
        {
            result.positionCS = surfVertex.pos;
            result.positionWS = surfVertex.worldPos;
            result.normalWS = surfVertex.worldNormal;
            // viewDirectionWS is never filled out in the legacy pass' function. Always use the value computed by SRP
            // World Tangent isn't an available input on v2f_surf
            result.shadowCoord = surfVertex._ShadowCoord;
        
            #if UNITY_ANY_INSTANCING_ENABLED
            #endif
            #if !defined(LIGHTMAP_ON)
            #if UNITY_SHOULD_SAMPLE_SH
            result.sh = surfVertex.sh;
            #endif
            #endif
            #if defined(LIGHTMAP_ON)
            result.lightmapUV = surfVertex.lmap.xy;
            #endif
            #ifdef VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
                result.fogFactorAndVertexLight.x = surfVertex.fogCoord;
                COPY_FROM_LIGHT_COORDS(result.fogFactorAndVertexLight.yzw, surfVertex);
            #endif
        
            DEFAULT_UNITY_TRANSFER_VERTEX_OUTPUT_STEREO(surfVertex, result);
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/PBRForwardPass.hlsl"
        
        ENDHLSL
        }
        Pass
        {
            Name "BuiltIn ForwardAdd"
            Tags
            {
                "LightMode" = "ForwardAdd"
            }
        
        // Render State
        Blend SrcAlpha One
        ZWrite Off
        ColorMask RGB
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 3.0
        #pragma multi_compile_instancing
        #pragma multi_compile_fog
        #pragma multi_compile_fwdadd_fullshadows
        #pragma vertex vert
        #pragma fragment frag
        
        // DotsInstancingOptions: <None>
        // HybridV1InjectedBuiltinProperties: <None>
        
        // Keywords
        #pragma multi_compile _ _SCREEN_SPACE_OCCLUSION
        #pragma multi_compile _ LIGHTMAP_ON
        #pragma multi_compile _ DIRLIGHTMAP_COMBINED
        #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
        #pragma multi_compile _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS _ADDITIONAL_OFF
        #pragma multi_compile _ _ADDITIONAL_LIGHT_SHADOWS
        #pragma multi_compile _ _SHADOWS_SOFT
        #pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
        #pragma multi_compile _ SHADOWS_SHADOWMASK
        // GraphKeywords: <None>
        
        // Defines
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD1
        #define VARYINGS_NEED_POSITION_WS
        #define VARYINGS_NEED_NORMAL_WS
        #define VARYINGS_NEED_TANGENT_WS
        #define VARYINGS_NEED_VIEWDIRECTION_WS
        #define VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_FORWARD_ADD
        #define BUILTIN_TARGET_API 1
        #define _BUILTIN_SURFACE_TYPE_TRANSPARENT 1
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
        #ifdef _BUILTIN_SURFACE_TYPE_TRANSPARENT
        #define _SURFACE_TYPE_TRANSPARENT _BUILTIN_SURFACE_TYPE_TRANSPARENT
        #endif
        #ifdef _BUILTIN_ALPHATEST_ON
        #define _ALPHATEST_ON _BUILTIN_ALPHATEST_ON
        #endif
        #ifdef _BUILTIN_AlphaClip
        #define _AlphaClip _BUILTIN_AlphaClip
        #endif
        #ifdef _BUILTIN_ALPHAPREMULTIPLY_ON
        #define _ALPHAPREMULTIPLY_ON _BUILTIN_ALPHAPREMULTIPLY_ON
        #endif
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/Shim/Shims.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/LegacySurfaceVertex.hlsl"
        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/ShaderGraphFunctions.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv1 : TEXCOORD1;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 positionWS;
             float3 normalWS;
             float4 tangentWS;
             float3 viewDirectionWS;
            #if defined(LIGHTMAP_ON)
             float2 lightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
             float3 sh;
            #endif
             float4 fogFactorAndVertexLight;
             float4 shadowCoord;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float3 WorldSpaceNormal;
             float3 TangentSpaceNormal;
             float3 WorldSpaceTangent;
             float3 WorldSpaceBiTangent;
             float3 WorldSpacePosition;
             float3 AbsoluteWorldSpacePosition;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float3 interp0 : INTERP0;
             float3 interp1 : INTERP1;
             float4 interp2 : INTERP2;
             float3 interp3 : INTERP3;
             float2 interp4 : INTERP4;
             float3 interp5 : INTERP5;
             float4 interp6 : INTERP6;
             float4 interp7 : INTERP7;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.positionWS;
            output.interp1.xyz =  input.normalWS;
            output.interp2.xyzw =  input.tangentWS;
            output.interp3.xyz =  input.viewDirectionWS;
            #if defined(LIGHTMAP_ON)
            output.interp4.xy =  input.lightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
            output.interp5.xyz =  input.sh;
            #endif
            output.interp6.xyzw =  input.fogFactorAndVertexLight;
            output.interp7.xyzw =  input.shadowCoord;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.positionWS = input.interp0.xyz;
            output.normalWS = input.interp1.xyz;
            output.tangentWS = input.interp2.xyzw;
            output.viewDirectionWS = input.interp3.xyz;
            #if defined(LIGHTMAP_ON)
            output.lightmapUV = input.interp4.xy;
            #endif
            #if !defined(LIGHTMAP_ON)
            output.sh = input.interp5.xyz;
            #endif
            output.fogFactorAndVertexLight = input.interp6.xyzw;
            output.shadowCoord = input.interp7.xyzw;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _Diffuse_TexelSize;
        float4 _Normal_Map_TexelSize;
        float _Tiling;
        float _Blend;
        float _Normal_Strength;
        float _Smoothness;
        float _Metallic;
        float4 __Filter_Color;
        float4 _Emission_Color;
        float4 _Alpha_Map_TexelSize;
        float _Opacity;
        float4 _Emission_Map_TexelSize;
        float _Emission_Strength;
        float4 _Smoothness_Map_TexelSize;
        float4 _Metallic_Map_TexelSize;
        float _Ambient_Occlusion;
        float4 _Ambient_Occlusion_Map_TexelSize;
        float __Filter_Contrast;
        float _Apply_Filters;
        float __Filter_Saturation;
        CBUFFER_END
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_Diffuse);
        SAMPLER(sampler_Diffuse);
        TEXTURE2D(_Normal_Map);
        SAMPLER(sampler_Normal_Map);
        TEXTURE2D(_Alpha_Map);
        SAMPLER(sampler_Alpha_Map);
        TEXTURE2D(_Emission_Map);
        SAMPLER(sampler_Emission_Map);
        TEXTURE2D(_Smoothness_Map);
        SAMPLER(sampler_Smoothness_Map);
        TEXTURE2D(_Metallic_Map);
        SAMPLER(sampler_Metallic_Map);
        TEXTURE2D(_Ambient_Occlusion_Map);
        SAMPLER(sampler_Ambient_Occlusion_Map);
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // Graph Functions
        
        void Unity_Branch_float4(float Predicate, float4 True, float4 False, out float4 Out)
        {
            Out = Predicate ? True : False;
        }
        
        void Unity_Blend_Overlay_float4(float4 Base, float4 Blend, out float4 Out, float Opacity)
        {
            float4 result1 = 1.0 - 2.0 * (1.0 - Base) * (1.0 - Blend);
            float4 result2 = 2.0 * Base * Blend;
            float4 zeroOrOne = step(Base, 0.5);
            Out = result2 * zeroOrOne + (1 - zeroOrOne) * result1;
            Out = lerp(Base, Out, Opacity);
        }
        
        void Unity_Branch_float(float Predicate, float True, float False, out float Out)
        {
            Out = Predicate ? True : False;
        }
        
        void Unity_Contrast_float(float3 In, float Contrast, out float3 Out)
        {
            float midpoint = pow(0.5, 2.2);
            Out =  (In - midpoint) * Contrast + midpoint;
        }
        
        void Unity_Saturation_float(float3 In, float Saturation, out float3 Out)
        {
            float luma = dot(In, float3(0.2126729, 0.7151522, 0.0721750));
            Out =  luma.xxx + Saturation.xxx * (In - luma.xxx);
        }
        
        void Unity_NormalStrength_float(float3 In, float Strength, out float3 Out)
        {
            Out = float3(In.rg * Strength, lerp(1, In.b, saturate(Strength)));
        }
        
        void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float3 BaseColor;
            float3 NormalTS;
            float3 Emission;
            float Metallic;
            float Smoothness;
            float Occlusion;
            float Alpha;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float _Property_7b5fcd77ad264a83a7858d8f8361dbd7_Out_0 = _Apply_Filters;
            float4 _Property_e0ca4e34dd184733915c6122832975e4_Out_0 = __Filter_Color;
            float4 _Branch_ef11623f9e8b4e6191fcc3ea8bc1312a_Out_3;
            Unity_Branch_float4(_Property_7b5fcd77ad264a83a7858d8f8361dbd7_Out_0, _Property_e0ca4e34dd184733915c6122832975e4_Out_0, float4(0.5, 0.5, 0.5, 0), _Branch_ef11623f9e8b4e6191fcc3ea8bc1312a_Out_3);
            UnityTexture2D _Property_6c8663f0373d4b058ae8b9af5db9f43e_Out_0 = UnityBuildTexture2DStructNoScale(_Diffuse);
            float _Property_0d71a168115a4531a21482c995ff11b8_Out_0 = _Tiling;
            float _Property_a5f4da8e125f4a69b3ef8e0eee9629a9_Out_0 = _Blend;
            float3 Triplanar_f96cb0998e494774b09fab89ebb65eb5_UV = IN.AbsoluteWorldSpacePosition * _Property_0d71a168115a4531a21482c995ff11b8_Out_0;
            float3 Triplanar_f96cb0998e494774b09fab89ebb65eb5_Blend = SafePositivePow_float(IN.WorldSpaceNormal, min(_Property_a5f4da8e125f4a69b3ef8e0eee9629a9_Out_0, floor(log2(Min_float())/log2(1/sqrt(3)))) );
            Triplanar_f96cb0998e494774b09fab89ebb65eb5_Blend /= dot(Triplanar_f96cb0998e494774b09fab89ebb65eb5_Blend, 1.0);
            float4 Triplanar_f96cb0998e494774b09fab89ebb65eb5_X = SAMPLE_TEXTURE2D(_Property_6c8663f0373d4b058ae8b9af5db9f43e_Out_0.tex, _Property_6c8663f0373d4b058ae8b9af5db9f43e_Out_0.samplerstate, Triplanar_f96cb0998e494774b09fab89ebb65eb5_UV.zy);
            float4 Triplanar_f96cb0998e494774b09fab89ebb65eb5_Y = SAMPLE_TEXTURE2D(_Property_6c8663f0373d4b058ae8b9af5db9f43e_Out_0.tex, _Property_6c8663f0373d4b058ae8b9af5db9f43e_Out_0.samplerstate, Triplanar_f96cb0998e494774b09fab89ebb65eb5_UV.xz);
            float4 Triplanar_f96cb0998e494774b09fab89ebb65eb5_Z = SAMPLE_TEXTURE2D(_Property_6c8663f0373d4b058ae8b9af5db9f43e_Out_0.tex, _Property_6c8663f0373d4b058ae8b9af5db9f43e_Out_0.samplerstate, Triplanar_f96cb0998e494774b09fab89ebb65eb5_UV.xy);
            float4 _Triplanar_f96cb0998e494774b09fab89ebb65eb5_Out_0 = Triplanar_f96cb0998e494774b09fab89ebb65eb5_X * Triplanar_f96cb0998e494774b09fab89ebb65eb5_Blend.x + Triplanar_f96cb0998e494774b09fab89ebb65eb5_Y * Triplanar_f96cb0998e494774b09fab89ebb65eb5_Blend.y + Triplanar_f96cb0998e494774b09fab89ebb65eb5_Z * Triplanar_f96cb0998e494774b09fab89ebb65eb5_Blend.z;
            float4 _Blend_24c4787dcd7349eaae00fa6c3d9ca4ee_Out_2;
            Unity_Blend_Overlay_float4(_Branch_ef11623f9e8b4e6191fcc3ea8bc1312a_Out_3, _Triplanar_f96cb0998e494774b09fab89ebb65eb5_Out_0, _Blend_24c4787dcd7349eaae00fa6c3d9ca4ee_Out_2, 1);
            float _Property_4bd6ac78ba874554b874b76acf5eb180_Out_0 = _Apply_Filters;
            float _Property_8294ca47c1a14914a77bfa2e11e7db60_Out_0 = __Filter_Contrast;
            float _Branch_7646794670b149f6b60b9fe083ccac25_Out_3;
            Unity_Branch_float(_Property_4bd6ac78ba874554b874b76acf5eb180_Out_0, _Property_8294ca47c1a14914a77bfa2e11e7db60_Out_0, 1, _Branch_7646794670b149f6b60b9fe083ccac25_Out_3);
            float3 _Contrast_5087ef763a7e408686e5684e2bd7fd3d_Out_2;
            Unity_Contrast_float((_Blend_24c4787dcd7349eaae00fa6c3d9ca4ee_Out_2.xyz), _Branch_7646794670b149f6b60b9fe083ccac25_Out_3, _Contrast_5087ef763a7e408686e5684e2bd7fd3d_Out_2);
            float _Property_507c099bfb814af6aeb4eebfbbf3d34a_Out_0 = _Apply_Filters;
            float _Property_5d9b092d0e4645c594f92d6e73dc7c4c_Out_0 = __Filter_Saturation;
            float _Branch_9912f29c61804626a6ab83b323d383d5_Out_3;
            Unity_Branch_float(_Property_507c099bfb814af6aeb4eebfbbf3d34a_Out_0, _Property_5d9b092d0e4645c594f92d6e73dc7c4c_Out_0, 1, _Branch_9912f29c61804626a6ab83b323d383d5_Out_3);
            float3 _Saturation_07d8daef15d04c6db1e1f18efb74c91f_Out_2;
            Unity_Saturation_float(_Contrast_5087ef763a7e408686e5684e2bd7fd3d_Out_2, _Branch_9912f29c61804626a6ab83b323d383d5_Out_3, _Saturation_07d8daef15d04c6db1e1f18efb74c91f_Out_2);
            UnityTexture2D _Property_4d22bb373eee4057a5413b8162f92e45_Out_0 = UnityBuildTexture2DStructNoScale(_Normal_Map);
            float3 Triplanar_5e2f2d627ffc47e7b32959be7a69b8c1_UV = IN.AbsoluteWorldSpacePosition * _Property_0d71a168115a4531a21482c995ff11b8_Out_0;
            float3 Triplanar_5e2f2d627ffc47e7b32959be7a69b8c1_Blend = SafePositivePow_float(IN.WorldSpaceNormal, min(_Property_a5f4da8e125f4a69b3ef8e0eee9629a9_Out_0, floor(log2(Min_float())/log2(1/sqrt(3)))) );
            Triplanar_5e2f2d627ffc47e7b32959be7a69b8c1_Blend /= (Triplanar_5e2f2d627ffc47e7b32959be7a69b8c1_Blend.x + Triplanar_5e2f2d627ffc47e7b32959be7a69b8c1_Blend.y + Triplanar_5e2f2d627ffc47e7b32959be7a69b8c1_Blend.z ).xxx;
            float3 Triplanar_5e2f2d627ffc47e7b32959be7a69b8c1_X = UnpackNormal(SAMPLE_TEXTURE2D(_Property_4d22bb373eee4057a5413b8162f92e45_Out_0.tex, _Property_4d22bb373eee4057a5413b8162f92e45_Out_0.samplerstate, Triplanar_5e2f2d627ffc47e7b32959be7a69b8c1_UV.zy));
            float3 Triplanar_5e2f2d627ffc47e7b32959be7a69b8c1_Y = UnpackNormal(SAMPLE_TEXTURE2D(_Property_4d22bb373eee4057a5413b8162f92e45_Out_0.tex, _Property_4d22bb373eee4057a5413b8162f92e45_Out_0.samplerstate, Triplanar_5e2f2d627ffc47e7b32959be7a69b8c1_UV.xz));
            float3 Triplanar_5e2f2d627ffc47e7b32959be7a69b8c1_Z = UnpackNormal(SAMPLE_TEXTURE2D(_Property_4d22bb373eee4057a5413b8162f92e45_Out_0.tex, _Property_4d22bb373eee4057a5413b8162f92e45_Out_0.samplerstate, Triplanar_5e2f2d627ffc47e7b32959be7a69b8c1_UV.xy));
            Triplanar_5e2f2d627ffc47e7b32959be7a69b8c1_X = float3(Triplanar_5e2f2d627ffc47e7b32959be7a69b8c1_X.xy + IN.WorldSpaceNormal.zy, abs(Triplanar_5e2f2d627ffc47e7b32959be7a69b8c1_X.z) * IN.WorldSpaceNormal.x);
            Triplanar_5e2f2d627ffc47e7b32959be7a69b8c1_Y = float3(Triplanar_5e2f2d627ffc47e7b32959be7a69b8c1_Y.xy + IN.WorldSpaceNormal.xz, abs(Triplanar_5e2f2d627ffc47e7b32959be7a69b8c1_Y.z) * IN.WorldSpaceNormal.y);
            Triplanar_5e2f2d627ffc47e7b32959be7a69b8c1_Z = float3(Triplanar_5e2f2d627ffc47e7b32959be7a69b8c1_Z.xy + IN.WorldSpaceNormal.xy, abs(Triplanar_5e2f2d627ffc47e7b32959be7a69b8c1_Z.z) * IN.WorldSpaceNormal.z);
            float4 _Triplanar_5e2f2d627ffc47e7b32959be7a69b8c1_Out_0 = float4(normalize(Triplanar_5e2f2d627ffc47e7b32959be7a69b8c1_X.zyx * Triplanar_5e2f2d627ffc47e7b32959be7a69b8c1_Blend.x + Triplanar_5e2f2d627ffc47e7b32959be7a69b8c1_Y.xzy * Triplanar_5e2f2d627ffc47e7b32959be7a69b8c1_Blend.y + Triplanar_5e2f2d627ffc47e7b32959be7a69b8c1_Z.xyz * Triplanar_5e2f2d627ffc47e7b32959be7a69b8c1_Blend.z), 1);
            float3x3 Triplanar_5e2f2d627ffc47e7b32959be7a69b8c1_Transform = float3x3(IN.WorldSpaceTangent, IN.WorldSpaceBiTangent, IN.WorldSpaceNormal);
            _Triplanar_5e2f2d627ffc47e7b32959be7a69b8c1_Out_0.rgb = TransformWorldToTangent(_Triplanar_5e2f2d627ffc47e7b32959be7a69b8c1_Out_0.rgb, Triplanar_5e2f2d627ffc47e7b32959be7a69b8c1_Transform);
            float _Property_465f1954a0214426b47c7da2af048f07_Out_0 = _Normal_Strength;
            float3 _NormalStrength_530366de39034d288415f2bd44ee2d24_Out_2;
            Unity_NormalStrength_float((_Triplanar_5e2f2d627ffc47e7b32959be7a69b8c1_Out_0.xyz), _Property_465f1954a0214426b47c7da2af048f07_Out_0, _NormalStrength_530366de39034d288415f2bd44ee2d24_Out_2);
            UnityTexture2D _Property_36a8b919311a4525bb742e047b0c7fad_Out_0 = UnityBuildTexture2DStructNoScale(_Emission_Map);
            float3 Triplanar_d184924eec244d279d611947e624fc09_UV = IN.AbsoluteWorldSpacePosition * _Property_0d71a168115a4531a21482c995ff11b8_Out_0;
            float3 Triplanar_d184924eec244d279d611947e624fc09_Blend = SafePositivePow_float(IN.WorldSpaceNormal, min(_Property_a5f4da8e125f4a69b3ef8e0eee9629a9_Out_0, floor(log2(Min_float())/log2(1/sqrt(3)))) );
            Triplanar_d184924eec244d279d611947e624fc09_Blend /= dot(Triplanar_d184924eec244d279d611947e624fc09_Blend, 1.0);
            float4 Triplanar_d184924eec244d279d611947e624fc09_X = SAMPLE_TEXTURE2D(_Property_36a8b919311a4525bb742e047b0c7fad_Out_0.tex, _Property_36a8b919311a4525bb742e047b0c7fad_Out_0.samplerstate, Triplanar_d184924eec244d279d611947e624fc09_UV.zy);
            float4 Triplanar_d184924eec244d279d611947e624fc09_Y = SAMPLE_TEXTURE2D(_Property_36a8b919311a4525bb742e047b0c7fad_Out_0.tex, _Property_36a8b919311a4525bb742e047b0c7fad_Out_0.samplerstate, Triplanar_d184924eec244d279d611947e624fc09_UV.xz);
            float4 Triplanar_d184924eec244d279d611947e624fc09_Z = SAMPLE_TEXTURE2D(_Property_36a8b919311a4525bb742e047b0c7fad_Out_0.tex, _Property_36a8b919311a4525bb742e047b0c7fad_Out_0.samplerstate, Triplanar_d184924eec244d279d611947e624fc09_UV.xy);
            float4 _Triplanar_d184924eec244d279d611947e624fc09_Out_0 = Triplanar_d184924eec244d279d611947e624fc09_X * Triplanar_d184924eec244d279d611947e624fc09_Blend.x + Triplanar_d184924eec244d279d611947e624fc09_Y * Triplanar_d184924eec244d279d611947e624fc09_Blend.y + Triplanar_d184924eec244d279d611947e624fc09_Z * Triplanar_d184924eec244d279d611947e624fc09_Blend.z;
            float4 _Property_d19f06a576904574bc1ce7a4bc0705de_Out_0 = IsGammaSpace() ? LinearToSRGB(_Emission_Color) : _Emission_Color;
            float _Property_8538694bbc6046818d0fe00a0884c6e1_Out_0 = _Emission_Strength;
            float4 _Multiply_a9f07d97808a4c1a81856fe1fc446ee1_Out_2;
            Unity_Multiply_float4_float4(_Property_d19f06a576904574bc1ce7a4bc0705de_Out_0, (_Property_8538694bbc6046818d0fe00a0884c6e1_Out_0.xxxx), _Multiply_a9f07d97808a4c1a81856fe1fc446ee1_Out_2);
            float4 _Multiply_b2871317a9804ae491f162ac9a41c7ee_Out_2;
            Unity_Multiply_float4_float4(_Triplanar_d184924eec244d279d611947e624fc09_Out_0, _Multiply_a9f07d97808a4c1a81856fe1fc446ee1_Out_2, _Multiply_b2871317a9804ae491f162ac9a41c7ee_Out_2);
            UnityTexture2D _Property_2645d69dc6fc44eabeb03b508fa73fa2_Out_0 = UnityBuildTexture2DStructNoScale(_Metallic_Map);
            float3 Triplanar_72251408cf774e2cb2bb6dade546d69f_UV = IN.AbsoluteWorldSpacePosition * _Property_0d71a168115a4531a21482c995ff11b8_Out_0;
            float3 Triplanar_72251408cf774e2cb2bb6dade546d69f_Blend = SafePositivePow_float(IN.WorldSpaceNormal, min(_Property_a5f4da8e125f4a69b3ef8e0eee9629a9_Out_0, floor(log2(Min_float())/log2(1/sqrt(3)))) );
            Triplanar_72251408cf774e2cb2bb6dade546d69f_Blend /= dot(Triplanar_72251408cf774e2cb2bb6dade546d69f_Blend, 1.0);
            float4 Triplanar_72251408cf774e2cb2bb6dade546d69f_X = SAMPLE_TEXTURE2D(_Property_2645d69dc6fc44eabeb03b508fa73fa2_Out_0.tex, _Property_2645d69dc6fc44eabeb03b508fa73fa2_Out_0.samplerstate, Triplanar_72251408cf774e2cb2bb6dade546d69f_UV.zy);
            float4 Triplanar_72251408cf774e2cb2bb6dade546d69f_Y = SAMPLE_TEXTURE2D(_Property_2645d69dc6fc44eabeb03b508fa73fa2_Out_0.tex, _Property_2645d69dc6fc44eabeb03b508fa73fa2_Out_0.samplerstate, Triplanar_72251408cf774e2cb2bb6dade546d69f_UV.xz);
            float4 Triplanar_72251408cf774e2cb2bb6dade546d69f_Z = SAMPLE_TEXTURE2D(_Property_2645d69dc6fc44eabeb03b508fa73fa2_Out_0.tex, _Property_2645d69dc6fc44eabeb03b508fa73fa2_Out_0.samplerstate, Triplanar_72251408cf774e2cb2bb6dade546d69f_UV.xy);
            float4 _Triplanar_72251408cf774e2cb2bb6dade546d69f_Out_0 = Triplanar_72251408cf774e2cb2bb6dade546d69f_X * Triplanar_72251408cf774e2cb2bb6dade546d69f_Blend.x + Triplanar_72251408cf774e2cb2bb6dade546d69f_Y * Triplanar_72251408cf774e2cb2bb6dade546d69f_Blend.y + Triplanar_72251408cf774e2cb2bb6dade546d69f_Z * Triplanar_72251408cf774e2cb2bb6dade546d69f_Blend.z;
            float _Property_a2de0712f3e74597a69dcb9c906c8323_Out_0 = _Metallic;
            float4 _Multiply_51419fc37ba3467492dc6057f62e848a_Out_2;
            Unity_Multiply_float4_float4(_Triplanar_72251408cf774e2cb2bb6dade546d69f_Out_0, (_Property_a2de0712f3e74597a69dcb9c906c8323_Out_0.xxxx), _Multiply_51419fc37ba3467492dc6057f62e848a_Out_2);
            UnityTexture2D _Property_2044c0171961481a87c99454b70146f3_Out_0 = UnityBuildTexture2DStructNoScale(_Smoothness_Map);
            float3 Triplanar_b21e7971fc0e4b8a966ee4585dca400a_UV = IN.AbsoluteWorldSpacePosition * _Property_0d71a168115a4531a21482c995ff11b8_Out_0;
            float3 Triplanar_b21e7971fc0e4b8a966ee4585dca400a_Blend = SafePositivePow_float(IN.WorldSpaceNormal, min(_Property_a5f4da8e125f4a69b3ef8e0eee9629a9_Out_0, floor(log2(Min_float())/log2(1/sqrt(3)))) );
            Triplanar_b21e7971fc0e4b8a966ee4585dca400a_Blend /= dot(Triplanar_b21e7971fc0e4b8a966ee4585dca400a_Blend, 1.0);
            float4 Triplanar_b21e7971fc0e4b8a966ee4585dca400a_X = SAMPLE_TEXTURE2D(_Property_2044c0171961481a87c99454b70146f3_Out_0.tex, _Property_2044c0171961481a87c99454b70146f3_Out_0.samplerstate, Triplanar_b21e7971fc0e4b8a966ee4585dca400a_UV.zy);
            float4 Triplanar_b21e7971fc0e4b8a966ee4585dca400a_Y = SAMPLE_TEXTURE2D(_Property_2044c0171961481a87c99454b70146f3_Out_0.tex, _Property_2044c0171961481a87c99454b70146f3_Out_0.samplerstate, Triplanar_b21e7971fc0e4b8a966ee4585dca400a_UV.xz);
            float4 Triplanar_b21e7971fc0e4b8a966ee4585dca400a_Z = SAMPLE_TEXTURE2D(_Property_2044c0171961481a87c99454b70146f3_Out_0.tex, _Property_2044c0171961481a87c99454b70146f3_Out_0.samplerstate, Triplanar_b21e7971fc0e4b8a966ee4585dca400a_UV.xy);
            float4 _Triplanar_b21e7971fc0e4b8a966ee4585dca400a_Out_0 = Triplanar_b21e7971fc0e4b8a966ee4585dca400a_X * Triplanar_b21e7971fc0e4b8a966ee4585dca400a_Blend.x + Triplanar_b21e7971fc0e4b8a966ee4585dca400a_Y * Triplanar_b21e7971fc0e4b8a966ee4585dca400a_Blend.y + Triplanar_b21e7971fc0e4b8a966ee4585dca400a_Z * Triplanar_b21e7971fc0e4b8a966ee4585dca400a_Blend.z;
            float _Property_6ac0f3d590a04d70b9b65f930607378e_Out_0 = _Smoothness;
            float4 _Multiply_1190034063a742598e70497b24a917d6_Out_2;
            Unity_Multiply_float4_float4(_Triplanar_b21e7971fc0e4b8a966ee4585dca400a_Out_0, (_Property_6ac0f3d590a04d70b9b65f930607378e_Out_0.xxxx), _Multiply_1190034063a742598e70497b24a917d6_Out_2);
            UnityTexture2D _Property_6fda6f621b89424d81cce741b5c87cfb_Out_0 = UnityBuildTexture2DStructNoScale(_Ambient_Occlusion_Map);
            float3 Triplanar_c18df43557c74ecf9550fa6e5f01b85a_UV = IN.AbsoluteWorldSpacePosition * _Property_0d71a168115a4531a21482c995ff11b8_Out_0;
            float3 Triplanar_c18df43557c74ecf9550fa6e5f01b85a_Blend = SafePositivePow_float(IN.WorldSpaceNormal, min(_Property_a5f4da8e125f4a69b3ef8e0eee9629a9_Out_0, floor(log2(Min_float())/log2(1/sqrt(3)))) );
            Triplanar_c18df43557c74ecf9550fa6e5f01b85a_Blend /= dot(Triplanar_c18df43557c74ecf9550fa6e5f01b85a_Blend, 1.0);
            float4 Triplanar_c18df43557c74ecf9550fa6e5f01b85a_X = SAMPLE_TEXTURE2D(_Property_6fda6f621b89424d81cce741b5c87cfb_Out_0.tex, _Property_6fda6f621b89424d81cce741b5c87cfb_Out_0.samplerstate, Triplanar_c18df43557c74ecf9550fa6e5f01b85a_UV.zy);
            float4 Triplanar_c18df43557c74ecf9550fa6e5f01b85a_Y = SAMPLE_TEXTURE2D(_Property_6fda6f621b89424d81cce741b5c87cfb_Out_0.tex, _Property_6fda6f621b89424d81cce741b5c87cfb_Out_0.samplerstate, Triplanar_c18df43557c74ecf9550fa6e5f01b85a_UV.xz);
            float4 Triplanar_c18df43557c74ecf9550fa6e5f01b85a_Z = SAMPLE_TEXTURE2D(_Property_6fda6f621b89424d81cce741b5c87cfb_Out_0.tex, _Property_6fda6f621b89424d81cce741b5c87cfb_Out_0.samplerstate, Triplanar_c18df43557c74ecf9550fa6e5f01b85a_UV.xy);
            float4 _Triplanar_c18df43557c74ecf9550fa6e5f01b85a_Out_0 = Triplanar_c18df43557c74ecf9550fa6e5f01b85a_X * Triplanar_c18df43557c74ecf9550fa6e5f01b85a_Blend.x + Triplanar_c18df43557c74ecf9550fa6e5f01b85a_Y * Triplanar_c18df43557c74ecf9550fa6e5f01b85a_Blend.y + Triplanar_c18df43557c74ecf9550fa6e5f01b85a_Z * Triplanar_c18df43557c74ecf9550fa6e5f01b85a_Blend.z;
            float _Property_b41c1f0171a8491283bb490d369c1633_Out_0 = _Ambient_Occlusion;
            float4 _Multiply_8460e617a2774fc4a9bc1b8ac4b4c498_Out_2;
            Unity_Multiply_float4_float4(_Triplanar_c18df43557c74ecf9550fa6e5f01b85a_Out_0, (_Property_b41c1f0171a8491283bb490d369c1633_Out_0.xxxx), _Multiply_8460e617a2774fc4a9bc1b8ac4b4c498_Out_2);
            float _Property_85bb0cea7a3e455b96bc35eef9b04b52_Out_0 = _Opacity;
            UnityTexture2D _Property_4ffddeb9667041dea5361019922617c3_Out_0 = UnityBuildTexture2DStructNoScale(_Alpha_Map);
            float3 Triplanar_6f2fd2dbd39f45f1b46f5b62d6f1ccb8_UV = IN.AbsoluteWorldSpacePosition * _Property_0d71a168115a4531a21482c995ff11b8_Out_0;
            float3 Triplanar_6f2fd2dbd39f45f1b46f5b62d6f1ccb8_Blend = SafePositivePow_float(IN.WorldSpaceNormal, min(_Property_a5f4da8e125f4a69b3ef8e0eee9629a9_Out_0, floor(log2(Min_float())/log2(1/sqrt(3)))) );
            Triplanar_6f2fd2dbd39f45f1b46f5b62d6f1ccb8_Blend /= dot(Triplanar_6f2fd2dbd39f45f1b46f5b62d6f1ccb8_Blend, 1.0);
            float4 Triplanar_6f2fd2dbd39f45f1b46f5b62d6f1ccb8_X = SAMPLE_TEXTURE2D(_Property_4ffddeb9667041dea5361019922617c3_Out_0.tex, _Property_4ffddeb9667041dea5361019922617c3_Out_0.samplerstate, Triplanar_6f2fd2dbd39f45f1b46f5b62d6f1ccb8_UV.zy);
            float4 Triplanar_6f2fd2dbd39f45f1b46f5b62d6f1ccb8_Y = SAMPLE_TEXTURE2D(_Property_4ffddeb9667041dea5361019922617c3_Out_0.tex, _Property_4ffddeb9667041dea5361019922617c3_Out_0.samplerstate, Triplanar_6f2fd2dbd39f45f1b46f5b62d6f1ccb8_UV.xz);
            float4 Triplanar_6f2fd2dbd39f45f1b46f5b62d6f1ccb8_Z = SAMPLE_TEXTURE2D(_Property_4ffddeb9667041dea5361019922617c3_Out_0.tex, _Property_4ffddeb9667041dea5361019922617c3_Out_0.samplerstate, Triplanar_6f2fd2dbd39f45f1b46f5b62d6f1ccb8_UV.xy);
            float4 _Triplanar_6f2fd2dbd39f45f1b46f5b62d6f1ccb8_Out_0 = Triplanar_6f2fd2dbd39f45f1b46f5b62d6f1ccb8_X * Triplanar_6f2fd2dbd39f45f1b46f5b62d6f1ccb8_Blend.x + Triplanar_6f2fd2dbd39f45f1b46f5b62d6f1ccb8_Y * Triplanar_6f2fd2dbd39f45f1b46f5b62d6f1ccb8_Blend.y + Triplanar_6f2fd2dbd39f45f1b46f5b62d6f1ccb8_Z * Triplanar_6f2fd2dbd39f45f1b46f5b62d6f1ccb8_Blend.z;
            float4 _Multiply_969d0f17e76149089b7efa601089c78e_Out_2;
            Unity_Multiply_float4_float4((_Property_85bb0cea7a3e455b96bc35eef9b04b52_Out_0.xxxx), _Triplanar_6f2fd2dbd39f45f1b46f5b62d6f1ccb8_Out_0, _Multiply_969d0f17e76149089b7efa601089c78e_Out_2);
            surface.BaseColor = _Saturation_07d8daef15d04c6db1e1f18efb74c91f_Out_2;
            surface.NormalTS = _NormalStrength_530366de39034d288415f2bd44ee2d24_Out_2;
            surface.Emission = (_Multiply_b2871317a9804ae491f162ac9a41c7ee_Out_2.xyz);
            surface.Metallic = (_Multiply_51419fc37ba3467492dc6057f62e848a_Out_2).x;
            surface.Smoothness = (_Multiply_1190034063a742598e70497b24a917d6_Out_2).x;
            surface.Occlusion = (_Multiply_8460e617a2774fc4a9bc1b8ac4b4c498_Out_2).x;
            surface.Alpha = (_Multiply_969d0f17e76149089b7efa601089c78e_Out_2).x;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
            
        
            // must use interpolated tangent, bitangent and normal before they are normalized in the pixel shader.
            float3 unnormalizedNormalWS = input.normalWS;
            const float renormFactor = 1.0 / length(unnormalizedNormalWS);
        
            // use bitangent on the fly like in hdrp
            // IMPORTANT! If we ever support Flip on double sided materials ensure bitangent and tangent are NOT flipped.
            float crossSign = (input.tangentWS.w > 0.0 ? 1.0 : -1.0)* GetOddNegativeScale();
            float3 bitang = crossSign * cross(input.normalWS.xyz, input.tangentWS.xyz);
        
            output.WorldSpaceNormal = renormFactor * input.normalWS.xyz;      // we want a unit length Normal Vector node in shader graph
            output.TangentSpaceNormal = float3(0.0f, 0.0f, 1.0f);
        
            // to preserve mikktspace compliance we use same scale renormFactor as was used on the normal.
            // This is explained in section 2.2 in "surface gradient based bump mapping framework"
            output.WorldSpaceTangent = renormFactor * input.tangentWS.xyz;
            output.WorldSpaceBiTangent = renormFactor * bitang;
        
            output.WorldSpacePosition = input.positionWS;
            output.AbsoluteWorldSpacePosition = GetAbsolutePositionWS(input.positionWS);
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        void BuildAppDataFull(Attributes attributes, VertexDescription vertexDescription, inout appdata_full result)
        {
            result.vertex     = float4(attributes.positionOS, 1);
            result.tangent    = attributes.tangentOS;
            result.normal     = attributes.normalOS;
            result.texcoord1  = attributes.uv1;
            result.vertex     = float4(vertexDescription.Position, 1);
            result.normal     = vertexDescription.Normal;
            result.tangent    = float4(vertexDescription.Tangent, 0);
            #if UNITY_ANY_INSTANCING_ENABLED
            #endif
        }
        
        void VaryingsToSurfaceVertex(Varyings varyings, inout v2f_surf result)
        {
            result.pos = varyings.positionCS;
            result.worldPos = varyings.positionWS;
            result.worldNormal = varyings.normalWS;
            result.viewDir = varyings.viewDirectionWS;
            // World Tangent isn't an available input on v2f_surf
        
            result._ShadowCoord = varyings.shadowCoord;
        
            #if UNITY_ANY_INSTANCING_ENABLED
            #endif
            #if !defined(LIGHTMAP_ON)
            #if UNITY_SHOULD_SAMPLE_SH
            result.sh = varyings.sh;
            #endif
            #endif
            #if defined(LIGHTMAP_ON)
            result.lmap.xy = varyings.lightmapUV;
            #endif
            #ifdef VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
                result.fogCoord = varyings.fogFactorAndVertexLight.x;
                COPY_TO_LIGHT_COORDS(result, varyings.fogFactorAndVertexLight.yzw);
            #endif
        
            DEFAULT_UNITY_TRANSFER_VERTEX_OUTPUT_STEREO(varyings, result);
        }
        
        void SurfaceVertexToVaryings(v2f_surf surfVertex, inout Varyings result)
        {
            result.positionCS = surfVertex.pos;
            result.positionWS = surfVertex.worldPos;
            result.normalWS = surfVertex.worldNormal;
            // viewDirectionWS is never filled out in the legacy pass' function. Always use the value computed by SRP
            // World Tangent isn't an available input on v2f_surf
            result.shadowCoord = surfVertex._ShadowCoord;
        
            #if UNITY_ANY_INSTANCING_ENABLED
            #endif
            #if !defined(LIGHTMAP_ON)
            #if UNITY_SHOULD_SAMPLE_SH
            result.sh = surfVertex.sh;
            #endif
            #endif
            #if defined(LIGHTMAP_ON)
            result.lightmapUV = surfVertex.lmap.xy;
            #endif
            #ifdef VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
                result.fogFactorAndVertexLight.x = surfVertex.fogCoord;
                COPY_FROM_LIGHT_COORDS(result.fogFactorAndVertexLight.yzw, surfVertex);
            #endif
        
            DEFAULT_UNITY_TRANSFER_VERTEX_OUTPUT_STEREO(surfVertex, result);
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/PBRForwardAddPass.hlsl"
        
        ENDHLSL
        }
        Pass
        {
            Name "BuiltIn Deferred"
            Tags
            {
                "LightMode" = "Deferred"
            }
        
        // Render State
        Cull Back
        Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
        ZTest LEqual
        ZWrite Off
        ColorMask RGB
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 4.5
        #pragma multi_compile_instancing
        #pragma exclude_renderers nomrt
        #pragma multi_compile_prepassfinal
        #pragma skip_variants FOG_LINEAR FOG_EXP FOG_EXP2
        #pragma vertex vert
        #pragma fragment frag
        
        // DotsInstancingOptions: <None>
        // HybridV1InjectedBuiltinProperties: <None>
        
        // Keywords
        #pragma multi_compile _ LIGHTMAP_ON
        #pragma multi_compile _ DIRLIGHTMAP_COMBINED
        #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
        #pragma multi_compile _ _SHADOWS_SOFT
        #pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
        #pragma multi_compile _ _MIXED_LIGHTING_SUBTRACTIVE
        #pragma multi_compile _ _GBUFFER_NORMALS_OCT
        // GraphKeywords: <None>
        
        // Defines
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD1
        #define VARYINGS_NEED_POSITION_WS
        #define VARYINGS_NEED_NORMAL_WS
        #define VARYINGS_NEED_TANGENT_WS
        #define VARYINGS_NEED_VIEWDIRECTION_WS
        #define VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_DEFERRED
        #define BUILTIN_TARGET_API 1
        #define _BUILTIN_SURFACE_TYPE_TRANSPARENT 1
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
        #ifdef _BUILTIN_SURFACE_TYPE_TRANSPARENT
        #define _SURFACE_TYPE_TRANSPARENT _BUILTIN_SURFACE_TYPE_TRANSPARENT
        #endif
        #ifdef _BUILTIN_ALPHATEST_ON
        #define _ALPHATEST_ON _BUILTIN_ALPHATEST_ON
        #endif
        #ifdef _BUILTIN_AlphaClip
        #define _AlphaClip _BUILTIN_AlphaClip
        #endif
        #ifdef _BUILTIN_ALPHAPREMULTIPLY_ON
        #define _ALPHAPREMULTIPLY_ON _BUILTIN_ALPHAPREMULTIPLY_ON
        #endif
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/Shim/Shims.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/LegacySurfaceVertex.hlsl"
        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/ShaderGraphFunctions.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv1 : TEXCOORD1;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 positionWS;
             float3 normalWS;
             float4 tangentWS;
             float3 viewDirectionWS;
            #if defined(LIGHTMAP_ON)
             float2 lightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
             float3 sh;
            #endif
             float4 fogFactorAndVertexLight;
             float4 shadowCoord;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float3 WorldSpaceNormal;
             float3 TangentSpaceNormal;
             float3 WorldSpaceTangent;
             float3 WorldSpaceBiTangent;
             float3 WorldSpacePosition;
             float3 AbsoluteWorldSpacePosition;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float3 interp0 : INTERP0;
             float3 interp1 : INTERP1;
             float4 interp2 : INTERP2;
             float3 interp3 : INTERP3;
             float2 interp4 : INTERP4;
             float3 interp5 : INTERP5;
             float4 interp6 : INTERP6;
             float4 interp7 : INTERP7;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.positionWS;
            output.interp1.xyz =  input.normalWS;
            output.interp2.xyzw =  input.tangentWS;
            output.interp3.xyz =  input.viewDirectionWS;
            #if defined(LIGHTMAP_ON)
            output.interp4.xy =  input.lightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
            output.interp5.xyz =  input.sh;
            #endif
            output.interp6.xyzw =  input.fogFactorAndVertexLight;
            output.interp7.xyzw =  input.shadowCoord;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.positionWS = input.interp0.xyz;
            output.normalWS = input.interp1.xyz;
            output.tangentWS = input.interp2.xyzw;
            output.viewDirectionWS = input.interp3.xyz;
            #if defined(LIGHTMAP_ON)
            output.lightmapUV = input.interp4.xy;
            #endif
            #if !defined(LIGHTMAP_ON)
            output.sh = input.interp5.xyz;
            #endif
            output.fogFactorAndVertexLight = input.interp6.xyzw;
            output.shadowCoord = input.interp7.xyzw;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _Diffuse_TexelSize;
        float4 _Normal_Map_TexelSize;
        float _Tiling;
        float _Blend;
        float _Normal_Strength;
        float _Smoothness;
        float _Metallic;
        float4 __Filter_Color;
        float4 _Emission_Color;
        float4 _Alpha_Map_TexelSize;
        float _Opacity;
        float4 _Emission_Map_TexelSize;
        float _Emission_Strength;
        float4 _Smoothness_Map_TexelSize;
        float4 _Metallic_Map_TexelSize;
        float _Ambient_Occlusion;
        float4 _Ambient_Occlusion_Map_TexelSize;
        float __Filter_Contrast;
        float _Apply_Filters;
        float __Filter_Saturation;
        CBUFFER_END
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_Diffuse);
        SAMPLER(sampler_Diffuse);
        TEXTURE2D(_Normal_Map);
        SAMPLER(sampler_Normal_Map);
        TEXTURE2D(_Alpha_Map);
        SAMPLER(sampler_Alpha_Map);
        TEXTURE2D(_Emission_Map);
        SAMPLER(sampler_Emission_Map);
        TEXTURE2D(_Smoothness_Map);
        SAMPLER(sampler_Smoothness_Map);
        TEXTURE2D(_Metallic_Map);
        SAMPLER(sampler_Metallic_Map);
        TEXTURE2D(_Ambient_Occlusion_Map);
        SAMPLER(sampler_Ambient_Occlusion_Map);
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // Graph Functions
        
        void Unity_Branch_float4(float Predicate, float4 True, float4 False, out float4 Out)
        {
            Out = Predicate ? True : False;
        }
        
        void Unity_Blend_Overlay_float4(float4 Base, float4 Blend, out float4 Out, float Opacity)
        {
            float4 result1 = 1.0 - 2.0 * (1.0 - Base) * (1.0 - Blend);
            float4 result2 = 2.0 * Base * Blend;
            float4 zeroOrOne = step(Base, 0.5);
            Out = result2 * zeroOrOne + (1 - zeroOrOne) * result1;
            Out = lerp(Base, Out, Opacity);
        }
        
        void Unity_Branch_float(float Predicate, float True, float False, out float Out)
        {
            Out = Predicate ? True : False;
        }
        
        void Unity_Contrast_float(float3 In, float Contrast, out float3 Out)
        {
            float midpoint = pow(0.5, 2.2);
            Out =  (In - midpoint) * Contrast + midpoint;
        }
        
        void Unity_Saturation_float(float3 In, float Saturation, out float3 Out)
        {
            float luma = dot(In, float3(0.2126729, 0.7151522, 0.0721750));
            Out =  luma.xxx + Saturation.xxx * (In - luma.xxx);
        }
        
        void Unity_NormalStrength_float(float3 In, float Strength, out float3 Out)
        {
            Out = float3(In.rg * Strength, lerp(1, In.b, saturate(Strength)));
        }
        
        void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float3 BaseColor;
            float3 NormalTS;
            float3 Emission;
            float Metallic;
            float Smoothness;
            float Occlusion;
            float Alpha;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float _Property_7b5fcd77ad264a83a7858d8f8361dbd7_Out_0 = _Apply_Filters;
            float4 _Property_e0ca4e34dd184733915c6122832975e4_Out_0 = __Filter_Color;
            float4 _Branch_ef11623f9e8b4e6191fcc3ea8bc1312a_Out_3;
            Unity_Branch_float4(_Property_7b5fcd77ad264a83a7858d8f8361dbd7_Out_0, _Property_e0ca4e34dd184733915c6122832975e4_Out_0, float4(0.5, 0.5, 0.5, 0), _Branch_ef11623f9e8b4e6191fcc3ea8bc1312a_Out_3);
            UnityTexture2D _Property_6c8663f0373d4b058ae8b9af5db9f43e_Out_0 = UnityBuildTexture2DStructNoScale(_Diffuse);
            float _Property_0d71a168115a4531a21482c995ff11b8_Out_0 = _Tiling;
            float _Property_a5f4da8e125f4a69b3ef8e0eee9629a9_Out_0 = _Blend;
            float3 Triplanar_f96cb0998e494774b09fab89ebb65eb5_UV = IN.AbsoluteWorldSpacePosition * _Property_0d71a168115a4531a21482c995ff11b8_Out_0;
            float3 Triplanar_f96cb0998e494774b09fab89ebb65eb5_Blend = SafePositivePow_float(IN.WorldSpaceNormal, min(_Property_a5f4da8e125f4a69b3ef8e0eee9629a9_Out_0, floor(log2(Min_float())/log2(1/sqrt(3)))) );
            Triplanar_f96cb0998e494774b09fab89ebb65eb5_Blend /= dot(Triplanar_f96cb0998e494774b09fab89ebb65eb5_Blend, 1.0);
            float4 Triplanar_f96cb0998e494774b09fab89ebb65eb5_X = SAMPLE_TEXTURE2D(_Property_6c8663f0373d4b058ae8b9af5db9f43e_Out_0.tex, _Property_6c8663f0373d4b058ae8b9af5db9f43e_Out_0.samplerstate, Triplanar_f96cb0998e494774b09fab89ebb65eb5_UV.zy);
            float4 Triplanar_f96cb0998e494774b09fab89ebb65eb5_Y = SAMPLE_TEXTURE2D(_Property_6c8663f0373d4b058ae8b9af5db9f43e_Out_0.tex, _Property_6c8663f0373d4b058ae8b9af5db9f43e_Out_0.samplerstate, Triplanar_f96cb0998e494774b09fab89ebb65eb5_UV.xz);
            float4 Triplanar_f96cb0998e494774b09fab89ebb65eb5_Z = SAMPLE_TEXTURE2D(_Property_6c8663f0373d4b058ae8b9af5db9f43e_Out_0.tex, _Property_6c8663f0373d4b058ae8b9af5db9f43e_Out_0.samplerstate, Triplanar_f96cb0998e494774b09fab89ebb65eb5_UV.xy);
            float4 _Triplanar_f96cb0998e494774b09fab89ebb65eb5_Out_0 = Triplanar_f96cb0998e494774b09fab89ebb65eb5_X * Triplanar_f96cb0998e494774b09fab89ebb65eb5_Blend.x + Triplanar_f96cb0998e494774b09fab89ebb65eb5_Y * Triplanar_f96cb0998e494774b09fab89ebb65eb5_Blend.y + Triplanar_f96cb0998e494774b09fab89ebb65eb5_Z * Triplanar_f96cb0998e494774b09fab89ebb65eb5_Blend.z;
            float4 _Blend_24c4787dcd7349eaae00fa6c3d9ca4ee_Out_2;
            Unity_Blend_Overlay_float4(_Branch_ef11623f9e8b4e6191fcc3ea8bc1312a_Out_3, _Triplanar_f96cb0998e494774b09fab89ebb65eb5_Out_0, _Blend_24c4787dcd7349eaae00fa6c3d9ca4ee_Out_2, 1);
            float _Property_4bd6ac78ba874554b874b76acf5eb180_Out_0 = _Apply_Filters;
            float _Property_8294ca47c1a14914a77bfa2e11e7db60_Out_0 = __Filter_Contrast;
            float _Branch_7646794670b149f6b60b9fe083ccac25_Out_3;
            Unity_Branch_float(_Property_4bd6ac78ba874554b874b76acf5eb180_Out_0, _Property_8294ca47c1a14914a77bfa2e11e7db60_Out_0, 1, _Branch_7646794670b149f6b60b9fe083ccac25_Out_3);
            float3 _Contrast_5087ef763a7e408686e5684e2bd7fd3d_Out_2;
            Unity_Contrast_float((_Blend_24c4787dcd7349eaae00fa6c3d9ca4ee_Out_2.xyz), _Branch_7646794670b149f6b60b9fe083ccac25_Out_3, _Contrast_5087ef763a7e408686e5684e2bd7fd3d_Out_2);
            float _Property_507c099bfb814af6aeb4eebfbbf3d34a_Out_0 = _Apply_Filters;
            float _Property_5d9b092d0e4645c594f92d6e73dc7c4c_Out_0 = __Filter_Saturation;
            float _Branch_9912f29c61804626a6ab83b323d383d5_Out_3;
            Unity_Branch_float(_Property_507c099bfb814af6aeb4eebfbbf3d34a_Out_0, _Property_5d9b092d0e4645c594f92d6e73dc7c4c_Out_0, 1, _Branch_9912f29c61804626a6ab83b323d383d5_Out_3);
            float3 _Saturation_07d8daef15d04c6db1e1f18efb74c91f_Out_2;
            Unity_Saturation_float(_Contrast_5087ef763a7e408686e5684e2bd7fd3d_Out_2, _Branch_9912f29c61804626a6ab83b323d383d5_Out_3, _Saturation_07d8daef15d04c6db1e1f18efb74c91f_Out_2);
            UnityTexture2D _Property_4d22bb373eee4057a5413b8162f92e45_Out_0 = UnityBuildTexture2DStructNoScale(_Normal_Map);
            float3 Triplanar_5e2f2d627ffc47e7b32959be7a69b8c1_UV = IN.AbsoluteWorldSpacePosition * _Property_0d71a168115a4531a21482c995ff11b8_Out_0;
            float3 Triplanar_5e2f2d627ffc47e7b32959be7a69b8c1_Blend = SafePositivePow_float(IN.WorldSpaceNormal, min(_Property_a5f4da8e125f4a69b3ef8e0eee9629a9_Out_0, floor(log2(Min_float())/log2(1/sqrt(3)))) );
            Triplanar_5e2f2d627ffc47e7b32959be7a69b8c1_Blend /= (Triplanar_5e2f2d627ffc47e7b32959be7a69b8c1_Blend.x + Triplanar_5e2f2d627ffc47e7b32959be7a69b8c1_Blend.y + Triplanar_5e2f2d627ffc47e7b32959be7a69b8c1_Blend.z ).xxx;
            float3 Triplanar_5e2f2d627ffc47e7b32959be7a69b8c1_X = UnpackNormal(SAMPLE_TEXTURE2D(_Property_4d22bb373eee4057a5413b8162f92e45_Out_0.tex, _Property_4d22bb373eee4057a5413b8162f92e45_Out_0.samplerstate, Triplanar_5e2f2d627ffc47e7b32959be7a69b8c1_UV.zy));
            float3 Triplanar_5e2f2d627ffc47e7b32959be7a69b8c1_Y = UnpackNormal(SAMPLE_TEXTURE2D(_Property_4d22bb373eee4057a5413b8162f92e45_Out_0.tex, _Property_4d22bb373eee4057a5413b8162f92e45_Out_0.samplerstate, Triplanar_5e2f2d627ffc47e7b32959be7a69b8c1_UV.xz));
            float3 Triplanar_5e2f2d627ffc47e7b32959be7a69b8c1_Z = UnpackNormal(SAMPLE_TEXTURE2D(_Property_4d22bb373eee4057a5413b8162f92e45_Out_0.tex, _Property_4d22bb373eee4057a5413b8162f92e45_Out_0.samplerstate, Triplanar_5e2f2d627ffc47e7b32959be7a69b8c1_UV.xy));
            Triplanar_5e2f2d627ffc47e7b32959be7a69b8c1_X = float3(Triplanar_5e2f2d627ffc47e7b32959be7a69b8c1_X.xy + IN.WorldSpaceNormal.zy, abs(Triplanar_5e2f2d627ffc47e7b32959be7a69b8c1_X.z) * IN.WorldSpaceNormal.x);
            Triplanar_5e2f2d627ffc47e7b32959be7a69b8c1_Y = float3(Triplanar_5e2f2d627ffc47e7b32959be7a69b8c1_Y.xy + IN.WorldSpaceNormal.xz, abs(Triplanar_5e2f2d627ffc47e7b32959be7a69b8c1_Y.z) * IN.WorldSpaceNormal.y);
            Triplanar_5e2f2d627ffc47e7b32959be7a69b8c1_Z = float3(Triplanar_5e2f2d627ffc47e7b32959be7a69b8c1_Z.xy + IN.WorldSpaceNormal.xy, abs(Triplanar_5e2f2d627ffc47e7b32959be7a69b8c1_Z.z) * IN.WorldSpaceNormal.z);
            float4 _Triplanar_5e2f2d627ffc47e7b32959be7a69b8c1_Out_0 = float4(normalize(Triplanar_5e2f2d627ffc47e7b32959be7a69b8c1_X.zyx * Triplanar_5e2f2d627ffc47e7b32959be7a69b8c1_Blend.x + Triplanar_5e2f2d627ffc47e7b32959be7a69b8c1_Y.xzy * Triplanar_5e2f2d627ffc47e7b32959be7a69b8c1_Blend.y + Triplanar_5e2f2d627ffc47e7b32959be7a69b8c1_Z.xyz * Triplanar_5e2f2d627ffc47e7b32959be7a69b8c1_Blend.z), 1);
            float3x3 Triplanar_5e2f2d627ffc47e7b32959be7a69b8c1_Transform = float3x3(IN.WorldSpaceTangent, IN.WorldSpaceBiTangent, IN.WorldSpaceNormal);
            _Triplanar_5e2f2d627ffc47e7b32959be7a69b8c1_Out_0.rgb = TransformWorldToTangent(_Triplanar_5e2f2d627ffc47e7b32959be7a69b8c1_Out_0.rgb, Triplanar_5e2f2d627ffc47e7b32959be7a69b8c1_Transform);
            float _Property_465f1954a0214426b47c7da2af048f07_Out_0 = _Normal_Strength;
            float3 _NormalStrength_530366de39034d288415f2bd44ee2d24_Out_2;
            Unity_NormalStrength_float((_Triplanar_5e2f2d627ffc47e7b32959be7a69b8c1_Out_0.xyz), _Property_465f1954a0214426b47c7da2af048f07_Out_0, _NormalStrength_530366de39034d288415f2bd44ee2d24_Out_2);
            UnityTexture2D _Property_36a8b919311a4525bb742e047b0c7fad_Out_0 = UnityBuildTexture2DStructNoScale(_Emission_Map);
            float3 Triplanar_d184924eec244d279d611947e624fc09_UV = IN.AbsoluteWorldSpacePosition * _Property_0d71a168115a4531a21482c995ff11b8_Out_0;
            float3 Triplanar_d184924eec244d279d611947e624fc09_Blend = SafePositivePow_float(IN.WorldSpaceNormal, min(_Property_a5f4da8e125f4a69b3ef8e0eee9629a9_Out_0, floor(log2(Min_float())/log2(1/sqrt(3)))) );
            Triplanar_d184924eec244d279d611947e624fc09_Blend /= dot(Triplanar_d184924eec244d279d611947e624fc09_Blend, 1.0);
            float4 Triplanar_d184924eec244d279d611947e624fc09_X = SAMPLE_TEXTURE2D(_Property_36a8b919311a4525bb742e047b0c7fad_Out_0.tex, _Property_36a8b919311a4525bb742e047b0c7fad_Out_0.samplerstate, Triplanar_d184924eec244d279d611947e624fc09_UV.zy);
            float4 Triplanar_d184924eec244d279d611947e624fc09_Y = SAMPLE_TEXTURE2D(_Property_36a8b919311a4525bb742e047b0c7fad_Out_0.tex, _Property_36a8b919311a4525bb742e047b0c7fad_Out_0.samplerstate, Triplanar_d184924eec244d279d611947e624fc09_UV.xz);
            float4 Triplanar_d184924eec244d279d611947e624fc09_Z = SAMPLE_TEXTURE2D(_Property_36a8b919311a4525bb742e047b0c7fad_Out_0.tex, _Property_36a8b919311a4525bb742e047b0c7fad_Out_0.samplerstate, Triplanar_d184924eec244d279d611947e624fc09_UV.xy);
            float4 _Triplanar_d184924eec244d279d611947e624fc09_Out_0 = Triplanar_d184924eec244d279d611947e624fc09_X * Triplanar_d184924eec244d279d611947e624fc09_Blend.x + Triplanar_d184924eec244d279d611947e624fc09_Y * Triplanar_d184924eec244d279d611947e624fc09_Blend.y + Triplanar_d184924eec244d279d611947e624fc09_Z * Triplanar_d184924eec244d279d611947e624fc09_Blend.z;
            float4 _Property_d19f06a576904574bc1ce7a4bc0705de_Out_0 = IsGammaSpace() ? LinearToSRGB(_Emission_Color) : _Emission_Color;
            float _Property_8538694bbc6046818d0fe00a0884c6e1_Out_0 = _Emission_Strength;
            float4 _Multiply_a9f07d97808a4c1a81856fe1fc446ee1_Out_2;
            Unity_Multiply_float4_float4(_Property_d19f06a576904574bc1ce7a4bc0705de_Out_0, (_Property_8538694bbc6046818d0fe00a0884c6e1_Out_0.xxxx), _Multiply_a9f07d97808a4c1a81856fe1fc446ee1_Out_2);
            float4 _Multiply_b2871317a9804ae491f162ac9a41c7ee_Out_2;
            Unity_Multiply_float4_float4(_Triplanar_d184924eec244d279d611947e624fc09_Out_0, _Multiply_a9f07d97808a4c1a81856fe1fc446ee1_Out_2, _Multiply_b2871317a9804ae491f162ac9a41c7ee_Out_2);
            UnityTexture2D _Property_2645d69dc6fc44eabeb03b508fa73fa2_Out_0 = UnityBuildTexture2DStructNoScale(_Metallic_Map);
            float3 Triplanar_72251408cf774e2cb2bb6dade546d69f_UV = IN.AbsoluteWorldSpacePosition * _Property_0d71a168115a4531a21482c995ff11b8_Out_0;
            float3 Triplanar_72251408cf774e2cb2bb6dade546d69f_Blend = SafePositivePow_float(IN.WorldSpaceNormal, min(_Property_a5f4da8e125f4a69b3ef8e0eee9629a9_Out_0, floor(log2(Min_float())/log2(1/sqrt(3)))) );
            Triplanar_72251408cf774e2cb2bb6dade546d69f_Blend /= dot(Triplanar_72251408cf774e2cb2bb6dade546d69f_Blend, 1.0);
            float4 Triplanar_72251408cf774e2cb2bb6dade546d69f_X = SAMPLE_TEXTURE2D(_Property_2645d69dc6fc44eabeb03b508fa73fa2_Out_0.tex, _Property_2645d69dc6fc44eabeb03b508fa73fa2_Out_0.samplerstate, Triplanar_72251408cf774e2cb2bb6dade546d69f_UV.zy);
            float4 Triplanar_72251408cf774e2cb2bb6dade546d69f_Y = SAMPLE_TEXTURE2D(_Property_2645d69dc6fc44eabeb03b508fa73fa2_Out_0.tex, _Property_2645d69dc6fc44eabeb03b508fa73fa2_Out_0.samplerstate, Triplanar_72251408cf774e2cb2bb6dade546d69f_UV.xz);
            float4 Triplanar_72251408cf774e2cb2bb6dade546d69f_Z = SAMPLE_TEXTURE2D(_Property_2645d69dc6fc44eabeb03b508fa73fa2_Out_0.tex, _Property_2645d69dc6fc44eabeb03b508fa73fa2_Out_0.samplerstate, Triplanar_72251408cf774e2cb2bb6dade546d69f_UV.xy);
            float4 _Triplanar_72251408cf774e2cb2bb6dade546d69f_Out_0 = Triplanar_72251408cf774e2cb2bb6dade546d69f_X * Triplanar_72251408cf774e2cb2bb6dade546d69f_Blend.x + Triplanar_72251408cf774e2cb2bb6dade546d69f_Y * Triplanar_72251408cf774e2cb2bb6dade546d69f_Blend.y + Triplanar_72251408cf774e2cb2bb6dade546d69f_Z * Triplanar_72251408cf774e2cb2bb6dade546d69f_Blend.z;
            float _Property_a2de0712f3e74597a69dcb9c906c8323_Out_0 = _Metallic;
            float4 _Multiply_51419fc37ba3467492dc6057f62e848a_Out_2;
            Unity_Multiply_float4_float4(_Triplanar_72251408cf774e2cb2bb6dade546d69f_Out_0, (_Property_a2de0712f3e74597a69dcb9c906c8323_Out_0.xxxx), _Multiply_51419fc37ba3467492dc6057f62e848a_Out_2);
            UnityTexture2D _Property_2044c0171961481a87c99454b70146f3_Out_0 = UnityBuildTexture2DStructNoScale(_Smoothness_Map);
            float3 Triplanar_b21e7971fc0e4b8a966ee4585dca400a_UV = IN.AbsoluteWorldSpacePosition * _Property_0d71a168115a4531a21482c995ff11b8_Out_0;
            float3 Triplanar_b21e7971fc0e4b8a966ee4585dca400a_Blend = SafePositivePow_float(IN.WorldSpaceNormal, min(_Property_a5f4da8e125f4a69b3ef8e0eee9629a9_Out_0, floor(log2(Min_float())/log2(1/sqrt(3)))) );
            Triplanar_b21e7971fc0e4b8a966ee4585dca400a_Blend /= dot(Triplanar_b21e7971fc0e4b8a966ee4585dca400a_Blend, 1.0);
            float4 Triplanar_b21e7971fc0e4b8a966ee4585dca400a_X = SAMPLE_TEXTURE2D(_Property_2044c0171961481a87c99454b70146f3_Out_0.tex, _Property_2044c0171961481a87c99454b70146f3_Out_0.samplerstate, Triplanar_b21e7971fc0e4b8a966ee4585dca400a_UV.zy);
            float4 Triplanar_b21e7971fc0e4b8a966ee4585dca400a_Y = SAMPLE_TEXTURE2D(_Property_2044c0171961481a87c99454b70146f3_Out_0.tex, _Property_2044c0171961481a87c99454b70146f3_Out_0.samplerstate, Triplanar_b21e7971fc0e4b8a966ee4585dca400a_UV.xz);
            float4 Triplanar_b21e7971fc0e4b8a966ee4585dca400a_Z = SAMPLE_TEXTURE2D(_Property_2044c0171961481a87c99454b70146f3_Out_0.tex, _Property_2044c0171961481a87c99454b70146f3_Out_0.samplerstate, Triplanar_b21e7971fc0e4b8a966ee4585dca400a_UV.xy);
            float4 _Triplanar_b21e7971fc0e4b8a966ee4585dca400a_Out_0 = Triplanar_b21e7971fc0e4b8a966ee4585dca400a_X * Triplanar_b21e7971fc0e4b8a966ee4585dca400a_Blend.x + Triplanar_b21e7971fc0e4b8a966ee4585dca400a_Y * Triplanar_b21e7971fc0e4b8a966ee4585dca400a_Blend.y + Triplanar_b21e7971fc0e4b8a966ee4585dca400a_Z * Triplanar_b21e7971fc0e4b8a966ee4585dca400a_Blend.z;
            float _Property_6ac0f3d590a04d70b9b65f930607378e_Out_0 = _Smoothness;
            float4 _Multiply_1190034063a742598e70497b24a917d6_Out_2;
            Unity_Multiply_float4_float4(_Triplanar_b21e7971fc0e4b8a966ee4585dca400a_Out_0, (_Property_6ac0f3d590a04d70b9b65f930607378e_Out_0.xxxx), _Multiply_1190034063a742598e70497b24a917d6_Out_2);
            UnityTexture2D _Property_6fda6f621b89424d81cce741b5c87cfb_Out_0 = UnityBuildTexture2DStructNoScale(_Ambient_Occlusion_Map);
            float3 Triplanar_c18df43557c74ecf9550fa6e5f01b85a_UV = IN.AbsoluteWorldSpacePosition * _Property_0d71a168115a4531a21482c995ff11b8_Out_0;
            float3 Triplanar_c18df43557c74ecf9550fa6e5f01b85a_Blend = SafePositivePow_float(IN.WorldSpaceNormal, min(_Property_a5f4da8e125f4a69b3ef8e0eee9629a9_Out_0, floor(log2(Min_float())/log2(1/sqrt(3)))) );
            Triplanar_c18df43557c74ecf9550fa6e5f01b85a_Blend /= dot(Triplanar_c18df43557c74ecf9550fa6e5f01b85a_Blend, 1.0);
            float4 Triplanar_c18df43557c74ecf9550fa6e5f01b85a_X = SAMPLE_TEXTURE2D(_Property_6fda6f621b89424d81cce741b5c87cfb_Out_0.tex, _Property_6fda6f621b89424d81cce741b5c87cfb_Out_0.samplerstate, Triplanar_c18df43557c74ecf9550fa6e5f01b85a_UV.zy);
            float4 Triplanar_c18df43557c74ecf9550fa6e5f01b85a_Y = SAMPLE_TEXTURE2D(_Property_6fda6f621b89424d81cce741b5c87cfb_Out_0.tex, _Property_6fda6f621b89424d81cce741b5c87cfb_Out_0.samplerstate, Triplanar_c18df43557c74ecf9550fa6e5f01b85a_UV.xz);
            float4 Triplanar_c18df43557c74ecf9550fa6e5f01b85a_Z = SAMPLE_TEXTURE2D(_Property_6fda6f621b89424d81cce741b5c87cfb_Out_0.tex, _Property_6fda6f621b89424d81cce741b5c87cfb_Out_0.samplerstate, Triplanar_c18df43557c74ecf9550fa6e5f01b85a_UV.xy);
            float4 _Triplanar_c18df43557c74ecf9550fa6e5f01b85a_Out_0 = Triplanar_c18df43557c74ecf9550fa6e5f01b85a_X * Triplanar_c18df43557c74ecf9550fa6e5f01b85a_Blend.x + Triplanar_c18df43557c74ecf9550fa6e5f01b85a_Y * Triplanar_c18df43557c74ecf9550fa6e5f01b85a_Blend.y + Triplanar_c18df43557c74ecf9550fa6e5f01b85a_Z * Triplanar_c18df43557c74ecf9550fa6e5f01b85a_Blend.z;
            float _Property_b41c1f0171a8491283bb490d369c1633_Out_0 = _Ambient_Occlusion;
            float4 _Multiply_8460e617a2774fc4a9bc1b8ac4b4c498_Out_2;
            Unity_Multiply_float4_float4(_Triplanar_c18df43557c74ecf9550fa6e5f01b85a_Out_0, (_Property_b41c1f0171a8491283bb490d369c1633_Out_0.xxxx), _Multiply_8460e617a2774fc4a9bc1b8ac4b4c498_Out_2);
            float _Property_85bb0cea7a3e455b96bc35eef9b04b52_Out_0 = _Opacity;
            UnityTexture2D _Property_4ffddeb9667041dea5361019922617c3_Out_0 = UnityBuildTexture2DStructNoScale(_Alpha_Map);
            float3 Triplanar_6f2fd2dbd39f45f1b46f5b62d6f1ccb8_UV = IN.AbsoluteWorldSpacePosition * _Property_0d71a168115a4531a21482c995ff11b8_Out_0;
            float3 Triplanar_6f2fd2dbd39f45f1b46f5b62d6f1ccb8_Blend = SafePositivePow_float(IN.WorldSpaceNormal, min(_Property_a5f4da8e125f4a69b3ef8e0eee9629a9_Out_0, floor(log2(Min_float())/log2(1/sqrt(3)))) );
            Triplanar_6f2fd2dbd39f45f1b46f5b62d6f1ccb8_Blend /= dot(Triplanar_6f2fd2dbd39f45f1b46f5b62d6f1ccb8_Blend, 1.0);
            float4 Triplanar_6f2fd2dbd39f45f1b46f5b62d6f1ccb8_X = SAMPLE_TEXTURE2D(_Property_4ffddeb9667041dea5361019922617c3_Out_0.tex, _Property_4ffddeb9667041dea5361019922617c3_Out_0.samplerstate, Triplanar_6f2fd2dbd39f45f1b46f5b62d6f1ccb8_UV.zy);
            float4 Triplanar_6f2fd2dbd39f45f1b46f5b62d6f1ccb8_Y = SAMPLE_TEXTURE2D(_Property_4ffddeb9667041dea5361019922617c3_Out_0.tex, _Property_4ffddeb9667041dea5361019922617c3_Out_0.samplerstate, Triplanar_6f2fd2dbd39f45f1b46f5b62d6f1ccb8_UV.xz);
            float4 Triplanar_6f2fd2dbd39f45f1b46f5b62d6f1ccb8_Z = SAMPLE_TEXTURE2D(_Property_4ffddeb9667041dea5361019922617c3_Out_0.tex, _Property_4ffddeb9667041dea5361019922617c3_Out_0.samplerstate, Triplanar_6f2fd2dbd39f45f1b46f5b62d6f1ccb8_UV.xy);
            float4 _Triplanar_6f2fd2dbd39f45f1b46f5b62d6f1ccb8_Out_0 = Triplanar_6f2fd2dbd39f45f1b46f5b62d6f1ccb8_X * Triplanar_6f2fd2dbd39f45f1b46f5b62d6f1ccb8_Blend.x + Triplanar_6f2fd2dbd39f45f1b46f5b62d6f1ccb8_Y * Triplanar_6f2fd2dbd39f45f1b46f5b62d6f1ccb8_Blend.y + Triplanar_6f2fd2dbd39f45f1b46f5b62d6f1ccb8_Z * Triplanar_6f2fd2dbd39f45f1b46f5b62d6f1ccb8_Blend.z;
            float4 _Multiply_969d0f17e76149089b7efa601089c78e_Out_2;
            Unity_Multiply_float4_float4((_Property_85bb0cea7a3e455b96bc35eef9b04b52_Out_0.xxxx), _Triplanar_6f2fd2dbd39f45f1b46f5b62d6f1ccb8_Out_0, _Multiply_969d0f17e76149089b7efa601089c78e_Out_2);
            surface.BaseColor = _Saturation_07d8daef15d04c6db1e1f18efb74c91f_Out_2;
            surface.NormalTS = _NormalStrength_530366de39034d288415f2bd44ee2d24_Out_2;
            surface.Emission = (_Multiply_b2871317a9804ae491f162ac9a41c7ee_Out_2.xyz);
            surface.Metallic = (_Multiply_51419fc37ba3467492dc6057f62e848a_Out_2).x;
            surface.Smoothness = (_Multiply_1190034063a742598e70497b24a917d6_Out_2).x;
            surface.Occlusion = (_Multiply_8460e617a2774fc4a9bc1b8ac4b4c498_Out_2).x;
            surface.Alpha = (_Multiply_969d0f17e76149089b7efa601089c78e_Out_2).x;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
            
        
            // must use interpolated tangent, bitangent and normal before they are normalized in the pixel shader.
            float3 unnormalizedNormalWS = input.normalWS;
            const float renormFactor = 1.0 / length(unnormalizedNormalWS);
        
            // use bitangent on the fly like in hdrp
            // IMPORTANT! If we ever support Flip on double sided materials ensure bitangent and tangent are NOT flipped.
            float crossSign = (input.tangentWS.w > 0.0 ? 1.0 : -1.0)* GetOddNegativeScale();
            float3 bitang = crossSign * cross(input.normalWS.xyz, input.tangentWS.xyz);
        
            output.WorldSpaceNormal = renormFactor * input.normalWS.xyz;      // we want a unit length Normal Vector node in shader graph
            output.TangentSpaceNormal = float3(0.0f, 0.0f, 1.0f);
        
            // to preserve mikktspace compliance we use same scale renormFactor as was used on the normal.
            // This is explained in section 2.2 in "surface gradient based bump mapping framework"
            output.WorldSpaceTangent = renormFactor * input.tangentWS.xyz;
            output.WorldSpaceBiTangent = renormFactor * bitang;
        
            output.WorldSpacePosition = input.positionWS;
            output.AbsoluteWorldSpacePosition = GetAbsolutePositionWS(input.positionWS);
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        void BuildAppDataFull(Attributes attributes, VertexDescription vertexDescription, inout appdata_full result)
        {
            result.vertex     = float4(attributes.positionOS, 1);
            result.tangent    = attributes.tangentOS;
            result.normal     = attributes.normalOS;
            result.texcoord1  = attributes.uv1;
            result.vertex     = float4(vertexDescription.Position, 1);
            result.normal     = vertexDescription.Normal;
            result.tangent    = float4(vertexDescription.Tangent, 0);
            #if UNITY_ANY_INSTANCING_ENABLED
            #endif
        }
        
        void VaryingsToSurfaceVertex(Varyings varyings, inout v2f_surf result)
        {
            result.pos = varyings.positionCS;
            result.worldPos = varyings.positionWS;
            result.worldNormal = varyings.normalWS;
            result.viewDir = varyings.viewDirectionWS;
            // World Tangent isn't an available input on v2f_surf
        
            result._ShadowCoord = varyings.shadowCoord;
        
            #if UNITY_ANY_INSTANCING_ENABLED
            #endif
            #if !defined(LIGHTMAP_ON)
            #if UNITY_SHOULD_SAMPLE_SH
            result.sh = varyings.sh;
            #endif
            #endif
            #if defined(LIGHTMAP_ON)
            result.lmap.xy = varyings.lightmapUV;
            #endif
            #ifdef VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
                result.fogCoord = varyings.fogFactorAndVertexLight.x;
                COPY_TO_LIGHT_COORDS(result, varyings.fogFactorAndVertexLight.yzw);
            #endif
        
            DEFAULT_UNITY_TRANSFER_VERTEX_OUTPUT_STEREO(varyings, result);
        }
        
        void SurfaceVertexToVaryings(v2f_surf surfVertex, inout Varyings result)
        {
            result.positionCS = surfVertex.pos;
            result.positionWS = surfVertex.worldPos;
            result.normalWS = surfVertex.worldNormal;
            // viewDirectionWS is never filled out in the legacy pass' function. Always use the value computed by SRP
            // World Tangent isn't an available input on v2f_surf
            result.shadowCoord = surfVertex._ShadowCoord;
        
            #if UNITY_ANY_INSTANCING_ENABLED
            #endif
            #if !defined(LIGHTMAP_ON)
            #if UNITY_SHOULD_SAMPLE_SH
            result.sh = surfVertex.sh;
            #endif
            #endif
            #if defined(LIGHTMAP_ON)
            result.lightmapUV = surfVertex.lmap.xy;
            #endif
            #ifdef VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
                result.fogFactorAndVertexLight.x = surfVertex.fogCoord;
                COPY_FROM_LIGHT_COORDS(result.fogFactorAndVertexLight.yzw, surfVertex);
            #endif
        
            DEFAULT_UNITY_TRANSFER_VERTEX_OUTPUT_STEREO(surfVertex, result);
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/PBRDeferredPass.hlsl"
        
        ENDHLSL
        }
        Pass
        {
            Name "ShadowCaster"
            Tags
            {
                "LightMode" = "ShadowCaster"
            }
        
        // Render State
        Cull Back
        Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
        ZTest LEqual
        ZWrite On
        ColorMask 0
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 3.0
        #pragma multi_compile_shadowcaster
        #pragma vertex vert
        #pragma fragment frag
        
        // DotsInstancingOptions: <None>
        // HybridV1InjectedBuiltinProperties: <None>
        
        // Keywords
        #pragma multi_compile _ _CASTING_PUNCTUAL_LIGHT_SHADOW
        // GraphKeywords: <None>
        
        // Defines
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define VARYINGS_NEED_POSITION_WS
        #define VARYINGS_NEED_NORMAL_WS
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_SHADOWCASTER
        #define BUILTIN_TARGET_API 1
        #define _BUILTIN_SURFACE_TYPE_TRANSPARENT 1
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
        #ifdef _BUILTIN_SURFACE_TYPE_TRANSPARENT
        #define _SURFACE_TYPE_TRANSPARENT _BUILTIN_SURFACE_TYPE_TRANSPARENT
        #endif
        #ifdef _BUILTIN_ALPHATEST_ON
        #define _ALPHATEST_ON _BUILTIN_ALPHATEST_ON
        #endif
        #ifdef _BUILTIN_AlphaClip
        #define _AlphaClip _BUILTIN_AlphaClip
        #endif
        #ifdef _BUILTIN_ALPHAPREMULTIPLY_ON
        #define _ALPHAPREMULTIPLY_ON _BUILTIN_ALPHAPREMULTIPLY_ON
        #endif
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/Shim/Shims.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/LegacySurfaceVertex.hlsl"
        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/ShaderGraphFunctions.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 positionWS;
             float3 normalWS;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float3 WorldSpaceNormal;
             float3 WorldSpacePosition;
             float3 AbsoluteWorldSpacePosition;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float3 interp0 : INTERP0;
             float3 interp1 : INTERP1;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.positionWS;
            output.interp1.xyz =  input.normalWS;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.positionWS = input.interp0.xyz;
            output.normalWS = input.interp1.xyz;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _Diffuse_TexelSize;
        float4 _Normal_Map_TexelSize;
        float _Tiling;
        float _Blend;
        float _Normal_Strength;
        float _Smoothness;
        float _Metallic;
        float4 __Filter_Color;
        float4 _Emission_Color;
        float4 _Alpha_Map_TexelSize;
        float _Opacity;
        float4 _Emission_Map_TexelSize;
        float _Emission_Strength;
        float4 _Smoothness_Map_TexelSize;
        float4 _Metallic_Map_TexelSize;
        float _Ambient_Occlusion;
        float4 _Ambient_Occlusion_Map_TexelSize;
        float __Filter_Contrast;
        float _Apply_Filters;
        float __Filter_Saturation;
        CBUFFER_END
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_Diffuse);
        SAMPLER(sampler_Diffuse);
        TEXTURE2D(_Normal_Map);
        SAMPLER(sampler_Normal_Map);
        TEXTURE2D(_Alpha_Map);
        SAMPLER(sampler_Alpha_Map);
        TEXTURE2D(_Emission_Map);
        SAMPLER(sampler_Emission_Map);
        TEXTURE2D(_Smoothness_Map);
        SAMPLER(sampler_Smoothness_Map);
        TEXTURE2D(_Metallic_Map);
        SAMPLER(sampler_Metallic_Map);
        TEXTURE2D(_Ambient_Occlusion_Map);
        SAMPLER(sampler_Ambient_Occlusion_Map);
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // Graph Functions
        
        void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float Alpha;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float _Property_85bb0cea7a3e455b96bc35eef9b04b52_Out_0 = _Opacity;
            UnityTexture2D _Property_4ffddeb9667041dea5361019922617c3_Out_0 = UnityBuildTexture2DStructNoScale(_Alpha_Map);
            float _Property_0d71a168115a4531a21482c995ff11b8_Out_0 = _Tiling;
            float _Property_a5f4da8e125f4a69b3ef8e0eee9629a9_Out_0 = _Blend;
            float3 Triplanar_6f2fd2dbd39f45f1b46f5b62d6f1ccb8_UV = IN.AbsoluteWorldSpacePosition * _Property_0d71a168115a4531a21482c995ff11b8_Out_0;
            float3 Triplanar_6f2fd2dbd39f45f1b46f5b62d6f1ccb8_Blend = SafePositivePow_float(IN.WorldSpaceNormal, min(_Property_a5f4da8e125f4a69b3ef8e0eee9629a9_Out_0, floor(log2(Min_float())/log2(1/sqrt(3)))) );
            Triplanar_6f2fd2dbd39f45f1b46f5b62d6f1ccb8_Blend /= dot(Triplanar_6f2fd2dbd39f45f1b46f5b62d6f1ccb8_Blend, 1.0);
            float4 Triplanar_6f2fd2dbd39f45f1b46f5b62d6f1ccb8_X = SAMPLE_TEXTURE2D(_Property_4ffddeb9667041dea5361019922617c3_Out_0.tex, _Property_4ffddeb9667041dea5361019922617c3_Out_0.samplerstate, Triplanar_6f2fd2dbd39f45f1b46f5b62d6f1ccb8_UV.zy);
            float4 Triplanar_6f2fd2dbd39f45f1b46f5b62d6f1ccb8_Y = SAMPLE_TEXTURE2D(_Property_4ffddeb9667041dea5361019922617c3_Out_0.tex, _Property_4ffddeb9667041dea5361019922617c3_Out_0.samplerstate, Triplanar_6f2fd2dbd39f45f1b46f5b62d6f1ccb8_UV.xz);
            float4 Triplanar_6f2fd2dbd39f45f1b46f5b62d6f1ccb8_Z = SAMPLE_TEXTURE2D(_Property_4ffddeb9667041dea5361019922617c3_Out_0.tex, _Property_4ffddeb9667041dea5361019922617c3_Out_0.samplerstate, Triplanar_6f2fd2dbd39f45f1b46f5b62d6f1ccb8_UV.xy);
            float4 _Triplanar_6f2fd2dbd39f45f1b46f5b62d6f1ccb8_Out_0 = Triplanar_6f2fd2dbd39f45f1b46f5b62d6f1ccb8_X * Triplanar_6f2fd2dbd39f45f1b46f5b62d6f1ccb8_Blend.x + Triplanar_6f2fd2dbd39f45f1b46f5b62d6f1ccb8_Y * Triplanar_6f2fd2dbd39f45f1b46f5b62d6f1ccb8_Blend.y + Triplanar_6f2fd2dbd39f45f1b46f5b62d6f1ccb8_Z * Triplanar_6f2fd2dbd39f45f1b46f5b62d6f1ccb8_Blend.z;
            float4 _Multiply_969d0f17e76149089b7efa601089c78e_Out_2;
            Unity_Multiply_float4_float4((_Property_85bb0cea7a3e455b96bc35eef9b04b52_Out_0.xxxx), _Triplanar_6f2fd2dbd39f45f1b46f5b62d6f1ccb8_Out_0, _Multiply_969d0f17e76149089b7efa601089c78e_Out_2);
            surface.Alpha = (_Multiply_969d0f17e76149089b7efa601089c78e_Out_2).x;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
            
        
            // must use interpolated tangent, bitangent and normal before they are normalized in the pixel shader.
            float3 unnormalizedNormalWS = input.normalWS;
            const float renormFactor = 1.0 / length(unnormalizedNormalWS);
        
        
            output.WorldSpaceNormal = renormFactor * input.normalWS.xyz;      // we want a unit length Normal Vector node in shader graph
        
        
            output.WorldSpacePosition = input.positionWS;
            output.AbsoluteWorldSpacePosition = GetAbsolutePositionWS(input.positionWS);
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        void BuildAppDataFull(Attributes attributes, VertexDescription vertexDescription, inout appdata_full result)
        {
            result.vertex     = float4(attributes.positionOS, 1);
            result.tangent    = attributes.tangentOS;
            result.normal     = attributes.normalOS;
            result.vertex     = float4(vertexDescription.Position, 1);
            result.normal     = vertexDescription.Normal;
            result.tangent    = float4(vertexDescription.Tangent, 0);
            #if UNITY_ANY_INSTANCING_ENABLED
            #endif
        }
        
        void VaryingsToSurfaceVertex(Varyings varyings, inout v2f_surf result)
        {
            result.pos = varyings.positionCS;
            result.worldPos = varyings.positionWS;
            result.worldNormal = varyings.normalWS;
            // World Tangent isn't an available input on v2f_surf
        
        
            #if UNITY_ANY_INSTANCING_ENABLED
            #endif
            #if !defined(LIGHTMAP_ON)
            #if UNITY_SHOULD_SAMPLE_SH
            #endif
            #endif
            #if defined(LIGHTMAP_ON)
            #endif
            #ifdef VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
                result.fogCoord = varyings.fogFactorAndVertexLight.x;
                COPY_TO_LIGHT_COORDS(result, varyings.fogFactorAndVertexLight.yzw);
            #endif
        
            DEFAULT_UNITY_TRANSFER_VERTEX_OUTPUT_STEREO(varyings, result);
        }
        
        void SurfaceVertexToVaryings(v2f_surf surfVertex, inout Varyings result)
        {
            result.positionCS = surfVertex.pos;
            result.positionWS = surfVertex.worldPos;
            result.normalWS = surfVertex.worldNormal;
            // viewDirectionWS is never filled out in the legacy pass' function. Always use the value computed by SRP
            // World Tangent isn't an available input on v2f_surf
        
            #if UNITY_ANY_INSTANCING_ENABLED
            #endif
            #if !defined(LIGHTMAP_ON)
            #if UNITY_SHOULD_SAMPLE_SH
            #endif
            #endif
            #if defined(LIGHTMAP_ON)
            #endif
            #ifdef VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
                result.fogFactorAndVertexLight.x = surfVertex.fogCoord;
                COPY_FROM_LIGHT_COORDS(result.fogFactorAndVertexLight.yzw, surfVertex);
            #endif
        
            DEFAULT_UNITY_TRANSFER_VERTEX_OUTPUT_STEREO(surfVertex, result);
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/ShadowCasterPass.hlsl"
        
        ENDHLSL
        }
        Pass
        {
            Name "Meta"
            Tags
            {
                "LightMode" = "Meta"
            }
        
        // Render State
        Cull Off
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 3.0
        #pragma vertex vert
        #pragma fragment frag
        
        // DotsInstancingOptions: <None>
        // HybridV1InjectedBuiltinProperties: <None>
        
        // Keywords
        #pragma shader_feature _ _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A
        // GraphKeywords: <None>
        
        // Defines
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD1
        #define ATTRIBUTES_NEED_TEXCOORD2
        #define VARYINGS_NEED_POSITION_WS
        #define VARYINGS_NEED_NORMAL_WS
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_META
        #define BUILTIN_TARGET_API 1
        #define _BUILTIN_SURFACE_TYPE_TRANSPARENT 1
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
        #ifdef _BUILTIN_SURFACE_TYPE_TRANSPARENT
        #define _SURFACE_TYPE_TRANSPARENT _BUILTIN_SURFACE_TYPE_TRANSPARENT
        #endif
        #ifdef _BUILTIN_ALPHATEST_ON
        #define _ALPHATEST_ON _BUILTIN_ALPHATEST_ON
        #endif
        #ifdef _BUILTIN_AlphaClip
        #define _AlphaClip _BUILTIN_AlphaClip
        #endif
        #ifdef _BUILTIN_ALPHAPREMULTIPLY_ON
        #define _ALPHAPREMULTIPLY_ON _BUILTIN_ALPHAPREMULTIPLY_ON
        #endif
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/Shim/Shims.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/LegacySurfaceVertex.hlsl"
        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/ShaderGraphFunctions.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv1 : TEXCOORD1;
             float4 uv2 : TEXCOORD2;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 positionWS;
             float3 normalWS;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float3 WorldSpaceNormal;
             float3 WorldSpacePosition;
             float3 AbsoluteWorldSpacePosition;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float3 interp0 : INTERP0;
             float3 interp1 : INTERP1;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.positionWS;
            output.interp1.xyz =  input.normalWS;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.positionWS = input.interp0.xyz;
            output.normalWS = input.interp1.xyz;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _Diffuse_TexelSize;
        float4 _Normal_Map_TexelSize;
        float _Tiling;
        float _Blend;
        float _Normal_Strength;
        float _Smoothness;
        float _Metallic;
        float4 __Filter_Color;
        float4 _Emission_Color;
        float4 _Alpha_Map_TexelSize;
        float _Opacity;
        float4 _Emission_Map_TexelSize;
        float _Emission_Strength;
        float4 _Smoothness_Map_TexelSize;
        float4 _Metallic_Map_TexelSize;
        float _Ambient_Occlusion;
        float4 _Ambient_Occlusion_Map_TexelSize;
        float __Filter_Contrast;
        float _Apply_Filters;
        float __Filter_Saturation;
        CBUFFER_END
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_Diffuse);
        SAMPLER(sampler_Diffuse);
        TEXTURE2D(_Normal_Map);
        SAMPLER(sampler_Normal_Map);
        TEXTURE2D(_Alpha_Map);
        SAMPLER(sampler_Alpha_Map);
        TEXTURE2D(_Emission_Map);
        SAMPLER(sampler_Emission_Map);
        TEXTURE2D(_Smoothness_Map);
        SAMPLER(sampler_Smoothness_Map);
        TEXTURE2D(_Metallic_Map);
        SAMPLER(sampler_Metallic_Map);
        TEXTURE2D(_Ambient_Occlusion_Map);
        SAMPLER(sampler_Ambient_Occlusion_Map);
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // Graph Functions
        
        void Unity_Branch_float4(float Predicate, float4 True, float4 False, out float4 Out)
        {
            Out = Predicate ? True : False;
        }
        
        void Unity_Blend_Overlay_float4(float4 Base, float4 Blend, out float4 Out, float Opacity)
        {
            float4 result1 = 1.0 - 2.0 * (1.0 - Base) * (1.0 - Blend);
            float4 result2 = 2.0 * Base * Blend;
            float4 zeroOrOne = step(Base, 0.5);
            Out = result2 * zeroOrOne + (1 - zeroOrOne) * result1;
            Out = lerp(Base, Out, Opacity);
        }
        
        void Unity_Branch_float(float Predicate, float True, float False, out float Out)
        {
            Out = Predicate ? True : False;
        }
        
        void Unity_Contrast_float(float3 In, float Contrast, out float3 Out)
        {
            float midpoint = pow(0.5, 2.2);
            Out =  (In - midpoint) * Contrast + midpoint;
        }
        
        void Unity_Saturation_float(float3 In, float Saturation, out float3 Out)
        {
            float luma = dot(In, float3(0.2126729, 0.7151522, 0.0721750));
            Out =  luma.xxx + Saturation.xxx * (In - luma.xxx);
        }
        
        void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float3 BaseColor;
            float3 Emission;
            float Alpha;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float _Property_7b5fcd77ad264a83a7858d8f8361dbd7_Out_0 = _Apply_Filters;
            float4 _Property_e0ca4e34dd184733915c6122832975e4_Out_0 = __Filter_Color;
            float4 _Branch_ef11623f9e8b4e6191fcc3ea8bc1312a_Out_3;
            Unity_Branch_float4(_Property_7b5fcd77ad264a83a7858d8f8361dbd7_Out_0, _Property_e0ca4e34dd184733915c6122832975e4_Out_0, float4(0.5, 0.5, 0.5, 0), _Branch_ef11623f9e8b4e6191fcc3ea8bc1312a_Out_3);
            UnityTexture2D _Property_6c8663f0373d4b058ae8b9af5db9f43e_Out_0 = UnityBuildTexture2DStructNoScale(_Diffuse);
            float _Property_0d71a168115a4531a21482c995ff11b8_Out_0 = _Tiling;
            float _Property_a5f4da8e125f4a69b3ef8e0eee9629a9_Out_0 = _Blend;
            float3 Triplanar_f96cb0998e494774b09fab89ebb65eb5_UV = IN.AbsoluteWorldSpacePosition * _Property_0d71a168115a4531a21482c995ff11b8_Out_0;
            float3 Triplanar_f96cb0998e494774b09fab89ebb65eb5_Blend = SafePositivePow_float(IN.WorldSpaceNormal, min(_Property_a5f4da8e125f4a69b3ef8e0eee9629a9_Out_0, floor(log2(Min_float())/log2(1/sqrt(3)))) );
            Triplanar_f96cb0998e494774b09fab89ebb65eb5_Blend /= dot(Triplanar_f96cb0998e494774b09fab89ebb65eb5_Blend, 1.0);
            float4 Triplanar_f96cb0998e494774b09fab89ebb65eb5_X = SAMPLE_TEXTURE2D(_Property_6c8663f0373d4b058ae8b9af5db9f43e_Out_0.tex, _Property_6c8663f0373d4b058ae8b9af5db9f43e_Out_0.samplerstate, Triplanar_f96cb0998e494774b09fab89ebb65eb5_UV.zy);
            float4 Triplanar_f96cb0998e494774b09fab89ebb65eb5_Y = SAMPLE_TEXTURE2D(_Property_6c8663f0373d4b058ae8b9af5db9f43e_Out_0.tex, _Property_6c8663f0373d4b058ae8b9af5db9f43e_Out_0.samplerstate, Triplanar_f96cb0998e494774b09fab89ebb65eb5_UV.xz);
            float4 Triplanar_f96cb0998e494774b09fab89ebb65eb5_Z = SAMPLE_TEXTURE2D(_Property_6c8663f0373d4b058ae8b9af5db9f43e_Out_0.tex, _Property_6c8663f0373d4b058ae8b9af5db9f43e_Out_0.samplerstate, Triplanar_f96cb0998e494774b09fab89ebb65eb5_UV.xy);
            float4 _Triplanar_f96cb0998e494774b09fab89ebb65eb5_Out_0 = Triplanar_f96cb0998e494774b09fab89ebb65eb5_X * Triplanar_f96cb0998e494774b09fab89ebb65eb5_Blend.x + Triplanar_f96cb0998e494774b09fab89ebb65eb5_Y * Triplanar_f96cb0998e494774b09fab89ebb65eb5_Blend.y + Triplanar_f96cb0998e494774b09fab89ebb65eb5_Z * Triplanar_f96cb0998e494774b09fab89ebb65eb5_Blend.z;
            float4 _Blend_24c4787dcd7349eaae00fa6c3d9ca4ee_Out_2;
            Unity_Blend_Overlay_float4(_Branch_ef11623f9e8b4e6191fcc3ea8bc1312a_Out_3, _Triplanar_f96cb0998e494774b09fab89ebb65eb5_Out_0, _Blend_24c4787dcd7349eaae00fa6c3d9ca4ee_Out_2, 1);
            float _Property_4bd6ac78ba874554b874b76acf5eb180_Out_0 = _Apply_Filters;
            float _Property_8294ca47c1a14914a77bfa2e11e7db60_Out_0 = __Filter_Contrast;
            float _Branch_7646794670b149f6b60b9fe083ccac25_Out_3;
            Unity_Branch_float(_Property_4bd6ac78ba874554b874b76acf5eb180_Out_0, _Property_8294ca47c1a14914a77bfa2e11e7db60_Out_0, 1, _Branch_7646794670b149f6b60b9fe083ccac25_Out_3);
            float3 _Contrast_5087ef763a7e408686e5684e2bd7fd3d_Out_2;
            Unity_Contrast_float((_Blend_24c4787dcd7349eaae00fa6c3d9ca4ee_Out_2.xyz), _Branch_7646794670b149f6b60b9fe083ccac25_Out_3, _Contrast_5087ef763a7e408686e5684e2bd7fd3d_Out_2);
            float _Property_507c099bfb814af6aeb4eebfbbf3d34a_Out_0 = _Apply_Filters;
            float _Property_5d9b092d0e4645c594f92d6e73dc7c4c_Out_0 = __Filter_Saturation;
            float _Branch_9912f29c61804626a6ab83b323d383d5_Out_3;
            Unity_Branch_float(_Property_507c099bfb814af6aeb4eebfbbf3d34a_Out_0, _Property_5d9b092d0e4645c594f92d6e73dc7c4c_Out_0, 1, _Branch_9912f29c61804626a6ab83b323d383d5_Out_3);
            float3 _Saturation_07d8daef15d04c6db1e1f18efb74c91f_Out_2;
            Unity_Saturation_float(_Contrast_5087ef763a7e408686e5684e2bd7fd3d_Out_2, _Branch_9912f29c61804626a6ab83b323d383d5_Out_3, _Saturation_07d8daef15d04c6db1e1f18efb74c91f_Out_2);
            UnityTexture2D _Property_36a8b919311a4525bb742e047b0c7fad_Out_0 = UnityBuildTexture2DStructNoScale(_Emission_Map);
            float3 Triplanar_d184924eec244d279d611947e624fc09_UV = IN.AbsoluteWorldSpacePosition * _Property_0d71a168115a4531a21482c995ff11b8_Out_0;
            float3 Triplanar_d184924eec244d279d611947e624fc09_Blend = SafePositivePow_float(IN.WorldSpaceNormal, min(_Property_a5f4da8e125f4a69b3ef8e0eee9629a9_Out_0, floor(log2(Min_float())/log2(1/sqrt(3)))) );
            Triplanar_d184924eec244d279d611947e624fc09_Blend /= dot(Triplanar_d184924eec244d279d611947e624fc09_Blend, 1.0);
            float4 Triplanar_d184924eec244d279d611947e624fc09_X = SAMPLE_TEXTURE2D(_Property_36a8b919311a4525bb742e047b0c7fad_Out_0.tex, _Property_36a8b919311a4525bb742e047b0c7fad_Out_0.samplerstate, Triplanar_d184924eec244d279d611947e624fc09_UV.zy);
            float4 Triplanar_d184924eec244d279d611947e624fc09_Y = SAMPLE_TEXTURE2D(_Property_36a8b919311a4525bb742e047b0c7fad_Out_0.tex, _Property_36a8b919311a4525bb742e047b0c7fad_Out_0.samplerstate, Triplanar_d184924eec244d279d611947e624fc09_UV.xz);
            float4 Triplanar_d184924eec244d279d611947e624fc09_Z = SAMPLE_TEXTURE2D(_Property_36a8b919311a4525bb742e047b0c7fad_Out_0.tex, _Property_36a8b919311a4525bb742e047b0c7fad_Out_0.samplerstate, Triplanar_d184924eec244d279d611947e624fc09_UV.xy);
            float4 _Triplanar_d184924eec244d279d611947e624fc09_Out_0 = Triplanar_d184924eec244d279d611947e624fc09_X * Triplanar_d184924eec244d279d611947e624fc09_Blend.x + Triplanar_d184924eec244d279d611947e624fc09_Y * Triplanar_d184924eec244d279d611947e624fc09_Blend.y + Triplanar_d184924eec244d279d611947e624fc09_Z * Triplanar_d184924eec244d279d611947e624fc09_Blend.z;
            float4 _Property_d19f06a576904574bc1ce7a4bc0705de_Out_0 = IsGammaSpace() ? LinearToSRGB(_Emission_Color) : _Emission_Color;
            float _Property_8538694bbc6046818d0fe00a0884c6e1_Out_0 = _Emission_Strength;
            float4 _Multiply_a9f07d97808a4c1a81856fe1fc446ee1_Out_2;
            Unity_Multiply_float4_float4(_Property_d19f06a576904574bc1ce7a4bc0705de_Out_0, (_Property_8538694bbc6046818d0fe00a0884c6e1_Out_0.xxxx), _Multiply_a9f07d97808a4c1a81856fe1fc446ee1_Out_2);
            float4 _Multiply_b2871317a9804ae491f162ac9a41c7ee_Out_2;
            Unity_Multiply_float4_float4(_Triplanar_d184924eec244d279d611947e624fc09_Out_0, _Multiply_a9f07d97808a4c1a81856fe1fc446ee1_Out_2, _Multiply_b2871317a9804ae491f162ac9a41c7ee_Out_2);
            float _Property_85bb0cea7a3e455b96bc35eef9b04b52_Out_0 = _Opacity;
            UnityTexture2D _Property_4ffddeb9667041dea5361019922617c3_Out_0 = UnityBuildTexture2DStructNoScale(_Alpha_Map);
            float3 Triplanar_6f2fd2dbd39f45f1b46f5b62d6f1ccb8_UV = IN.AbsoluteWorldSpacePosition * _Property_0d71a168115a4531a21482c995ff11b8_Out_0;
            float3 Triplanar_6f2fd2dbd39f45f1b46f5b62d6f1ccb8_Blend = SafePositivePow_float(IN.WorldSpaceNormal, min(_Property_a5f4da8e125f4a69b3ef8e0eee9629a9_Out_0, floor(log2(Min_float())/log2(1/sqrt(3)))) );
            Triplanar_6f2fd2dbd39f45f1b46f5b62d6f1ccb8_Blend /= dot(Triplanar_6f2fd2dbd39f45f1b46f5b62d6f1ccb8_Blend, 1.0);
            float4 Triplanar_6f2fd2dbd39f45f1b46f5b62d6f1ccb8_X = SAMPLE_TEXTURE2D(_Property_4ffddeb9667041dea5361019922617c3_Out_0.tex, _Property_4ffddeb9667041dea5361019922617c3_Out_0.samplerstate, Triplanar_6f2fd2dbd39f45f1b46f5b62d6f1ccb8_UV.zy);
            float4 Triplanar_6f2fd2dbd39f45f1b46f5b62d6f1ccb8_Y = SAMPLE_TEXTURE2D(_Property_4ffddeb9667041dea5361019922617c3_Out_0.tex, _Property_4ffddeb9667041dea5361019922617c3_Out_0.samplerstate, Triplanar_6f2fd2dbd39f45f1b46f5b62d6f1ccb8_UV.xz);
            float4 Triplanar_6f2fd2dbd39f45f1b46f5b62d6f1ccb8_Z = SAMPLE_TEXTURE2D(_Property_4ffddeb9667041dea5361019922617c3_Out_0.tex, _Property_4ffddeb9667041dea5361019922617c3_Out_0.samplerstate, Triplanar_6f2fd2dbd39f45f1b46f5b62d6f1ccb8_UV.xy);
            float4 _Triplanar_6f2fd2dbd39f45f1b46f5b62d6f1ccb8_Out_0 = Triplanar_6f2fd2dbd39f45f1b46f5b62d6f1ccb8_X * Triplanar_6f2fd2dbd39f45f1b46f5b62d6f1ccb8_Blend.x + Triplanar_6f2fd2dbd39f45f1b46f5b62d6f1ccb8_Y * Triplanar_6f2fd2dbd39f45f1b46f5b62d6f1ccb8_Blend.y + Triplanar_6f2fd2dbd39f45f1b46f5b62d6f1ccb8_Z * Triplanar_6f2fd2dbd39f45f1b46f5b62d6f1ccb8_Blend.z;
            float4 _Multiply_969d0f17e76149089b7efa601089c78e_Out_2;
            Unity_Multiply_float4_float4((_Property_85bb0cea7a3e455b96bc35eef9b04b52_Out_0.xxxx), _Triplanar_6f2fd2dbd39f45f1b46f5b62d6f1ccb8_Out_0, _Multiply_969d0f17e76149089b7efa601089c78e_Out_2);
            surface.BaseColor = _Saturation_07d8daef15d04c6db1e1f18efb74c91f_Out_2;
            surface.Emission = (_Multiply_b2871317a9804ae491f162ac9a41c7ee_Out_2.xyz);
            surface.Alpha = (_Multiply_969d0f17e76149089b7efa601089c78e_Out_2).x;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
            
        
            // must use interpolated tangent, bitangent and normal before they are normalized in the pixel shader.
            float3 unnormalizedNormalWS = input.normalWS;
            const float renormFactor = 1.0 / length(unnormalizedNormalWS);
        
        
            output.WorldSpaceNormal = renormFactor * input.normalWS.xyz;      // we want a unit length Normal Vector node in shader graph
        
        
            output.WorldSpacePosition = input.positionWS;
            output.AbsoluteWorldSpacePosition = GetAbsolutePositionWS(input.positionWS);
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        void BuildAppDataFull(Attributes attributes, VertexDescription vertexDescription, inout appdata_full result)
        {
            result.vertex     = float4(attributes.positionOS, 1);
            result.tangent    = attributes.tangentOS;
            result.normal     = attributes.normalOS;
            result.texcoord1  = attributes.uv1;
            result.texcoord2  = attributes.uv2;
            result.vertex     = float4(vertexDescription.Position, 1);
            result.normal     = vertexDescription.Normal;
            result.tangent    = float4(vertexDescription.Tangent, 0);
            #if UNITY_ANY_INSTANCING_ENABLED
            #endif
        }
        
        void VaryingsToSurfaceVertex(Varyings varyings, inout v2f_surf result)
        {
            result.pos = varyings.positionCS;
            result.worldPos = varyings.positionWS;
            result.worldNormal = varyings.normalWS;
            // World Tangent isn't an available input on v2f_surf
        
        
            #if UNITY_ANY_INSTANCING_ENABLED
            #endif
            #if !defined(LIGHTMAP_ON)
            #if UNITY_SHOULD_SAMPLE_SH
            #endif
            #endif
            #if defined(LIGHTMAP_ON)
            #endif
            #ifdef VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
                result.fogCoord = varyings.fogFactorAndVertexLight.x;
                COPY_TO_LIGHT_COORDS(result, varyings.fogFactorAndVertexLight.yzw);
            #endif
        
            DEFAULT_UNITY_TRANSFER_VERTEX_OUTPUT_STEREO(varyings, result);
        }
        
        void SurfaceVertexToVaryings(v2f_surf surfVertex, inout Varyings result)
        {
            result.positionCS = surfVertex.pos;
            result.positionWS = surfVertex.worldPos;
            result.normalWS = surfVertex.worldNormal;
            // viewDirectionWS is never filled out in the legacy pass' function. Always use the value computed by SRP
            // World Tangent isn't an available input on v2f_surf
        
            #if UNITY_ANY_INSTANCING_ENABLED
            #endif
            #if !defined(LIGHTMAP_ON)
            #if UNITY_SHOULD_SAMPLE_SH
            #endif
            #endif
            #if defined(LIGHTMAP_ON)
            #endif
            #ifdef VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
                result.fogFactorAndVertexLight.x = surfVertex.fogCoord;
                COPY_FROM_LIGHT_COORDS(result.fogFactorAndVertexLight.yzw, surfVertex);
            #endif
        
            DEFAULT_UNITY_TRANSFER_VERTEX_OUTPUT_STEREO(surfVertex, result);
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/LightingMetaPass.hlsl"
        
        ENDHLSL
        }
        Pass
        {
            Name "SceneSelectionPass"
            Tags
            {
                "LightMode" = "SceneSelectionPass"
            }
        
        // Render State
        Cull Off
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 3.0
        #pragma multi_compile_instancing
        #pragma vertex vert
        #pragma fragment frag
        
        // DotsInstancingOptions: <None>
        // HybridV1InjectedBuiltinProperties: <None>
        
        // Keywords
        // PassKeywords: <None>
        // GraphKeywords: <None>
        
        // Defines
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define VARYINGS_NEED_POSITION_WS
        #define VARYINGS_NEED_NORMAL_WS
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SceneSelectionPass
        #define BUILTIN_TARGET_API 1
        #define SCENESELECTIONPASS 1
        #define _BUILTIN_SURFACE_TYPE_TRANSPARENT 1
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
        #ifdef _BUILTIN_SURFACE_TYPE_TRANSPARENT
        #define _SURFACE_TYPE_TRANSPARENT _BUILTIN_SURFACE_TYPE_TRANSPARENT
        #endif
        #ifdef _BUILTIN_ALPHATEST_ON
        #define _ALPHATEST_ON _BUILTIN_ALPHATEST_ON
        #endif
        #ifdef _BUILTIN_AlphaClip
        #define _AlphaClip _BUILTIN_AlphaClip
        #endif
        #ifdef _BUILTIN_ALPHAPREMULTIPLY_ON
        #define _ALPHAPREMULTIPLY_ON _BUILTIN_ALPHAPREMULTIPLY_ON
        #endif
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/Shim/Shims.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/LegacySurfaceVertex.hlsl"
        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/ShaderGraphFunctions.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 positionWS;
             float3 normalWS;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float3 WorldSpaceNormal;
             float3 WorldSpacePosition;
             float3 AbsoluteWorldSpacePosition;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float3 interp0 : INTERP0;
             float3 interp1 : INTERP1;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.positionWS;
            output.interp1.xyz =  input.normalWS;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.positionWS = input.interp0.xyz;
            output.normalWS = input.interp1.xyz;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _Diffuse_TexelSize;
        float4 _Normal_Map_TexelSize;
        float _Tiling;
        float _Blend;
        float _Normal_Strength;
        float _Smoothness;
        float _Metallic;
        float4 __Filter_Color;
        float4 _Emission_Color;
        float4 _Alpha_Map_TexelSize;
        float _Opacity;
        float4 _Emission_Map_TexelSize;
        float _Emission_Strength;
        float4 _Smoothness_Map_TexelSize;
        float4 _Metallic_Map_TexelSize;
        float _Ambient_Occlusion;
        float4 _Ambient_Occlusion_Map_TexelSize;
        float __Filter_Contrast;
        float _Apply_Filters;
        float __Filter_Saturation;
        CBUFFER_END
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_Diffuse);
        SAMPLER(sampler_Diffuse);
        TEXTURE2D(_Normal_Map);
        SAMPLER(sampler_Normal_Map);
        TEXTURE2D(_Alpha_Map);
        SAMPLER(sampler_Alpha_Map);
        TEXTURE2D(_Emission_Map);
        SAMPLER(sampler_Emission_Map);
        TEXTURE2D(_Smoothness_Map);
        SAMPLER(sampler_Smoothness_Map);
        TEXTURE2D(_Metallic_Map);
        SAMPLER(sampler_Metallic_Map);
        TEXTURE2D(_Ambient_Occlusion_Map);
        SAMPLER(sampler_Ambient_Occlusion_Map);
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // Graph Functions
        
        void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float Alpha;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float _Property_85bb0cea7a3e455b96bc35eef9b04b52_Out_0 = _Opacity;
            UnityTexture2D _Property_4ffddeb9667041dea5361019922617c3_Out_0 = UnityBuildTexture2DStructNoScale(_Alpha_Map);
            float _Property_0d71a168115a4531a21482c995ff11b8_Out_0 = _Tiling;
            float _Property_a5f4da8e125f4a69b3ef8e0eee9629a9_Out_0 = _Blend;
            float3 Triplanar_6f2fd2dbd39f45f1b46f5b62d6f1ccb8_UV = IN.AbsoluteWorldSpacePosition * _Property_0d71a168115a4531a21482c995ff11b8_Out_0;
            float3 Triplanar_6f2fd2dbd39f45f1b46f5b62d6f1ccb8_Blend = SafePositivePow_float(IN.WorldSpaceNormal, min(_Property_a5f4da8e125f4a69b3ef8e0eee9629a9_Out_0, floor(log2(Min_float())/log2(1/sqrt(3)))) );
            Triplanar_6f2fd2dbd39f45f1b46f5b62d6f1ccb8_Blend /= dot(Triplanar_6f2fd2dbd39f45f1b46f5b62d6f1ccb8_Blend, 1.0);
            float4 Triplanar_6f2fd2dbd39f45f1b46f5b62d6f1ccb8_X = SAMPLE_TEXTURE2D(_Property_4ffddeb9667041dea5361019922617c3_Out_0.tex, _Property_4ffddeb9667041dea5361019922617c3_Out_0.samplerstate, Triplanar_6f2fd2dbd39f45f1b46f5b62d6f1ccb8_UV.zy);
            float4 Triplanar_6f2fd2dbd39f45f1b46f5b62d6f1ccb8_Y = SAMPLE_TEXTURE2D(_Property_4ffddeb9667041dea5361019922617c3_Out_0.tex, _Property_4ffddeb9667041dea5361019922617c3_Out_0.samplerstate, Triplanar_6f2fd2dbd39f45f1b46f5b62d6f1ccb8_UV.xz);
            float4 Triplanar_6f2fd2dbd39f45f1b46f5b62d6f1ccb8_Z = SAMPLE_TEXTURE2D(_Property_4ffddeb9667041dea5361019922617c3_Out_0.tex, _Property_4ffddeb9667041dea5361019922617c3_Out_0.samplerstate, Triplanar_6f2fd2dbd39f45f1b46f5b62d6f1ccb8_UV.xy);
            float4 _Triplanar_6f2fd2dbd39f45f1b46f5b62d6f1ccb8_Out_0 = Triplanar_6f2fd2dbd39f45f1b46f5b62d6f1ccb8_X * Triplanar_6f2fd2dbd39f45f1b46f5b62d6f1ccb8_Blend.x + Triplanar_6f2fd2dbd39f45f1b46f5b62d6f1ccb8_Y * Triplanar_6f2fd2dbd39f45f1b46f5b62d6f1ccb8_Blend.y + Triplanar_6f2fd2dbd39f45f1b46f5b62d6f1ccb8_Z * Triplanar_6f2fd2dbd39f45f1b46f5b62d6f1ccb8_Blend.z;
            float4 _Multiply_969d0f17e76149089b7efa601089c78e_Out_2;
            Unity_Multiply_float4_float4((_Property_85bb0cea7a3e455b96bc35eef9b04b52_Out_0.xxxx), _Triplanar_6f2fd2dbd39f45f1b46f5b62d6f1ccb8_Out_0, _Multiply_969d0f17e76149089b7efa601089c78e_Out_2);
            surface.Alpha = (_Multiply_969d0f17e76149089b7efa601089c78e_Out_2).x;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
            
        
            // must use interpolated tangent, bitangent and normal before they are normalized in the pixel shader.
            float3 unnormalizedNormalWS = input.normalWS;
            const float renormFactor = 1.0 / length(unnormalizedNormalWS);
        
        
            output.WorldSpaceNormal = renormFactor * input.normalWS.xyz;      // we want a unit length Normal Vector node in shader graph
        
        
            output.WorldSpacePosition = input.positionWS;
            output.AbsoluteWorldSpacePosition = GetAbsolutePositionWS(input.positionWS);
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        void BuildAppDataFull(Attributes attributes, VertexDescription vertexDescription, inout appdata_full result)
        {
            result.vertex     = float4(attributes.positionOS, 1);
            result.tangent    = attributes.tangentOS;
            result.normal     = attributes.normalOS;
            result.vertex     = float4(vertexDescription.Position, 1);
            result.normal     = vertexDescription.Normal;
            result.tangent    = float4(vertexDescription.Tangent, 0);
            #if UNITY_ANY_INSTANCING_ENABLED
            #endif
        }
        
        void VaryingsToSurfaceVertex(Varyings varyings, inout v2f_surf result)
        {
            result.pos = varyings.positionCS;
            result.worldPos = varyings.positionWS;
            result.worldNormal = varyings.normalWS;
            // World Tangent isn't an available input on v2f_surf
        
        
            #if UNITY_ANY_INSTANCING_ENABLED
            #endif
            #if !defined(LIGHTMAP_ON)
            #if UNITY_SHOULD_SAMPLE_SH
            #endif
            #endif
            #if defined(LIGHTMAP_ON)
            #endif
            #ifdef VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
                result.fogCoord = varyings.fogFactorAndVertexLight.x;
                COPY_TO_LIGHT_COORDS(result, varyings.fogFactorAndVertexLight.yzw);
            #endif
        
            DEFAULT_UNITY_TRANSFER_VERTEX_OUTPUT_STEREO(varyings, result);
        }
        
        void SurfaceVertexToVaryings(v2f_surf surfVertex, inout Varyings result)
        {
            result.positionCS = surfVertex.pos;
            result.positionWS = surfVertex.worldPos;
            result.normalWS = surfVertex.worldNormal;
            // viewDirectionWS is never filled out in the legacy pass' function. Always use the value computed by SRP
            // World Tangent isn't an available input on v2f_surf
        
            #if UNITY_ANY_INSTANCING_ENABLED
            #endif
            #if !defined(LIGHTMAP_ON)
            #if UNITY_SHOULD_SAMPLE_SH
            #endif
            #endif
            #if defined(LIGHTMAP_ON)
            #endif
            #ifdef VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
                result.fogFactorAndVertexLight.x = surfVertex.fogCoord;
                COPY_FROM_LIGHT_COORDS(result.fogFactorAndVertexLight.yzw, surfVertex);
            #endif
        
            DEFAULT_UNITY_TRANSFER_VERTEX_OUTPUT_STEREO(surfVertex, result);
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/DepthOnlyPass.hlsl"
        
        ENDHLSL
        }
        Pass
        {
            Name "ScenePickingPass"
            Tags
            {
                "LightMode" = "Picking"
            }
        
        // Render State
        Cull Back
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 3.0
        #pragma multi_compile_instancing
        #pragma vertex vert
        #pragma fragment frag
        
        // DotsInstancingOptions: <None>
        // HybridV1InjectedBuiltinProperties: <None>
        
        // Keywords
        // PassKeywords: <None>
        // GraphKeywords: <None>
        
        // Defines
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define VARYINGS_NEED_POSITION_WS
        #define VARYINGS_NEED_NORMAL_WS
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS ScenePickingPass
        #define BUILTIN_TARGET_API 1
        #define SCENEPICKINGPASS 1
        #define _BUILTIN_SURFACE_TYPE_TRANSPARENT 1
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
        #ifdef _BUILTIN_SURFACE_TYPE_TRANSPARENT
        #define _SURFACE_TYPE_TRANSPARENT _BUILTIN_SURFACE_TYPE_TRANSPARENT
        #endif
        #ifdef _BUILTIN_ALPHATEST_ON
        #define _ALPHATEST_ON _BUILTIN_ALPHATEST_ON
        #endif
        #ifdef _BUILTIN_AlphaClip
        #define _AlphaClip _BUILTIN_AlphaClip
        #endif
        #ifdef _BUILTIN_ALPHAPREMULTIPLY_ON
        #define _ALPHAPREMULTIPLY_ON _BUILTIN_ALPHAPREMULTIPLY_ON
        #endif
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/Shim/Shims.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/LegacySurfaceVertex.hlsl"
        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/ShaderGraphFunctions.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 positionWS;
             float3 normalWS;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float3 WorldSpaceNormal;
             float3 WorldSpacePosition;
             float3 AbsoluteWorldSpacePosition;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float3 interp0 : INTERP0;
             float3 interp1 : INTERP1;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.positionWS;
            output.interp1.xyz =  input.normalWS;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.positionWS = input.interp0.xyz;
            output.normalWS = input.interp1.xyz;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _Diffuse_TexelSize;
        float4 _Normal_Map_TexelSize;
        float _Tiling;
        float _Blend;
        float _Normal_Strength;
        float _Smoothness;
        float _Metallic;
        float4 __Filter_Color;
        float4 _Emission_Color;
        float4 _Alpha_Map_TexelSize;
        float _Opacity;
        float4 _Emission_Map_TexelSize;
        float _Emission_Strength;
        float4 _Smoothness_Map_TexelSize;
        float4 _Metallic_Map_TexelSize;
        float _Ambient_Occlusion;
        float4 _Ambient_Occlusion_Map_TexelSize;
        float __Filter_Contrast;
        float _Apply_Filters;
        float __Filter_Saturation;
        CBUFFER_END
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_Diffuse);
        SAMPLER(sampler_Diffuse);
        TEXTURE2D(_Normal_Map);
        SAMPLER(sampler_Normal_Map);
        TEXTURE2D(_Alpha_Map);
        SAMPLER(sampler_Alpha_Map);
        TEXTURE2D(_Emission_Map);
        SAMPLER(sampler_Emission_Map);
        TEXTURE2D(_Smoothness_Map);
        SAMPLER(sampler_Smoothness_Map);
        TEXTURE2D(_Metallic_Map);
        SAMPLER(sampler_Metallic_Map);
        TEXTURE2D(_Ambient_Occlusion_Map);
        SAMPLER(sampler_Ambient_Occlusion_Map);
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // Graph Functions
        
        void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float Alpha;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float _Property_85bb0cea7a3e455b96bc35eef9b04b52_Out_0 = _Opacity;
            UnityTexture2D _Property_4ffddeb9667041dea5361019922617c3_Out_0 = UnityBuildTexture2DStructNoScale(_Alpha_Map);
            float _Property_0d71a168115a4531a21482c995ff11b8_Out_0 = _Tiling;
            float _Property_a5f4da8e125f4a69b3ef8e0eee9629a9_Out_0 = _Blend;
            float3 Triplanar_6f2fd2dbd39f45f1b46f5b62d6f1ccb8_UV = IN.AbsoluteWorldSpacePosition * _Property_0d71a168115a4531a21482c995ff11b8_Out_0;
            float3 Triplanar_6f2fd2dbd39f45f1b46f5b62d6f1ccb8_Blend = SafePositivePow_float(IN.WorldSpaceNormal, min(_Property_a5f4da8e125f4a69b3ef8e0eee9629a9_Out_0, floor(log2(Min_float())/log2(1/sqrt(3)))) );
            Triplanar_6f2fd2dbd39f45f1b46f5b62d6f1ccb8_Blend /= dot(Triplanar_6f2fd2dbd39f45f1b46f5b62d6f1ccb8_Blend, 1.0);
            float4 Triplanar_6f2fd2dbd39f45f1b46f5b62d6f1ccb8_X = SAMPLE_TEXTURE2D(_Property_4ffddeb9667041dea5361019922617c3_Out_0.tex, _Property_4ffddeb9667041dea5361019922617c3_Out_0.samplerstate, Triplanar_6f2fd2dbd39f45f1b46f5b62d6f1ccb8_UV.zy);
            float4 Triplanar_6f2fd2dbd39f45f1b46f5b62d6f1ccb8_Y = SAMPLE_TEXTURE2D(_Property_4ffddeb9667041dea5361019922617c3_Out_0.tex, _Property_4ffddeb9667041dea5361019922617c3_Out_0.samplerstate, Triplanar_6f2fd2dbd39f45f1b46f5b62d6f1ccb8_UV.xz);
            float4 Triplanar_6f2fd2dbd39f45f1b46f5b62d6f1ccb8_Z = SAMPLE_TEXTURE2D(_Property_4ffddeb9667041dea5361019922617c3_Out_0.tex, _Property_4ffddeb9667041dea5361019922617c3_Out_0.samplerstate, Triplanar_6f2fd2dbd39f45f1b46f5b62d6f1ccb8_UV.xy);
            float4 _Triplanar_6f2fd2dbd39f45f1b46f5b62d6f1ccb8_Out_0 = Triplanar_6f2fd2dbd39f45f1b46f5b62d6f1ccb8_X * Triplanar_6f2fd2dbd39f45f1b46f5b62d6f1ccb8_Blend.x + Triplanar_6f2fd2dbd39f45f1b46f5b62d6f1ccb8_Y * Triplanar_6f2fd2dbd39f45f1b46f5b62d6f1ccb8_Blend.y + Triplanar_6f2fd2dbd39f45f1b46f5b62d6f1ccb8_Z * Triplanar_6f2fd2dbd39f45f1b46f5b62d6f1ccb8_Blend.z;
            float4 _Multiply_969d0f17e76149089b7efa601089c78e_Out_2;
            Unity_Multiply_float4_float4((_Property_85bb0cea7a3e455b96bc35eef9b04b52_Out_0.xxxx), _Triplanar_6f2fd2dbd39f45f1b46f5b62d6f1ccb8_Out_0, _Multiply_969d0f17e76149089b7efa601089c78e_Out_2);
            surface.Alpha = (_Multiply_969d0f17e76149089b7efa601089c78e_Out_2).x;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
            
        
            // must use interpolated tangent, bitangent and normal before they are normalized in the pixel shader.
            float3 unnormalizedNormalWS = input.normalWS;
            const float renormFactor = 1.0 / length(unnormalizedNormalWS);
        
        
            output.WorldSpaceNormal = renormFactor * input.normalWS.xyz;      // we want a unit length Normal Vector node in shader graph
        
        
            output.WorldSpacePosition = input.positionWS;
            output.AbsoluteWorldSpacePosition = GetAbsolutePositionWS(input.positionWS);
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        void BuildAppDataFull(Attributes attributes, VertexDescription vertexDescription, inout appdata_full result)
        {
            result.vertex     = float4(attributes.positionOS, 1);
            result.tangent    = attributes.tangentOS;
            result.normal     = attributes.normalOS;
            result.vertex     = float4(vertexDescription.Position, 1);
            result.normal     = vertexDescription.Normal;
            result.tangent    = float4(vertexDescription.Tangent, 0);
            #if UNITY_ANY_INSTANCING_ENABLED
            #endif
        }
        
        void VaryingsToSurfaceVertex(Varyings varyings, inout v2f_surf result)
        {
            result.pos = varyings.positionCS;
            result.worldPos = varyings.positionWS;
            result.worldNormal = varyings.normalWS;
            // World Tangent isn't an available input on v2f_surf
        
        
            #if UNITY_ANY_INSTANCING_ENABLED
            #endif
            #if !defined(LIGHTMAP_ON)
            #if UNITY_SHOULD_SAMPLE_SH
            #endif
            #endif
            #if defined(LIGHTMAP_ON)
            #endif
            #ifdef VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
                result.fogCoord = varyings.fogFactorAndVertexLight.x;
                COPY_TO_LIGHT_COORDS(result, varyings.fogFactorAndVertexLight.yzw);
            #endif
        
            DEFAULT_UNITY_TRANSFER_VERTEX_OUTPUT_STEREO(varyings, result);
        }
        
        void SurfaceVertexToVaryings(v2f_surf surfVertex, inout Varyings result)
        {
            result.positionCS = surfVertex.pos;
            result.positionWS = surfVertex.worldPos;
            result.normalWS = surfVertex.worldNormal;
            // viewDirectionWS is never filled out in the legacy pass' function. Always use the value computed by SRP
            // World Tangent isn't an available input on v2f_surf
        
            #if UNITY_ANY_INSTANCING_ENABLED
            #endif
            #if !defined(LIGHTMAP_ON)
            #if UNITY_SHOULD_SAMPLE_SH
            #endif
            #endif
            #if defined(LIGHTMAP_ON)
            #endif
            #ifdef VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
                result.fogFactorAndVertexLight.x = surfVertex.fogCoord;
                COPY_FROM_LIGHT_COORDS(result.fogFactorAndVertexLight.yzw, surfVertex);
            #endif
        
            DEFAULT_UNITY_TRANSFER_VERTEX_OUTPUT_STEREO(surfVertex, result);
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/DepthOnlyPass.hlsl"
        
        ENDHLSL
        }
    }
    CustomEditorForRenderPipeline "UnityEditor.Rendering.BuiltIn.ShaderGraph.BuiltInLitGUI" ""
    CustomEditor "UnityEditor.ShaderGraph.GenericShaderGraphMaterialGUI"
    FallBack "Hidden/Shader Graph/FallbackError"
}