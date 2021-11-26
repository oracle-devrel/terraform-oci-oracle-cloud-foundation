data "template_cloudinit_config" "bastion-config" {
  gzip          = true
  base64_encode = true

  # cloud-config configuration file.
  # /var/lib/cloud/instance/scripts/*

  part {
    filename     = "ainit.sh"
    content_type = "text/x-shellscript"
    content      = "${data.template_file.bastion_key_script.rendered}"
  }

  part {
    filename     = "init.sh"
    content_type = "text/cloud-config"
    content      = "${file(var.bastion_bootstrap_file)}"
  }
}
