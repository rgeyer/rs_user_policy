default["rs_user_policy"]["runtime_environment"] = "gem"

default["rs_user_policy"]["home"] = "/mnt/storage/rs_user_policy"
default["rs_user_policy"]["retention_period"] = "+30"
default["rs_user_policy"]["user_assignments"]["json"] = "{}"
default["rs_user_policy"]["user"]["phone"] = "9999999999"
default["rs_user_policy"]["apply_policy_schedule"]["minute"] = "0"

default["rs_user_policy"]["docker"]["container_version"] = "latest"

node.set["rs_user_policy"]["user_assignments_dir"] = ::File.join(node["rs_user_policy"]["home"], "user_assignments")
node.set["rs_user_policy"]["audits_dir"] = ::File.join(node["rs_user_policy"]["home"], "audits")
node.set["rs_user_policy"]["log_dir"] = ::File.join(node["rs_user_policy"]["home"], "logs")
