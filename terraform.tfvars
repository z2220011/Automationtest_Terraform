servers = {
  # APサーバ1台目
  AP01 = {
    vpc_id              = "vpc-4a00282d"
    subnet_id           = "subnet-f98bafa2"
    security_groups     = ["sg-06d312c494b3fc6c2"]
    instance_type       = "t3.micro"
    ami_id              = "ami-06c6f3fa7959e5fdd"
    server_name         = "ec2-z2220011TerraformServer-01"
    key_name            = "z2220011"
    iam_instance_profile = "z2220011-splunk-iam-role"
    ebs_optimized       = true
    monitoring          = false
    user_data           = <<-EOF
      #!/bin/bash
      yum update -y
      yum install -y httpd
      systemctl start httpd
      systemctl enable httpd
      echo "<h1>Welcome to Terraform Apache Server!</h1>" > /var/www/html/index.html
    EOF
    root_volume_size    = 20
    root_volume_type    = "gp3"
    environment         = "staging"
    project             = "MyProject"
  }

  # APサーバ2台目
  AP02 = {
    vpc_id              = "vpc-4a00282d"
    subnet_id           = "subnet-f98bafa2"
    security_groups     = ["sg-06d312c494b3fc6c2"]
    instance_type       = "t3.micro"
    ami_id              = "ami-06c6f3fa7959e5fdd"
    server_name         = "ec2-z2220011TerraformServer-02"
    key_name            = "z2220011"
    iam_instance_profile = "z2220011-splunk-iam-role"
    ebs_optimized       = true
    monitoring          = false
    user_data           = <<-EOF
      #!/bin/bash
      yum update -y
      yum install -y httpd
      systemctl start httpd
      systemctl enable httpd
      echo "<h1>Welcome to Terraform Apache Server!</h1>" > /var/www/html/index.html
    EOF
    root_volume_size    = 15
    root_volume_type    = "gp3"
    environment         = "staging"
    project             = "MyProject"
  }

  # APサーバ3台目
  AP03 = {
    vpc_id              = "vpc-4a00282d"
    subnet_id           = "subnet-f98bafa2"
    security_groups     = ["sg-06d312c494b3fc6c2"]
    instance_type       = "t3.micro"
    ami_id              = "ami-06c6f3fa7959e5fdd"
    server_name         = "ec2-z2220011TerraformServer-03"
    key_name            = "z2220011"
    iam_instance_profile = "z2220011-splunk-iam-role"
    ebs_optimized       = true
    monitoring          = false
    user_data           = <<-EOF
      #!/bin/bash
      yum update -y
      yum install -y httpd
      systemctl start httpd
      systemctl enable httpd
      echo "<h1>Welcome to Terraform Apache Server!</h1>" > /var/www/html/index.html
    EOF
    root_volume_size    = 10
    root_volume_type    = "gp3"
    environment         = "staging"
    project             = "MyProject"
  }
}
