# output "instance_public_ip" {
#   value = aws_instance.clock_instance.public_ip
# }
#
# output "instance_id" {
#   value = aws_instance.clock_instance.id
# }
#
# output "instance_state" {
#   description = "The state of the EC2 instance"
#   value       = aws_instance.clock_instance.instance_state
# }


output "instance_details" {
  value = {
    for i, instance in aws_instance.clock_instances : var.instance_names[i] => {
      id         = instance.id
      public_ip  = instance.public_ip
      state      = instance.instance_state
    }
  }
}