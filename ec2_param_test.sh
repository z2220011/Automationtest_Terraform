#!/bin/bash

# ====== CSVファイルの初期化 ======
CSV_FILE="ec2_test_results.csv"
echo "Instance ID,Parameter,Expected Value,Actual Value,Result" > "$CSV_FILE"  # ヘッダー作成

# ====== Terraform Planの実行とJSON形式での出力 ======
terraform plan -out=plan.out
terraform show -json plan.out > plan.json

# ====== EC2インスタンスIDの取得 ======
INSTANCE_IDS=$(jq -r '.planned_values.root_module.resources[] 
    | select(.type=="aws_instance") 
    | .values.id' plan.json)

# ====== チェック対象のパラメータ一覧 ======
PARAMETERS=("instance_type" "ami" "private_ip" "subnet_id" "vpc_security_group_ids" "key_name" "iam_instance_profile")

# ====== テスト結果のヘッダー表示 ======
echo "=== EC2 パラメータ詳細テスト結果 ==="

# ====== 各インスタンスごとにパラメータ検証を実行 ======
for INSTANCE_ID in $INSTANCE_IDS; do
    echo ">> テスト対象インスタンス: $INSTANCE_ID"

    # ====== Terraform Planから期待値を取得 ======
    PLAN_DATA=$(jq -r --arg id "$INSTANCE_ID" '.planned_values.root_module.resources[] 
        | select(.type=="aws_instance" and .values.id == $id) 
        | .values' plan.json)

    # ====== AWS CLIで実際のインスタンス情報を取得 ======
    ACTUAL_DATA=$(aws ec2 describe-instances --instance-ids "$INSTANCE_ID" | jq '.Reservations[].Instances[0]')

    # ====== 各パラメータの比較処理 ======
    for PARAM in "${PARAMETERS[@]}"; do
        # ====== Terraform Planからパラメータの期待値を取得 ======
        EXPECTED_VALUE=$(echo "$PLAN_DATA" | jq -r ".$PARAM")

        # ====== パラメータごとの取得ロジックを分岐 ======
        case "$PARAM" in
            "vpc_security_group_ids")
                EXPECTED_VALUE=$(echo "$PLAN_DATA" | jq -r ".$PARAM[]" | sort | tr '\n' ',' | sed 's/,$//')
                ACTUAL_VALUE=$(echo "$ACTUAL_DATA" | jq -r '.SecurityGroups[].GroupId' | sort | tr '\n' ',' | sed 's/,$//')
                ;;
            "instance_type")
                ACTUAL_VALUE=$(echo "$ACTUAL_DATA" | jq -r '.InstanceType')
                ;;
            "ami")
                ACTUAL_VALUE=$(echo "$ACTUAL_DATA" | jq -r '.ImageId')
                ;;
            "private_ip")
                ACTUAL_VALUE=$(echo "$ACTUAL_DATA" | jq -r '.PrivateIpAddress')
                ;;
            "subnet_id")
                ACTUAL_VALUE=$(echo "$ACTUAL_DATA" | jq -r '.SubnetId')
                ;;
            "key_name")
                ACTUAL_VALUE=$(echo "$ACTUAL_DATA" | jq -r '.KeyName // "N/A"')
                ;;
            "iam_instance_profile")
                ACTUAL_VALUE=$(echo "$ACTUAL_DATA" | jq -r '.IamInstanceProfile.Arn // "N/A"')
                ;;
            *)
                ACTUAL_VALUE=$(echo "$ACTUAL_DATA" | jq -r ".$PARAM")
                ;;
        esac

        # ====== 期待値と実際の値を比較 ======
        if [ "$EXPECTED_VALUE" == "$ACTUAL_VALUE" ]; then
            RESULT="OK"
            echo "[$RESULT] $PARAM (Expected: $EXPECTED_VALUE, Actual: $ACTUAL_VALUE)"
        else
            RESULT="NG"
            echo "[$RESULT] $PARAM (Expected: $EXPECTED_VALUE, Actual: $ACTUAL_VALUE)"
        fi

        # ====== 結果をCSVファイルに出力 ======
        echo "$INSTANCE_ID,$PARAM,$EXPECTED_VALUE,$ACTUAL_VALUE,$RESULT" >> "$CSV_FILE"
    done

    echo "-----------------------------------------"
done

# ====== 完了メッセージ ======
echo "テスト終了"
