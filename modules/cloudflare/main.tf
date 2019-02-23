data "cloudflare_zone" "zone" {
  filter {
    name = "${var.domain_name}"
    status = "active"
    paused = false
  }
}

resource "cloudflare_load_balancer_pool" "lb_pool" {
  name = "meetup-pool"
  
  origins {
    name = "${var.pool_name1}"
    address = "${var.pool_address1}"
  }

  origins {
    name = "${var.pool_name2}"
    address = "${var.pool_address2}"
  }

  check_regions = ["WNAM"]
}


resource "cloudflare_load_balancer" "lb" {
  zone = "${var.domain_name}"
  name = "hashi-meetup"
  fallback_pool_id = "${cloudflare_load_balancer_pool.lb_pool.id}"
  default_pool_ids = ["${cloudflare_load_balancer_pool.lb_pool.id}"]
}

resource "cloudflare_record" "record" {
  count = "${var.num_records}"
  domain = "${var.domain_name}"
  name = "${element(var.record_names, count.index)}"
  type = "${var.record_type}"
  value = "${var.record_value}"
}

