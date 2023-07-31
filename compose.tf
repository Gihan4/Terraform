provider "aws" {
  region = "us-east-1"
}

# Create a new key pair for the EC2 instance
resource "aws_key_pair" "terra_key" {
  key_name   = "terra_key"
  public_key = file("/home/gihanroey/.ssh/id_rsa.pub")  # Path to your new public key
}

# Create an AWS EC2 instance
resource "aws_instance" "testing" {
  ami           = "ami-0f34c5ae932e6f0e4"
  instance_type = "t2.micro"
  key_name      = aws_key_pair.terra_key.key_name  # Use the key_name from the created key pair

  tags = {
    Name = "Example Instance"
  }

  vpc_security_group_ids = [aws_security_group.web_server_sg.id]  # Attach the security group to the instance

  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = file("/home/gihanroey/.ssh/id_rsa")  # Path to your private key file
    host        = aws_instance.testing.public_ip
  }

  # Install Docker on the EC2 instance
  provisioner "remote-exec" {
    inline = [
      "sudo yum update -y",
      "sudo yum install docker -y",
      "sudo service docker start",
      "sudo usermod -aG docker ec2-user"  # Add the current user to the docker group to run docker commands without sudo
    }
  }

  # Copy Docker Compose YAML file to the EC2 instance
  provisioner "file" {
    source      = "path/to/docker-compose.yml"  # Replace with the path to your Docker Compose YAML file
    destination = "/home/ec2-user/docker-compose.yml"
  }

  # Start Docker Compose on the EC2 instance
  provisioner "remote-exec" {
    inline = [
      "sudo docker login -u Gihan4 -p Ro123Ey123G4",  # Login to Docker Hub (if needed)
      "sudo docker-compose -f /home/ec2-user/docker-compose.yml up -d"  # Run Docker Compose in detached mode
    ]
  }
}

# Create a security group that allows ports 80, 443, 22, and 5000, with outbound all traffic
resource "aws_security_group" "web_server_sg" {
  name_prefix = "example-security-group"

  # Inbound rules for the Flask application
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Outbound rule (allow all traffic)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"  # -1 represents all protocols
    cidr_blocks = ["0.0.0.0/0"]
  }
}

output "test_ip" {
  value = aws_instance.testing.public_ip
}
