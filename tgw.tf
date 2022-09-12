# Create transit gateway in region1
resource "aws_ec2_transit_gateway" "region1" {
  provider = aws.region1

  tags = {
    Name = "${local.deployment_id}-tgw"
  }
}

# Create transit gateway in region2
resource "aws_ec2_transit_gateway" "region2" {
  provider = aws.region2

  tags = {
    Name = "${local.deployment_id}-tgw"
  }
}

# Create the TGW Peering attachment request in region2
resource "aws_ec2_transit_gateway_peering_attachment" "requester" {
  provider                = aws.region2
  peer_region             = local.region1
  peer_transit_gateway_id = aws_ec2_transit_gateway.region1.id
  transit_gateway_id      = aws_ec2_transit_gateway.region2.id

  tags = {
    Name = "${local.deployment_id}-tgw-peering-requestor"
    Side = "Requestor"
  }
}

# Load the TGW peering attachment request for acceptance in region1
data "aws_ec2_transit_gateway_peering_attachment" "accepter" {
  provider = aws.region1
  filter {
    name   = "transit-gateway-id"
    values = [aws_ec2_transit_gateway.region1.id]
  }

  depends_on = [
    aws_ec2_transit_gateway_peering_attachment.requester
  ]
}


# Accept the TGW Peering attachment request in region1
resource "aws_ec2_transit_gateway_peering_attachment_accepter" "this" {
  provider                      = aws.region1
  transit_gateway_attachment_id = data.aws_ec2_transit_gateway_peering_attachment.accepter.id

  tags = {
    Name = "${local.deployment_id}-cross-region-attachment"
    Side = "Accepter"
  }
}

# Attach region1 VPC to TGW in region1
resource "aws_ec2_transit_gateway_vpc_attachment" "region1" {
  provider           = aws.region1
  subnet_ids         = module.vpc-region1.private_subnets
  transit_gateway_id = aws_ec2_transit_gateway.region1.id
  vpc_id             = module.vpc-region1.vpc_id
}

# Attach region2 VPC to TGW in region2
resource "aws_ec2_transit_gateway_vpc_attachment" "region2" {
  provider           = aws.region2
  subnet_ids         = module.vpc-region2.private_subnets
  transit_gateway_id = aws_ec2_transit_gateway.region2.id
  vpc_id             = module.vpc-region2.vpc_id
}

# Load TGW route table in region1
data "aws_ec2_transit_gateway_route_table" "region1" {
  provider = aws.region1
  filter {
    name   = "transit-gateway-id"
    values = [aws_ec2_transit_gateway.region1.id]
  }
}

# Add route for region2 VPC via peering attachment in the region1 TGW route table 
resource "aws_ec2_transit_gateway_route" "region1" {
  provider                       = aws.region1
  destination_cidr_block         = module.vpc-region2.vpc_cidr_block
  transit_gateway_attachment_id  = data.aws_ec2_transit_gateway_peering_attachment.accepter.id
  transit_gateway_route_table_id = data.aws_ec2_transit_gateway_route_table.region1.id
  depends_on = [
    aws_ec2_transit_gateway_peering_attachment_accepter.this
  ]
}

# Load TGW route table in region2
data "aws_ec2_transit_gateway_route_table" "region2" {
  provider = aws.region2
  filter {
    name   = "transit-gateway-id"
    values = [aws_ec2_transit_gateway.region2.id]
  }
}

# Add route for region1 VPC via peering attachment in the region2 TGW route table 
resource "aws_ec2_transit_gateway_route" "region2" {
  provider                       = aws.region2
  destination_cidr_block         = module.vpc-region1.vpc_cidr_block
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment.requester.id
  transit_gateway_route_table_id = data.aws_ec2_transit_gateway_route_table.region2.id
  depends_on = [
    aws_ec2_transit_gateway_peering_attachment_accepter.this
  ]
}

# Load route table for region1 private subnet
data "aws_route_table" "region1_private" {
  provider = aws.region1
  vpc_id   = module.vpc-region1.vpc_id
  tags = {
    Name = "${local.deployment_id}-private"
  }
  depends_on = [
    module.vpc-region1
  ]
}

# Load route table for region1 public subnet
data "aws_route_table" "region1_public" {
  provider = aws.region1
  vpc_id   = module.vpc-region1.vpc_id
  tags = {
    Name = "${local.deployment_id}-public"
  }
  depends_on = [
    module.vpc-region1
  ]
}

# Create a new route entry in region1 private route table to route to region2 VPC via TGW
resource "aws_route" "region1_private_route" {
  provider               = aws.region1
  route_table_id         = data.aws_route_table.region1_private.id
  transit_gateway_id     = aws_ec2_transit_gateway.region1.id
  destination_cidr_block = module.vpc-region2.vpc_cidr_block
  depends_on = [
    module.vpc-region1
  ]
}

# Create a new route entry in region1 public route table to route to region2 VPC via TGW
resource "aws_route" "region1_public_route" {
  provider               = aws.region1
  route_table_id         = data.aws_route_table.region1_public.id
  transit_gateway_id     = aws_ec2_transit_gateway.region1.id
  destination_cidr_block = module.vpc-region2.vpc_cidr_block
  depends_on = [
    module.vpc-region1
  ]
}

# Load route table for region2 private subnet
data "aws_route_table" "region2_private" {
  provider = aws.region2
  vpc_id   = module.vpc-region2.vpc_id
  tags = {
    Name = "${local.deployment_id}-private"
  }
  depends_on = [
    module.vpc-region2
  ]
}

# Load route table for region2 public subnet
data "aws_route_table" "region2_public" {
  provider = aws.region2
  vpc_id   = module.vpc-region2.vpc_id
  tags = {
    Name = "${local.deployment_id}-public"
  }
  depends_on = [
    module.vpc-region2
  ]
}


# Create a new route entry in region2 private route table to route to region1 VPC via TGW
resource "aws_route" "region2_private_route" {
  provider               = aws.region2
  route_table_id         = data.aws_route_table.region2_private.id
  transit_gateway_id     = aws_ec2_transit_gateway.region2.id
  destination_cidr_block = module.vpc-region1.vpc_cidr_block
  depends_on = [
    module.vpc-region2
  ]
}

# Create a new route entry in region2 public route table to route to region1 VPC via TGW
resource "aws_route" "region2_public_route" {
  provider               = aws.region2
  route_table_id         = data.aws_route_table.region2_public.id
  transit_gateway_id     = aws_ec2_transit_gateway.region2.id
  destination_cidr_block = module.vpc-region1.vpc_cidr_block
  depends_on = [
    module.vpc-region2
  ]
}

