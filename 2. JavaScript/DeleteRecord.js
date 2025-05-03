$p.ex.execDeleteRecord = function () {
    const siteId = 0;
    try {
        // レコードのIDをコンソールに出力
        $p.apiDelete({
            id: $p.id(),
            done: function (data) {
                window.location.href = 'https://pleasanter.net/fs/items/' + siteId + '/index'
            }
        });
    } catch (ex) {
        console.log(ex.stack)
    }
}