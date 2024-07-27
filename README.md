# utilities
personal convenience utilities


## Table of Contents

1. [AWS](#AWS)
   1. [aws-token-role](#aws-token-role)


## AWS

### aws-token-role

--profile seems to not use env_vars with profile
meaning ~/.aws/credentials needs to hold key_id and secret for the specified profile
rather `--profile` overrides local env_vars, and so if not set in ~/.aws/credentials then no key_id/secret_key will be found
