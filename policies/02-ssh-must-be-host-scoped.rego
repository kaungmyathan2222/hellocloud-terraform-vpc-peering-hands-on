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

	# Only CIDR-based rules are in scope. A rule that names another security
	# group has cidr_ipv4 == null and is already host-scoped by construction.
	# object.get, not `== null`: a missing key is *undefined* in Rego, which
	# would fail the whole body silently rather than passing this guard.
	object.get(a, "referenced_security_group_id", null) == null

	cidr := object.get(a, "cidr_ipv4", null)
	cidr != null
	not endswith(cidr, "/32")
	msg := sprintf("%v opens SSH to %v -- use a /32 or a security group reference", [r.address, cidr])
}
