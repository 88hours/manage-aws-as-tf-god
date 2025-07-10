```bash
#!/bin/bash

ADMIN_NAME=$1
ADMIN_PASSWORD=$2

aws iam create-user --user-name "$ADMIN_NAME"
aws iam attach-user-policy --user-name "$ADMIN_NAME" --policy-arn arn:aws:iam::aws:policy/AdministratorAccess
aws iam create-login-profile --user-name "$ADMIN_NAME" --password "$ADMIN_PASSWORD" --password-reset-required
aws iam create-access-key --user-name "$ADMIN_NAME"
```

