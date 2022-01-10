// 当 删除该期刊 点下，弹窗
var btn = $('#delete');
btn.on('click', function () {
    var win = document.getElementById('popwin');
    win.style.display = 'block';
});

// 当 取消 按下时
var cancel_btn = $('#cancel');
cancel_btn.on('click', function () {
    var win = document.getElementById('popwin');
    win.style.display = 'none';
});