// This shader fills the mesh shape with a color predefined in the code.
Shader "Example/SimpleURPShader"
{
    
    // The properties block of the Unity shader. In this example this block is empty
    // because the output color is predefined in the fragment shader code.
    Properties
    { 
        [MainColor] _BaseColour("Base Colour", color) = (1, 1, 1, 1)
    }

    /*
        From: https://docs.unity3d.com/6000.2/Documentation/Manual/shader-objects.html
        SubShaders let you separate your Shader object into parts that are compatible with different hardware, render pipelines, and runtime settings.

        A SubShader contains:

        Information about which hardware, render pipelines, and runtime settings this SubShader is compatible with
        SubShader tags, which are key-value pairs that provide information about the SubShader
        One or more Passes
    */

    // The SubShader block containing the Shader code.
    SubShader
    {
        // SubShader Tags define when and under which conditions a SubShader block or
        // a pass is executed.
        // RenderType = "Opaque": Tells Unity this is a solid, non-transparent object
        // RenderPipeline = "UniversalPipeline": Specifies this shader is for URP
        Tags { "RenderType" = "Opaque" "RenderPipeline" = "UniversalPipeline" }
        LOD 200 // level of detail value for the SubShader - optional 

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

            // Define a constant buffer for the material
            CBUFFER_START(UnityPerMaterial)
                half4 _BaseColour;
            CBUFFER_END

            // The structure definition defines which variables it contains.
            // This example uses the Attributes structure as an input structure in
            // the vertex shader.
            struct Attributes
            {
                // The positionOS variable contains the vertex positions in object space.
                float4 positionOS   : POSITION;
            };

            struct Varyings
            {
                // The positions in this struct must have the SV_POSITION semantic.
                // SV Semantic Value
                float4 positionHCS  : SV_POSITION;
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
                // Returning the output.
                return OUT;
            }

            // The fragment shader definition. 
            // HLSL shader programs, input and output variables need to have their “intent” 
            // indicated via semantics. SV_Target indicates the ouput is a colour
            half4 frag() : SV_Target
            {
                // Defining the color variable and returning it.
                //half4 customColor = half4(0, 0, 1, 1);
                //return customColor;
                
                // Just return the colour stored in the _BaseColor constant buffer.
                return _BaseColour;
            }
            ENDHLSL
        }
    }

}