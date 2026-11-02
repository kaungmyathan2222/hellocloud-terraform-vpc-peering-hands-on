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

# Candidate rules: SSH-reaching ingress that is scoped by CIDR rather than by a
# security group reference. Factored out so the v4 and v6 checks below cannot
# drift apart -- the original v4-only check left an IPv6 /64 wide open.
#
# A rule scoped by prefix_list_id reaches neither check: both cidr fields are
# null, so the `!= null` guard stops it. That is deliberate -- a managed prefix
# list is a curated set of CIDRs, reviewed where it is defined, not here.
ssh_cidr_rule[r] {
	r := plan.resource_changes[_]
	changed(r)
	r.type == "aws_vpc_security_group_ingress_rule"
	covers_ssh(r.change.after)

	# object.get, not `== null`: a missing key is *undefined* in Rego, which
	# would fail the whole body silently rather than passing this guard.
	object.get(r.change.after, "referenced_security_group_id", null) == null
}

deny[msg] {
	r := ssh_cidr_rule[_]
	cidr := object.get(r.change.after, "cidr_ipv4", null)
	cidr != null
	not endswith(cidr, "/32")
	msg := sprintf("%v opens SSH to %v -- use a /32 or a security group reference", [r.address, cidr])
}

deny[msg] {
	r := ssh_cidr_rule[_]
	cidr := object.get(r.change.after, "cidr_ipv6", null)
	cidr != null
	not endswith(cidr, "/128")
	msg := sprintf("%v opens SSH to %v -- use a /128 or a security group reference", [r.address, cidr])
}
