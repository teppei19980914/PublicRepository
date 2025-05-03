
#関数mainの呼び出し
main

#メイン処理
function main () {

#実行時点の年月日
$ToDay = Get-Date -UFormat "%Y%m%d"
    
    #SCVファイルの格納場所
    $fromPath = 'C:\OutputData\' + $ToDay

    #SCVファイルの取込場所
    $toPath = 'http://{サーバー名}/api/items/{サイトID}/upsert'

    #APIキー
    $apiKey = 'a0415…'

    #フォルダ内のCSVファイルを絞り込み
    $csvFiles = Get-ChildItem $fromPath -Filter *.Csv

    #行番号の初期値設定
    $number = 1

    #それぞれのCSVファイルごとの処理
    foreach ($csvFile in $csvFiles) {

        #ファイルが変わるごとに行番号を初期化
        $number = 1

        #1つのCSVファイルを読み込む
        $products = Import-Csv ($fromPath + '\' + $csvFile)

        #CSVファイルの中身を処理
        foreach ($product in $products) {

            #行をカウント
            $number = $number + 1

            #自動取込する情報を取得
            $serialnumber = $product.serialnumber
            $date = $product.'Config取得日付(最新)'
            $imagePath = $product.Configイメージパス

            #JSONの中身
            $jsonData = @{
                "ApiVersion"      = 1.1
                "ApiKey"          = $apiKey
                "Keys"            = @("ClassB", "DateA", "DescriptionA")
                "ClassHash"       = @{
                    "ClassB" = $serialnumber
                }
                "DateHash"        = @{
                    "DateA" = $date
                }
                "DescriptionHash" = @{
                    "DescriptionA" = $imagePath
                }
            }

            #テキスト形式に変換
            $json = $jsonData | ConvertTo-Json

            try {

                #WEBページにリクエストを送る処理
                $responseData = Invoke-WebRequest -Uri $toPath -ContentType "application/json" -Method 'Post' -Body $json
        
            }
            catch {

                #CSVを取り込む際のエラー通知処理
                Write-Output 'CSV取り込み処理でエラーが発生しました'
        
                #エラー情報を取得
                $errorInfo = $csvFile.Name + ', ' + $number + ', ' + $serialnumber
        
                #関数errorの呼び出し
                error $apiKey $errorInfo
        
            }

        }
    }
}

#エラー発生時に呼び出される関数
function error ($apiKey, $errorInfo) {

    #エラーログの取込場所
    $toPath1 = 'http://{サーバー名}/api/items/{サイトID}/upsert'

    #JSONの中身
    $jsonData1 = @{
        "ApiVersion"      = 1.1
        "ApiKey"          = $apiKey
        "Keys"            = @("DescriptionA")
        "DescriptionHash" = @{
            "DescriptionA" = $errorInfo
        }
    }

    #テキスト形式に変換
    $json1 = $jsonData1 | ConvertTo-Json

    #プリザンターで表示時に文字化けしないようにUTF-8にエンコーディング
    $convertBody = [System.Text.Encoding]::UTF8.GetBytes($json1)

    #WEBページにアクセスし応答を代入
    $responseData = Invoke-RestMethod -Uri $toPath1 -ContentType "application/json" -Method POST -Body $convertBody

}

