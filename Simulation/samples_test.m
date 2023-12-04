numSamples = 10000;
% groundTruthOccupancy = [519,789,919,1044,1143,1028,867,768,607,514,442,400,309,213,152,70]; % Your hourly occupancy data here
% groundTruthOccupancy = [519,789,919,1044,1143,1028,867,768,507,278,142,80,50,10];
groundTruthOccupancy = [519,789,989,1544,1143,919,867,768,507,278,142,80,50,10];
arrivalTimes = [];
leaveTimes = [];
courseTimes = [138,130,251,270,130,263,229,136,109,31,2];
coursexlabels = 8:1:18;
coursePredicts = [519,789,919,1044,1143,1028,867,768,507,278,142];


for i = 1:numSamples
    % Randomly select an hour based on occupancy distribution
    arrivalHour = randWeightedHour(groundTruthOccupancy);
    arrivalTime = arrivalHour + rand(); % Random minute within the hour

%     % Determine parking duration (this is a placeholder logic)
%     parkingDuration = rand() * 3; % Random duration, placeholder logic
% 
%     % Calculate leave time
%     leaveTime = arrivalTime + parkingDuration;

    % Store the times
    arrivalTimes(end+1) = arrivalTime;
%     leaveTimes(end+1) = leaveTime;
end
arrivalTimes = arrivalTimes + 5;
meanValue = 3;
stdDev = 2;
randomNumbers = meanValue + stdDev * randn(numSamples, 1);
indices = randomNumbers < 1; % 找到所有小于 1 的元素的逻辑索引
randomNumbers(indices) = 6 - randomNumbers(indices);
leaveTimes = arrivalTimes + randomNumbers';

indices = leaveTimes > 24; % 找到所有小于 1 的元素的逻辑索引
leaveTimes(indices) = 48 - leaveTimes(indices);

% Plot Histogram for Arrival Times
figure;
histogram(arrivalTimes, 'BinWidth', 1); % Adjust 'BinWidth' as needed
xlabel('Arrival Time (Hours past 6 AM)');
ylabel('Frequency');
title('Histogram of Arrival Times');

% Plot Histogram for Leave Times
figure;
histogram(leaveTimes, 'BinWidth', 1); % Adjust 'BinWidth' as needed
xlabel('Leave Time (Hours past 6 AM)');
ylabel('Frequency');
title('Histogram of Leave Times');

% Define time intervals (e.g., each hour)
timeIntervals = 6:1:24; % From 6 AM to 6 PM, assuming times are in hours

% Initialize occupancy array
occupancy = zeros(size(timeIntervals));

% Calculate occupancy for each interval
for i = 1:length(timeIntervals)
    arrivals = sum(arrivalTimes < (i+6));
    leaves = sum(leaveTimes < (i+5));
    occupancy(i) = arrivals - leaves;
end

% Calculate cumulative occupancy
cumulativeOccupancy = cumsum(occupancy);

% Plot the histogram
figure;
bar(timeIntervals(1:end), occupancy);
xlabel('Time of Day (Hours)');
ylabel('Number of Cars in Parking Lot');
title('Parking Lot Occupancy');

% figure();
% plot(occupancy);

% 创建一个图形窗口
figure;



% 在左侧 Y 轴上添加柱状图
hold on; % 保持当前图形
bar(timeIntervals, occupancy*0.3, 'FaceColor', [0.7, 0.7, 0.7]); % 灰色柱状图

% 使用左侧 Y 轴绘制第一个折线图
yyaxis left;
plot(coursexlabels, coursePredicts, 'b-o'); % 'b-o' 表示蓝色线条和圆圈标记
ylabel('Predicted parking space demand');
yticks([]); % 隐藏左侧 Y 轴的刻度

% 使用右侧 Y 轴绘制第二个折线图
yyaxis right;
plot(coursexlabels, courseTimes, 'r-*'); % 'r-*' 表示红色线条和星号标记
ylabel('Course numbers');
% 调整右侧 Y 轴的范围
ylim([0 1000]);

% 添加图例和标签
legend('Adjusted demand ', 'Course based demand[3]', 'UVic 23fall course amount');
xlabel('Time/h');
xticks(timeIntervals(1:end-1));
title('UVic parking space demand analysis');

% 取消 hold 状态
hold off;

%%
Arrival = round(arrivalTimes * 60)';
Departure = Arrival - randi([5, 30], numSamples, 1);
Leave = round(leaveTimes * 60)';
Destination = randi([1, 10], numSamples, 1);
Second = randi([0, 59], numSamples, 1);
Dataset = [Departure,Arrival,Leave,Destination,Second];

save("dataset.mat","Dataset");

% Function to randomly select an hour based on weight (occupancy)
function hour = randWeightedHour(weights)
    cumulativeWeights = cumsum(weights);
    randomValue = rand() * cumulativeWeights(end);
    hour = find(cumulativeWeights >= randomValue, 1);
end
