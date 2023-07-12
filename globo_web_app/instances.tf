##################################################################################
# DATA
##################################################################################

data "aws_ssm_parameter" "amzn2_linux" {
  name = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}

resource "aws_key_pair" "wopr4-vex-key-pair" {
  key_name   = "wopr4-vex-key-pair"
  public_key = file(var.AWS_PUBLIC_KEY_PATH)
}

# INSTANCES #
resource "aws_instance" "nginx1" {
  ami                    = nonsensitive(data.aws_ssm_parameter.amzn2_linux.value)
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.public_subnet1.id
  vpc_security_group_ids = [aws_security_group.nginx_sg.id, aws_security_group.admin_nginx.id]
  key_name               = aws_key_pair.wopr4-vex-key-pair.key_name
  iam_instance_profile   = aws_iam_instance_profile.nginx_profile.name
  depends_on             = [aws_iam_role_policy.allow_s3_all]
  user_data              = <<EOF
#! /bin/bash
sudo amazon-linux-extras install -y nginx1
sudo service nginx start
aws s3 cp s3://${aws_s3_bucket.buck.id}/website/index.html /home/ec2-user/index.html
aws s3 cp s3://${aws_s3_bucket.buck.id}/website/Globo_logo_Vert.png /home/ec2-user/Globo_logo_Vert.png
sudo rm /usr/share/nginx/html/index.html
sudo cp /home/ec2-user/Globo_logo_Vert.png /usr/share/nginx/html/Globo_logo_Vert.png
sudo sh -c 'sed "s/Site/Site #1/g" /home/ec2-user/index.html > /usr/share/nginx/html/index.html'
#OLD echo sudo rm /usr/share/nginx/html/index.html
#OLD echo '<html><head><title>Taco Team Server</title></head><body style=\"background-color:#1F778D\"><p style=\"text-align: center;\"><span style=\"color:#FFFFFF;\"><span style=\"font-size:28px;\">You did it! Have a &#127790;</span></span></p></body></html>' | sudo tee /usr/share/nginx/html/index.html
EOF
}

resource "aws_instance" "nginx2" {
  ami                    = nonsensitive(data.aws_ssm_parameter.amzn2_linux.value)
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.public_subnet2.id
  vpc_security_group_ids = [aws_security_group.nginx_sg.id, aws_security_group.admin_nginx.id]
  key_name               = aws_key_pair.wopr4-vex-key-pair.key_name
  iam_instance_profile   = aws_iam_instance_profile.nginx_profile.name
  depends_on             = [aws_iam_role_policy.allow_s3_all]
  user_data              = <<EOF
#! /bin/bash
sudo amazon-linux-extras install -y nginx1
sudo service nginx start
aws s3 cp s3://${aws_s3_bucket.buck.id}/website/index.html /home/ec2-user/index.html
aws s3 cp s3://${aws_s3_bucket.buck.id}/website/Globo_logo_Vert.png /home/ec2-user/Globo_logo_Vert.png
sudo rm /usr/share/nginx/html/index.html
sudo cp /home/ec2-user/Globo_logo_Vert.png /usr/share/nginx/html/Globo_logo_Vert.png
sudo sh -c 'sed "s/Site/Site #2/g" /home/ec2-user/index.html > /usr/share/nginx/html/index.html'
#OLD echo rm /usr/share/nginx/html/index.html
#OLD echo '<html><head><title>Taco Team Server</title></head><body style=\"background-color:#1F778D\"><p style=\"text-align: center;\"><span style=\"color:#FFFFFF;\"><span style=\"font-size:28px;\">You did it! Have a &#127790;</span></span></p></body></html>' | sudo tee /usr/share/nginx/html/index.html
EOF
}

resource "aws_instance" "admin" {
  ami                         = nonsensitive(data.aws_ssm_parameter.amzn2_linux.value)
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.public_subnetA.id
  vpc_security_group_ids      = [aws_security_group.nginx_admin.id]
  key_name                    = aws_key_pair.wopr4-vex-key-pair.key_name
  iam_instance_profile        = aws_iam_instance_profile.nginx_profile.name
  associate_public_ip_address = true
  depends_on                  = [aws_iam_role_policy.allow_s3_all]
}
