output "load_balancer_id" {
  value = module.wls-lb.load_balancer_id
}

output "load_balancer_IP" {
  value = element(coalescelist(module.wls-lb.load_balancer_IP, tolist([tolist([""])]))[0], 0)
}