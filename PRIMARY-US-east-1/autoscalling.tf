# Autoscaling Group for Frontend Servers
resource "aws_autoscaling_group" "frontend-asg" {
  name_prefix = "frontend-asg"
  desired_capacity   = 1
  max_size           = 1
  min_size           = 1

  # VPC Subnets in which the instances should be launched.
  vpc_zone_identifier = [aws_subnet.prvt3.id, aws_subnet.prvt4.id]

  # Target Group for the Load Balancer to route traffic to the instances.
  target_group_arns = [aws_lb_target_group.front_end.arn]
  
  health_check_type = "EC2"
  #health_check_grace_period = 300 # default is 300 seconds  

  # Launch Template defines the configuration for the instances.
  launch_template {
    id      = aws_launch_template.frontend.id
    version = aws_launch_template.frontend.latest_version
  }
  # Instance Refresh settings help apply changes to the Auto Scaling Group.
   instance_refresh {
    strategy = "Rolling"
    preferences {
      #instance_warmup = 300 # Default behavior is to use the Auto Scaling Group's health check grace period.
      min_healthy_percentage = 50
    }
    triggers = [ /*"launch_template",*/ "desired_capacity" ] # You can add any argument from ASG here, if those has changes, ASG Instance Refresh will trigger
  } 
  # Tagging the Auto Scaling Group with the Name 'frontend-asg' for identification.
  tag {
    key                 = "Name"
    value               = "frontend-asg"
    propagate_at_launch = true
  }      
}

#####################################################################

# Autoscaling Group for Backend Servers
resource "aws_autoscaling_group" "backend-asg" {
  name_prefix = "backend-asg"
  desired_capacity   = 1
  max_size           = 1
  min_size           = 1

  # VPC Subnets in which the instances should be launched.
  vpc_zone_identifier = [aws_subnet.prvt5.id, aws_subnet.prvt6.id]

  # Target Group for the Load Balancer to route traffic to the instances.
  target_group_arns = [aws_lb_target_group.back_end.arn]

  health_check_type = "EC2"
  #health_check_grace_period = 300 # default is 300 seconds  

  # Launch Template defines the configuration for the instances.
  launch_template {
    id      = aws_launch_template.backend.id
    version = aws_launch_template.backend.latest_version
  }

  # Instance Refresh settings help apply changes to the Auto Scaling Group.
    instance_refresh {
    strategy = "Rolling"
    preferences {
      #instance_warmup = 300 # Default behavior is to use the Auto Scaling Group's health check grace period.
      min_healthy_percentage = 50
    }
    triggers = [ /*"launch_template",*/ "desired_capacity" ] # You can add any argument from ASG here, if those has changes, ASG Instance Refresh will trigger
  } 
   # Tagging the Auto Scaling Group with the Name 'backend-asg' for identification.
  tag {
    key                 = "Name"
    value               = "backend-asg"
    propagate_at_launch = true
  }      
}
