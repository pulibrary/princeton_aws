/* Security group for the project */
resource "aws_security_group" "project_server_sg" {
  name        = "${var.environment}-project-server-sg"
  description = "Security group for project that allows project traffic from internet"
  vpc_id      = "${var.vpc_id}"

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"
    cidr_blocks = ["${var.vpc_cidr_block}"]
  }

  ingress {
    from_port = 3000
    to_port   = 3000
    protocol  = "tcp"
    cidr_blocks = ["${var.vpc_cidr_block}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8
    to_port     = 0
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name        = "${var.environment}-project-server-sg"
    Environment = "${var.environment}"
  }
}

resource "aws_security_group" "project_inbound_sg" {
  name        = "${var.environment}-project-inbound-sg"
  description = "Allow HTTP from Anywhere"
  vpc_id      = "${var.vpc_id}"

  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8
    to_port     = 0
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "${var.environment}-project-inbound-sg"
  }
}

/* Docnow servers */
resource "aws_instance" "project" {
  count             = "${var.project_instance_count}"
  ami               = "${lookup(var.amis, var.region)}"
  instance_type     = "${var.instance_type}"
  subnet_id         = "${var.private_subnet_id}"
  vpc_security_group_ids = [
    "${aws_security_group.project_server_sg.id}"
  ]
  key_name          = "${var.key_name}"
  user_data         = "${file("${path.module}/files/user_data.sh")}"
  tags = {
    Name        = "${var.environment}-project-${count.index+1}"
    Environment = "${var.environment}"
  }
}

/* Load Balancer */
resource "aws_elb" "project" {
  name            = "${var.environment}-project-lb"
  subnets         = ["${var.public_subnet_id}"]
  security_groups = ["${aws_security_group.project_inbound_sg.id}"]

  listener {
    instance_port     = 3000
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  health_check {
  healthy_threshold = 2
  unhealthy_threshold = 2
  timeout = 3
  target = "HTTP:3000/"
  interval = 30
  }

  instances = ["${aws_instance.project.*.id}"]
  connection_draining = true
  idle_timeout = 400
  connection_draining_timeout = 400

  tags {
    Environment = "${var.environment}"
  }
}
