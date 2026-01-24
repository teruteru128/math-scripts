#!/bin/bash

# 環境変数の確認
session_id="$FDB_SESSION_ID"
if [ -z "$session_id" ]; then
    echo "エラー: 環境変数 'FDB_SESSION_ID' が設定されていません。処理を中断します。" >&2
    exit 1
fi

target_url="https://factordb.com/uploadcert.php" # 送信先URL
max_retries=3                                   # 最大リトライ回数
retry_delay=7                                   # リトライ間の待機秒数

# カレントディレクトリ内の cert*.txt ファイルをループ
for file in certs/*cert3148.txt; do
    # ファイルが存在しない場合のハンドリング
    [ -e "$file" ] || continue

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
        # --fail: HTTPエラー時にエラーコードを返す
        # --retry: curl自体のリトライ機能
        # -b: クッキーの指定
        # -F: フォームデータの送信
        curl --fail --retry 10 \
             --cookie "fdbuser=$session_id" \
             -F "cert=@$zip_path" \
             -F "zip=on" \
             "$target_url"

        if [ $? -eq 0 ]; then
            echo -e "\e[32mSuccessfully uploaded: $zip_path\e[0m"
            success=true
            # 送信成功後に元ファイルを移動しZIPを削除
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
