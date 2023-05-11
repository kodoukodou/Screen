using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ScreenManager : MonoBehaviour
{
    public Material material;
    [ColorUsage(false, true), SerializeField]
    public Color BaseColor;
    public Texture BaseTexure;
    public Texture BaseTexureArray;
    public Texture MaskTexture;
    public int[] count;
    public int check_Element=0;
    public bool InputKey_Change;
    public bool Semi_automatic;
    public bool ArrayTex;
    [Range(0,11)]
    public int TexNum;
    [Range(0, 2)]
    public float speed = 1;
    public float Rotate;
    [Range(0, 1)]
    public float CutOff;
    //public float FLOAT;

    private float _timeElapsed = 0;
    private int arrayCount = 0;
    private int colorCount = 0;
    private int reset = 0;
    private int point = 0;
    private int max = 11;
    private int a;
    private int currentCount = 0;
    private int Element=-1;

    void Start()
    {
        Texture();
    }
    void Update()
    {
        material.SetFloat("_RotationIntensity", Rotate);
        material.SetFloat("_Cutoff", CutOff);
        material.SetColor("_EmissionColor", BaseColor);

        if (Input.GetKey(KeyCode.N))
        {
            ChangeColor();
        }

        if (Input.GetKeyDown(KeyCode.Space))
        {
            if (arrayCount % 2 == 1)
            {
                ArrayTex = true;
            }
            else
            {
                ArrayTex = false;
            }
            arrayCount++;
        }
        if (ArrayTex == true)
        {
            ChangeArray();
        }
        else
        {
            ChangeNotArray();
        }

        if (InputKey_Change)
        {

            if (Input.GetKey(KeyCode.Z))
            {
                Element = 0;
                ChangeTexture();
            }
            else if (Input.GetKey(KeyCode.X))
            {
                Element = 1;
                ChangeTexture();
            }
            else if (Input.GetKey(KeyCode.C))
            {
                Element = 2;
                ChangeTexture();
            }
            else if (Input.GetKey(KeyCode.V))
            {
                Element = 3;
                ChangeTexture();
            }
            else if (Input.GetKey(KeyCode.B))
            {
                Element = 4;
                ChangeTexture();
            }

            Timeloop();
        }
        else if(Semi_automatic)
        {
            a = Element;
            /*for(int i = 0; i < check.Length; i++)
            {
                if (check[i])
                {
                    Element = i;
                }
            }*/
            Element=check_Element;
            if (a!=Element){
                ChangeTexture();
            }
            Timeloop();
        }
        else
            material.SetFloat("_TextureNo", TexNum);

    }
    void ChangeTexture()
    {
        currentCount = 0;

        if (Element != 0)
        {
            for (int i = 0; i < Element; i++)
            {
                currentCount += count[i];
            }
        }

        point = currentCount - 1;// 1
        reset = currentCount;// 2
        max = count[Element] + reset - 1;// 3
    }
    void Timeloop()
    {
        if (point >= max)
        {
            point = reset - 1;
        }

        _timeElapsed += Time.deltaTime;     //時間をカウントする
        if (_timeElapsed >= speed)
        {
            point++;
            material.SetFloat("_TextureNo", point);

            _timeElapsed = 0;   //経過時間をリセットする
        }
    }

    void Texture()
    {
        material.SetTexture("_MainTex", BaseTexureArray);//ArrayTexture
        material.SetTexture("_MainTex2", BaseTexure);//Texture
        material.SetTexture("_Mask", MaskTexture);
    }
    void ChangeArray()
    {
        material.EnableKeyword("_APPLY_ARRAY_ON");
    }
    void ChangeNotArray()
    {
        material.DisableKeyword("_APPLY_ARRAY_ON");
    }
    void ChangeColor()
    {
        colorCount++;
        if (colorCount % 2 == 1)
            BaseColor = Color.black;
        else
            BaseColor = Color.white;
    }
}