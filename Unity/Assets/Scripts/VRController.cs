using UnityEngine;
using System.Collections;

public class VRController : MonoBehaviour {

	public static VRController Instance { get; private set; }
	
	public GameObject TouchDebugObject;
	public GameObject TapDebugObject;

	public float DebugScaleFactor = 0.0025f;
	public float AxisScaleFactor = 0.005f;
	public float MoveSpeedScaleFactor = 0.005f;
	
	void Awake()
	{
		if (Instance != null && Instance != this){
			Destroy(gameObject);
		}
		
		Instance = this;
		
		// keep between scenes
		DontDestroyOnLoad(gameObject);
		
	}
	
	void Start () {
		MobileListener.OnTap += HandleOnTap;
		HideTap();
	}

	void HandleOnTap (Vector3 touchPoint)
	{
		if (TapDebugObject != null){
			TapDebugObject.SetActive(true);
			TapDebugObject.transform.localPosition = touchPoint*DebugScaleFactor;
			Invoke("HideTap",0.5f);
		}
	}

	void HideTap(){
		if (TapDebugObject != null){
			TapDebugObject.SetActive(false);
		}
	}

	void Update () {

		if (TouchDebugObject != null){
			if (MobileListener.Instance.IsTouching) {
				TouchDebugObject.SetActive(true);
				TouchDebugObject.transform.localPosition = MobileListener.Instance.AbsoluteTouchPosition*DebugScaleFactor;
			} else {
				TouchDebugObject.SetActive(false);
			}
		}

	}
}
