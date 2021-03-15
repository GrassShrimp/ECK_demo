module "traefik" {
  source = "./modules/traefik"
  domain = "pinjyun.local"
  storageClassName = "hostpath"
}
module "logstash" {
  source = "./modules/logstash"
}

module "ECK" {
  source = "./modules/ECK"
  domain = "pinjyun.local"
  storageClassName = "hostpath"
}