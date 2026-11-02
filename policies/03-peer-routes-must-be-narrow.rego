# ADVISORY. Routes pointing at a peering connection must name a single /24,
# never a blanket /16. The whole point of the same-ordinal design is that
# private-02 can reach only the peer's private-02.
package terraform.policies.peer_routes_narrow

import input.plan as plan

changed(r) {
	r.change.actions[_] != "delete"
}

deny[msg] {
	r := plan.resource_changes[_]
	changed(r)
	r.type == "aws_route"
	a := r.change.after
	a.vpc_peering_connection_id != null
	not endswith(a.destination_cidr_block, "/24")
	msg := sprintf("%v routes %v over a peering connection -- peer routes must be a /24", [r.address, a.destination_cidr_block])
}
