resource "local_file" "private_key" {
    content  = module.keygen.OPCPrivateKey["private_key_pem"]
    filename = "private_key.pem"
}