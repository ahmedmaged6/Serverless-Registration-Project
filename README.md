# Serverless Registration Project

This project is a serverless web application that handles user registration, login, and profile management using AWS services. The infrastructure is fully deployed using Terraform.
[Click here to view the live project](http://serverless-register-demo.s3-website.us-east-2.amazonaws.com/)  

## Technologies Used
- **Frontend**: HTML, CSS, JavaScript (hosted on S3 as a static website)
- **Backend**: AWS Lambda (Python) handling the logic and interacting with AWS Cognito User Pools
- **Traffic Management**: API Gateway to route requests between frontend and backend
- **Infrastructure**: Terraform to manage and deploy the entire project

## Main Features
1. **User Signup**: Users can register in the AWS Cognito User Pool.
2. **Confirm Code**: Users confirm their signup via a confirmation code.
3. **User Login**: Users can log in and authenticate via Cognito.
4. **User Profile**: After login, users can view their profile data fetched from Cognito.

## Project Setup

### 1. Clone the repository:
```bash
git clone git@github.com:ahmedmaged6/Serverless-Registration-Project.git
cd Serverless-Registration-Project/terraform/
```

### 2. Initialize and deploy with Terraform:
1. **Initialize Terraform**:
    ```bash
    terraform init
    ```
2. **Plan deployment** (replace `value` with your unique S3 bucket name):
    ```bash
    terraform plan -var 's3_website_bucket=value'
    ```
3. **Apply changes** (replace `value` with your unique S3 bucket name):
    ```bash
    terraform apply -var 's3_website_bucket=value'
    ```
4. **To destroy the infrastructure** (replace `value` with your unique S3 bucket name):
    ```bash
    terraform destroy -var 's3_website_bucket=value'
    ```

## Project Structure
```
Serverless-Registration-Project/
│
├── web_src_code/                 # Frontend code (HTML, CSS, JS)
│   ├── index.html
│   ├── login.html
│   ├── profile.html
│   ├── signup.html
│   ├── script.js
│   └── styles.css
│
│
├── lambda_src_code/              # Backend Lambda functions source code 
│   ├── confirm_code/
│   │   └── confirm_code.py
│   ├── login/
│   │   └── login.py
│   ├── profile/
│   │   └── profile.py
│   └── signup/
│       └── signup.py
│       
│
├── terraform/                    # Terraform configuration files
│   ├── main.tf
│   ├── provider.tf
│   ├── modules/
│   │   ├── frontend-module/
│   │   │   ├── static_website_s3.tf
│   │   │   ├── outputs.tf
│   │   │   └── variables.tf
│   │   ├── backend-module/
│   │   │   ├── api_gw.tf
│   │   │   ├── cognito.tf
│   │   │   ├── lambda.tf
│   │   │   ├── outputs.tf
│   │   │   ├── script.tpl
│   │   │   └── variables.tf
│
│
├── .gitignore
└── README.md

```

## Important Notes
- Ensure you provide a **unique S3 bucket name** when running the Terraform commands.
- **AWS Configuration:** Before running Terraform, configure your AWS credentials using `aws configure`. Set up your access key, secret key, and default region.  
  Example:
  ```bash
  aws configure
  ```
  - **Default region:** `us-east-2` (this is where the S3 bucket will be deployed)
    
---



