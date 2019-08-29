output "ken_eip" {
  value = module.ken_jumpbox.eip
}
 output "aws_subnets" {
   data.aws_vpcs.vpc_list.ids
 }
