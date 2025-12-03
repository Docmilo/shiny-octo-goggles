// A shader that just uses Unity's BlinnPhong
Shader "CustomURPBlinnPhong"
{
     Properties {
        // Material property declarations go here
        _Color ("Colour", Color) = (1,1,1,1)
    }
    

    SubShader
    {
        Tags { "RenderType" = "Opaque" "RenderPipeline" = "UniversalPipeline" "Queue" = "Geometry"}

        Pass
        {
            Name "ForwardPass"
            // The Pass renders object geometry and evaluates all light contributions. URP uses this tag value in the Forward Rendering Path.
            // See: https://docs.unity3d.com/Packages/com.unity.render-pipelines.universal@14.0/manual/urp-shaders/urp-shaderlab-pass-tags.html
            Tags {"LightMode" = "UniversalForward"}
            
            HLSLPROGRAM
            #define _SPECULAR_COLOR
            #pragma vertex vert
            #pragma fragment frag
            // Make the shader compatible with forward and deferred rendering paths
            #pragma shader_feature _CLUSTER_LIGHT_LOOP

            // To enable shadows from objects illuminated by directional light define these declarations
            #pragma shader_feature_fragment _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN

            // To enable shadows from objects illuminated by point lights
            #pragma shader_feature_fragment _ADDITIONAL_LIGHT_SHADOWS
                                            

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            
            CBUFFER_START(UnityPerMaterial)
                half4 _Color;
            CBUFFER_END


            struct Attributes
            {
                float4 positionOS : POSITION;
                float3 normal : NORMAL;
                float2 uv: TEXCOORD0;
            };

            struct Varyings
            {
                float4 positionCS  : SV_POSITION;
                float3 normalWS: TEXCOORD0;
                float3 positionWS : TEXCOORD1;
            };

            Varyings vert(Attributes IN)
            {
                Varyings OUT;

                OUT.positionCS = TransformObjectToHClip(IN.positionOS);
                OUT.normalWS = TransformObjectToWorldNormal(IN.normal);
                OUT.positionWS = TransformObjectToWorld(IN.positionOS);
                
                return OUT;
            }

            half4 frag(Varyings IN) : SV_Target
            {
                InputData lighting = (InputData) 0;
                lighting.positionWS = IN.positionWS;
                // Normals in the fragement shader can be interpolated so they need to be normalised
                lighting.normalWS = normalize(IN.normalWS);
                lighting.viewDirectionWS = GetWorldSpaceViewDir(IN.positionWS);

                // To make the object cast and recieve shadows
                lighting.shadowCoord = TransformWorldToShadowCoord(IN.positionWS);

                // Define surface data for our object
                SurfaceData surface = (SurfaceData) 0;
                surface.albedo = _Color;
                surface.alpha = 1;
                surface.smoothness = 0.9;
                surface.specular = 0.9;

                // Call the UniversalFragmentBlinnPhong with the light and surface information
                return UniversalFragmentBlinnPhong(lighting, surface);
                // Add the ambient light colour from Unity's skybox
                //return UniversalFragmentBlinnPhong(lighting, surface) + unity_AmbientSky;


            }
            ENDHLSL
        }

        Pass {
            Name "ShadowCaster"
            Tags {"LightMode" = "ShadowCaster"}
            // Set GPU command to say that this pass doesn't return any colour
            ColorMask 0
                
            HLSLPROGRAM         

            #pragma vertex vert
            #pragma fragment frag                                         

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"

            float3 _LightDirection; //Populated by URP

            struct Attributes
            {
                float4 positionOS : POSITION;
                float3 normal : NORMAL;
            };

            struct Varyings
            {
                float4 positionCS  : SV_POSITION;

            };
                
            float4 GetShadowPositionHClip(Attributes input){
                float3 positionWS = TransformObjectToWorld(input.positionOS);
                float3 normalWS = TransformObjectToWorldNormal(input.normal);
                float4 positionCS = TransformWorldToHClip(ApplyShadowBias(positionWS, normalWS, _LightDirection));
                positionCS = ApplyShadowClamping(positionCS);
                return positionCS;
            }

            Varyings vert(Attributes IN)
            {
                Varyings OUT;

                OUT.positionCS = GetShadowPositionHClip(IN);
                
                return OUT;
            }

            half4 frag(Varyings IN) : SV_TARGET{
                return 0;
            }

            ENDHLSL

        }
    }
}

