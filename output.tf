
output "private_key" {
  value       = tls_private_key.kubernetes_key.private_key_pem
  description = "Private Key"
  sensitive   = true
}
