using UnityEngine;

[ExecuteInEditMode, ImageEffectAllowedInSceneView]
public class MasterFractal : MonoBehaviour 
{
    public ComputeShader coreShader;

    [Range (1, 20)]
    public float fractalPower = 10;
    public float darkness = 70;

    [Header ("Color")]
    [Range (0, 1)] public float Grayscale;
    [Range (0, 1)] public float PrimaryRed;
    [Range (0, 1)] public float PrimaryGreen = 0.2f;
    [Range (0, 1)] public float PrimaryBlue;
    [Range (0, 1)] public float SecondaryRed;
    [Range (0, 1)] public float SecondaryGreen;
    [Range (0, 1)] public float SecondaryBlue = 1;

    RenderTexture target;
    Camera cam;
    Light directionalLight;

    [Header ("Animation")]
    public float powerIncreaseSpeed = 0.2f;

    void Start() 
    {
        Application.targetFrameRate = 60;
    }
    
    void Init() 
    {
        cam = Camera.current;
        directionalLight = FindObjectOfType<Light>();
    }

    // Animate properties
    void Update() 
    {
        if (Application.isPlaying) 
        {
            fractalPower += powerIncreaseSpeed * Time.deltaTime;
        }
    }

    void OnRenderImage(RenderTexture source, RenderTexture destination) 
    {
        Init();
        InitRenderTexture();
        SetParameters();

        int threadGroupsX = Mathf.CeilToInt(cam.pixelWidth / 8.0f);
        int threadGroupsY = Mathf.CeilToInt(cam.pixelHeight / 8.0f);
        coreShader.Dispatch(0, threadGroupsX, threadGroupsY, 1);

        Graphics.Blit(target, destination);
    }

    void SetParameters() 
    {
        coreShader.SetTexture(0, "Destination", target);
        coreShader.SetFloat("power", Mathf.Max(fractalPower, 1.01f));
        coreShader.SetFloat("darkness", darkness);
        coreShader.SetFloat("grayscale", Grayscale);
        coreShader.SetVector("colorPrimeMix", new Vector3(PrimaryRed, PrimaryGreen, PrimaryBlue));
        coreShader.SetVector("colorSecondMix", new Vector3(SecondaryRed, SecondaryGreen, SecondaryBlue));

        coreShader.SetMatrix("_CameraToWorld", cam.cameraToWorldMatrix);
        coreShader.SetMatrix("_CameraInverseProjection", cam.projectionMatrix.inverse);
        coreShader.SetVector("_LightDirection", directionalLight.transform.forward);

    }

    void InitRenderTexture() 
    {
        if (target == null || target.width != cam.pixelWidth || target.height != cam.pixelHeight) 
        {
            if (target != null) 
            {
                target.Release();
            }
            target = new RenderTexture(cam.pixelWidth, cam.pixelHeight, 0, RenderTextureFormat.ARGBFloat, RenderTextureReadWrite.Linear);
            target.enableRandomWrite = true;
            target.Create();
        }
    }
}