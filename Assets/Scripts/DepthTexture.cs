using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
[RequireComponent(typeof(Camera))]
public class DepthTexture : MonoBehaviour
{
    public Camera cam;
    public Material mat;
    [SerializeField]
    DepthTextureMode depthTextureMode;

    private void Start()
    {

    }

    private void Awake()
    {
        if (cam == null)
        {
            cam = this.GetComponent<Camera>();
        }
        if (mat == null)
        {
            mat = new Material(Shader.Find("Texture/GetDepth"));
        }
    }

    private void Update()
    {
        SetCameraDepthTextureMode();
    }

    private void OnPreRender()
    {
        Shader.SetGlobalMatrix(Shader.PropertyToID("UNITY_MATRIX_IV"), cam.cameraToWorldMatrix);
    }

    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        Graphics.Blit(source, destination, mat);
    }

    void SetCameraDepthTextureMode()
    {
        cam.depthTextureMode = depthTextureMode;
    }
}
