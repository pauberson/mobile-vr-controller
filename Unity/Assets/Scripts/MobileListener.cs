using System;
using System.Net;
using System.Net.Sockets;
using System.Text;
using UnityEngine;
using System.Collections;

public class MobileListener : MonoBehaviour {

	public static MobileListener Instance { get; private set; }

	private const int ListenPort = 11000;
	
	private UdpClient _listener;
	private IPEndPoint _groupEp;

	private int _touchX = 0;
	private int _touchY = 0;

	public Vector2 TouchPosition 
	{
		get { return new Vector2(_touchX, _touchY); }
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
		
		if (msg[0] == "touch") {
			int.TryParse(msg[1], out _touchX);
			int.TryParse(msg[2], out _touchY);
		
		} 
		
		_listener.BeginReceive(new AsyncCallback(DataReceived), null);
	}
}
