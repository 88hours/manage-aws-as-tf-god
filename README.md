Terraform use AWS_PROFILE

create-aws-org-admin will still require you to enable mfa manually, it will also not allow org-admin to create its own access keys. 
IAM allows each user to have up to two access keys maximum.


You must manage key rotation and cleanup via processes or automation (scripts, Lambda, aws config).