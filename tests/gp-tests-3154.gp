\\ --- 設定エリア ---
target_n = (52725606790129827602687852529862497809531948763975871^93+1)/(52725606790129827602687852529862497809531948763975871^31+1)/51882993858084354816133263063288127149266683478410166607684383313564275439704714330807264626691295215443787308376383;
output_file = "../certs/cert3154.txt";
windows_dest = "windows:C:/Users/terut/OneDrive/Documents/gp/certs/";

\\ --- 計測開始 ---
start_time = gettime();
print("Calculation started at: ", getwalltime());

\\ --- メイン処理 ---
\\ 1. 証明書の生成
cert = primecert(target_n);

\\ 2. エクスポート形式に変換（書式1）
cert_exported = primecertexport(cert, 1);

\\ 3. ファイル書き出し
write(output_file, cert_exported);

\\ --- 計測終了 ---
end_time = gettime();
elapsed_sec = end_time / 1000.0;

print("Calculation finished!");
print("Elapsed time: ", elapsed_sec, " seconds.");

\\ --- Windowsへの自動転送 (SSHが開通している前提) ---
print("Sending result to Windows...");
system(strprintf("scp %s %s", output_file, windows_dest));

print("All done.");
