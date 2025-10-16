using System.Collections;
using Unity.VisualScripting;
using UnityEditor;
using UnityEngine;
using UnityEngine.UI;

public class PokeballLine : MonoBehaviour
{
    public LineRenderer lineRenderer;
    public Transform pokeballPos;
    public Transform pokeballTarget;
    public Animator animator;
    public Vector3 lerpVector;

    

    // Start is called once before the first execution of Update after the MonoBehaviour is created
    void Start(){
        lineRenderer = GetComponent<LineRenderer>();
        lineRenderer.positionCount = 2;
        lerpVector = pokeballPos.position;

    }

    // Update is called once per frame
    void Update(){
        lineRenderer.SetPosition(0, pokeballPos.position);
        lineRenderer.SetPosition(1, lerpVector);
    }
    public void OnClick(){
        StopAllCoroutines();
        pokeballPos.LookAt(pokeballTarget.position);

        StartCoroutine(LineLerp(pokeballPos.position, pokeballTarget.position));

        animator.SetTrigger("GoNuts");

    }
    public IEnumerator LineLerp(Vector3 startPos, Vector3 endPos){
        float time = 0 ;
        while (time < 10){
            lerpVector = Vector3.Lerp(startPos, endPos, time);
            time += Time.deltaTime;

            yield return null;
        }


        yield return null;
    }
    public void ReturnLine(){

        StartCoroutine(LineLerp(pokeballTarget.position, pokeballPos.position));

    }



}
