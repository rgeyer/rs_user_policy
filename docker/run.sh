#!/usr/bin/env bash

if [ -z "$POLICY" ]
then
  echo "You need to supply either a path to a policy file, or json text for a policy with the ENV variable POLICY"
  exit 1
fi

# Validation for EMAIL, PASSWORD, ACCOUNT_IDS?

if [ ! -f $POLICY ]
then
  echo $POLICY > /tmp/policy.json
  export POLICY=/tmp/policy.json
fi

if [ -n "$USER_ASSIGNMENT" ]
then
  if [ ! -f $USER_ASSIGNMENT ]
  then
    if [ "$USER_ASSIGNMENT" == 'latest' ]
    then
      export USER_ASSIGNMENT=/opt/rs_user_policy/user_assignments/$(ls -t /opt/rs_user_policy/user_assignments | head -n1)
    else
      echo $USER_ASSIGNMENT > /tmp/user_assignments.json
      export USER_ASSIGNMENT=/tmp/user_assignments.json
    fi
  fi
  export USER_ASSIGNMENT_OPTIONS=" -u $USER_ASSIGNMENT -e"
fi

export EXPLODED=$(echo $ACCOUNT_IDS | sed "s/,/ -a /g")
export ACCOUNT_OPTIONS="-a $EXPLODED"
export TS=$(date +%s)

cd /opt/rs_user_policy/user_assignments
rs_user_policy -r $EMAIL -s $PASSWORD -p $POLICY$USER_ASSIGNMENT_OPTIONS -d /opt/rs_user_policy/audits $ACCOUNT_OPTIONS > /opt/rs_user_policy/logs/rs_user_policy-$TS.log 2>&1
