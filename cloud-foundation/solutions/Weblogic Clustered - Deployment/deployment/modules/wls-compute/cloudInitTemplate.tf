
data "template_cloudinit_config" "config" {
  gzip          = true
  base64_encode = true

  # cloud-config configuration file.
  # /var/lib/cloud/instance/scripts/*

  part {
    filename     = "ainit.sh"
    content_type = "text/x-shellscript"
    content      = "${data.template_file.key_script.rendered}"
  }
  part {
    filename     = "init.sh"
    content_type = "text/x-shellscript"
    content      = "${file(var.bootStrapFile)}"
  }
}
