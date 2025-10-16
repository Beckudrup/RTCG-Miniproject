using UnityEngine;

public class ColorChanger : MonoBehaviour
{
    public MeshRenderer gridMeshRenderer;

    // Start is called once before the first execution of Update after the MonoBehaviour is created
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        gridMeshRenderer.material.color = Random.ColorHSV();    
    }
}
