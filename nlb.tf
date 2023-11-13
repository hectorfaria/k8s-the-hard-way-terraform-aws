/*   LOAD_BALANCER_ARN=$(aws elbv2 create-load-balancer \
    --name kubernetes \
    --subnets ${SUBNET_ID} \
    --scheme internet-facing \
    --type network \
    --output text --query 'LoadBalancers[].LoadBalancerArn')
  TARGET_GROUP_ARN=$(aws elbv2 create-target-group \
    --name kubernetes \
    --protocol TCP \
    --port 6443 \
    --vpc-id ${VPC_ID} \
    --target-type ip \
    --output text --query 'TargetGroups[].TargetGroupArn')
  aws elbv2 register-targets --target-group-arn ${TARGET_GROUP_ARN} --targets Id=10.0.1.1{0,1,2}
  aws elbv2 create-listener \
    --load-balancer-arn ${LOAD_BALANCER_ARN} \
    --protocol TCP \
    --port 443 \
    --default-actions Type=forward,TargetGroupArn=${TARGET_GROUP_ARN} \
    --output text --query 'Listeners[].ListenerArn'

KUBERNETES_PUBLIC_ADDRESS=$(aws elbv2 describe-load-balancers \
  --load-balancer-arns ${LOAD_BALANCER_ARN} \
  --output text --query 'LoadBalancers[].DNSName') */


resource "aws_lb" "this" {
  name                       = "kubernetes"
  load_balancer_type         = "network"
  subnets                    = module.vpc.public_subnets
  enable_deletion_protection = false
  security_groups            = ["${aws_security_group.kubernetes.id}"]
  tags                       = local.tags
}


resource "aws_lb_target_group" "this" {
  name        = "kubernetes"
  port        = 6443
  protocol    = "TCP"
  vpc_id      = module.vpc.vpc_id
  target_type = "ip"


  depends_on = [
    aws_lb.this
  ]
  tags = local.tags
}

resource "aws_lb_listener" "this" {

  load_balancer_arn = aws_lb.this.arn

  protocol = "TCP"
  port     = 443

  depends_on = [
    aws_lb.this
  ]

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.arn
  }

  tags = local.tags
}

resource "aws_lb_target_group_attachment" "this" {

  target_group_arn  = aws_lb_target_group.this.arn
  target_id         = "10.0.1.10"
  availability_zone = "us-east-1a"
  port              = 6443
}


resource "aws_lb_target_group_attachment" "this-two" {

  target_group_arn  = aws_lb_target_group.this.arn
  target_id         = "10.0.1.11"
  availability_zone = "us-east-1a"
  port              = 6443
}

resource "aws_lb_target_group_attachment" "this-three" {

  target_group_arn  = aws_lb_target_group.this.arn
  target_id         = "10.0.1.12"
  availability_zone = "us-east-1a"
  port              = 6443
}
