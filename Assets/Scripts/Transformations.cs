using UnityEngine;
using System;

public class Transformations : MonoBehaviour
{

    CreateGrid createGrid;

    Vector3[] startPos;

    [Header("Movement Controls")]
    public float moveFrequency = 2f;
    public float moveAmplitude = 5f;
    public float moveOffset = 0f;

    Vector3 startScale = Vector3.zero;

    [Header("Scale Controls")]
    public float scaleFrequency = 2f;
    public float scaleAmplitude = 5f;
    public float scaleOffset = 0f;

    [Header("Rotation Controls")]
    public float rotationSpeed = 5f;
    public Vector3 rotationVector = new Vector3(1, 1, 1);


    // Start is called once before the first execution of Update after the MonoBehaviour is created
    private void Start()
    {
        createGrid = GetComponent<CreateGrid>();
        startPos = createGrid.startPos;
        startScale = createGrid.grid[0].localScale;
    }

    // Update is called once per frame
    void Update()
    {
        {
            for (int i = 0, z = 0; z < createGrid.gridResolution; z++)
            {
                for (int y = 0; y < createGrid.gridResolution; y++)
                {
                    for (int x = 0; x < createGrid.gridResolution; x++, i++)
                    {
                        createGrid.grid[i].localPosition = startPos[i] + Vector3.up * Mathf.Sin(Time.time * moveFrequency + moveOffset) * moveAmplitude;

                        createGrid.grid[i].localScale = startScale * Mathf.Cos(Time.time * scaleFrequency) * scaleAmplitude + Vector3.one * scaleOffset;

                        createGrid.grid[i].Rotate(rotationVector * Time.deltaTime * rotationSpeed * UnityEngine.Random.Range(-20, 20));
                    }
                }
            }
        }
    }
}
