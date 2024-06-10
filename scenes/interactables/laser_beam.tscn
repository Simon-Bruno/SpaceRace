[gd_scene load_steps=5 format=3 uid="uid://8gurumik6vsg"]

[ext_resource type="Script" path="res://scripts/interactables/laser_beam.gd" id="1_qojdh"]

[sub_resource type="StandardMaterial3D" id="StandardMaterial3D_mj71s"]
albedo_color = Color(0.822335, 0.0526998, 4.81307e-07, 1)

[sub_resource type="BoxMesh" id="BoxMesh_muaet"]
material = SubResource("StandardMaterial3D_mj71s")
size = Vector3(5, 0.2, 0.2)

[sub_resource type="BoxShape3D" id="BoxShape3D_u6b37"]
size = Vector3(5, 0.2, 0.2)

[node name="LaserBeamActivate" type="Node3D"]
script = ExtResource("1_qojdh")

[node name="LaserBeam" type="Node3D" parent="."]

[node name="MeshInstance3D" type="MeshInstance3D" parent="LaserBeam"]
mesh = SubResource("BoxMesh_muaet")
skeleton = NodePath("../..")

[node name="Area3D" type="Area3D" parent="LaserBeam/MeshInstance3D"]
collision_layer = 4
collision_mask = 2

[node name="CollisionShape3D" type="CollisionShape3D" parent="LaserBeam/MeshInstance3D/Area3D"]
shape = SubResource("BoxShape3D_u6b37")

[connection signal="body_entered" from="LaserBeam/MeshInstance3D/Area3D" to="." method="_on_area_3d_body_entered"]
[connection signal="body_exited" from="LaserBeam/MeshInstance3D/Area3D" to="." method="_on_area_3d_body_exited"]
