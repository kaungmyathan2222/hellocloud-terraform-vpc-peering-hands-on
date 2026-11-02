package terraform.policies.deny_public_ingress

import input.plan as plan

changed(r) {
	r.change.actions[_] != "delete"
}

deny[msg] {
	r := plan.resource_changes[_]
	changed(r)
	r.type == "aws_vpc_security_group_ingress_rule"
	r.change.after.cidr_ipv4 == "0.0.0.0/0"
	msg := sprintf("%v allows ingress from 0.0.0.0/0", [r.address])
}

deny[msg] {
	r := plan.resource_changes[_]
	changed(r)
	r.type == "aws_vpc_security_group_ingress_rule"
	r.change.after.cidr_ipv6 == "::/0"
	msg := sprintf("%v allows ingress from ::/0", [r.address])
}

deny[msg] {
	r := plan.resource_changes[_]
	changed(r)
	r.type == "aws_security_group"
	r.change.after.ingress[_].cidr_blocks[_] == "0.0.0.0/0"
	msg := sprintf("%v has 0.0.0.0/0 as allowed ingress", [r.address])
}

deny[msg] {
	r := plan.resource_changes[_]
	changed(r)
	r.type == "aws_security_group_rule"
	r.change.after.type == "ingress"
	r.change.after.cidr_blocks[_] == "0.0.0.0/0"
	msg := sprintf("%v allows ingress from 0.0.0.0/0", [r.address])
}
