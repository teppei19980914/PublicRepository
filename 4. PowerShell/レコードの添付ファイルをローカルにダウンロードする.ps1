#ダウンロード先Path(「C:\work」のように指定)
$toPath = "XXXX"

#ダウンロード元uri(スキーマ+ドメイン「http://localhost」のように指定)
#$baseUri = "http://localhost/api/items/2/get"
$baseUri = "XXXX"

#Offsetを初期化
$offSet = 0

#ファイルをダウンロードする処理
do {

    #JSONの中身
    $jsonData = @{
        "ApiVersion" = 1.1
        "ApiKey" = "a0415…"
        "Offset" = $offSet
    }

    #テキスト形式に変換
    $json = $jsonData|ConvertTo-Json

    #URIを設定
    $itemUri = $baseUri + "/api/items/2/get"

    #WEBページにアクセスし応答を代入
    $responseData = Invoke-WebRequest -Uri $itemUri -ContentType "application/json" -Method 'Post' -Body $json

    #処理で使う情報の1階層上までを代入
    $response = ($responseData.Content|ConvertFrom-Json).Response

    #1ページあたりに保有できるレコード数を代入
    $pageSize = $response.PageSize

    #テーブルに記録されている全レコード数を代入
    $totalCount = $response.TotalCount

    #レコード情報を代入
    $records = $response.Data

    #レコード単位の反復処理
    foreach ($record in $records) {

        #レコードのResultIdを代入
        $id = $record.ResultId

        #ダウンロード先フォルダパスを代入
        $folderPath = $toPath + "\" + $id

        #フォルダが存在しない場合処理を続行
        if (-not(Test-Path $folderPath)) {

            #ダウンロード先フォルダを作成
            New-Item -Path $folderPath -Type Directory

        #フォルダが存在する場合
        } else {

            write-host "フォルダが存在します"

        }

        #応答のAttachmentsHashの中身を代入
        $recordLinks = $record.AttachmentsHash

        #データ単位の反復処理
        foreach ($recordLink in $recordLinks){

            #AttachmentsAの中身を代入
            $attachments = $recordLink.AttachmentsA

            #ファイル単位の反復処理
            foreach ($attachment in $attachments) {

                #ファイル名を代入
                $name = $attachment.Name

                #Guidを代入
                $guId = $attachment.Guid

                #ダウンロード元にファイルが存在していれば処理を続行
                if (-not($name -eq $null)) {

                    #GUIDをもとにダウンロード元Pathを代入
                    $uri = $baseUri + "/api/binaries/" + $guId + "/get"

                    #WEBページにアクセスし応答を代入
                    $responseData = Invoke-WebRequest -Uri $uri -ContentType "application/json" -Method 'Post' -Body $json

                    #各ファイルのBase64を代入
                    $base64 = ($responseData.Content|ConvertFrom-Json).Response.Base64

                    #$base64をデコード
                    $byte = [System.Convert]::FromBase64String($base64)

                    #出力先のファイル名を代入
                    $toFileName = $toPath + "\" + $id + "\" + $name

                    #ファイルが存在しない場合処理を続行
                    if (-not(Test-Path $toFileName)) {

                        #ファイルをダウンロード先に作成
                        New-Item -Path $folderPath -Name $name -Type File

                        #ダウンロード先のファイルに$srcを書き込む
                        [System.IO.File]::WriteAllBytes($folderPath + "\" + $name,$byte)

                    #ファイルが存在する場合
                    } else {

                        Write-Host "ファイルが存在します"

                    }
                }
            }
        }
    }
    $offSet = $offSet + $pageSize
} while ($totalCount -ge $offSet)

write-host "ダウンロードが完了いたしました"