// クライアントスクリプト
try {
    // my-row-buttonがクリックされたときのイベント
    $(document).on('click', '.my-row-button', function (event) {
        // レコードのIDをコンソールに出力
        $p.apiDelete({
        id: $(this).data('id'),
        done: function (data) {
            location.reload();
        }
    });
        // 編集画面が開かないようにイベントの伝搬を停止
        event.stopImmediatePropagation();
    });
} catch (ex) {
    console.log(ex.stack)
}