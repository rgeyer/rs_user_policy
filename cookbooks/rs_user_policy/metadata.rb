maintainer       "Ryan J. Geyer"
maintainer_email "me@ryangeyer.com"
license          "All rights reserved"
description      "Installs/Configures rs_user_policy"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          "0.1.0"

depends "rightscale"

recipe "rs_user_policy::install", "Installs and initially configures rs_user_policy"
recipe "rs_user_policy::do_apply_policy", "Runs rs_user_policy with the specified parameters"
recipe "rs_user_policy::do_add_user", "Add a new user to the user_assignments file and schedules do_apply_policy for execution."
recipe "rs_user_policy::do_remove_user", "Sets the user (specified by their email) to the \"delete\" status in user_assignments and schedules do_apply_policy for execution."
recipe "rs_user_policy::do_update_user", "Sets the roles for a user (specified by their email) to the \"delete\" status in user_assignments and schedules do_apply_policy for execution."
recipe "rs_user_policy::do_apply_policy_schedule_enable", "Sets up a cron job to apply the policy on a regular basis"
recipe "rs_user_policy::do_apply_policy_schedule_disable", "Removes the cron job to apply the policy on a regular basis created by rs_user_policy::do_apply_policy_schedule_enable"

attribute "rs_user_policy/home",
  :display_name => "RightScale User Policy Home Dir",
  :required => "optional",
  :default => "/mnt/storage/rs_user_policy"

attribute "rs_user_policy/retention_period",
  :display_name => "RightScale Retention Period",
  :description => "A value passed to find with the -mtime parameter. Any of the user_assignment JSON files or logs created past that retention period will be deleted.",
  :required => "optional",
  :default => "-30d",
  :recipes => ["rs_user_policy::do_apply_policy"]

attribute "rs_user_policy/user_assigments/json",
  :display_name => "RightScale User Assignments JSON",
  :description => "JSON user assignments as specified by https://github.com/rgeyer/rs_user_policy#managing-existing-user-permissions.  This is only used during install, and won't override a user_assignments file that already exists.",
  :required => "optional",
  :default => "{}",
  :recipes => ["rs_user_policy::install"]

attribute "rs_user_policy/email",
  :display_name => "RightScale Email Address",
  :description => "A RightScale user email address used to authenticate with the API",
  :required => "required",
  :recipes => ["rs_user_policy::do_apply_policy"]

attribute "rs_user_policy/password",
  :display_name => "RightScale Password",
  :description => "A RightScale password used to authenticate with the API",
  :required => "required",
  :recipes => ["rs_user_policy::do_apply_policy"]

attribute "rs_user_policy/account_ids",
  :display_name => "RightScale Account IDs",
  :description => "An array/list of RightScale account IDs which will be acted upon",
  :type => "array",
  :required => "required",
  :recipes => ["rs_user_policy::do_apply_policy"]

attribute "rs_user_policy/policy",
  :display_name => "RightScale User Policy JSON",
  :description => "A JSON policy as specified by https://github.com/rgeyer/rs_user_policy#managing-existing-user-permissions",
  :required => "required",
  :recipes => ["rs_user_policy::do_apply_policy"]

attribute "rs_user_policy/user/email",
  :display_name => "RightScale User Policy New User Email",
  :description => "The email address of a user who should be added to the user_assignments JSON file and created immediately",
  :required => "required",
  :recipes => ["rs_user_policy::do_add_user","rs_user_policy::do_remove_user","rs_user_policy::do_update_user"]

attribute "rs_user_policy/user/roles",
  :display_name => "RightScale User Policy New User Roles",
  :description => "An array of roles for a user who should be added to the user_assignments JSON file and created immtediately",
  :type => "array",
  :required => "required",
  :recipes => ["rs_user_policy::do_add_user","rs_user_policy::do_update_user"]

attribute "rs_user_policy/user/company",
  :display_name => "RightScale User Policy New User Company",
  :description => "The company name for a user who should be added to the user_assignments JSON file and created immediately",
  :required => "required",
  :recipes => ["rs_user_policy::do_add_user"]

attribute "rs_user_policy/user/first_name",
  :display_name => "RightScale User Policy New User First Name",
  :description => "The first name of a user who should be added to the user_assignments JSON file and created immediately",
  :required => "required",
  :recipes => ["rs_user_policy::do_add_user"]

attribute "rs_user_policy/user/last_name",
  :display_name => "RightScale User Policy New User Last Name",
  :description => "The last name of a user who should be added to the user_assignments JSON file and created immediately",
  :required => "required",
  :recipes => ["rs_user_policy::do_add_user"]

attribute "rs_user_policy/user/phone",
  :display_name => "RightScale User Policy New User Phone Number",
  :description => "The phone number of a user who should be added to the user_assignments JSON file and created immediately",
  :required => "optional",
  :default => "9999999999",
  :recipes => ["rs_user_policy::do_add_user"]

attribute "rs_user_policy/user/passowrd",
  :display_name => "RightScale User Policy New User Password",
  :description => "The password of a user who should be added to the user_assignments JSON file and created immediately.  If not specified a random secure password will be generated for the user.",
  :required => "optional",
  :recipes => ["rs_user_policy::do_add_user"]

attribute "rs_user_policy/apply_policy_schedule/minute",
  :display_name => "RightScale User Policy Schedule Cron Minute",
  :description => "A value passed directly into the crontab file for the \"minute\" directive.  This determines the frequency with which rs_user_policy::do_apply_policy is executed.  Since it goes directly into the crontab directive, options like */5 (for every five minutes) and */10 (for every ten minutes) are valid.  Since only the minute directive can be manipulated, the longest time between runs is 1hr",
  :required => "optional",
  :default => "0",
  :recipes => ["rs_user_policy::do_apply_policy_schedule_disable","rs_user_policy::do_apply_policy_schedule_enable"]
