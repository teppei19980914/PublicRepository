(function () {
    // テーブルの種類を指定（期限付きテーブルの場合はIssues、記録テーブルの場合はResults）
    var tableType = 'Results';
    // 差分を確認したい項目IDと表示名を指定
    var targetColumnId = 'Body';
    var targetColumnName = '内容';
    // 編集前と編集後の値を格納する変数
    var value1 = '';
    var value2 = '';
    // 外部ライブラリの読み込み（jsdiff／diff2html）
    var script1 = document.createElement('script');
    var script2 = document.createElement('script');
    var script3 = document.createElement('script');
    var css1 = document.createElement('link');
    script1.src = 'https://cdnjs.cloudflare.com/ajax/libs/jsdiff/3.4.0/diff.min.js';
    script2.src = 'https://cdnjs.cloudflare.com/ajax/libs/diff2html/2.3.3/diff2html.min.js';
    script3.src = 'https://cdnjs.cloudflare.com/ajax/libs/diff2html/2.3.3/diff2html-ui.min.js';
    css1.setAttribute('rel', 'stylesheet');
    css1.setAttribute('type', 'text/css');
    css1.setAttribute('href', 'https://cdnjs.cloudflare.com/ajax/libs/diff2html/2.3.3/diff2html.min.css');
    document.body.appendChild(script1);
    document.body.appendChild(script2);
    document.body.appendChild(script3);
    document.body.appendChild(css1);
    // 編集画面ロード時の値を取得する
    $p.events.on_editor_load = function () {
        value1 = $p.getControl(targetColumnId).val();
    };
    // 対象項目を変更したタイミングで値を取得して差分を表示する
    $(document).on('change', '#' + tableType + '_' + targetColumnId, function () {
        value2 = $p.getControl(targetColumnId).val();
        diff2html();
    });
    // 編集画面の下部に対象項目の編集前後の差分を表示する関数
    function diff2html() {
        $('#diff2html').remove();
        $("#Editor").after('<div id="diff2html" style="display:inline-block;"></div>');
        $('#diff2html').css("width","calc(100% - 250px)");
        html = '<div id="app">';
        $('#diff2html').append(html);
        unifiedDiff = JsDiff.createPatch(targetColumnName, value1, value2, 'before', 'after');
        diff2htmlUi = new Diff2HtmlUI({diff: unifiedDiff});
        diff2htmlUi.draw('#app', {inputFormat: 'json', outputFormat: 'side-by-side', matching: 'lines'});
    };
})();