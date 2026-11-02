# ADVISORY. SSH may only be opened to a single host (/32) or to another
# security group. A /24 on port 22 passes the 0.0.0.0/0 gate but is still
# an entire subnet of machines that can reach the bastion.
package terraform.policies.ssh_host_scoped

import input.plan as plan

changed(r) {
	r.change.actions[_] != "delete"
}

covers_ssh(a) {
	a.ip_protocol == "tcp"
	a.from_port <= 22
	a.to_port >= 22
}

covers_ssh(a) {
	a.ip_protocol == "-1"
}

deny[msg] {
	r := plan.resource_changes[_]
	changed(r)
	r.type == "aws_vpc_security_group_ingress_rule"
	a := r.change.after
	covers_ssh(a)
	cidr := a.cidr_ipv4
	not endswith(cidr, "/32")
	msg := sprintf("%v opens SSH to %v -- use a /32 or a security group reference", [r.address, cidr])
}
