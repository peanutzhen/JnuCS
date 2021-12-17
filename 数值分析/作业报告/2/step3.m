function [equ_f, chebf] = step3(equ_x, chebx, f)
    % 插值实验第三步，绘制插值多项式的图
    % equ_x = 等间距样本点
    % chebx = 切比雪夫样本点
    % f = 原函数 使用符号表达式

    % 统计样本点个数
    n = length(equ_x);
    % 计算对应样本点的y值
    equ_y = f(equ_x);
    cheby = f(chebx);
    % 生成插值函数
    equ_f = ndd(equ_x, equ_y);
    chebf = ndd(chebx, cheby);

    x = [-1:0.01:1];
    y1 = f(x);
    y2 = equ_f(x);
    y3 = chebf(x);

    % 原函数与等间距插值比较
    figure()
    plot(x, y1, 'k-', 'linewidth', 1.1)
    hold on
    grid on
    plot(x, y2, 'r--', 'linewidth', 1.1)
    plot(equ_x, equ_y, 'o', 'markerfacecolor', [36, 169, 225]/255)

    % 坐标轴边框线宽1.1, 坐标轴字体与大小为Times New Roman和16
    set(gca, 'linewidth', 1.1, 'fontsize', 16, 'fontname', 'times')
    xlabel('X')
    ylabel('Y')
    % legend还可以使用Location参数设置图标位置
    legend('Origin', 'Evenly spaced')
    title(['等间距样本点对比','n = ', num2str(n)])
    hold off

    % 原函数和切比雪夫插值多项式比较
    figure()
    plot(x, y1, 'k-', 'linewidth', 1.1)
    hold on
    grid on
    plot(x, y3, 'g--', 'linewidth', 1.1)
    plot(chebx, cheby, 'o', 'markerfacecolor', [29, 191, 151]/255)

    % 坐标轴边框线宽1.1, 坐标轴字体与大小为Times New Roman和16
    set(gca, 'linewidth', 1.1, 'fontsize', 16, 'fontname', 'times')
    xlabel('X')
    ylabel('Y')
    % legend还可以使用Location参数设置图标位置
    legend('Origin', 'Chebf')
    title(['切比雪夫样本点对比','n = ', num2str(n)])
    hold off

end