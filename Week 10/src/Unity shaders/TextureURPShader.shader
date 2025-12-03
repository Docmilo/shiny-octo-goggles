// This shader fills the mesh shape with a color predefined in the code.
Shader "Example/TextureURPShader"
{
    // Let's define a texture for the material
    Properties
    { 
        [MainTexture] _BaseMap("Base Map", 2D) = "white" {}
    }

    // The SubShader block containing the Shader code.
    SubShader
    {
        // SubShader Tags define when and under which conditions a SubShader block or
        // a pass is executed.
        // RenderType = "Opaque": Tells Unity this is a solid, non-transparent object
        // RenderPipeline = "UniversalPipeline": Specifies this shader is for URP
        Tags { "RenderType" = "Opaque" "RenderPipeline" = "UniversalPipeline" }

        /*
            A subshader consists of one or more several Passes
            A Pass contains:

            Pass tags, which are key-value pairs that provide information about the Pass
            Instructions for updating the render state before running its shader programs
            Shader programs, organised into one or more shader variants
        
        */
        Pass
        {
            // The HLSL code block. Unity SRP uses the HLSL language.
            HLSLPROGRAM
            // This line defines the name of the vertex shader.
            #pragma vertex vert
            // This line defines the name of the fragment shader.
            #pragma fragment frag

            // The Core.hlsl file contains definitions of frequently used HLSL
            // macros and functions, and also contains #include references to other
            // HLSL files (for example, Common.hlsl, SpaceTransforms.hlsl, etc.).
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            // This macro declares _BaseMap as a Texture2D object.
            TEXTURE2D(_BaseMap);
            // This macro declares the sampler state for the _BaseMap texture.
            SAMPLER(sampler_BaseMap);
            // For more information on texture samplers : https://docs.unity3d.com/6000.2/Documentation/Manual/SL-SamplerStates.html
            

            // Define a constant buffer for the material
            CBUFFER_START(UnityPerMaterial)
                // The _ST suffix is necessary as some macros use it
                float4 _BaseMap_ST;
            CBUFFER_END

            // The structure definition defines which variables it contains.
            // This example uses the Attributes structure as an input structure in
            // the vertex shader.
            struct Attributes
            {
                // The positionOS variable contains the vertex positions in object
                // space.
                float4 positionOS   : POSITION;
                // Add texture coordinates
                float2 uv           : TEXCOORD0;

            };

            struct Varyings
            {
                // The positions in this struct must have the SV_POSITION semantic.
                // SV Semantic Value
                float4 positionHCS  : SV_POSITION;
                // Add texture coordinates
                float2 uv           : TEXCOORD0;
            };

            // The vertex shader definition with properties defined in the Varyings
            // structure. The type of the vert function must match the type (struct)
            // that it returns.
            Varyings vert(Attributes IN)
            {
                // Declaring the output object (OUT) with the Varyings struct.
                Varyings OUT;
                // The TransformObjectToHClip function transforms vertex positions
                // from object space to homogenous clip space.
                OUT.positionHCS = TransformObjectToHClip(IN.positionOS.xyz);
                OUT.uv = TRANSFORM_TEX(IN.uv, _BaseMap);
                // Returning the output.
                return OUT;
            }

            // The fragment shader definition. 
            // HLSL shader programs, input and output variables need to have their “intent” 
            // indicated via semantics. SV_Target indicates the ouput is a colour
            half4 frag(Varyings IN) : SV_Target
            {
                // Defining the color variable and returning it.
                //half4 customColor = half4(0.5, 0, 0, 1);
                //return customColor;
                
                // Get the pixel colour by sampling the texutre usin the UVs
                half4 color = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, IN.uv);
                return color;
            }
            ENDHLSL
        }
    }
}