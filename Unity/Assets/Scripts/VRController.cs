using UnityEngine;
using System.Collections;

public class VRController : MonoBehaviour {

	public GameObject touchDebugObject;
	public GameObject tapDebugObject;

	private float _scaleFactor = 0.0025f;

	void Start () {
		MobileListener.OnTap += HandleOnTap;
		HideTap();
	}

	void HandleOnTap (Vector3 touchPoint)
	{
		tapDebugObject.SetActive(true);
		tapDebugObject.transform.localPosition = touchPoint*_scaleFactor;
		Invoke("HideTap",0.5f);
	}

	void HideTap(){
		tapDebugObject.SetActive(false);
	}

	void Update () {

		if (MobileListener.Instance.IsTouching) {
			touchDebugObject.SetActive(true);
			touchDebugObject.transform.localPosition = MobileListener.Instance.TouchPosition*_scaleFactor;
		} else {
			touchDebugObject.SetActive(false);
		}

	}
}
