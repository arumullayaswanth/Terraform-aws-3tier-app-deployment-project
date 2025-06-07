variable "rds-password" {
    description = "rds password"
    type = string
    default = "yaswanth"
  
}
variable "rds-username" {
    description = "rds username"
    type = string
    default = "admin"
  
}
variable "ami" {
    description = "ami"
    type = string
    default = "ami-0731becbf832f281e"  #Ubuntu Server 24.04 LTS (HVM), SSD Volume Type
  
}
variable "instance-type" {
    description = "instance-type"
    type = string
    default = "t2.micro"
  
}
variable "key-name" {
    description = "keyname"
    type = string
    default = "us-east-1"
  
}
variable "backupr-retention" {
    type = number
    default = "7"
  
}
