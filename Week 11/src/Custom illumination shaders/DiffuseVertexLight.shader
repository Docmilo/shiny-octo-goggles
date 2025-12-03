// Simple shader to demonstate per vertex illumination using Lambertian lighting equation
// Lambertian lighting is fine for directional lights simulating the sun

Shader "Custom/DiffuseVertexLighting"
{
    Properties
    {
        //Surface colour - what light is reflected back to the eye/camera
        _ObjectSurfaceColor("Object surface Color", Color) = (1, 1, 1, 1)
        
    }

    SubShader
    {
        Tags { "RenderType" = "Opaque" "RenderPipeline" = "UniversalPipeline" }

        Pass
        {
            HLSLPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            // We need need to include core unity lighting functions
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

             CBUFFER_START(UnityPerMaterial)
                half4 _ObjectSurfaceColor;
            CBUFFER_END

            // Input structure to the vertex shader
            struct Attributes
            {
                // Vertex position (in object space)
                float4 positionOS : POSITION;
                // Vertex nortmal (also in object space)
                float3 normal : NORMAL;
            };

            // Output from the vertex shader and input into the pixel shader
            struct Varyings
            {
                float4 positionHCS : SV_POSITION;                
                half4 litVertexColour: COLOR;
                half3 normal : NORMAL;
                
            };


            Varyings vert(Attributes IN)
            {
                Varyings OUT;
                OUT.positionHCS = TransformObjectToHClip(IN.positionOS.xyz);               
                
                // Get the VertexNormalInputs of the vertex, which contains the normal in world space
                // This gives us tangetWS, bitangentWS and normalWS
                // See: https://docs.unity3d.com/Packages/com.unity.render-pipelines.universal@14.0/manual/use-built-in-shader-methods-transformations.html
                VertexNormalInputs positions = GetVertexNormalInputs(IN.positionOS);
                OUT.normal = positions.normalWS;

                // Get the properties of the main light (usually the directional light)
                Light mainLight = GetMainLight();
                // returns this structure: https://docs.unity3d.com/Packages/com.unity.render-pipelines.universal@14.0/manual/use-built-in-shader-methods-lighting.html 

                 // Calculate the amount of light the vertex receives
                //OUT.lightAmount = LightingLambert(mainLight.color, mainLight.direction, positions.normalWS.xyz);

                // // Calculate the dot product between the light and surface normal
                 half3 NdotL = saturate(dot(positions.normalWS,mainLight.direction));
                // // Amount of Light
                 half3 lightAmount = NdotL * mainLight.color;
                 half3 finalColour = _ObjectSurfaceColor * (mainLight.distanceAttenuation * lightAmount);

                OUT.litVertexColour = half4(finalColour,1);
                
                return OUT;
            }

            half4 frag(Varyings IN) : SV_Target
            {
                // return the colour calculated by the vertex shader 
                return IN.litVertexColour ;
            }
            ENDHLSL
        }
    }
}

