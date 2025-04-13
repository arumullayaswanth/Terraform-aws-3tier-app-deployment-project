provider "aws" {
    region = "us-west-2"
}
provider "aws" {
  alias  = "secondary"  
  region = "us-east-1"
}
