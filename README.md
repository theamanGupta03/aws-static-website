# ☁️ AWS Static Website — Full Deployment

> A production-grade static website hosted on AWS using S3, CloudFront, API Gateway, Lambda, and Terraform.

![AWS](https://img.shields.io/badge/AWS-Deployed-orange?logo=amazon-aws)
![Terraform](https://img.shields.io/badge/Terraform-IaC-7B42BC?logo=terraform)
![Lambda](https://img.shields.io/badge/Lambda-Node.js%2020.x-yellow?logo=aws-lambda)
![Status](https://img.shields.io/badge/Status-Live-brightgreen)

---

## 🌐 Live Demo

| Resource | URL |
|---|---|
| Website | https://d3p4q617l9xvbu.cloudfront.net |
| API Hello | https://kj5al4ss4k.execute-api.us-east-1.amazonaws.com/api/hello |

---

## 📐 Architecture

```
User Browser
     │
     ▼
CloudFront CDN  (Global Edge Network)
     │
     ├──── /api/*  ──────▶  API Gateway  ──▶  Lambda (Node.js)
     │
     └──── /*  ────────────▶  S3 Bucket  (HTML / CSS / JS)
```

### Components

| Component | Service | Purpose |
|---|---|---|
| Static Hosting | Amazon S3 | Stores HTML, CSS, JS files |
| CDN | Amazon CloudFront | Delivers files globally from 400+ edge locations |
| API Layer | API Gateway (HTTP v2) | Routes `/api/*` requests to backend |
| Backend | AWS Lambda (Node.js 20.x) | Serverless function handler |
| IAM | AWS IAM Role | Lambda execution permissions |
| Logging | Amazon CloudWatch | API access logs (7-day retention) |
| Infrastructure | Terraform | All resources defined as code |

---

## 📁 Project Structure

```
aws-website-project/
│
├── my-website/                 ← Frontend files
│   ├── index.html
│   ├── about.html
│   ├── contact.html
│   ├── style.css
│   └── main.js
│
└── terraform/                  ← Infrastructure as Code
    ├── main.tf                 ← Provider config
    ├── variables.tf            ← Input variables
    ├── s3.tf                   ← S3 bucket + policy
    ├── cloudfront.tf           ← CloudFront distribution
    ├── apigateway.tf           ← API Gateway + Lambda + IAM
    ├── outputs.tf              ← Output values
    └── deploy.sh               ← Upload + cache invalidation script
```

---

## 🚀 How to Deploy

### Prerequisites

- [Terraform](https://developer.hashicorp.com/terraform/downloads) v1.3+
- [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html) v2+
- AWS account with IAM user credentials

### Step 1 — Configure AWS CLI

```bash
aws configure
# Enter your Access Key ID, Secret Access Key, region (us-east-1), output (json)
```

Verify:
```bash
aws sts get-caller-identity
```

### Step 2 — Clone the repo

```bash
git clone https://github.com/YOUR_USERNAME/YOUR_REPO_NAME.git
cd YOUR_REPO_NAME/terraform
```

### Step 3 — Deploy infrastructure

```bash
# Initialize Terraform
terraform init

# Preview what will be created
terraform plan

# Deploy everything to AWS
terraform apply
```

Type `yes` when prompted. Takes about 5 minutes (CloudFront deploys globally).

After completion you'll see:
```
Apply complete! Resources: 17 added, 0 changed, 0 destroyed.

Outputs:
website_url                = "https://xxxx.cloudfront.net"
s3_bucket_name             = "mywebsite-static-website-xxxx"
cloudfront_distribution_id = "EXXXXXXXXX"
api_endpoint               = "https://xxxx.execute-api.us-east-1.amazonaws.com"
api_hello_url              = "https://xxxx.execute-api.us-east-1.amazonaws.com/api/hello"
```

### Step 4 — Upload website files

```bash
bash deploy.sh
```

Your site is live! ✅

---

## 🔄 Updating the Website

Any time you edit HTML, CSS, or JS files:

```bash
cd aws-website-project/terraform
bash deploy.sh
```

Changes go live in ~30 seconds.

---

## 🔧 Updating Infrastructure

To add or modify AWS resources (e.g. new API route):

```bash
# Edit the relevant .tf file, then:
terraform plan     # preview changes
terraform apply    # apply changes
```

---

## 🧪 Testing

**Website loads:**
```
https://YOUR_CLOUDFRONT_URL
```

**API is working:**
```
https://YOUR_CLOUDFRONT_URL/api/hello
```
Expected response:
```json
{
  "message": "Hello from Lambda!",
  "path": "/api/hello",
  "timestamp": "2026-04-14T10:00:00.000Z"
}
```

**Navigation:** Click About and Contact in the navbar — both pages should load correctly.

---

## 🛠️ Troubleshooting

| Error | Fix |
|---|---|
| `terraform: command not found` | Reinstall Terraform and ensure it's in your PATH |
| `No valid credential sources` | Run `aws configure` again |
| `BucketAlreadyExists` | Edit `variables.tf` and change `project_name` to something unique |
| `403 Forbidden` on website | Wait 5 min — CloudFront is still deploying globally |
| Site shows old content | Run `bash deploy.sh` to clear CloudFront cache |
| `AccessDenied` on S3 upload | Check that `AdministratorAccess` is attached to your IAM user |
| Lambda returns 500 | Check CloudWatch Logs: `/aws/apigateway/mywebsite` |

---

## 💰 Cost

This project runs almost entirely within **AWS Free Tier** limits.

| Service | Free Tier |
|---|---|
| S3 | 5 GB storage, 20K GET requests/month |
| CloudFront | 1 TB data transfer, 10M requests/month |
| API Gateway | 1M requests/month |
| Lambda | 1M requests/month |

**Expected monthly cost for a demo with low traffic: $0.00 – $0.05**

> ⚠️ Always run `terraform destroy` when you're done to avoid any ongoing charges.

---

## 🗑️ Tear Down

To delete all AWS resources when you're done:

```bash
# First empty the S3 bucket (Terraform can't delete non-empty buckets)
aws s3 rm s3://YOUR_BUCKET_NAME --recursive

# Then destroy all infrastructure
cd terraform
terraform destroy
# Type 'yes' when prompted
```

---

## 📖 Glossary

| Term | Meaning |
|---|---|
| Terraform | Tool that creates cloud resources by reading `.tf` files |
| S3 Bucket | A folder in the cloud to store files |
| CloudFront | Global CDN — serves files from locations near the user |
| API Gateway | Routes web requests to the right backend service |
| Lambda | A function that runs in the cloud with no server to manage |
| IAM | AWS Identity & Access Management — controls permissions |
| OAC | Origin Access Control — secure way for CloudFront to read S3 |
| Invalidation | Clearing CloudFront cache so fresh files are served |
| terraform init | Downloads Terraform providers needed for your project |
| terraform plan | Shows what will be created/changed — no changes made |
| terraform apply | Actually creates or changes resources on AWS |
| terraform destroy | Deletes all resources Terraform created |

---

## 👤 Author

**Aman Gupta**
- GitHub: [@amangupta03](https://github.com/amangupta03)

---

## 📄 License

This project is open source and available under the [MIT License](LICENSE).