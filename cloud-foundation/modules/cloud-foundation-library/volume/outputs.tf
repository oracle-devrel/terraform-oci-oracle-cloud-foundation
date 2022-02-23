
output "DataVolumeOcids" {
  value = [ for b in oci_core_volume.block : b.id]
}