module "traefik" {
  source = "./modules/traefik"
  domain = "pinjyun.local"
  storageClassName = "hostpath"
}
module "ECK" {
  source = "./modules/ECK"
  domain = "pinjyun.local"
  storageClassName = "hostpath"
}
module "demo" {
  source = "./modules/demo"
  domain = "pinjyun.local"
}