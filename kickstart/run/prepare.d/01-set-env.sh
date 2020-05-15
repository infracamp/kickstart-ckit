#!/bin/bash

##
# Load the environment from kick.yml and evaluate it
# So you can also extend like PATH or modify environment
# directly
#

envtoset=`kick kick_to_env`
echo "kick_to_env raw: $envtoset"
## Evaluate and replace $PATH in envtoset
eval envtoset_parsed="\"$envtoset\""
export $envtoset_parsed


