provider "aws" {
    region = "ap-northeast-2"
}

resource "aws_instance" "example" {
    ami = "ami-0eb14fe5735c13eb5"
    instance_type = "t2.micro"
    
    tags = {
      "Name" = "terraform-example"
    }
}