data "cloudflare_zones" "zone" {
  filter {
    name   = "${var.domain_name}"
    status = "active"
    paused = false
  }
}

resource "cloudflare_record" "record" {
  count   = "${length(var.record_names)}"
  domain  = "${var.domain_name}"
  name    = "${element(var.record_names, count.index)}"
  type    = "${var.record_type}"
  value   = "${element(var.record_value, count.index)}"
  proxied = "${var.proxied}"
}
