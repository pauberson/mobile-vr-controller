using UnityEngine;
using System.Collections;

public class VRController : MonoBehaviour {
	
	void Start () {
	
	}

	void Update () {
		Debug.Log (MobileListener.Instance.TouchPosition);
	}
}
