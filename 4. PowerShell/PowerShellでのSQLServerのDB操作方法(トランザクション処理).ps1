# 接続情報の作成
$connectionString = New-Object -TypeName System.Data.SqlClient.SqlConnectionStringBuilder
$connectionString['Database'] = 'XXXX'
$connectionString['Integrated Security'] = 'TRUE'
$connectionString['User ID'] = 'XXXX'
$connectionString['Password'] = 'XXXX'

# SQL文の作成
$query = "Query"

# SQLConnectionとSQLCommandを設定する
$sqlConnection = New-Object System.Data.SQLClient.SQLConnection($connectionString)
$sqlCommand = New-Object System.Data.SQLClient.SQLCommand($query, $sqlConnection)

# データベース接続
$sqlConnection.Open()

# トランザクションスタート
$transaction = $SqlConnection.BeginTransaction()

# コマンドにトランザクションを割り当てる
$SqlCommand.Transaction = $transaction

try {
    # 処理の実装

} catch {
    # ロールバック
    $transaction.Rollback()
} finally {
    # データベース接続解除
    $SqlConnection.Close()
}