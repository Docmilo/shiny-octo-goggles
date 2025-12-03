using System;
using System.Runtime.CompilerServices;
using UnityEngine;
namespace Week9
{
    /// <summary>
    /// VertexYValueController implements the singleton design pattern and we will use it to store
    /// x, y and z position values for a single vertex.
    /// </summary>
    public class VertexYValueController : MonoBehaviour
    {
        // Start is called once before the first execution of Update after the MonoBehaviour is created
        public float xValue;
        public float yValue;
        public float zValue;

        static VertexYValueController _instance;


        /// <summary>
        /// The GetInstance is a static method that returns an new instance of VertexYValueController
        /// if one doesn't exist. Otherwise it returns the _instance static data member of the class
        /// </summary>
        /// <returns></returns>
        public static VertexYValueController GetInstance()
        {
            if (_instance == null)
            {
                _instance = new GameObject("_YValueController").AddComponent<VertexYValueController>();

            }
            return _instance;
        }



    }

}
