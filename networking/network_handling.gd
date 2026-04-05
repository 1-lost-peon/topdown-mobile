extends Node

#const IP_ADDRESS: String = "127.0.0.1"
const IP_ADDRESS: String = "192.168.1.191"
const PORT: int = 42069

var peer: ENetMultiplayerPeer

func get_local_lan_ip() -> String:
	for ip in IP.get_local_addresses():
		# Only normal IPv4 LAN addresses
		if ip.begins_with("192.168.") or ip.begins_with("10."):
			return ip
		
		# 172.16.0.0 - 172.31.255.255 are also private LAN addresses
		if ip.begins_with("172."):
			var parts := ip.split(".")
			if parts.size() == 4:
				var second_octet := int(parts[1])
				if second_octet >= 16 and second_octet <= 31:
					return ip
	
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
