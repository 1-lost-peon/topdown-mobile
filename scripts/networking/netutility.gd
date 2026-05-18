extends Node

var net_multiplayer


func _init(new_multiplayer) -> void:
	net_multiplayer = new_multiplayer


func get_local_lan_ip() -> String:
	var interfaces = IP.get_local_interfaces()

	for iface in interfaces:
		var friendly := str(iface.get("friendly", "")).to_lower()
		var addresses: Array = iface.get("addresses", [])

		if "wi-fi" in friendly or "wifi" in friendly or "wlan" in friendly or "wireless" in friendly:
			for address in addresses:
				var ip := str(address)

				# IPv4 only
				if "." in ip and ":" not in ip:
					# Avoid link-local fallback addresses like 169.254.x.x
					if not ip.begins_with("169.254."):
						return ip

	return "127.0.0.1"


func log(...args) -> void:
	var role: String= "SERVER" if OS.has_feature("server") else "CLIENT"
	var peer_id: int = net_multiplayer.get_unique_id()

	var parts: PackedStringArray = []
	for arg in args:
		parts.append(str(arg))

	print("[%s][%s] %s" % [role, peer_id, " ".join(parts)])
