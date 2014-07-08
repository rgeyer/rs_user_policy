# rs_user_policy Docker Container

A simple container for running [rs_user_policy](https://github.com/rgeyer/rs_user_policy)
with some best practices.

# Environment Variables (Parameters)

## Required

### POLICY
-e "POLICY=<path to policy json, or json blob with whitespace removed"

If you pass it a path to a policy file, you should have mapped a volume to /opt/rs_user_policy a'la -v /host/path:/opt/rs_user_policy and the path had better be somewhere in that volume.

### EMAIL
-e "EMAIL=<Your RightScale email address for authentication>"

### PASSWORD
-e "PASSWORD=<Your RightScale password for authentication>"

### ACCOUNT_IDS
-e "ACCOUNT_IDS=<One RightScale account ID, or a comma separated list of RightScale account IDs>"

## Optional

### USER_ASSIGNMENTS
-e "USER_ASSIGNMENTS=<path to user_assignments json, a json blob with whitespace removed, the string 'latest', or nothing>"

If you pass it a path to a user_assignments file, you should have mapped a volume to /opt/rs_user_policy a'la -v /host/path:/opt/rs_user_policy and the path had better be somewhere in that volume.
If you pass a json blob, it'll be written to a temp file and used, then disposed of. The resultant user_assignments file (after rs_user_policy processes and takes actions) will be written to /opt/rs_user_policy/user_assignments
If you pass the string 'latest', the newest file in the directory /opt/rs_user_policy/user_assignments will be used.
If you pass nothing, you'll get a user_assignments file with all discovered users assiged an "immutable" role written to /opt/rs_user_policy/user_assignments

If either a path to a user_assignments file, or a json blob is provided, the --empty-user-assignments-fatal or -e flag will be set. Meaning that if the file cannot be found, parsed, or it contains less than 1 user the execution will fail.

Expected content of the mounted volume.

audits/
user_assignments/
logs/
