Shader "Custom/CustomShader"
// This is just sample code for the powerpoint slides illustrating the 
// structure of a Unity ShaderLab shader
{
 Properties
    {
        // Material property declarations go here
    }

    SubShader
    {
        Tags {"ExampleSubShaderTaKey" = "ExampleSubShaderTagVale"}
        LOD 10 // level of detail value for the SubShader - optional 


        HLSLINCLUDE
        // Common HLSL code that you want to share goes here
        ENDHLSL

        // The code that defines the rest of the SubShader goes here

        Pass
        {
           Name "SimpleShaderPass"
           Tags {"SimplePassTagKey" = "SimplePassTagValue"}

           // Shader commnds that apply to this pass would go here
           // see: https://docs.unity3d.com/6000.0/Documentation/Manual/SL-Commands.html 

           // HLSL code block is defined by the HLSLPROGRAM directive
           
           HLSLPROGRAM
                // HLSL shader code goes here
           ENDHLSL

        }
    }

    Fallback "ExampleFallbackShader"
}

