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
