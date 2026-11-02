# OPA policies

Five policies, one policy set. Written in **Rego v0** syntax (`deny[msg] { ... }`) to match
HCP Terraform's OPA runtime and its documented example.

| # | Policy | Query | Enforcement |
|---|---|---|---|
| 01 | `deny-public-ingress` | `data.terraform.policies.deny_public_ingress.deny` | **mandatory** |
| 02 | `ssh-must-be-host-scoped` | `data.terraform.policies.ssh_host_scoped.deny` | advisory |
| 03 | `peer-routes-must-be-narrow` | `data.terraform.policies.peer_routes_narrow.deny` | advisory |
| 04 | `require-name-tag` | `data.terraform.policies.require_name_tag.deny` | advisory |
| 05 | `restrict-instance-type` | `data.terraform.policies.restrict_instance_type.deny` | advisory |

## Org limits (plan entitlements)

```
policy-set-limit                   1    one set, total
policy-limit                       5    five policies, total
policy-mandatory-enforcement-limit 1    only ONE may be mandatory
versioned-policy-set-limit         0    policy sets CANNOT be VCS-connected
```

The last line is why these files are not auto-synced: on this plan each policy must be created
individually in the UI or API, with the Rego pasted in. This directory is the source of truth —
edit here, then paste.

## Why 01 does not match the HashiCorp example

The documented example checks `aws_security_group.ingress[]`. This repo declares **zero** inline
ingress blocks — all 18 ingress rules are standalone `aws_vpc_security_group_ingress_rule`
resources. Pasting the example gives a policy that reports no violations no matter how open the
rules are. Policy 01 checks all three forms so a refactor between them cannot bypass it.

## Testing locally

```bash
brew install opa
opa check --v0-compatible policies/
opa eval --v0-compatible -d policies/01-deny-public-ingress.rego -i plan.json \
  data.terraform.policies.deny_public_ingress.deny --format raw
```

An empty array `[]` means the policy passes. Generate `plan.json` from a real run with
`terraform show -json <planfile>`, and wrap it as `{"plan": <that json>}` — HCP nests the plan
under `input.plan`, alongside `input.run`.
