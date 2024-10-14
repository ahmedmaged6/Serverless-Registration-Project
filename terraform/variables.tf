variable "region" {
  type    = string
  default = "us-east-2"
}
variable "frontend_paths" {
  type    = list(string)
  default = ["index.html","signup.html", "login.html", "profile.html","styles.css"]
}
variable "lambda_names" {
  type    = list(string)
  default = ["signup", "login", "profile", "confirm_code"]
}
variable "api_paths" {
  type    = list(string)
  default = ["signup", "login", "profile", "confirm_code"]
}
variable "post_paths" {
  type    = list(string)
  default = ["signup", "login", "confirm_code"]
}

