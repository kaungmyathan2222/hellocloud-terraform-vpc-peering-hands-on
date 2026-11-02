# ADVISORY. Every taggable resource carries a Name tag, so the console is
# readable and orphans are identifiable after a workspace is deleted.
package terraform.policies.require_name_tag

import input.plan as plan

taggable := {
	"aws_vpc",
	"aws_subnet",
	"aws_route_table",
	"aws_internet_gateway",
	"aws_nat_gateway",
	"aws_security_group",
	"aws_instance",
	"aws_vpc_peering_connection",
}

deny[msg] {
	r := plan.resource_changes[_]
	r.change.actions[_] == "create"
	taggable[r.type]
	not r.change.after.tags.Name
	msg := sprintf("%v is created without a Name tag", [r.address])
}
