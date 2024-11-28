#IAM USER 
resource "aws_iam_user" "admin_user" {
  name = "Bhavana"
    tags = {
    Description = "Associate-Software-Developer"
  }

}

resource "aws_iam_policy" "adminUser" {
  name = "AdminUser"
  policy =   file("admin-policy.json")
}

resource "aws_iam_user_policy_attachment" "bhavana-admin-Access" {
    user = aws_iam_user.admin_user.name
    policy_arn = aws_iam_policy.adminUser.arn
  
}


# resource "aws_s3_bucket" "my_bucket" {
#   bucket = "terraform-demo-bucket-27-11-24"
#   acl    = "private"  

#   lifecycle {
#     //create_before_destroy = true //create content before destroy
#     prevent_destroy = true //prevent from accidental deletion of resource
#   }
  
# }

resource "aws_s3_bucket" "my_bucket" {
  bucket = var.bucketname

  tags = {
    Name        = "My bucket"
    Environment = "Dev"
  }
}


resource "aws_s3_bucket_ownership_controls" "my_bucket" {
  bucket = aws_s3_bucket.my_bucket.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "my_bucket" {
  bucket = aws_s3_bucket.my_bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}


resource "aws_s3_bucket_acl" "my_bucket" {
  depends_on = [
    aws_s3_bucket_ownership_controls.my_bucket,
    aws_s3_bucket_public_access_block.my_bucket,
  ]

  bucket = aws_s3_bucket.my_bucket.id
  acl    = "public-read"
}


resource "aws_s3_bucket_object" "index" {
    source = "index.html"
    key = "index.html"
    bucket = aws_s3_bucket.my_bucket.id  
    acl ="public-read"
    content_type = "text/html"
    
    lifecycle {
    create_before_destroy = true 
   }
}

resource "aws_s3_bucket_object" "error" {
    source = "error.html"
    key = "error.html"
    bucket = aws_s3_bucket.my_bucket.id  
    acl ="public-read"
    content_type = "text/html"
}

resource "aws_s3_bucket_website_configuration" "website" {
  bucket = aws_s3_bucket.my_bucket.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }

  depends_on = [ aws_s3_bucket_acl.my_bucket]

  
}