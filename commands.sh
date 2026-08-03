## sign up

curl -X POST \
  -H "Content-Type: application/x-amz-json-1.1" \
  -H "X-Amz-Target: AWSCognitoIdentityProviderService.SignUp" \
  -d '{
    "ClientId": "lhkb9ibu7398heoqe3urigjre",
    "Username": "mustaphaboutoubdev@gmail.com",
    "Password": "Passw0rd@",
    "UserAttributes": [
      {"Name": "email", "Value": "mustaphaboutoubdev@gmail.com"}
    ]
  }' \
  https://cognito-idp.eu-west-3.amazonaws.com/ | jq

## confirmation

curl -X POST \
  -H "Content-Type: application/x-amz-json-1.1" \
  -H "X-Amz-Target: AWSCognitoIdentityProviderService.ConfirmSignUp" \
  -d '{
    "ClientId": "<your-client-id>",
    "Username": "alice@example.com",
    "ConfirmationCode": "123456"
  }' \
  https://cognito-idp.<region>.amazonaws.com/ | jq

## sign in
curl -X POST \
  -H "Content-Type: application/x-amz-json-1.1" \
  -H "X-Amz-Target: AWSCognitoIdentityProviderService.InitiateAuth" \
  -d '{
    "AuthFlow": "USER_PASSWORD_AUTH", 
    "ClientId": "lhkb9ibu7398heoqe3urigjre", 
    "AuthParameters": {  
      "USERNAME": "mustaphaboutoubdev@gmail.com", 
      "PASSWORD": "Passw0rd@" 
    } 
  }' \
  https://cognito-idp.eu-west-3.amazonaws.com/ | jq


aws ecs list-clusters
aws s3 ls
aws ecs list-services --cluster cloud-design-cluster
aws ecs list-tasks --cluster cloud-design-cluster
aws ecs stop-task --cluster cloud-design-cluster  --task <id>