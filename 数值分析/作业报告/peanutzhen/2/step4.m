function [] = step4(equ_f, chebf, f, name)
    % 插值实验第三步，绘制插值多项式的图
    % equ_f = 等间距插值多项式
    % chebf = 切比雪夫插值多项式
    % f = 原函数 使用符号表达式

    % 以0.05间隔从[-1, 1]采样点进行误差计算
    x = -1:0.05:1;
    % 计算对应多项式的y值
    y = f(x);
    equ_y = equ_f(x);
    cheby = chebf(x);
    % 计算误差
    error_equ = y - equ_y;
    error_cheb = y - cheby;
    % 画图
    figure()
    plot(x, error_equ, 'k-', 'linewidth', 1.1)
    hold on
    grid on
    plot(x, error_cheb, 'r--', 'linewidth', 1.1)
    % 坐标轴边框线宽1.1, 坐标轴字体与大小为Times New Roman和16
    set(gca, 'linewidth', 1.1, 'fontsize', 16, 'fontname', 'times')
    xlabel('X')
    ylabel('Error')
    % legend还可以使用Location参数设置图标位置
    legend('Error-equ', 'Error-cheb')
    title(name)
    hold off
end