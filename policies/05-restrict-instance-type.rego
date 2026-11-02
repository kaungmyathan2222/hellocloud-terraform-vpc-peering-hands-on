# ADVISORY. Lab cost guard -- free-tier-sized instances only.
package terraform.policies.restrict_instance_type

import input.plan as plan

allowed := {"t2.micro", "t3.micro"}

deny[msg] {
	r := plan.resource_changes[_]
	r.change.actions[_] != "delete"
	r.type == "aws_instance"
	t := r.change.after.instance_type
	not allowed[t]
	msg := sprintf("%v uses %v -- allowed: t2.micro, t3.micro", [r.address, t])
}
