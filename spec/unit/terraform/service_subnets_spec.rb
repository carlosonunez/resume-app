# frozen_string_literal: true

%w[a b].each do |availability_zone|
  aws_region = ENV['AWS_REGION'] || ENV['AWS_DEFAULT_REGION']
  aws_availability_zone = "#{aws_region}#{availability_zone}"
  raise 'VPC CIDR block not defined.' unless ENV['LB_VPC_CIDR_BLOCK']
  aws_vpc_cidr_block = ENV['LB_VPC_CIDR_BLOCK']
  base_subnet_cidr_block = aws_vpc_cidr_block.split('.')[0..1].join('.')
  aws_subnet_id = availability_zone.chars.map(&:ord).first
  expected_subnet_cidr = "#{base_subnet_cidr_block}.#{aws_subnet_id}.0/24"
  RSpecHelpers::Terraform.run_tests(
    resource_name: "aws_subnet.subnet_#{availability_zone}",
    test_definitions_hash: {
      availability_zone: {
        test_name: "It should be configured to use #{aws_availability_zone}",
        should_be: aws_availability_zone
      },
      cidr_block: {
        test_name: 'It should be a /24 within the same CIDR as its parent VPC',
        should_be: expected_subnet_cidr
      },
      map_public_ip_on_launch: {
        test_name: 'It should not generate public IPs on the fly',
        should_be: false
      },
      vpc_id: {
        test_name: 'It should be assigned to the VPC specified in our .env',
        should_be: ENV['LOAD_BALANCER_VPC']
      }
    }
  )
end
