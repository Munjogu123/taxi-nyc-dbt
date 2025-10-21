# configure AWS provider with region and profile
provider "aws" {
  region  = var.aws_region
  profile = "fred"
}

# Get your public IP dynamically
data "http" "myip" {
  url = "https://checkip.amazonaws.com/"
}

# create a vpc
resource "aws_vpc" "taxi_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "taxi_vpc"
  }

  enable_dns_hostnames = true
  enable_dns_support   = true
}

# create 3 public subnets
resource "aws_subnet" "public_subnet_1" {
  vpc_id            = aws_vpc.taxi_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = var.aws_availability_zone[0]

  tags = {
    Name = "public-subnet-1"
  }
}

resource "aws_subnet" "public_subnet_2" {
  vpc_id            = aws_vpc.taxi_vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = var.aws_availability_zone[1]

  tags = {
    Name = "public-subnet-2"
  }
}

resource "aws_subnet" "public_subnet_3" {
  vpc_id            = aws_vpc.taxi_vpc.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = var.aws_availability_zone[2]

  tags = {
    Name = "public-subnet-3"
  }
}

# create a security group
resource "aws_security_group" "taxi_sg" {
  name        = "taxisg"
  description = "security group for redshift serverless"
  vpc_id      = aws_vpc.taxi_vpc.id
  tags = {
    Name = "taxiSG"
  }
}

# allow inbound traffic from port 5439
resource "aws_vpc_security_group_ingress_rule" "allow_ssh_webserver" {
  security_group_id = aws_security_group.taxi_sg.id
  cidr_ipv4         = "${chomp(data.http.myip.response_body)}/32"
  from_port         = 5439
  ip_protocol       = "tcp"
  to_port           = 5439
}

# allow all outbound traffic
resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_webserver" {
  security_group_id = aws_security_group.taxi_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

# create s3 bucket
resource "aws_s3_bucket" "kestra_bucket" {
  bucket = var.bucket_name

  tags = {
    Name = "nyc-taxi-bucket"
  }
}

# create an IAM role for kestra
resource "aws_iam_role" "redshift_role" {
  name = "kestra_s3_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "redshift.amazonaws.com"
      }
    }]
  })
}

# create a policy to allow kestra to upload files to s3
resource "aws_iam_policy" "kestra_s3_policy" {
  name = "kestra-s3-rw-policy"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid      = "ListBucket",
        Effect   = "Allow",
        Action   = ["s3:ListBucket", "s3:GetBucketLocation"],
        Resource = "arn:aws:s3:::${var.bucket_name}"
      },
      {
        Sid      = "ReadWriteAccess",
        Effect   = "Allow",
        Action   = ["s3:GetObject", "s3:PutObject", "s3:DeleteObject"],
        Resource = "arn:aws:s3:::${var.bucket_name}/*"
      }
  ] })
}

# attach the role to the policy
resource "aws_iam_policy_attachment" "kestra_policy_attachment" {
  name       = "kestra-policy-attachment"
  roles      = [aws_iam_role.redshift_role.name]
  policy_arn = aws_iam_policy.kestra_s3_policy.arn
}

# create a redshift serverless namespace
resource "aws_redshiftserverless_namespace" "kestra_namespace" {
  namespace_name      = "nyc-taxi-namespace"
  admin_username      = var.redshift_admin_username
  admin_user_password = var.redshift_admin_password

  iam_roles = [aws_iam_role.redshift_role.arn]

  tags = {
    Name = "redshift-namespace"
  }
}

# create a redshift serverless workgroup
resource "aws_redshiftserverless_workgroup" "kestra_workgroup" {
  workgroup_name     = "kestra-workgroup-123"
  namespace_name     = aws_redshiftserverless_namespace.kestra_namespace.namespace_name
  base_capacity      = 8
  subnet_ids         = [aws_subnet.public_subnet_1.id, aws_subnet.public_subnet_2.id, aws_subnet.public_subnet_3.id]
  security_group_ids = [aws_security_group.taxi_sg.id]

  tags = {
    Name = "redshift-workgroup"
  }
}

# retrieve values we will use in our connection to kestra
output "redshift_endpoint" {
  value = aws_redshiftserverless_workgroup.kestra_workgroup.endpoint
}

output "redshift_role_arn" {
  value = aws_iam_role.redshift_role.arn
}

output "s3_bucket_name" {
  value = aws_s3_bucket.kestra_bucket.bucket
}
