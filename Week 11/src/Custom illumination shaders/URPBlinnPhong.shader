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
            // See: https://docs.unity3d.com/Packages/com.unity.render-pipelines.universal@14.0/manual/use-built-in-shader-methods-shadows.html 
            Name "ShadowCaster" 
           // In order to cast shadows, a shader has to have a ShadowCaster pass type/tag 
           // See: https://docs.unity3d.com/6000.2/Documentation/Manual/SL-PassTags.html 
           Tags {"LightMode" = "ShadowCaster"} 
           // The ShadowCaster pass is used to render the object into the shadowmap
           // Set GPU command to say that this pass doesn't return any colour as we render the shadow map not the back buffer
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
               float4 shadowCoords : TEXCOORD3;
          
           };
               
          
           Varyings vert(Attributes IN)
           {
               // The vertex shader funtion only needs to evaluate the vertex position in clip space for the ShadowCaster
               // We can use Unity's ApplyShadowClamping function in Shadows.hlsl
               Varyings OUT;
          
               OUT.positionCS = TransformObjectToHClip(IN.positionOS.xyz);
          
               // Get the VertexPositionInputs for the vertex position  
               VertexPositionInputs positions = GetVertexPositionInputs(IN.positionOS.xyz);
          
               // Convert the vertex position to a position on the shadow map
               float4 shadowCoordinates = GetShadowCoord(positions);
          
               // Pass the shadow coordinates to the fragment shader
               OUT.shadowCoords = shadowCoordinates;
          
               return OUT;
           }
          
           half4 frag(Varyings IN) : SV_TARGET{
               return 0;
           }
          
           ENDHLSL

        }
    }
}

