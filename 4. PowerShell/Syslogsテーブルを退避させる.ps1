# 今月の月を取得
$toMonth = Get-Date -UFormat "%Y%m"

# Csvファイルの格納Path
$toPath = 'XXXX'

# SCVファイル名
$fileName = 'syslog' + $toMonth + '.csv'

# Csvファイルの格納場所
$filePath = $toPath + '\' + $fileName

# RetentionPeriodの設定
$retentionPeriod = XX

# 接続情報の作成
$connectionInfo = New-Object -TypeName System.Data.SqlClient.SqlConnectionStringBuilder
$connectionInfo['Database'] = 'XXXX'
$connectionInfo['Integrated Security'] = 'TRUE'
$connectionInfo['User ID'] = 'XXXX'
$connectionInfo['Password'] = 'XXXX'

# 起点月を取得
$fromDate = Get-Date (Get-Date).AddDays(-$retentionPeriod) -Format "yyyy/MM/dd"

# SELECT文の作成
$selectQuery = "select * from [dbo].[SysLogs] where CreatedTime < '${fromDate}'"

# SQLConnectionとSQLCommandを設定する
$sqlConnection = New-Object System.Data.SQLClient.SQLConnection($connectionInfo)
$sqlCommand = New-Object System.Data.SQLClient.SQLCommand($selectQuery, $sqlConnection)

# データベース接続
$sqlConnection.Open()

# ExecuteReaderメソッドを呼び出す
$reader = $sqlCommand.ExecuteReader()

# ExecuteReaderメソッドのプロパティを使用
$fielsCounts = $reader.FieldCount

# 次の行が存在するときは処理を続行
while ( $reader.Read() ) {
    
    # 連想配列(ハッシュテーブル)を定義(第二引数は型が固定ではないためPSObject)
    $dictionary = @{}

    # 列数分処理を続行
    for ($i = 0; $i -lt $fielsCounts; $i++) {

        # 連想配列にkeyとvalueを追加していく(valueは文字列なので、ToString()で文字列にキャスト)
        $dictionary.Add($reader.GetName($i), $reader.GetValue($i).ToString())
    }
    
    # テーブル1行分をCsvファイルに出力
    [PSCustomObject]$dictionary | Export-Csv -Path $filePath -Append
}

# $readerを閉じる
$reader.Close()

# DELETE文の作成
$deleteQuery = "delete from [dbo].[SysLogs] where CreatedTime < '${fromDate}'"

# SQLCommandを設定する
$sqlCommand = New-Object System.Data.SQLClient.SQLCommand($deleteQuery, $sqlConnection)

# ExecuteNonQueryメソッドを呼び出す
$sqlCommand.ExecuteNonQuery()

# $readerを閉じる
$reader.Close()

# データベース接続解除
$sqlConnection.Close()