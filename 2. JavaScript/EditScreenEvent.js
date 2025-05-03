$p.events.on_editor_load = function () {
    try {
        // 常に新バージョンとして保存をオン
        let verup = $("#VerUp");
        verup.prop('checked', true);

        // リンクボタンの表示
        $('#Results_ClassBField').after('<button type="button" style="display:block;float:left;height:30px;padding:7px 12px;border:solid 1px silver;background-color:white;" onclick="Transition()">リンク</button>');
    } catch (ex) {
        console.log(ex.stack);
    }
};
function Transition() {
    open($p.getControl('ClassB').val());
}