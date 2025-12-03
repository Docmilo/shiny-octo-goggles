// Modified per pixel shader illumination with additional 
// ambient light colour and strength values

Shader "Custom/DiffusePixelLighting"
{
    Properties
    {
        //Surface colour - what light is reflected back to the eye/camera
        _ObjectSurfaceColor("Object surface Color", Color) = (1, 1, 1, 1)   
        _AmbientColor("Ambient Color", Color) = (1, 1, 1, 1)
        _AmbientStrength("Ambient Strength", Vector) = (1, 1, 1, 1)
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
                half4 _AmbientColor;
                half3 _AmbientStrength;
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
                // we don't need this if light is calculated at the pixel level
                //half4 litVertexColour: COLOR; 
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

                return OUT;
            }

            half4 frag(Varyings IN) : SV_Target
            {
                //Calculate lighting at the per pixel level
                 // Get the properties of the main light
                Light mainLight = GetMainLight();
                // returns this structure: https://docs.unity3d.com/Packages/com.unity.render-pipelines.universal@14.0/manual/use-built-in-shader-methods-lighting.html 

                // Calculate the dot product between the light and surface normal
                //half3 NdotL = saturate(dot(IN.normal,mainLight.direction));
                 half3 NdotL = saturate(dot(normalize(IN.normal),mainLight.direction));
                // Amount of Light
                 half3 lightStrength = NdotL * mainLight.color;

                 // Just use the LightingLambert function in Lighting.hlsl to implement lambert 
                 //half3 LightingLambert(half3 lightColor, half3 lightDir, half3 normal)
                 //half3 lightStrength = LightingLambert(mainLight.color, mainLight.direction, IN.normal);

                 // In reality we would have indirect lighting from multiple sources
                 // We can simulate that with an overall ambient light
                 //We can specify a general ambient amount of light and add it to remove black areas
                 float3 ambient = _AmbientColor * _AmbientStrength;

                 half3 finalColour = _ObjectSurfaceColor * (mainLight.distanceAttenuation * lightStrength) + ambient;

                return half4(finalColour,1);
                
            }
            ENDHLSL
        }
    }
}

