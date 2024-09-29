resource "aws_ecr_repository" "ecr_repo" {
  name                 = var.name
  image_tag_mutability = "MUTABLE"
  force_delete         = var.force_delete

  image_scanning_configuration {
    scan_on_push = false
  }
}

resource "aws_ecr_lifecycle_policy" "images_policy" {
  repository = aws_ecr_repository.ecr_repo.name

  policy = <<EOF
{
    "rules": [
        {
            "rulePriority": 1,
            "description": "Keep last 10 images",
            "selection": {
                "tagStatus": "tagged",
                "tagPrefixList": ["20"],
                "countType": "imageCountMoreThan",
                "countNumber": 10
            },
            "action": {
                "type": "expire"
            }
        },
        {
            "rulePriority": 2,
            "description": "Expire images older than 10 days",
            "selection": {
                "tagStatus": "untagged",
                "countType": "sinceImagePushed",
                "countUnit": "days",
                "countNumber": 10
            },
            "action": {
                "type": "expire"
            }
        }
    ]
}
EOF
}

locals {
  actions = [
    "ecr:GetDownloadUrlForLayer",
    "ecr:BatchGetImage",
    "ecr:BatchCheckLayerAvailability",
    "ecr:DescribeRepositories",
    "ecr:ListImages",
    "ecr:DescribeImages"
  ]

  read_iam_identifiers = var.aws_ecr_read_iam_identifiers == "" ? [] : split(",", var.aws_ecr_read_iam_identifiers)
}

data "aws_iam_policy_document" "ecr_policy" {
  statement {
    sid    = "ReadECRPolicy"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = [for identifier in local.read_iam_identifiers : "arn:aws:iam::${identifier}:root"]
    }

    actions = local.actions
  }


  statement {
    sid    = "LambdaECRImageCrossAccountRetrievalPolicy"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = local.actions

    condition {
      test        = "StringLike"
      variable    = "aws:sourceArn"
      values = [for identifier in local.read_iam_identifiers : "arn:aws:lambda:*:${identifier}:function:*"]
    }
  }
}

resource "aws_ecr_repository_policy" "sharing" {
  repository = aws_ecr_repository.ecr_repo.name
  policy     = data.aws_iam_policy_document.ecr_policy.json
}
