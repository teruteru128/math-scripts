$sessionId = $env:FDB_SESSION_ID
if ([string]::IsNullOrWhiteSpace($sessionId)) {
    Write-Error "エラー: 環境変数 'FDB_SESSION_ID' が設定されていません。処理を中断します。"
    exit 1  # スクリプトを終了
}
$targetUrl = "https://factordb.com/uploadcert.php" # 送信先URL
$maxRetries = 3                                   # 最大リトライ回数
$retryDelay = 7                                   # リトライ間の待機秒数
foreach($file in get-childitem *.txt) {
    $zipPath = "$($file.BaseName).zip"
    Write-Host "Compressing: $($file.Name)..."
    Compress-Archive -Path $file.FullName -DestinationPath $zipPath -Force

    $success = $false
    $attempt = 0
    while (-not $success -and $attempt -lt $maxRetries) {
        $attempt++
        Write-Host "Sending $zipPath (Attempt $attempt)..."

        # curl.exe を実行 (--form でファイルを指定)
        # --retry は curl 自体のリトライ機能
        # --fail はエラー時に非ゼロの終了コードを返すためのオプション
        curl.exe --fail --retry 10 `
        --cookie "fdbuser=$sessionId" `
        -F "cert=@$zipPath" -F "zip=on" $targetUrl

        if ($LASTEXITCODE -eq 0) {
            Write-Host "Successfully uploaded: $zipPath" -ForegroundColor Green
            $success = $true
            # 送信成功後にZIPを削除する場合は以下を有効化
            Remove-Item $file
            Remove-Item $zipPath
        } else {
            Write-Warning "Failed to upload $zipPath. Retrying in $retryDelay seconds..."
            if ($attempt -lt $maxRetries) { Start-Sleep -Seconds $retryDelay }
        }
    }
    if (-not $success) {
        Write-Error "Final failure: Could not upload $zipPath after $maxRetries attempts."
    }
}
