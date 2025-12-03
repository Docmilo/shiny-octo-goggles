// Simple shader to demonstate/simulate diffusing lighting

Shader "Custom/DiffuseReflection"
{
    Properties
    {
        // Inspector Properties to allow us to define the surface colour
        // and incoming light colour
        _DiffuseLightColor("Incoming diffuse light Color", Color) = (1, 1, 1, 1)
        _DiffuseReflectionColor("Diffuse reflection Color", Color) = (1, 1, 1, 1)
        
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

             CBUFFER_START(UnityPerMaterial)
                half4 _DiffuseLightColor;
                half4 _DiffuseReflectionColor;
            CBUFFER_END

            struct Attributes
            {
                float4 positionOS : POSITION;
            };

            struct Varyings
            {
                float4 positionHCS : SV_POSITION;                
                half4 vertexColour: COLOR;
            };


            Varyings vert(Attributes IN)
            {
                Varyings OUT;
                OUT.positionHCS = TransformObjectToHClip(IN.positionOS.xyz);
                
                // Calculate the diffuse reflection
                // Remember reflection is the amount of light an object reflects back
                OUT.vertexColour = _DiffuseLightColor * _DiffuseReflectionColor;
                return OUT;
            }

            half4 frag(Varyings IN) : SV_Target
            {
                // return the colour calculated by the vertex shader               
                return IN.vertexColour;
            }
            ENDHLSL
        }
    }
}
