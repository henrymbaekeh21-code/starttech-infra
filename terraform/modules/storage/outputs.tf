output "s3_bucket_name" { value = aws_s3_bucket.frontend.id }
output "s3_bucket_arn" { value = aws_s3_bucket.frontend.arn }
output "s3_website_url" { value = "http://${aws_s3_bucket.frontend.bucket}.s3-website-${data.aws_region.current.name}.amazonaws.com" }
output "cloudfront_domain_name" { value = aws_cloudfront_distribution.frontend.domain_name }
output "cloudfront_distribution_id" { value = aws_cloudfront_distribution.frontend.id }

data "aws_region" "current" {}
