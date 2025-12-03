using UnityEngine;
using UnityEngine.AI;

namespace Week9
{
    [RequireComponent(typeof(MeshFilter))]
    public class MeshGenerator : MonoBehaviour
    {
        Mesh objectMesh;

        Vector3[] vertices;
        int[] indicies;

        // Start is called once before the first execution of Update after the MonoBehaviour is created
        void Start()
        {
            objectMesh = new Mesh();
            GetComponent<MeshFilter>().mesh = objectMesh;

            CreateGeometry();
        }
        /// <summary>
        /// The CreateGeometry method defines some simple geometry for our gameobject
        /// </summary>
        void CreateGeometry()
        {
            // Clear the mesh geometry (vertices and indicies)
            objectMesh.Clear();
            // We could define the vertices in an array and assign the array to the mesh or do it directly
            // vertices = new Vector3[] { new Vector3(0, 0, 0), new Vector3(0, 1, 0), new Vector3(1, 1, 0), new Vector3(1, 0, 0) };
            // objectMesh.vertices = vertices;

            // and indicies / triangles
            // indicies = new int[] { 0, 1, 2, 0, 2, 3 };
            // objectMesh.triangles = indicies;

            // or just do it directly
            //objectMesh.vertices = new Vector3[] { new Vector3(0, 0, 0), new Vector3(0, 1, 0), new Vector3(1, 1, 0), new Vector3(1, 0, 0) };

            // Using the dynamy yvalue to deform the quad
            objectMesh.vertices = new Vector3[] { new Vector3(VertexYValueController.GetInstance().xValue, VertexYValueController.GetInstance().yValue, VertexYValueController.GetInstance().zValue)
                , new Vector3(0, 1, 0), new Vector3(1, 1, 0), new Vector3(1, 0, 0) };
            //
            objectMesh.triangles = new int[] { 0, 1, 2, 0, 2, 3 };


        }

        // Update is called once per frame
        void Update()
        {
            CreateGeometry();

        }
    }
}
