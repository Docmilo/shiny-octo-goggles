using System;
using Unity.VisualScripting;
using UnityEngine;
using UnityEngine.LowLevelPhysics;
using UnityEngine.UIElements;
using static UnityEditor.Searcher.SearcherWindow.Alignment;

/// <summary>
/// Build a mesh containing a single triangle with UVs.
/// Create an array of vertices, UVs and triangles, and copy them to the mesh
/// </summary>

namespace GraphicsDemo
{
    public class MeshTriangles : MonoBehaviour
    {
        // Start is called once before the first execution of Update after the MonoBehaviour is created
        // Textures https://free-3dtextureshd.com/
        void Start()
        {
            // Add a meshFilter and MeshRenderer to the empty game object
            MeshFilter meshFilter = gameObject.AddComponent<MeshFilter>();
            MeshRenderer meshRender = gameObject.AddComponent<MeshRenderer>();

            //Make sure to enable the Keywords
            meshRender.material.EnableKeyword("_NORMALMAP");
            meshRender.material.EnableKeyword("_METALLICGLOSSMAP");


            // Get the mesh from the meshFilter
            Mesh triangle = meshFilter.mesh;

            // Clear all vertex data and all triangle indices.
            triangle.Clear();

            // Let's add some verticies to the triangle mesh
            triangle.vertices = new Vector3[] { new Vector3(0, 0, 0), new Vector3(0, 1, 0), new Vector3(1, 1, 0), new Vector3(1,0,0) } ;

            // Add some UV coordinates for the each of the verticies
            // Unity stores UVs in 0-1 space. [0,0] represents the bottom-left corner of the texture, and [1,1] represents the top-right.
            triangle.uv = new Vector2[] { new Vector2(0, 0), new Vector2(0, 1), new Vector2(1, 1), new Vector2(1, 0) };

            //mesh.triangles contains a list of indicies into the vertex array. Must always be multiples of 3
            // Define the indicies required to draw a simple triangle

            //triangle.triangles = new int[] { 0, 1, 2 }; 

            // Define the indicies required to draw a simple square consisting of two triangles
            triangle.triangles = new int[] { 0, 1, 2, 0, 2, 3 }; 
            //triangle.triangles = new int[] { 0, 1, 2, 0, 3, 2 }; // hidden triangle

            // Recalculates the normals of the Mesh from the triangles and vertices.
            triangle.RecalculateNormals();

            // Load the texture from the resources folder
            Texture tex = Resources.Load("WoodCrate") as Texture; // simple texture
            //Texture tex = Resources.Load("Dirty_pavement_Albedo") as Texture;
            //Texture normalMap = Resources.Load("Dirty_pavement_Normal") as Texture;

            meshRender.material.mainTexture = tex;

            // Set the normal map using the texture
            //meshRender.material.SetTexture("_BumpMap", normalMap);

            print(meshRender.material.ToString());
            print("a message ");

            //Shader defaultShader = Resources.Load("DefaultShader") as Shader;
            //Material mat = new Material(defaultShader);


            //mat.SetTexture("_MainTex", tex);


            //meshRender.materials[0] = Resources.Load("Dirty") as Material;



            //mat.mainTexture = Resources.Load("Dirty") as Texture; 
            //            triangle.GetComponent<MeshRenderer>().materials[0] = mat;

            //gameObject.GetComponent<MeshRenderer>().material = mat;

        }

    }
}


