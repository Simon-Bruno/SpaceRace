extends Node3D

var multiplayer_peer = ENetMultiplayerPeer.new()
var max_client_connections = 3
var broadcast_port = 4242
var listening_port = 4243
var is_host = false

@onready var menu = $Menu
@onready var ip_label = $Menu/IPLabel
@onready var host_list_node = $Menu/HostList

var ip_address: String = "127.0.0.1"  # Default IP address
var found_hosts = []

# Declare UDP listener and broadcaster
var udp_listener: UDPServer
var udp_broadcaster: UDPServer

# Signal to indicate that a broadcast has been sent
signal broadcast_sent

func _ready():
	var local_addresses = IP.get_local_addresses()
	for address in local_addresses:
		if address.split('.').size() == 4:  # Check if the address is in IPv4 format
			ip_address = address
			break
	print("Resolved Local IP Address: ", ip_address)
	ip_label.text = "Local IP: " + ip_address  # Update the label text with the detected IP address

# Start listening for broadcast messages if acting as host
func start_broadcast_listener():
	udp_listener = UDPServer.new()
	udp_listener.listen(broadcast_port)
	set_process(true)

# Broadcast a message to find hosts if acting as client
func scan_for_hosts():
	var broadcast_port = 4242  # Broadcast port
	var udp_broadcaster = UDPServer.new()
	udp_broadcaster.listen(broadcast_port, "0.0.0.0")  # Listen on any address
	print("Broadcasting...")
	var broadcast_message = "Looking for hosts"
	udp_broadcaster.poll()  # Allow the server to poll for incoming packets (required)
	await get_tree().create_timer(30).timeout # Wait for  seconds
	udp_broadcaster.stop()  # Stop listening after a delay
	print("Broadcast sent!")  # Print a message when the broadcast is sent
	set_process(true)



# Function to handle host logic
func host_process(delta):
	if udp_listener.is_connection_available():
		var packet = udp_listener.get_packet()
		var sender_address = udp_listener.get_packet_ip()
		var sender_port = udp_listener.get_packet_port()
		print("Received broadcast from ", sender_address, ":", sender_port)
		# Send a response to the client with host info
		var response = "Host IP: " + ip_address + ", Port: " + str(listening_port)
		udp_listener.put_packet(response.to_utf8(), sender_address, sender_port)

# Function to handle client logic
func client_process(delta):
	if udp_broadcaster.is_connection_available():
		var packet = udp_broadcaster.get_packet()
		var sender_address = udp_broadcaster.get_packet_ip()
		var sender_port = udp_broadcaster.get_packet_port()
		var host_info = packet.get_string_from_utf8()
		print("Found host: ", host_info)
		found_hosts.append(host_info)
		update_host_list()

func _process(delta):
	if is_host:
		if udp_listener != null and udp_listener.is_connection_available():
			host_process(delta)
	else:
		if udp_broadcaster != null and udp_broadcaster.is_connection_available():
			client_process(delta)

# Update the UI with the list of found hosts
func update_host_list():
	host_list_node.clear()
	for host in found_hosts:
		host_list_node.add_item(host)

# Called when the host button is pressed
func _on_host_pressed():
	is_host = true
	var port = str($Menu/Port.text).to_int()
	print("Using Local IP Address for hosting: ", ip_address)
	multiplayer_peer.create_server(port, max_client_connections)
	multiplayer.multiplayer_peer = multiplayer_peer
	multiplayer_peer.peer_connected.connect(func(id): add_player_character(id))
	menu.visible = false
	add_player_character()
	start_broadcast_listener()  # Start listening for broadcasts

# Called when the join button is pressed
func _on_join_pressed():
	var ip = $Menu/IP.text  # Use the IP address input by the user
	var port = str($Menu/Port.text).to_int()
	multiplayer_peer.create_client(ip, port)
	multiplayer.multiplayer_peer = multiplayer_peer
	menu.visible = false

# Function to add a new player character to the scene
func add_player_character(id=1):
	var character = preload("res://player.tscn").instantiate()
	character.name = str(id)
	add_child(character)

# Called when the scan button is pressed
func _on_scan_pressed():
	scan_for_hosts()
