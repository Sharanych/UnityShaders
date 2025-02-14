using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode, ImageEffectAllowedInSceneView]
public class ComplexRaymarching : MonoBehaviour 
{
    public ComputeShader raymarching;
    RenderTexture target;
    Camera ccamera;
    Light lightSource;
    List<ComputeBuffer> buffersToDispose;

    struct ShapeData 
    {
        public Vector3 position;
        public Vector3 scale;
        public Vector3 colour;
        public int shapeType;
        public int operation;
        public float blendStrength;
        public int numChildren;

        public static int GetSize()
        {
            return sizeof(float) * 10 + sizeof(int) * 3;
        }
    }

    void Init() 
    {
        ccamera = Camera.current;
        lightSource = FindObjectOfType<Light>();
    }


    void OnRenderImage(RenderTexture source, RenderTexture destination) 
    {
        Init();
        buffersToDispose = new List<ComputeBuffer>();

        InitRenderTexture();
        CreateScene();
        SetParameters();

        raymarching.SetTexture(0, "Source", source);
        raymarching.SetTexture(0, "Destination", target);

        int threadGroupsX = Mathf.CeilToInt(ccamera.pixelWidth / 8.0f);
        int threadGroupsY = Mathf.CeilToInt(ccamera.pixelHeight / 8.0f);
        raymarching.Dispatch(0, threadGroupsX, threadGroupsY, 1);

        Graphics.Blit(target, destination);

        foreach(var buffer in buffersToDispose) 
        {
            buffer.Dispose();
        }
    }

    void CreateScene() 
    {
        List<ShapePattern> allShapes = new List<ShapePattern>(FindObjectsOfType<ShapePattern>());
        allShapes.Sort((a, b) => a.operation.CompareTo(b.operation));

        List<ShapePattern> orderedShapes = new List<ShapePattern>();

        for (int i = 0; i < allShapes.Count; i++) 
        {
            // Add top-level shapes (those without a parent)
            if (allShapes[i].transform.parent == null) 
            {
                Transform parentShape = allShapes[i].transform;
                orderedShapes.Add(allShapes[i]);
                allShapes[i].numChildren = parentShape.childCount;
                // Add all children of the shape (nested children not supported currently)
                for (int j = 0; j < parentShape.childCount; j++) 
                {
                    if (parentShape.GetChild(j).GetComponent<ShapePattern>() != null) 
                    {
                        orderedShapes.Add(parentShape.GetChild(j).GetComponent<ShapePattern>());
                        orderedShapes[orderedShapes.Count - 1].numChildren = 0;
                    }
                }
            }

        }

        ShapeData[] shapeData = new ShapeData[orderedShapes.Count];
        for (int i = 0; i < orderedShapes.Count; i++) 
        {
            var s = orderedShapes[i];
            Vector3 col = new Vector3 (s.colour.r, s.colour.g, s.colour.b);
            shapeData[i] = new ShapeData() 
            {
                position = s.Position,
                scale = s.Scale, colour = col,
                shapeType = (int)s.shapeType,
                operation = (int)s.operation,
                blendStrength = s.blendStrength*3,
                numChildren = s.numChildren
            };
        }

        ComputeBuffer shapeBuffer = new ComputeBuffer(shapeData.Length, ShapeData.GetSize());
        shapeBuffer.SetData(shapeData);
        raymarching.SetBuffer(0, "shapes", shapeBuffer);
        raymarching.SetInt("numShapes", shapeData.Length);

        buffersToDispose.Add(shapeBuffer);
    }

    void SetParameters() 
    {
        bool lightIsDirectional = lightSource.type == LightType.Directional;
    
        raymarching.SetMatrix("_CameraToWorld", ccamera.cameraToWorldMatrix);
        raymarching.SetMatrix("_CameraInverseProjection", ccamera.projectionMatrix.inverse);
        raymarching.SetVector("_Light", (lightIsDirectional) ? lightSource.transform.forward : lightSource.transform.position);
        raymarching.SetBool("positionLight", !lightIsDirectional);
    }

    void InitRenderTexture() 
    {
        if (target == null || target.width != ccamera.pixelWidth || target.height != ccamera.pixelHeight) 
        {
            if (target != null) 
            {
                target.Release();
            }
            target = new RenderTexture (ccamera.pixelWidth, ccamera.pixelHeight, 0, RenderTextureFormat.ARGBFloat, RenderTextureReadWrite.Linear);
            target.enableRandomWrite = true;
            
            target.Create();
        }
    }
}
