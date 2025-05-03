<#
変数定義箇所
ユーザは変更する必要がある
#>

<#
connpassのイベント操作に関する変数定義
#>
# Connpass API のエンドポイント
$apiEndpoint = "https://connpass.com/api/v1/event/"
# 表示順序を指定(1: 更新日時順, 2: 開催日時順, 3: 新着順)
$order = 2
# ニックネームを指定
$nickname = 'XXXX'

<#
API処理に関する変数定義
#>
# APIキー
$apiKey = 'XXXX'
# 一括処理URLとレコード作成URLのドメインまでの指定(スキーマ+ドメイン「http://localhost」のように指定)
$baseUri = 'https://pleasanter.net'
# メール送信APIを実行する際のダミーレコードIDを指定
$sendMailRecordId = 'XXXX'
# APIバージョンを指定
$apiVersion = 1.1
# 宛先メールアドレスを指定
$toMailAddress = 'XXXX@example.co.jp'
# 通知メールの件名を指定
$mailTitle = 'connpassのイベント情報をOutlookに登録しました。'
# 通知メールの本文を指定
$mailBody = 'connpassのイベント情報をOutlookに登録しました。ご確認をよろしくお願いいたします。'
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
ロジック定義箇所
ユーザは変更する必要がない
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


# 「参加予定のイベント情報を取得する処理」が開始したことをログファイルに出力
$comment = '[' + $(Get-Date -Uformat %Y%m%d_%H:%M:%S) + '] 【DEBUG】「参加予定のイベント情報を取得する処理」の開始'
Add-Content -Path $createLogFilePath -Value $comment
# APIリクエストを生成
$requestUrl = $apiEndpoint + '?nickname=' + $nickname + '&order=' + $order
# 「参加予定のイベント情報を取得する処理」が開始したことをログファイルに出力
$comment = '[' + $(Get-Date -Uformat %Y%m%d_%H:%M:%S) + '] 【INFO】APIリクエスト：' + $requestUrl
Add-Content -Path $createLogFilePath -Value $comment
# APIからデータを取得
$response = Invoke-RestMethod -Uri $requestUrl
# イベントごとの区切りをログファイルに出力
$comment = '[' + $(Get-Date -Uformat %Y%m%d_%H:%M:%S) + '] -----------------------------------------------------------------------------'
Add-Content -Path $createLogFilePath -Value $comment
# 必要な情報を抽出して表示
foreach ($event in $response.events) {
    # スクリプトを待機
    Start-Sleep -Seconds 5  # 適切な待機時間を指定
    # Outlook COM オブジェクトを作成
    $app = New-Object -ComObject Outlook.Application
    # プロファイルを選択してログオン
    $namespace = $app.GetNamespace("MAPI");
    $namespace.Logon("Outlook");
    $overlap = $false
    # 「参加予定のイベント情報をOutlookに登録する反復処理」が開始したことをログファイルに出力
    $comment = '[' + $(Get-Date -Uformat %Y%m%d_%H:%M:%S) + '] 【DEBUG】参加予定のイベント情報を設定する反復処理の開始。'
    Add-Content -Path $createLogFilePath -Value $comment
    $now = Get-Date -Format 'yyyy/MM/dd'
    $requiredTime = New-TimeSpan ([DateTime]$event.started_at).ToString('yyyy/MM/dd HH:mm:ss') ([DateTime]$event.ended_at).ToString('yyyy/MM/dd HH:mm:ss')
    $requiredTime = $requiredTime.TotalMinutes
    $startedTime = ([DateTime]$event.started_at).ToString('yyyy-MM-dd HH:mm')
    $endedTime = ([DateTime]$event.ended_at).ToString('yyyy-MM-dd HH:mm')
    # イベントIDをログファイルに出力
    $comment = '[' + $(Get-Date -Uformat %Y%m%d_%H:%M:%S) + '] 【INFO】イベントID：' + $event.event_id
    Add-Content -Path $createLogFilePath -Value $comment
    # イベント名をログファイルに出力
    $comment = '[' + $(Get-Date -Uformat %Y%m%d_%H:%M:%S) + '] 【INFO】イベント名：' + $event.title
    Add-Content -Path $createLogFilePath -Value $comment
    # URLをログファイルに出力
    $comment = '[' + $(Get-Date -Uformat %Y%m%d_%H:%M:%S) + '] 【INFO】URL：' + $event.event_url
    Add-Content -Path $createLogFilePath -Value $comment
    # 開催場所をログファイルに出力
    $comment = '[' + $(Get-Date -Uformat %Y%m%d_%H:%M:%S) + '] 【INFO】開催場所：' + $event.place
    Add-Content -Path $createLogFilePath -Value $comment
    # 住所をログファイルに出力
    $comment = '[' + $(Get-Date -Uformat %Y%m%d_%H:%M:%S) + '] 【INFO】住所：' + $event.address
    Add-Content -Path $createLogFilePath -Value $comment
    # 開始日時をログファイルに出力
    $comment = '[' + $(Get-Date -Uformat %Y%m%d_%H:%M:%S) + '] 【INFO】開始日時：' + $startedTime
    Add-Content -Path $createLogFilePath -Value $comment
    # 終了日時をログファイルに出力
    $comment = '[' + $(Get-Date -Uformat %Y%m%d_%H:%M:%S) + '] 【INFO】終了日時：' + $endedTime
    Add-Content -Path $createLogFilePath -Value $comment
    # 予想所要時間をログファイルに出力
    $comment = '[' + $(Get-Date -Uformat %Y%m%d_%H:%M:%S) + '] 【INFO】予想所要時間：' + $requiredTime
    Add-Content -Path $createLogFilePath -Value $comment
    if (([DateTime]$event.started_at).ToString('yyyy/MM/dd') -lt $now) {
        # 処理対象のイベントが開催済みであることをログファイルに出力
        $comment = '[' + $(Get-Date -Uformat %Y%m%d_%H:%M:%S) + '] 【DEBUG】上記のイベント以前の予定に関しては開催済みです。'
        Add-Content -Path $createLogFilePath -Value $comment
        # 「参加予定のイベント情報をOutlookに登録する反復処理」が終了したことをログファイルに出力
        $comment = '[' + $(Get-Date -Uformat %Y%m%d_%H:%M:%S) + '] 【DEBUG】参加予定のイベント情報を設定する反復処理の終了。'
        Add-Content -Path $createLogFilePath -Value $comment
        # イベントごとの区切りをログファイルに出力
        $comment = '[' + $(Get-Date -Uformat %Y%m%d_%H:%M:%S) + '] -----------------------------------------------------------------------------'
        Add-Content -Path $createLogFilePath -Value $comment
        break;
    }
    else {
        # 「参加予定のイベント情報をOutlookに登録する反復処理」が終了したことをログファイルに出力
        $comment = '[' + $(Get-Date -Uformat %Y%m%d_%H:%M:%S) + '] 【DEBUG】参加予定のイベント情報を設定する反復処理の終了。'
        Add-Content -Path $createLogFilePath -Value $comment
        # 「Outlookに新規予定を保存する処理」が開始されたことをログファイルに出力
        $comment = '[' + $(Get-Date -Uformat %Y%m%d_%H:%M:%S) + '] 【DEBUG】Outlookに新規予定を保存する処理の開始。'
        Add-Content -Path $createLogFilePath -Value $comment
        # 「Outlookに既存の予定を取得する処理」が開始されたことをログファイルに出力
        $comment = '[' + $(Get-Date -Uformat %Y%m%d_%H:%M:%S) + '] 【DEBUG】既に同じ予定がOutlookに存在する場合の処理の開始。'
        Add-Content -Path $createLogFilePath -Value $comment
        # 既存の予定を取得
        $calendar = $app.Session.GetDefaultFolder(9)  # 9 は olFolderCalendar を表します
        $items = $calendar.Items
        # 予定の詳細を設定
        # タイトル
        $subject = $event.title
        # タイトルをログファイルに出力
        $comment = '[' + $(Get-Date -Uformat %Y%m%d_%H:%M:%S) + '] 【INFO】件名：' + $subject
        Add-Content -Path $createLogFilePath -Value $comment
        # 開始時刻
        $start = Get-Date $startedTime
        # 開始時刻をログファイルに出力
        $comment = '[' + $(Get-Date -Uformat %Y%m%d_%H:%M:%S) + '] 【INFO】開始時刻：' + $start
        Add-Content -Path $createLogFilePath -Value $comment
        # 期間
        $duration = $requiredTime  # 分単位で指定
        # 期間をログファイルに出力
        $comment = '[' + $(Get-Date -Uformat %Y%m%d_%H:%M:%S) + '] 【INFO】期間：' + $duration
        Add-Content -Path $createLogFilePath -Value $comment
        # 場所
        $location = $event.address
        # 場所をログファイルに出力
        $comment = '[' + $(Get-Date -Uformat %Y%m%d_%H:%M:%S) + '] 【INFO】場所：' + $location
        Add-Content -Path $createLogFilePath -Value $comment
        # 本文
        $body = 'イベントID：' + $event.event_id + 'イベント名：' + $subject + 'URL：' + $event.event_url + '開催場所：' + $event.place + '住所：' + $event.address + '開始日時：' + $startedTime + '終了日時：' + $endedTime
        # 本文をログファイルに出力
        $comment = '[' + $(Get-Date -Uformat %Y%m%d_%H:%M:%S) + '] 【INFO】本文：' + $body
        Add-Content -Path $createLogFilePath -Value $comment
        # 重複がある場合は処理を終了
        foreach ($item in $items) {
            if ($item.Class -eq 26 -and $item.Start -le $start.AddMinutes($duration) -and $item.End -ge $start -and $item.Subject -eq $event.title) {
                $overlap = $true
                break
            }
        }
        if ($overlap) {
            # 「Outlookに既存の予定があるため処理を終了する」ことをログファイルに出力
            $comment = '[' + $(Get-Date -Uformat %Y%m%d_%H:%M:%S) + '] 【DEBUG】Outlookに既存の予定があるため処理を終了します。'
            Add-Content -Path $createLogFilePath -Value $comment
            # イベント名をログファイルに出力
            $comment = '[' + $(Get-Date -Uformat %Y%m%d_%H:%M:%S) + '] 【INFO】イベント名：' + $event.title
            Add-Content -Path $createLogFilePath -Value $comment
            # URLをログファイルに出力
            $comment = '[' + $(Get-Date -Uformat %Y%m%d_%H:%M:%S) + '] 【INFO】URL：' + $event.event_url
            Add-Content -Path $createLogFilePath -Value $comment
            # 「Outlookに既存の予定を取得する処理」が終了されたことをログファイルに出力
            $comment = '[' + $(Get-Date -Uformat %Y%m%d_%H:%M:%S) + '] 【DEBUG】Outlookに既存の予定を取得する処理の終了。'
            Add-Content -Path $createLogFilePath -Value $comment
            # 「Outlookに新規予定を保存する処理」が終了されたことをログファイルに出力
            $comment = '[' + $(Get-Date -Uformat %Y%m%d_%H:%M:%S) + '] 【DEBUG】Outlookに新規予定を保存する処理の終了。'
            Add-Content -Path $createLogFilePath -Value $comment
        }
        else {
            # 「Outlookに既存の予定を取得する処理」が終了されたことをログファイルに出力
            $comment = '[' + $(Get-Date -Uformat %Y%m%d_%H:%M:%S) + '] 【DEBUG】同じ予定が存在しなかったため、「既に同じ予定がOutlookに存在する場合の処理」を終了し、「Outlookに新規予定を保存する処理」を続行します。'
            Add-Content -Path $createLogFilePath -Value $comment
            # 重複がない場合は新しい予定を作成
            $appointment = $app.CreateItem(1)  # 1 は olAppointmentItem を表します
            # タイトル
            $appointment.Subject = $subject
            # 開始時刻
            $appointment.Start = $start
            # 終了時刻
            $appointment.End = $endedTime
            # 場所
            $appointment.Location = $location
            # 本文
            $appointment.Body = $body
            # 新しい予定を保存
            $appointment.Save()
        }
    }
    # スクリプトを待機
    Start-Sleep -Seconds 5  # 適切な待機時間を指定
    # Outlook COM オブジェクトを解放
    [System.Runtime.Interopservices.Marshal]::ReleaseComObject($app) | Out-Null
    $app = $null
    # 「Outlookに新規予定を保存する処理」が終了されたことをログファイルに出力
    $comment = '[' + $(Get-Date -Uformat %Y%m%d_%H:%M:%S) + '] 【DEBUG】Outlookに新規予定を保存する処理の終了。'
    Add-Content -Path $createLogFilePath -Value $comment
    # イベントごとの区切りをログファイルに出力
    $comment = '[' + $(Get-Date -Uformat %Y%m%d_%H:%M:%S) + '] -----------------------------------------------------------------------------'
    Add-Content -Path $createLogFilePath -Value $comment
    # Outlook のプロセスを終了する
    Stop-Process -Name OUTLOOK -Force
}


# 処理が完了したことをメール通知するとログファイルに出力
$comment = '[' + $(Get-Date -Uformat %Y%m%d_%H:%M:%S) + '] 【DEBUG】メール通知処理が開始しました。'
Add-Content -Path $createLogFilePath -Value $comment
$sendMailJsonData = @{
    'ApiVersion' = $apiVersion
    'ApiKey'     = $apiKey
    'To'         = $toMailAddress
    'Title'      = $mailTitle
    'Body'       = $mailBody
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