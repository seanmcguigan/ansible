provider "aws" {
  region = "eu-west-1"
}

# get the vpc
data "aws_vpc" "test" {
  tags {
    Name = "test-eu-west-vpc"
  }
}

output "vpc_id" {
  value = "${data.aws_vpc.test.id}"
}

# get a list of subnet ids from the vpc
data "aws_subnet_ids" "test" {
  vpc_id = "${data.aws_vpc.test.id}"
}

data "aws_subnet" "test" {
  count = "${length(data.aws_subnet_ids.test.ids)}"
  id = "${data.aws_subnet_ids.test.ids[count.index]}"
}

output "aws_subnet_ids" {
  value = ["${data.aws_subnet.test.*.id}"]
}

# target the latest packer ami
data "aws_ami" "bastion" {
  most_recent = true
  filter {
    name   = "name"
    values = ["stage-bastion"]
  }

 filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["417034048139"]
}

output "aws_ami" {
  value = ["${data.aws_ami.bastion.id}"]
}


# create the instance
resource "aws_instance" "web" {
  ami           = "${data.aws_ami.bastion.id}"
  instance_type = "t2.micro"
  associate_public_ip_address = "true"
  vpc_security_group_ids = ["sg-041c8b61"]
  key_name = "dinky_toy"
  subnet_id = "${element(data.aws_subnet.test.*.id, 0)}"
  
  tags {
    Name = "testbox"
  }
}

output ipaddress {
  value = "${aws_instance.web.public_ip}" 
}
