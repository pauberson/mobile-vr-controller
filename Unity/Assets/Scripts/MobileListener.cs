using System;
using System.Net;
using System.Net.Sockets;
using System.Text;
using UnityEngine;
using System.Collections;

public class MobileListener : MonoBehaviour {

	public static MobileListener Instance { get; private set; }

	public delegate void TouchAction(Vector3 touchPoint);
	public static event TouchAction OnTap;

	private const int ListenPort = 11000;
	
	private UdpClient _listener;
	private IPEndPoint _groupEp;

	private int _touchX = 0;
	private int _touchY = 0;
	private int _tapX = 0;
	private int _tapY = 0;
	private bool _isTouching = false;
	private bool _pendingTap = false;

	public Vector3 TouchPosition 
	{
		get { return new Vector3(_touchX, _touchY, 0); }
	}

	public bool IsTouching {
		get { return _isTouching;}
	}

	void Awake()
	{
		if (Instance != null && Instance != this){
			Destroy(gameObject);
		}
		
		Instance = this;
		
		// keep between scenes
		DontDestroyOnLoad(gameObject);

	}

	void Start()
	{
		InitializeListener();
	}

	void Update()
	{
		if (_pendingTap){
			_pendingTap = false;
			if (OnTap != null){
				OnTap(new Vector3(_tapX, _tapY,0));
			}
		}
	}

	void InitializeListener()
	{
		_listener = new UdpClient(ListenPort);
		_groupEp = new IPEndPoint(IPAddress.Any, ListenPort);
		_listener.BeginReceive(new AsyncCallback(DataReceived), null);
		
	}
	
	void DataReceived(IAsyncResult result)
	{
		var receiveByteArray = _listener.EndReceive(result, ref _groupEp);
		
		var receivedMessage = Encoding.ASCII.GetString(receiveByteArray, 0, receiveByteArray.Length);
		
		var msg = receivedMessage.Split(',');
		Debug.Log(msg[0]);
		if (msg[0] == "touch") {
			_isTouching = true;
			int.TryParse(msg[1], out _touchX);
			int.TryParse(msg[2], out _touchY);

		} else if (msg[0] == "touchend") {
			_isTouching = false;
		} else if (msg[0] == "tap") {
			_isTouching = false;
			int.TryParse(msg[1], out _tapX);
			int.TryParse(msg[2], out _tapY);
			_pendingTap = true;
		} 

		_listener.BeginReceive(new AsyncCallback(DataReceived), null);
	}
}
