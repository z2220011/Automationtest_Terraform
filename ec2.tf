resource "aws_instance" "ec2_instances" {
  for_each              = var.servers
  ami                   = each.value.ami_id
  instance_type         = each.value.instance_type
  subnet_id             = each.value.subnet_id
  vpc_security_group_ids = each.value.security_groups

  # SSHキー（EC2にログインするためのキー）
  key_name              = each.value.key_name

  # IAMロールの指定（必要に応じて）
  iam_instance_profile  = each.value.iam_instance_profile

  # EBS最適化を有効化
  ebs_optimized         = lookup(each.value, "ebs_optimized", true)

  # 詳細モニタリングを有効化（CloudWatch メトリクス収集）
  monitoring            = lookup(each.value, "monitoring", false)

  # インスタンス起動時に実行するスクリプト
  user_data             = lookup(each.value, "user_data", "")

  # ルートボリュームの設定
  root_block_device {
    volume_size = each.value.root_volume_size
    volume_type = lookup(each.value, "root_volume_type", "gp3") # デフォルトで gp3 を指定
    delete_on_termination = true
  }

  # タグを追加
  tags = {
    Name        = each.value.server_name
    Environment = lookup(each.value, "environment", "development")
    Project     = lookup(each.value, "project", "default")
  }
}
