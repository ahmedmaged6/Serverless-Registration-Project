variable "region" {
  type    = string
  default = "us-east-2"
}
variable "s3_website_bucket"{
  type=string
  default = "very-unique-66-web"
  description="Enter Unique Name for Static Website Bucket"
}
variable "frontend_paths" {
  type    = list(string)
  default = ["index.html","signup.html", "login.html", "profile.html","styles.css","script.js"]
}


