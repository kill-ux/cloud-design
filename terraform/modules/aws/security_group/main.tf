
resource "aws_security_group" "sg" {
  name        = var.name
  description = var.description
  vpc_id      = var.vpc_id

  tags = merge(var.tags, { "Name" = var.name })
}

# Ingress rules
resource "aws_vpc_security_group_ingress_rule" "ingress" {
  for_each = { for i, rule in var.ingress_rules : i => rule }

  security_group_id = aws_security_group.sg.id
  description       = each.value.description
  from_port         = each.value.protocol == "-1" ? null : each.value.from_port
  to_port           = each.value.protocol == "-1" ? null : each.value.to_port
  ip_protocol       = each.value.protocol

  cidr_ipv4                    = each.value.cidr_ipv4
  referenced_security_group_id = try(each.value.self, false) == true ? aws_security_group.sg.id : each.value.referenced_security_group_id
}


# Egress rules
resource "aws_vpc_security_group_egress_rule" "egress" {
  # for_each = { for i, rule in var.egress_rules : i => rule }

  # security_group_id = aws_security_group.sg.id
  # description       = each.value.description
  # from_port         = each.value.from_port
  # to_port           = each.value.to_port
  # ip_protocol       = each.value.protocol
  # cidr_ipv4         = each.value.cidr_ipv4

  count = length(var.egress_rules)

  security_group_id = aws_security_group.sg.id
  description       = var.egress_rules[count.index].description
  cidr_ipv4         = var.egress_rules[count.index].cidr_ipv4
  ip_protocol       = var.egress_rules[count.index].protocol

  # Force null if protocol is "-1" (all protocols)
  from_port = var.egress_rules[count.index].protocol == "-1" ? null : var.egress_rules[count.index].from_port
  to_port   = var.egress_rules[count.index].protocol == "-1" ? null : var.egress_rules[count.index].to_port

  lifecycle {
    create_before_destroy = false
  }
}

