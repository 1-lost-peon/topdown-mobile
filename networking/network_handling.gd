extends Node

#const IP_ADDRESS: String = "127.0.0.1"
const IP_ADDRESS: String = "192.168.1.191"
const PORT: int = 42069

var peer: ENetMultiplayerPeer

func get_local_lan_ip() -> String:
	var interfaces = IP.get_local_interfaces()
	for iface in interfaces:
		print(iface)
		var friendly := str(iface.get("friendly", "")).to_lower()
		var addresses = iface.get("addresses", [])
		if "wi-fi" in friendly or "wifi" in friendly or "wlan" in friendly or "wireless" in friendly:
			return addresses[1]
		
	return "127.0.0.1"

func start_server() -> void:
	peer = ENetMultiplayerPeer.new()
	var error := peer.create_server(PORT)
	if error != OK:
		push_error("Failed to start server: " + str(error))
		return
	
	multiplayer.multiplayer_peer = peer
	
	var local_ip := get_local_lan_ip()
	print("Server started")
	print("Local IP: ", local_ip)


func start_client(server_ip: String) -> void:
	peer = ENetMultiplayerPeer.new()
	var error := peer.create_client(server_ip, PORT)
	if error != OK:
		push_error("Failed to connect: " + str(error))
		return
		
	multiplayer.multiplayer_peer = peer
	print("Connecting to: ", server_ip)
