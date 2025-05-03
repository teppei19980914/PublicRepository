<#
変数定義箇所
ユーザは変更する必要がある
#>

<#
Qiitaの記事操作に関する変数定義
#>
# Qiita APIのエンドポイントURLの指定
$qiitaApiUrl = 'https://qiita.com/api/v2/items'
# アクセストークン
$accessToken = 'XXXX'
# 取得したいユーザー名を指定
$userName = 'XXXX'
# 取得したい件数を指定
$maxPage = 100

<#
API処理に関する変数定義
#>
# APIキー
$apiKey = 'XXXX'
# 一括処理URLとレコード作成URLのドメインまでの指定(スキーマ+ドメイン「http://localhost」のように指定)
$baseUri = 'https://pleasanter.net'
# Qiita記事を登録するサイトのサイトIDを指定
$qiitaSiteId = 'XXXX'
# メール送信APIを実行する際のダミーレコードIDを指定
$sendMailRecordId = 'XXXX'
# APIバージョンを指定
$apiVersion = 1.1
# 宛先メールアドレスを指定
$toMailAddress = 'XXXX@example.co.jp'
# 通知メールの件名を指定
$mailTitle = 'Qiitaの記事を登録しました。'
# 通知メールの本文を指定
$mailBodyText = 'Qiitaの記事をプリザンターに登録しました。該当テーブルは下記になります。ご確認をよろしくお願いいたします。'
$mailBodyURL = $baseUri + '/fs/items/' + $qiitaSiteId + '/index'
$mailBody = $mailBodyText + $mailBodyURL
# ContentTypeを指定
$contentType = 'application/json'

<#
ログファイルの操作に関する変数定義
#>
# ログファイルを削除する期間を定義(日にち単位)
# 例) 18日 17:00に実行し、かつ「4」を指定した場合、14日の16:59以前のファイルが削除されます。
$deletLogFilePeriod = 31
# ログファイルの格納ディレクトリのPathを定義
$createLogDirectoryPath = 'XXXX\logFile'
# 現在日時を取得
$nowDate = Get-Date -Format 'yyyyMMddHHmmss'
# ログファイルの格納場所を定義
$createLogFilePath = $createLogDirectoryPath + '\' + $nowDate + '.log'


<#
プログラム箇所
ユーザは操作する必要なし
#>


# 指定のフォルダが存在する場合の処理
if (Test-Path $createLogDirectoryPath) {
    # 同名のログファイルが存在しない場合の処理
    if ( - !(Test-Path $createLogFilePath)) {
        # 空のログファイルを新規作成
        Out-File $createLogFilePath
        # ログファイルが作成されたことをログファイルに出力
        $comment = '[' + $(Get-Date -Uformat %Y%m%d_%H:%M:%S) + '] 【INFO】ログファイルが作成されました。作成ファイル：' + $createLogFilePath
        Add-Content -Path $createLogFilePath -Value $comment
        # スクリプトを実行する事をログファイルに出力
        $comment = '[' + $(Get-Date -Uformat %Y%m%d_%H:%M:%S) + '] 【DEBUG】スクリプトの実行開始'
        Add-Content -Path $createLogFilePath -Value $comment
    }
    # 同名のログファイルが存在する場合の処理
    else {
        # ログファイルに追記する場合のログ開始位置がわかるようにログファイルに出力
        $comment = '------------------------------------'
        Add-Content -Path $createLogFilePath -Value $comment
        # スクリプトを実行する事をログファイルに出力
        $comment = '[' + $(Get-Date -Uformat %Y%m%d_%H:%M:%S) + '] 【DEBUG】スクリプトの実行開始'
        Add-Content -Path $createLogFilePath -Value $comment
    }
}
# 指定のフォルダが存在しない場合の処理
else {
    # 指定のフォルダが存在しない旨、コンソールに出力
    $comment = '[' + $(Get-Date -Uformat %Y%m%d_%H:%M:%S) + '] 指定のフォルダが存在しません。指定のフォルダ：' + $createLogDirectoryPath
    write-host $comment
    # 処理を中断する
    exit
}


# 「過去のログファイルを削除する処理」が開始したことをログファイルに出力
$comment = '[' + $(Get-Date -Uformat %Y%m%d_%H:%M:%S) + '] 【DEBUG】「過去のログファイルを削除する処理」の開始'
Add-Content -Path $createLogFilePath -Value $comment
# 削除対象のログファイルをログファイルに出力
$comment = '[' + $(Get-Date -Uformat %Y%m%d_%H:%M:%S) + '] 【INFO】削除対象ファイル：今日から' + $deletLogFilePeriod + '日以前のファイル'
Add-Content -Path $createLogFilePath -Value $comment
# 過去のログファイルを削除
Get-ChildItem $createLogDirectoryPath -Recurse | Where-Object { $_.CreationTime -lt (Get-Date).AddDays(-$deletLogFilePeriod) } | Remove-Item -Force
# 過去のログファイルの削除処理を終了した旨ログファイルに出力
$comment = '[' + $(Get-Date -Uformat %Y%m%d_%H:%M:%S) + '] 【DEBUG】ファイルの削除処理終了'
Add-Content -Path $createLogFilePath -Value $comment


# 「レコードを全て削除する処理」が開始したことをログファイルに出力
$comment = '[' + $(Get-Date -Uformat %Y%m%d_%H:%M:%S) + '] 【DEBUG】「レコードを全て削除する処理」の開始'
Add-Content -Path $createLogFilePath -Value $comment
# リクエスト情報を設定
$deleteRecordJsonData = @{
    'ApiVersion' = $apiVersion
    'ApiKey'     = $apiKey
    'All'        = 'TRUE'
}
# JSON形式に変換
$deleteRecordConvertBody = $deleteRecordJsonData | ConvertTo-Json
# 一括処理URLの指定
$deleteRecordPath = $baseUri + '/fs/api/items/' + $qiitaSiteId + '/bulkdelete'
# 一括処理URLをログファイルに出力
$comment = '[' + $(Get-Date -Uformat %Y%m%d_%H:%M:%S) + '] 【INFO】一括処理URL：' + $deleteRecordPath
Add-Content -Path $createLogFilePath -Value $comment
# Webページからのレスポンスを取得
$deleteRecordResponseData = Invoke-RestMethod -Uri $deleteRecordPath -ContentType $contentType -Method POST -Body $deleteRecordConvertBody
# Webページからのレスポンスをログファイルに出力
$comment = '[' + $(Get-Date -Uformat %Y%m%d_%H:%M:%S) + '] 【INFO】レスポンス内容：' + $deleteRecordResponseData
Add-Content -Path $createLogFilePath -Value $comment


# 「Qiitaの記事を取得する処理」が開始したことをログファイルに出力
$comment = '[' + $(Get-Date -Uformat %Y%m%d_%H:%M:%S) + '] 【DEBUG】「Qiitaの記事を取得する処理」の開始'
Add-Content -Path $createLogFilePath -Value $comment
# 全件のQiita記事を取得して表示
$page = 1
# Qiitaの記事内容を取得する反復処理が開始したことをログファイルに出力
$comment = '[' + $(Get-Date -Uformat %Y%m%d_%H:%M:%S) + '] 【DEBUG】Qiitaの記事内容を取得する反復処理が開始しました。'
Add-Content -Path $createLogFilePath -Value $comment
# Qiitaの記事内容(Webページからのレスポンス)を設定
# Queryを発行する
$query = '?per_page=' + $maxPage + '&page=' + $page + '&query=user:' + $userName
# Queryをログファイルに出力
$comment = '[' + $(Get-Date -Uformat %Y%m%d_%H:%M:%S) + '] 【INFO】Query：' + $query
Add-Content -Path $createLogFilePath -Value $comment
# URLを設定する
$url = $qiitaApiUrl + $query
# URLをログファイルに出力
$comment = '[' + $(Get-Date -Uformat %Y%m%d_%H:%M:%S) + '] 【INFO】URL：' + $url
Add-Content -Path $createLogFilePath -Value $comment
# Qiita APIへのリクエスト用ヘッダーを作成
$headers = @{
    'Authorization' = 'Bearer ' + $accessToken
}
# Webページからのレスポンスを取得
$response = Invoke-RestMethod -Uri $url -Headers $headers -Method Get

# Qiitaの記事情報が存在した場合の処理
if ($response) {
    # Qiitaの記事情報を読み込む反復処理が開始したことをログファイルに出力
    $comment = '[' + $(Get-Date -Uformat %Y%m%d_%H:%M:%S) + '] 【DEBUG】Qiitaの記事情報を読み込む反復処理が開始しました。'
    Add-Content -Path $createLogFilePath -Value $comment
    # カウンタを指定
    $count = 1
    # Qiitaの記事情報を1件ずつ読み込む
    foreach ($article in $response) {
        # 「タイトル」を設定
        $title = $article.title
        # 「内容」を設定(マークダウン形式になるように設定)
        $body = '[md]' + $article.body
        # 「分類B」を設定
        $classB = $article.url
        # 区切りをログファイルに出力
        $comment = '-----------------------------------------------------------------------------'
        Add-Content -Path $createLogFilePath -Value $comment
        # 「レコードを新規作成する処理」が開始したことをログファイルに出力
        $comment = '[' + $(Get-Date -Uformat %Y%m%d_%H:%M:%S) + '] 【DEBUG】' + $count + '件目の「レコードを新規作成する処理」の開始'
        Add-Content -Path $createLogFilePath -Value $comment
        # リクエスト情報を設定
        $createRecordJsonData = @{
            'ApiVersion' = $apiVersion
            'ApiKey'     = $apiKey
            'Title'      = $title
            'Body'       = $body
            'ClassHash'  = @{
            'ClassB'     = $classB
            }
        }
        # JSON形式に変換
        $createRecordConvertBody = $createRecordJsonData | ConvertTo-Json
        # プリザンターで表示時に文字化けしないようにUTF-8にエンコーディング
        $createRecordEncodedConvertBody = [System.Text.Encoding]::UTF8.GetBytes($createRecordConvertBody)
        # レコード作成URLの指定
        $createRecordPath = $baseUri + '/fs/api/items/' + $qiitaSiteId + '/create'
        # レコード作成URLをログファイルに出力
        $comment = '[' + $(Get-Date -Uformat %Y%m%d_%H:%M:%S) + '] 【INFO】レコード作成URL：' + $createRecordPath
        Add-Content -Path $createLogFilePath -Value $comment
        # Webページからのレスポンスを取得
        $createRecordResponseData = Invoke-RestMethod -Uri $createRecordPath -ContentType $contentType -Method POST -Body $createRecordEncodedConvertBody
        # レコード作成APIのレスポンスをログファイルに出力
        $comment = '[' + $(Get-Date -Uformat %Y%m%d_%H:%M:%S) + '] 【INFO】レスポンス内容' + $createRecordResponseData
        Add-Content -Path $createLogFilePath -Value $comment

        # カウンタをインクリメント
        $count++
    }
    # 区切りをログファイルに出力
    $comment = '-----------------------------------------------------------------------------'
    Add-Content -Path $createLogFilePath -Value $comment
    # Qiitaの記事情報を読み込む反復処理が終了したことをログファイルに出力
    $comment = '[' + $(Get-Date -Uformat %Y%m%d_%H:%M:%S) + '] 【DEBUG】Qiitaの記事情報を読み込む反復処理が終了しました。'
    Add-Content -Path $createLogFilePath -Value $comment
}

# 処理が完了したことをメール通知するとログファイルに出力
$comment = '[' + $(Get-Date -Uformat %Y%m%d_%H:%M:%S) + '] 【DEBUG】メール通知処理が開始しました。'
Add-Content -Path $createLogFilePath -Value $comment
$sendMailJsonData = @{
        'ApiVersion' = $apiVersion
        'ApiKey' = $apiKey
        'To' = $toMailAddress
        'Title' = $mailTitle
        'Body' = $mailBody
}
# JSON形式に変換
$sendMailConvertBody = $sendMailJsonData | ConvertTo-Json
# メールの本文で文字化けしないようにUTF-8にエンコーディング
$sendMailEncodedConvertBody = [System.Text.Encoding]::UTF8.GetBytes($sendMailConvertBody)
# レコード作成URLの指定
$sendMailPath = $baseUri + '/fs/api/items/' + $sendMailRecordId + '/OutgoingMails/Send'
# メール通知URLをログファイルに出力
$comment = '[' + $(Get-Date -Uformat %Y%m%d_%H:%M:%S) + '] 【INFO】メール通知URL：' + $sendMailPath
Add-Content -Path $createLogFilePath -Value $comment
# Webページからのレスポンスを取得
$sendMailResponseData = Invoke-RestMethod -Uri $sendMailPath -ContentType $contentType -Method POST -Body $sendMailEncodedConvertBody
# レコード作成APIのレスポンスをログファイルに出力
$comment = '[' + $(Get-Date -Uformat %Y%m%d_%H:%M:%S) + '] 【INFO】レスポンス内容' + $sendMailResponseData
Add-Content -Path $createLogFilePath -Value $comment