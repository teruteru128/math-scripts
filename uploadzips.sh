#!/bin/bash

# 環境変数の確認
session_id="$FDB_SESSION_ID"
if [ -z "$session_id" ]; then
    echo "エラー: 環境変数 'FDB_SESSION_ID' が設定されていません。処理を中断します。" >&2
    exit 1
fi

# 第1引数があればそれを使用し、なければデフォルトのパターンを使用
# 引用符で囲まずに変数に代入することで、ループ時にワイルドカードを展開させます
target_pattern="${1:-certs/*cert3149.txt}"

target_url="https://factordb.com/uploadcert.php" # 送信先URL
max_retries=3                                   # 最大リトライ回数
retry_delay=7                                   # リトライ間の待機秒数

# 指定されたパターンに一致するファイルをループ
# シェルの展開を利用するため、変数は引用符で囲みません
for file in $target_pattern; do
    # ファイルが存在しない（パターンに一致するものがない）場合のハンドリング
    [ -e "$file" ] || { echo "対象ファイルが見つかりません: $target_pattern"; continue; }

    base_name="${file%.*}"
    zip_path="${base_name}.zip"

    echo "Compressing: $file..."
    # -j オプションはパスを含めずファイル名のみを格納、-q は静止モード
    zip -jq "$zip_path" "$file"

    success=false
    attempt=0

    while [ "$success" = false ] && [ "$attempt" -lt "$max_retries" ]; do
        attempt=$((attempt + 1))
        echo "Sending $zip_path (Attempt $attempt)..."

        # curl の実行
        curl --fail --retry 10 \
             --cookie "fdbuser=$session_id" \
             -F "cert=@$zip_path" \
             -F "zip=on" \
             "$target_url"

        if [ $? -eq 0 ]; then
            echo -e "\e[32mSuccessfully uploaded: $zip_path\e[0m"
            success=true
            # 送信成功後に元ファイルを移動しZIPを削除
            # 移動先ディレクトリが存在することを確認
            mkdir -p ./転送済み/
            mv "$file" ./転送済み/
            rm "$zip_path"
        else
            echo "Warning: Failed to upload $zip_path. Retrying in $retry_delay seconds..." >&2
            if [ "$attempt" -lt "$max_retries" ]; then
                sleep "$retry_delay"
            fi
        fi
    done

    if [ "$success" = false ]; then
        echo "Final failure: Could not upload $zip_path after $max_retries attempts." >&2
    fi
done
