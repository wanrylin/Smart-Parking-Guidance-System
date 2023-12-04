% plot result

load("1st_try_benchmark.mat")
bencmark1 = left;
bencmarkwaste1 = waste;
load("2nd_try_benchmark.mat")
bencmark2 = left;
bencmarkwaste2 = waste;
load("1st_try_result.mat")
result1 = left;
resultwaste1 = waste;
load("2nd_try_result.mat")
result2 = left;
resultwaste2 = waste;
load("3rd_try_benchmark.mat")
bencmark3 = left;
bencmarkwaste3 = waste;
load("3rd_try_result.mat")
result3 = left;
resultwaste3 = waste;
load("4th_try_benchmark.mat")
bencmark4 = left;
bencmarkwaste4 = waste;
load("4th_try_result.mat")
result4 = left;
resultwaste4 = waste;

avg_re_1 = mean(result1(:,1));
avg_re_2 = mean(result2(:,1));
avg_be_1 = mean(bencmark1(:,1));
avg_be_2 = mean(bencmark2(:,1));
avg_re_3 = mean(result3(:,1));
avg_be_3 = mean(bencmark3(:,1));
avg_re_4 = mean(result4(:,1));
avg_be_4 = mean(bencmark4(:,1));

% 定义数据
x = 1:2:8; % 四个类别
y1 = [avg_re_1, avg_re_2, avg_re_3, avg_re_4]; % 第一组数据（左侧Y轴）
y2 = [avg_be_1, avg_be_2, avg_be_3, avg_be_4]; % 第二组数据（右侧Y轴）
y3 = [resultwaste1, resultwaste2, resultwaste3, resultwaste4]; % 第一组数据（左侧Y轴）
y4 = [bencmarkwaste1, bencmarkwaste2, bencmarkwaste3, bencmarkwaste4]; % 第二组数据（右侧Y轴）

% 创建图形
figure;

% 绘制第一组数据（左侧Y轴）
yyaxis left
bar(x-0.6, y1, 0.2, 'FaceColor', [162, 205, 90]/255) % 更柔和的绿色
hold on;
bar(x-0.2, y2, 0.2, 'FaceColor', [176, 224, 230]/255) % 更柔和的蓝色
ylabel('Average time spend on parking/min')

% 绘制第二组数据（右侧Y轴）
yyaxis right
bar(x+0.2, y3, 0.2, 'FaceColor', [152, 251, 152]/255) % 更柔和的红色
bar(x+0.6, y4, 0.2, 'FaceColor',  [0, 0, 139]/255) % 更柔和的品红色
ylabel('Vehicles blocked times')

% 关闭 hold on
hold off;

% 设置X轴标签
xticks(x)
xticklabels({'1000', '3400', '5000', 'unbalanced 1000'})
xlabel('Number of parking car samples')

% 添加图例和标题
legend({'proposed system avg parking time', 'benchmark system avg parking time', 'proposed system blocked times', 'benchmark system blocked times'})
title('Overall Performance')


avg_d = zeros(10,3);
for d = 1:10
    indices = find(result1(:, 5) == d);
    samples = result1(indices,:);
    avg_time(1) = mean(samples(:,1));
    indices = find(result2(:, 5) == d);
    samples = result2(indices,:);
    avg_time(2) = mean(samples(:,1));
    indices = find(result3(:, 5) == d);
    samples = result3(indices,:);
    avg_time(3) = mean(samples(:,1));
    avg_d(d,:) = avg_time; 
end

avg_avg_d = mean(avg_d,2);
[sortedavg, index] = sort(avg_avg_d, 'ascend');
indices = [index(1:2);index(end-1:end)];
parking_lot = avg_d(indices,:);

% 创建条形图
figure;
bar(parking_lot, 'grouped'); % 'grouped' 选项用于分组显示每一类的三个条形

% 添加额外的图形属性
xlabel('Terminal Building');
ylabel('Average parking time/min');
title('Average parking time according to terminal building');
legend('1000 samples', '3400 samples', '5000 samples'); % 根据你的数据来设置图例
xticks(1:4);
xticklabels({'CARSA', 'Visual Arts Department', 'McPherson Library', 'CUN'}); % 设置X轴的刻度标签



