variable "s3_website_bucket"{
  type=string
  default = "very-unique-77-web"
  description="Enter Unique Name for Static Website Bucket"
}
variable "frontend_paths" {
  type    = list(string)
  default = ["index.html","signup.html", "login.html", "profile.html","styles.css","script.js","api_url.js"]
}


