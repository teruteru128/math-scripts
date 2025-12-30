\\ --- 設定エリア ---
target_n = (10^3151 - 733) / 2254084809;
output_file = "cert3142.txt";
windows_dest = "windows:C:/Users/terut/OneDrive/Documents/gp/certs/";

\\ --- 計測開始 ---
start_time = gettime();
print("Calculation started at: ", strtime(getwalltime()));

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
system(lsprintf("scp %s %s", output_file, windows_dest));

print("All done.");
quit;
