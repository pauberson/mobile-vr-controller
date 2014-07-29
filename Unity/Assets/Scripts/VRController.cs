using UnityEngine;
using System.Collections;

public class VRController : MonoBehaviour {

	public GameObject touchDebugObject;

	void Start () {
	
	}

	void Update () {

		if (MobileListener.Instance.IsTouching) {
			touchDebugObject.SetActive(true);
			touchDebugObject.transform.localPosition = MobileListener.Instance.TouchPosition*0.0025f;
		} else {
			touchDebugObject.SetActive(false);
		}
;
	}
}
