locals {
  api_url = module.backend_module.api_gateway_url
}
variable "s3_website_bucket" {
  description = "The name of the S3 bucket for hosting the website"
  type        = string
}

module "backend_module" {
  source = "./modules/backend-module"
}
module "frontend_module" {
  source = "./modules/frontend-module"
  s3_website_bucket = var.s3_website_bucket

  depends_on = [module.backend_module]
}

# Use a template to generate content with variables
data "template_file" "example" {
  template = file("${path.module}/modules/backend-module/script.tpl")
  vars = {
    api_url = local.api_url
  }
}

# Write the rendered template content to a file
resource "local_file" "output_file" {
  filename = "${path.module}/../web_src_code/api_url.js"
  content  = data.template_file.example.rendered
}


output "website_link" {
  value = module.frontend_module.s3_website_url
}




