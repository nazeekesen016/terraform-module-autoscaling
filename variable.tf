variable "template_name" {
default = "terra"
}

variable "image-id" {
default = ""
  
}

variable "instance-type" {
    default = ""
  
}

variable "sg-name" {
default = "terra"  
}

variable "asg-name" {
 default = "terra" 
}

variable "lb-name" {
 default = "terra" 
}

variable "lb-type" {
 default = "" 
}

variable "tg-name" {
    type = string
 default = "terra" 
}
variable "vpc_id" {
 default = "" 
}

variable "subnets" {
 default = "" 
}