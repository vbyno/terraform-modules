output "redis_connection_uri" {
  sensitive = true
  value     = "redis://${aws_elasticache_cluster.redis.cache_nodes[0].address}:${aws_elasticache_cluster.redis.cache_nodes[0].port}"
}

output "connection_security_group_id" {
  value = aws_security_group.redis_connection_security_group.id
}
