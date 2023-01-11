using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;

public class kickBack : MonoBehaviour
{

    public static kickBack Instance = null;

    void Awake()
    {

        if (Instance == null)
        {
            Instance = this;
            SceneManager.LoadScene("LoadingStart");
        }
        else if (Instance != this)
        {
            Destroy(gameObject);
        }
        DontDestroyOnLoad(gameObject);
    }
}
