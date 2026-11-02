# MANDATORY. The one hard gate: nothing may accept traffic from the whole internet.
#
# Checks all three ways an SG rule can be expressed, so a refactor between them
# cannot silently bypass the policy. This repo uses the standalone form only --
# the HashiCorp docs' example checks aws_security_group.ingress[] and would
# report zero violations here regardless of how open the rules actually were.
package terraform.policies.deny_public_ingress

import input.plan as plan

# Ignore pure deletions: a resource on its way out cannot open anything.
changed(r) {
	r.change.actions[_] != "delete"
}

# Standalone rules -- what this repo uses.
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

# Inline ingress blocks -- legacy style, kept as a guard against refactors.
deny[msg] {
	r := plan.resource_changes[_]
	changed(r)
	r.type == "aws_security_group"
	r.change.after.ingress[_].cidr_blocks[_] == "0.0.0.0/0"
	msg := sprintf("%v has 0.0.0.0/0 as allowed ingress", [r.address])
}

# The deprecated aws_security_group_rule resource.
deny[msg] {
	r := plan.resource_changes[_]
	changed(r)
	r.type == "aws_security_group_rule"
	r.change.after.type == "ingress"
	r.change.after.cidr_blocks[_] == "0.0.0.0/0"
	msg := sprintf("%v allows ingress from 0.0.0.0/0", [r.address])
}
