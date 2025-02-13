terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0"
    }
  }
}


variable "servers" {
  type = map(object({
    ami_id              = string   # 使用するAMI ID
    instance_type       = string   # インスタンスタイプ
    subnet_id           = string   # 配置するサブネットID
    security_groups     = list(string) # 割り当てるセキュリティグループIDリスト
    server_name         = string   # インスタンス名
    vpc_id              = string   # 所属するVPCのID
    key_name            = string   # SSH接続用のキー名
    iam_instance_profile = string  # IAMインスタンスプロファイル
    ebs_optimized       = optional(bool, true)  # EBS最適化を有効化するか
    monitoring          = optional(bool, false) # 詳細モニタリングの有効化
    user_data           = optional(string, "")  # 起動時のスクリプト
    root_volume_size    = number   # ルートボリュームサイズ (GB)
    root_volume_type    = optional(string, "gp3") # デフォルトは gp3
    environment         = optional(string, "development") # 環境タグ
    project            = optional(string, "default") # プロジェクトタグ
  }))
}
