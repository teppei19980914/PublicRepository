# プログラムの処理速度を計測
$processingSpeed = (Measure-Command {

<#
*********************************************
変数定義箇所
環境に合わせて適宜設定してください。
*********************************************
#>

<#
ログファイルに関する変数定義
#>

# ログファイルを削除する期間を定義(日にち単位)
# 例) 18日 17:00に実行し、かつ「4」を指定した場合、14日の16:59以前のファイルが削除されます
$deletLogPeriod = 4
# ログファイルの格納ディレクトリのPathを定義
$toPath = 'XXXX'

<#
データベースに関する変数定義
#>

# データベース名を定義
$databaseName = 'XXXX'
# Windows統合認証を定義(TRUE:有効化, FALSE:無効化)
$integratedSecurity = 'XXXX'
# ユーザIDを定義
$userId = 'XXXX'
# パスワードを定義
$password = 'XXXX'

<#
SQL文に関する変数定義
#>

# AD連携ユーザを登録するグループを定義
$groupId = 7
# ドメインを定義
$domain = 'XXX.XX'
# Creatorの定義
$creator = 1
# Updatorの定義
$updator = 1
# Adminの定義
$admin = 0



<#
*********************************************
ロジック箇所
ここから先はプログラムのため修正不要です。
*********************************************
#>

<#
ログファイルに関する変数定義
#>

# 現在日時を取得
$dateLogFile = Get-Date -Format "yyyyMMddHHmmss"
# ログファイル名を定義
$fileName = 'log' + $dateLogFile
# ログファイルの格納場所を定義
$filePath = $toPath + '\' + $fileName + '.log'

<#
SQL文に関する変数定義
#>

# 組織IDの定義
$deptId = 0
# verの定義
$ver = 0
# Commentsの定義
$comments = ''
# SQL文3のLIKE句の定義
$like = '%@' + $domain
try {
    # 指定のフォルダが存在する場合の処理
    if (Test-Path $toPath) {

        # 同名のログファイルが存在しない場合の処理
        if ( - !(Test-Path $filePath)) {

            # 空のログファイルを新規作成
            Out-File $filePath

            # ログファイルが作成されたことをログファイルに出力
            $comment = '[' + $(Get-Date -Uformat %Y%m%d_%H:%M:%S) + '] 【INFO】ログファイルが作成されました。作成ファイル：' + $filePath
            Add-Content -Path $filePath -Value $comment

            # スクリプトを実行する事をログファイルに出力
            $comment = '[' + $(Get-Date -Uformat %Y%m%d_%H:%M:%S) + '] 【DEBUG】スクリプトの実行開始'
            Add-Content -Path $filePath -Value $comment

        }
        # 同名のログファイルが存在する場合の処理
        else {

            # ログファイルに追記する場合のログ開始位置がわかるようにログファイルに出力
            $comment = '------------------------------------'
            Add-Content -Path $filePath -Value $comment

            # スクリプトを実行する事をログファイルに出力
            $comment = '[' + $(Get-Date -Uformat %Y%m%d_%H:%M:%S) + '] 【DEBUG】スクリプトの実行開始'
            Add-Content -Path $filePath -Value $comment
        }
    }
    # 指定のフォルダが存在しない場合の処理
    else {

        # 指定のフォルダが存在しない旨、コンソールに出力
        $comment = '指定のフォルダが存在しません。指定のフォルダ：' + $toPath
        write-host $comment

        exit

    }

    $comment = '[' + $(Get-Date -Uformat %Y%m%d_%H:%M:%S) + '] 【DEBUG】ファイルの削除処理開始'
    Add-Content -Path $filePath -Value $comment

    # 過去のログファイルの削除処理を開始
    $comment = '[' + $(Get-Date -Uformat %Y%m%d_%H:%M:%S) + '] 【INFO】削除対象ファイル：今日から' + $deletLogPeriod + '日以前のファイル'
    Add-Content -Path $filePath -Value $comment

    # 過去のログファイルを削除
    Get-ChildItem $toPath -Recurse | Where-Object { $_.CreationTime -lt (Get-Date).AddDays(-$deletLogPeriod) } | Remove-Item -Force

    # 過去のログファイルの削除処理を終了
    $comment = '[' + $(Get-Date -Uformat %Y%m%d_%H:%M:%S) + '] 【DEBUG】ファイルの削除処理終了'

    # ログファイルの出力開始
    Add-Content -Path $filePath -Value $comment
    $comment = '[' + $(Get-Date -Uformat %Y%m%d_%H:%M:%S) + '] 【DEBUG】ログファイル出力開始'
    Add-Content -Path $filePath -Value $comment

    # 接続情報の作成
    # 接続情報変数を生成
    $connectionString = New-Object -TypeName System.Data.SqlClient.SqlConnectionStringBuilder

    # 接続文字列の生成処理開始
    $comment = '[' + $(Get-Date -Uformat %Y%m%d_%H:%M:%S) + '] 【DEBUG】接続文字列の生成処理開始'
    Add-Content -Path $filePath -Value $comment

    # データベース名を設定
    $connectionString['Database'] = $databaseName

    # データベース名をログファイルに出力
    $comment = '[' + $(Get-Date -Uformat %Y%m%d_%H:%M:%S) + '] 【INFO】データベース名 ：' + $databaseName
    Add-Content -Path $filePath -Value $comment

    # Windows統合認証を設定
    $connectionString['Integrated Security'] = $integratedSecurity

    # Windows統合認証をログファイルに出力
    $comment = '[' + $(Get-Date -Uformat %Y%m%d_%H:%M:%S) + '] 【INFO】Windows統合認証：' + $integratedSecurity
    Add-Content -Path $filePath -Value $comment

    # ユーザIDを設定
    $connectionString['User ID'] = $userId

    # パスワードを設定
    $connectionString['Password'] = $password

    # 接続文字列の生成処理終了
    $comment = '[' + $(Get-Date -Uformat %Y%m%d_%H:%M:%S) + '] 【DEBUG】接続文字列の生成処理終了'
    Add-Content -Path $filePath -Value $comment

    # SQL文の作成
    # SQL文1:指定されたグループの存在可否
    $selectGroupQuery = "
        select Count(*) from [" + $databaseName + "].[dbo].[Groups] where [GroupId] = '${groupId}';
    "
    # SQL文2:指定されたユーザの存在可否
    $selectUserQuery = "
        select Count(*) from [" + $databaseName + "].[dbo].[MailAddresses]
               where [MailAddress] like '${like}'
               and [OwnerId] in
               (
                   select [UserId]
                   from [" + $databaseName + "].[dbo].[Users]
                   where [Disabled] = 0
               );
    "
    # SQL文3:特定のグループのメンバーを一括削除する
    $deleteQuery = "
        delete from [" + $databaseName + "].[dbo].[GroupMembers] where [GroupId] = '${groupId}';
    "
    # SQL文4:無効でない、かつメールアドレスが特定のドメインのユーザーをグループのメンバーに挿入する
    $insertQuery = "
        insert into [" + $databaseName + "].[dbo].[GroupMembers]
        (
            [GroupId]
            ,[DeptId]
            ,[UserId]
            ,[Ver]
            ,[Admin]
            ,[Comments]
            ,[Creator]
            ,[Updator]
        )
            select DISTINCT
               '${groupId}'
               ,'${deptId}'
               ,[OwnerId]
               ,'${ver}'
               ,'${admin}'
               ,'${comments}'
               ,'${creator}'
               ,'${updator}'
               from [" + $databaseName + "].[dbo].[MailAddresses]
               where [MailAddress] like '${like}'
               and [OwnerId] in
               (
                   select [UserId]
                   from [" + $databaseName + "].[dbo].[Users]
                   where [Disabled] = 0
               );
    "
    # SQLコネクションの設定開始
    $comment = '[' + $(Get-Date -Uformat %Y%m%d_%H:%M:%S) + '] 【DEBUG】SQLコネクションの設定開始'
    Add-Content -Path $filePath -Value $comment

    # コネクション情報の設定
    $sqlConnection = New-Object System.Data.SQLClient.SQLConnection($connectionString)

    # コネクション情報をログファイルに出力
    $comment = '[' + $(Get-Date -Uformat %Y%m%d_%H:%M:%S) + '] 【INFO】SQLコネクションが設定されました。'
    Add-Content -Path $filePath -Value $comment

    # SQLコネクションの設定終了
    $comment = '[' + $(Get-Date -Uformat %Y%m%d_%H:%M:%S) + '] 【DEBUG】SQLコネクションの設定終了'
    Add-Content -Path $filePath -Value $comment

    # SQLコマンドの設定開始
    $comment = '[' + $(Get-Date -Uformat %Y%m%d_%H:%M:%S) + '] 【DEBUG】SQLコマンドの設定開始'
    Add-Content -Path $filePath -Value $comment

    # SQL文1を設定
    $selectGroupSqlCommand = New-Object System.Data.SQLClient.SQLCommand($selectGroupQuery, $sqlConnection)

    # SQL文1をログファイルに出力
    $comment = '[' + $(Get-Date -Uformat %Y%m%d_%H:%M:%S) + '] 【INFO】GroupsのSELECT文：' + $selectGroupQuery
    Add-Content -Path $filePath -Value $comment

    # SQL文2を設定
    $selectUserSqlCommand = New-Object System.Data.SQLClient.SQLCommand($selectUserQuery, $sqlConnection)

    # SQL文2をログファイルに出力
    $comment = '[' + $(Get-Date -Uformat %Y%m%d_%H:%M:%S) + '] 【INFO】MailAddressのSELECT文：' + $selectUserQuery
    Add-Content -Path $filePath -Value $comment

    # SQL文3を設定
    $deleteSqlCommand = New-Object System.Data.SQLClient.SQLCommand($deleteQuery, $sqlConnection)

    # SQL文3をログファイルに出力
    $comment = '[' + $(Get-Date -Uformat %Y%m%d_%H:%M:%S) + '] 【INFO】GroupMembersのDELETE文：' + $deleteQuery
    Add-Content -Path $filePath -Value $comment

    # SQL文4を設定
    $insertSqlCommand = New-Object System.Data.SQLClient.SQLCommand($insertQuery, $sqlConnection)

    # SQL文4をログファイルに出力
    $comment = '[' + $(Get-Date -Uformat %Y%m%d_%H:%M:%S) + '] 【INFO】GroupMembersのINSERT文：' + $insertQuery
    Add-Content -Path $filePath -Value $comment

    # SQLコマンドの設定終了
    $comment = '[' + $(Get-Date -Uformat %Y%m%d_%H:%M:%S) + '] 【DEBUG】SQLコマンドの設定終了'
    Add-Content -Path $filePath -Value $comment

    # データベースの接続処理開始
    $comment = '[' + $(Get-Date -Uformat %Y%m%d_%H:%M:%S) + '] 【DEBUG】データベースの接続処理開始'
    Add-Content -Path $filePath -Value $comment

    # データベース接続
    $sqlConnection.Open()

    # データベース接続開始をログファイルに出力
    $comment = '[' + $(Get-Date -Uformat %Y%m%d_%H:%M:%S) + '] 【INFO】データベースの接続を開始しました。'
    Add-Content -Path $filePath -Value $comment

    # データベースの接続処理終了
    $comment = '[' + $(Get-Date -Uformat %Y%m%d_%H:%M:%S) + '] 【DEBUG】データベースの接続処理終了'
    Add-Content -Path $filePath -Value $comment

    # トランザクションの設定処理スタート
    $comment = '[' + $(Get-Date -Uformat %Y%m%d_%H:%M:%S) + '] 【DEBUG】トランザクションの設定処理開始'
    Add-Content -Path $filePath -Value $comment

    # トランザクションの設定
    $transaction = $SqlConnection.BeginTransaction()

    # トランザクションが開始されたことをログファイルに出力
    $comment = '[' + $(Get-Date -Uformat %Y%m%d_%H:%M:%S) + '] 【INFO】トランザクションが開始されました。'
    Add-Content -Path $filePath -Value $comment

    # トランザクションの設定処理終了
    $comment = '[' + $(Get-Date -Uformat %Y%m%d_%H:%M:%S) + '] 【DEBUG】トランザクションの設定処理終了'
    Add-Content -Path $filePath -Value $comment

    # 各コマンドへのトランザクションの割り当て処理開始
    $comment = '[' + $(Get-Date -Uformat %Y%m%d_%H:%M:%S) + '] 【DEBUG】トランザクションの割り当て処理開始'
    Add-Content -Path $filePath -Value $comment

    # SQL文1にトランザクションの割り当てを設定
    $selectGroupSqlCommand.Transaction = $transaction

    # SQL文2にトランザクションの割り当てを設定
    $selectUserSqlCommand.Transaction = $transaction

    # SQL文3にトランザクションの割り当てを設定
    $deleteSqlCommand.Transaction = $transaction

    # SQL文4にトランザクションの割り当てを設定
    $insertSqlCommand.Transaction = $transaction

    # トランザクションが割り当てられたことをログファイルに出力
    $comment = '[' + $(Get-Date -Uformat %Y%m%d_%H:%M:%S) + '] 【INFO】トランザクションがSQL文に割り当てられました。'
    Add-Content -Path $filePath -Value $comment

    # 各コマンドへのトランザクションの割り当て処理終了
    $comment = '[' + $(Get-Date -Uformat %Y%m%d_%H:%M:%S) + '] 【DEBUG】トランザクションの割り当て終了'
    Add-Content -Path $filePath -Value $comment

    try {
        # SQL文1を発行
        $selectGroupCount = $selectGroupSqlCommand.ExecuteScalar()

        # Groupsテーブルに指定したグループが存在していない場合
        if ($selectGroupCount -eq 0) {

            # 処理を終了する旨ログに出力
            $comment = '[' + $(Get-Date -Uformat %Y%m%d_%H:%M:%S) + '] 【ERROR】指定されたグループは存在しません。'
            Add-Content -Path $filePath -Value $comment

            throw '【ERROR】正しいグループを指定してください。指定のグループID：' + $groupId

        }
        # Groupsテーブルに指定したグループが存在している場合
        else {

            # 処理を続行する旨ログに出力
            $comment = '[' + $(Get-Date -Uformat %Y%m%d_%H:%M:%S) + '] 【INFO】指定されたグループは存在しています。指定のグループID：' + $groupId
            Add-Content -Path $filePath -Value $comment

        }

        # SQL文2を発行
        $selectUserCount = $selectUserSqlCommand.ExecuteScalar()

        # Groupsテーブルに指定したユーザが存在していない場合
        if ($selectUserCount -eq 0) {

            # 処理を終了する旨ログに出力
            $comment = '[' + $(Get-Date -Uformat %Y%m%d_%H:%M:%S) + '] 【ERROR】指定されたドメインを持つユーザは存在しません。'
            Add-Content -Path $filePath -Value $comment

            throw '【ERROR】正しいドメインを指定してください。指定のドメイン：@' + $domain

        }
        # MailAddressテーブルに指定したドメインを持つユーザが存在している場合
        else {

            # 処理を続行する旨ログに出力
            $comment = '[' + $(Get-Date -Uformat %Y%m%d_%H:%M:%S) + '] 【INFO】指定されたドメインを持つユーザは存在しています。指定されたドメイン：@' + $domain
            Add-Content -Path $filePath -Value $comment

        }

        # SQL実行開始
        $comment = '[' + $(Get-Date -Uformat %Y%m%d_%H:%M:%S) + '] 【DEBUG】SQL実行開始'
        Add-Content -Path $filePath -Value $comment

        # 処理を開始することをログファイルに出力
        $comment = '[' + $(Get-Date -Uformat %Y%m%d_%H:%M:%S) + '] 【INFO】処理を開始します。'
        Add-Content -Path $filePath -Value $comment

        # SQL文3を発行
        $deleteCount = $deleteSqlCommand.ExecuteNonQuery()

        # SQL文3の実行結果を出力
        $comment = '[' + $(Get-Date -Uformat %Y%m%d_%H:%M:%S) + '] 【INFO】GroupMembersのDELETE文の実行結果：' + $deleteCount + '件'
        Add-Content -Path $filePath -Value $comment

        # SQL文4を発行
        $insertCount = $insertSqlCommand.ExecuteNonQuery()

        # SQL文4の実行結果を出力
        $comment = '[' + $(Get-Date -Uformat %Y%m%d_%H:%M:%S) + '] 【INFO】GroupMembersのINSERT文の実行結果：' + $insertCount + '件'
        Add-Content -Path $filePath -Value $comment

        # コミットの実行
        $transaction.Commit()

        # 処理がコミットされたことをログファイルに出力
        $comment = '[' + $(Get-Date -Uformat %Y%m%d_%H:%M:%S) + '] 【INFO】処理が正常終了しました。'
        Add-Content -Path $filePath -Value $comment

        # SQL正常終了
        $comment = '[' + $(Get-Date -Uformat %Y%m%d_%H:%M:%S) + '] 【DEBUG】SQL正常終了'
        Add-Content -Path $filePath -Value $comment
    }
    catch {

        # ロールバック
        $transaction.Rollback()

        # スクリプトの処理でのエラー内容をログファイルに出力
        $comment = '[' + $(Get-Date -Uformat %Y%m%d_%H:%M:%S) + '] ' + $error[0]
        Add-Content -Path $filePath -Value $comment

        # 処理がロールバックされたことをログファイルに出力
        $comment = '[' + $(Get-Date -Uformat %Y%m%d_%H:%M:%S) + '] 【ERROR】SQL文の発行エラーによって異常終了しました。'
        Add-Content -Path $filePath -Value $comment

        # SQL異常終了
        $comment = '[' + $(Get-Date -Uformat %Y%m%d_%H:%M:%S) + '] 【DEBUG】SQL異常終了'
        Add-Content -Path $filePath -Value $comment
    }
    finally {

        # データベース接続解除
        $SqlConnection.Close()

        # ファイルが存在した場合の処理
        if (Test-Path $filePath) {

            # データベース接続終了をログファイルに出力
            $comment = '[' + $(Get-Date -Uformat %Y%m%d_%H:%M:%S) + '] 【INFO】データベースの接続を解除しました。'
            Add-Content -Path $filePath -Value $comment

            # データベースの接続終了
            $comment = '[' + $(Get-Date -Uformat %Y%m%d_%H:%M:%S) + '] 【DEBUG】データベースの接続終了'
            Add-Content -Path $filePath -Value $comment

        }
    }
}
catch {

    # スクリプトの処理でのエラー内容をログファイルに出力
    $comment = '[' + $(Get-Date -Uformat %Y%m%d_%H:%M:%S) + '] ' + $error[0]
    Add-Content -Path $filePath -Value $comment

    # スクリプトの処理でエラーが発生したことをログファイルに出力
    $comment = '[' + $(Get-Date -Uformat %Y%m%d_%H:%M:%S) + '] 【ERROR】：スクリプトの実行エラーによって異常終了しました。'
    Add-Content -Path $filePath -Value $comment

    # スクリプトの実行エラーによって異常終了
    $comment = '[' + $(Get-Date -Uformat %Y%m%d_%H:%M:%S) + '] 【DEBUG】スクリプト異常終了'
    Add-Content -Path $filePath -Value $comment
}
finally {

    # 指定のフォルダが存在しない場合の処理
    if ( - !(Test-Path $toPath)) {

        exit
    }

    # 全ての処理が終了したことをログファイルに出力
    $comment = '[' + $(Get-Date -Uformat %Y%m%d_%H:%M:%S) + '] 【INFO】全ての処理が終了しました。'
    Add-Content -Path $filePath -Value $comment

    # 全ての処理が終了
    $comment = '[' + $(Get-Date -Uformat %Y%m%d_%H:%M:%S) + '] 【DEBUG】全ての処理終了'
    Add-Content -Path $filePath -Value $comment
}
}).TotalMilliseconds

# プログラムの処理速度をログファイルに出力
$comment = '[' + $(Get-Date -Uformat %Y%m%d_%H:%M:%S) + '] 【DEBUG】処理速度(ミリ秒)' + $processingSpeed
Add-Content -Path $filePath -Value $comment