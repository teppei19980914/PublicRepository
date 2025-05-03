$p.events.on_grid_load = function () {
    try {
        // リンク列にリンクを設定
        let table = document.getElementById('Grid');
        let colNum = $p.getGridColumnIndex('ClassB');
        for (let row of table.rows) {
            console.log(row.className);
            if (row.className === 'grid-row') {
                let urlText = row.cells[colNum].textContent;
                const a1 = document.createElement("a");
                a1.href = urlText;
                a1.target = "_blank";
                a1.innerText = urlText;
                row.cells[colNum].textContent = "";
                row.cells[colNum].appendChild(a1);
            }
        }
    } catch (ex) {
        console.log(ex.stack);
    }
}